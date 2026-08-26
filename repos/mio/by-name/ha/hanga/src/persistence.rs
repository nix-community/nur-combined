use rusqlite::{Connection, params};
use std::path::PathBuf;
use crossbeam_channel::{Sender, unbounded};
use std::sync::{LazyLock, RwLock};

use crate::{VoxelOverlay, VOXEL_OVERLAY};

static PERSIST_TX: LazyLock<RwLock<Option<Sender<(i32, i32, i32, VoxelOverlay)>>>> = LazyLock::new(|| RwLock::new(None));

pub fn resolve_data_path() -> PathBuf {
    let base = std::env::var("XDG_DATA_HOME")
        .map(PathBuf::from)
        .or_else(|_| std::env::var("HOME").map(|home| PathBuf::from(home).join(".local").join("share")))
        .unwrap_or_else(|_| PathBuf::from("."));
    base.join("hanga").join("worlds")
}

pub fn init_world_db(collection_key: &str) {
    let data_dir = resolve_data_path();
    std::fs::create_dir_all(&data_dir).unwrap_or_else(|e| eprintln!("Failed to create worlds dir: {}", e));
    let db_path = data_dir.join(format!("{}.db", collection_key));
    
    let conn = Connection::open(&db_path).expect("Failed to open world database");
    conn.execute(
        "CREATE TABLE IF NOT EXISTS voxel_edits (
            x INTEGER,
            y INTEGER,
            z INTEGER,
            voxel_id TEXT,
            PRIMARY KEY (x, y, z)
        )",
        [],
    ).expect("Failed to create voxel_edits table");

    crate::overlay_clear();
    
    {
        let mut map = VOXEL_OVERLAY.write().unwrap();
        let mut stmt = conn.prepare("SELECT x, y, z, voxel_id FROM voxel_edits").unwrap();
        let rows = stmt.query_map([], |row| {
            let x: i32 = row.get(0)?;
            let y: i32 = row.get(1)?;
            let z: i32 = row.get(2)?;
            let vid: Option<String> = row.get(3)?;
            let voxel = match vid {
                Some(s) => VoxelOverlay::Solid(s),
                None => VoxelOverlay::Air,
            };
            Ok(((x, y, z), voxel))
        }).unwrap();
        for row in rows {
            if let Ok((pos, voxel)) = row {
                map.insert(pos, voxel);
            }
        }
    }

    let (tx, rx) = unbounded();
    if let Ok(mut w) = PERSIST_TX.write() {
        *w = Some(tx);
    }
    
    std::thread::spawn(move || {
        let mut conn = Connection::open(&db_path).expect("Failed to open world database in writer thread");
        while let Ok((x, y, z, voxel)) = rx.recv() {
            let mut batch = vec![(x, y, z, voxel)];
            while let Ok(msg) = rx.try_recv() {
                batch.push(msg);
            }
            
            let tx = conn.transaction().unwrap();
            {
                let mut stmt_ins = tx.prepare("INSERT INTO voxel_edits (x, y, z, voxel_id) VALUES (?1, ?2, ?3, ?4) ON CONFLICT(x, y, z) DO UPDATE SET voxel_id=excluded.voxel_id").unwrap();
                for (x, y, z, voxel) in batch {
                    match voxel {
                        VoxelOverlay::Air => {
                            stmt_ins.execute(params![x, y, z, rusqlite::types::Null]).unwrap();
                        }
                        VoxelOverlay::Solid(vid) => {
                            stmt_ins.execute(params![x, y, z, vid]).unwrap();
                        }
                    }
                }
            }
            tx.commit().unwrap();
        }
    });
}

pub fn persist_overlay_set(x: i32, y: i32, z: i32, voxel: VoxelOverlay) {
    if let Ok(guard) = PERSIST_TX.read() {
        if let Some(tx) = guard.as_ref() {
            let _ = tx.send((x, y, z, voxel));
        }
    }
}
