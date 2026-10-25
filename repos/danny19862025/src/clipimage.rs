use gtk::{gdk, gdk_pixbuf, glib, prelude::*};
use std::{
    collections::HashSet,
    ffi::{CStr, CString, c_char, c_int, c_void},
    fs,
    path::{Path, PathBuf},
};

#[derive(Clone)]
pub struct Image {
    pub path: PathBuf,
    pub width: i32,
    pub height: i32,
    pub preview: Vec<u8>,
}
pub fn history() -> Result<Vec<Image>, String> {
    let path = std::env::var_os("KLIPPER_DATABASE")
        .map(PathBuf::from)
        .unwrap_or_else(|| glib::user_data_dir().join("klipper/history3.sqlite"));
    history_at(&path)
}
pub fn history_at(path: &Path) -> Result<Vec<Image>, String> {
    if !path.is_file() {
        return Ok(Vec::new());
    }
    let db = Database::open(path)?;
    if db
        .rows("SELECT db_version FROM version", 1)?
        .first()
        .and_then(|r| r.first())
        .is_none_or(|s| s != "3")
    {
        return Err("This Klipper image-history format is not supported; the current clipboard image still works".into());
    }
    let rows = db.rows("SELECT main.uuid,aux.data_uuid FROM main JOIN aux ON main.uuid=aux.uuid WHERE aux.mimetype LIKE 'image/%' OR aux.mimetype='application/x-qt-image' ORDER BY COALESCE(main.last_used_time,main.added_time) DESC,main.added_time DESC LIMIT 64",64)?;
    let root = path.parent().unwrap().join("data");
    let Ok(real_root) = root.canonicalize() else {
        return Ok(Vec::new());
    };
    let mut seen = HashSet::new();
    let mut images = Vec::new();
    for row in rows {
        if row.len() != 2
            || !row
                .iter()
                .all(|s| s.len() == 40 && s.bytes().all(|b| b.is_ascii_hexdigit()))
        {
            continue;
        }
        if !seen.insert(row[0].clone()) {
            continue;
        }
        let path = root.join(&row[0]).join(&row[1]);
        if !path.canonicalize().is_ok_and(|p| p.starts_with(&real_root)) {
            continue;
        }
        if let Ok((width, height)) = dimensions(&path)
            && let Ok(pixbuf) = gdk_pixbuf::Pixbuf::from_file_at_scale(&path, 64, 64, true)
            && let Ok(preview) = pixbuf.save_to_bufferv("png", &[])
        {
            images.push(Image {
                path,
                width,
                height,
                preview,
            });
        }
        if images.len() >= 24 {
            break;
        }
    }
    Ok(images)
}
fn dimensions(path: &Path) -> Result<(i32, i32), String> {
    if fs::metadata(path).map_err(|e| e.to_string())?.len() > 16_777_216 {
        return Err("Clipboard image exceeds 16 MiB".into());
    }
    let (_, w, h) = gdk_pixbuf::Pixbuf::file_info(path).ok_or("Unsupported clipboard image")?;
    if w <= 0 || h <= 0 || i64::from(w) * i64::from(h) > 16_000_000 {
        return Err("Clipboard image exceeds 16 million pixels".into());
    }
    Ok((w, h))
}
pub fn load(path: &Path) -> Result<gdk::Texture, String> {
    dimensions(path)?;
    let pixbuf = gdk_pixbuf::Pixbuf::from_file(path).map_err(|e| e.to_string())?;
    Ok(gdk::Texture::for_pixbuf(&pixbuf))
}
pub fn thumbnail(texture: &gdk::Texture) -> Result<Vec<u8>, String> {
    if texture.width() <= 0
        || texture.height() <= 0
        || i64::from(texture.width()) * i64::from(texture.height()) > 16_000_000
    {
        return Err("Clipboard image exceeds 16 million pixels".into());
    }
    let bytes = texture.save_to_png_bytes();
    let stream = gtk::gio::MemoryInputStream::from_bytes(&bytes);
    let pixbuf = gdk_pixbuf::Pixbuf::from_stream_at_scale(
        &stream,
        64,
        64,
        true,
        None::<&gtk::gio::Cancellable>,
    )
    .map_err(|e| e.to_string())?;
    pixbuf
        .save_to_bufferv("png", &[])
        .map_err(|e| e.to_string())
}
struct Database(*mut c_void);
impl Drop for Database {
    fn drop(&mut self) {
        unsafe {
            sqlite3_close_v2(self.0);
        }
    }
}
impl Database {
    fn open(path: &Path) -> Result<Self, String> {
        let name = CString::new(path.as_os_str().as_encoded_bytes())
            .map_err(|_| "Invalid database path")?;
        let mut ptr = std::ptr::null_mut();
        let code = unsafe { sqlite3_open_v2(name.as_ptr(), &mut ptr, 1, std::ptr::null()) };
        if code != 0 {
            if !ptr.is_null() {
                unsafe {
                    sqlite3_close_v2(ptr);
                }
            }
            return Err("Klipper image history could not be opened read-only".into());
        }
        unsafe {
            sqlite3_busy_timeout(ptr, 100);
        }
        Ok(Self(ptr))
    }
    fn rows(&self, sql: &str, limit: usize) -> Result<Vec<Vec<String>>, String> {
        struct Statement(*mut c_void);
        impl Drop for Statement {
            fn drop(&mut self) {
                unsafe {
                    sqlite3_finalize(self.0);
                }
            }
        }
        let sql = CString::new(sql).unwrap();
        let mut ptr = std::ptr::null_mut();
        if unsafe { sqlite3_prepare_v2(self.0, sql.as_ptr(), -1, &mut ptr, std::ptr::null_mut()) }
            != 0
        {
            return Err("Unsupported Klipper image-history schema".into());
        }
        let statement = Statement(ptr);
        let mut rows = Vec::new();
        loop {
            match unsafe { sqlite3_step(statement.0) } {
                100 => {
                    let n = unsafe { sqlite3_column_count(statement.0) };
                    let mut row = Vec::new();
                    for i in 0..n {
                        let p = unsafe { sqlite3_column_text(statement.0, i) };
                        row.push(if p.is_null() {
                            String::new()
                        } else {
                            unsafe { CStr::from_ptr(p.cast()) }
                                .to_string_lossy()
                                .into_owned()
                        });
                    }
                    rows.push(row);
                    if rows.len() >= limit {
                        break;
                    }
                }
                101 => break,
                _ => return Err("Klipper image history is busy or unreadable".into()),
            }
        }
        Ok(rows)
    }
}
#[link(name = "sqlite3")]
unsafe extern "C" {
    fn sqlite3_open_v2(
        path: *const c_char,
        db: *mut *mut c_void,
        flags: c_int,
        vfs: *const c_char,
    ) -> c_int;
    fn sqlite3_close_v2(db: *mut c_void) -> c_int;
    fn sqlite3_busy_timeout(db: *mut c_void, milliseconds: c_int) -> c_int;
    fn sqlite3_prepare_v2(
        db: *mut c_void,
        sql: *const c_char,
        n: c_int,
        stmt: *mut *mut c_void,
        tail: *mut *const c_char,
    ) -> c_int;
    fn sqlite3_finalize(stmt: *mut c_void) -> c_int;
    fn sqlite3_step(stmt: *mut c_void) -> c_int;
    fn sqlite3_column_count(stmt: *mut c_void) -> c_int;
    fn sqlite3_column_text(stmt: *mut c_void, i: c_int) -> *const u8;
}
