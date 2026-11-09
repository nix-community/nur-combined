mod support;

use serde_json::json;
use std::time::{Duration, Instant};
use support::Agent;

#[test]
fn bundled_games_support_single_player_movement_digging_and_building() {
    for game in ["urban_chaos", "testbed", "sandbox"] {
        let mut agent = Agent::new(game, false);
        let initial = agent.wait_for(|reply| reply["world_ready"] == true);
        std::thread::sleep(Duration::from_secs(3));
        let standing = agent.look();
        let height = standing["player_pos"][1].as_f64().unwrap();
        assert!(
            height >= initial["player_pos"][1].as_f64().unwrap() - 1.5,
            "{game}: player fell through spawn terrain: {initial} -> {standing}"
        );
        assert_eq!(
            standing["wanted_level"], 0,
            "{game}: unprovoked crash at spawn"
        );
        assert_eq!(standing["trust_score"], 1.0);
        agent.send(json!({"action": "MoveForward"}));
        std::thread::sleep(Duration::from_millis(800));
        let moved = agent.look();
        assert!(
            (moved["player_pos"][2].as_f64().unwrap()
                - standing["player_pos"][2].as_f64().unwrap())
            .abs()
                > 0.3,
            "{game}: walk input did not move the player"
        );
        if game == "testbed" {
            agent.restart();
            agent.wait_for(|reply| reply["world_ready"] == true);
        }
        let aimed = agent.wait_for(|reply| reply["voxel_ahead"] != "air");
        let target = aimed["voxel_pos"].clone();
        agent.send(json!({"action": "BreakBlock", "pos": target}));
        let carrying =
            agent.wait_for(|reply| reply["held_item"].as_str().is_some_and(|s| !s.is_empty()));
        let item = carrying["held_item"].clone();
        agent.send(json!({"action": "PlaceBlock", "pos": target, "voxel": item}));
        agent.wait_for(|reply| reply["held_item"] == "");
        let db = agent.home.join("data/hanga/worlds").join(format!(
            "{game}:{}.db",
            if game == "sandbox" {
                "urban_chaos+testbed"
            } else {
                game
            }
        ));
        let deadline = Instant::now() + Duration::from_secs(5);
        loop {
            let conn = rusqlite::Connection::open(&db).unwrap();
            let saved: Option<String> = conn
                .query_row(
                    "SELECT voxel_id FROM voxel_edits WHERE x=?1 AND y=?2 AND z=?3",
                    rusqlite::params![
                        target[0].as_i64().unwrap(),
                        target[1].as_i64().unwrap(),
                        target[2].as_i64().unwrap()
                    ],
                    |row| row.get(0),
                )
                .ok()
                .flatten();
            if saved.as_deref() == item.as_str() {
                break;
            }
            assert!(
                Instant::now() < deadline,
                "{game}: placed voxel was not saved"
            );
            std::thread::sleep(Duration::from_millis(50));
        }
        if game == "testbed" {
            // Persist an air edit and verify regenerated terrain honors it after restarting.
            agent.send(json!({"action": "BreakBlock", "pos": target}));
            agent.wait_for(|reply| reply["held_item"].as_str().is_some_and(|s| !s.is_empty()));
            let deadline = Instant::now() + Duration::from_secs(5);
            loop {
                let conn = rusqlite::Connection::open(&db).unwrap();
                let saved: Option<String> = conn
                    .query_row(
                        "SELECT voxel_id FROM voxel_edits WHERE x=?1 AND y=?2 AND z=?3",
                        rusqlite::params![
                            target[0].as_i64().unwrap(),
                            target[1].as_i64().unwrap(),
                            target[2].as_i64().unwrap()
                        ],
                        |row| row.get(0),
                    )
                    .unwrap();
                if saved.is_none() {
                    break;
                }
                assert!(Instant::now() < deadline, "dig was not saved");
                std::thread::sleep(Duration::from_millis(50));
            }
            agent.restart();
            let restored = agent.wait_for(|reply| reply["world_ready"] == true);
            let deadline = Instant::now() + Duration::from_secs(60);
            loop {
                let cell = agent.inspect(target.clone());
                if cell["loaded"] == true {
                    assert_eq!(
                        cell["voxel"], "air",
                        "saved air was replaced by procedural terrain"
                    );
                    break;
                }
                assert!(Instant::now() < deadline, "saved terrain did not load");
                std::thread::sleep(Duration::from_millis(100));
            }
            assert_eq!(restored["held_item"], "");
            agent.send(json!({"action": "EnterVehicle"}));
            agent.wait_for(|reply| reply["in_vehicle"] == true);
            agent.send(json!({"action": "EnterVehicle"}));
            agent.wait_for(|reply| reply["in_vehicle"] == false);
        }
    }
}
