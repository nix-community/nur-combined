const BUS_TOPICS: &str = "ping,name,catalog,hello,voxel,probe,has,methods,gravity,supported-locales,player-spawn,vehicle-spawn-count,vehicle-spawn,vehicle-kit,ambient-agent-count,ambient-agent-spawn,fracture-kit,sound-kit,evaluate-action,should-spawn-agent,wallet-after,contract-mark,action-range,loot-item,craft-result,can-complete,crash-kit,steer,fire-kit,tick,should-despawn-agent,story-event,event-label,offer-contract,economy-params,economy-price,voxel-label,contract-label,item-label";

fn host_bus_reply(
    topic: &str,
    payload: &hanga::engine::host::Value,
) -> Option<hanga::engine::host::Value> {
    Some(match topic {
        "gravity" => crate::gravity(),
        "supported-locales" => wire_methods(&crate::supported_locales()),
        "player-spawn" => {
            let (x, y, z) = crate::player_spawn();
            wire_xyz(x, y, z)
        }
        "vehicle-spawn-count" => wire_int(crate::vehicle_spawn_count() as i64),
        "vehicle-spawn" => {
            let (x, y, z) = crate::vehicle_spawn(payload_as_i32(payload));
            wire_xyz(x, y, z)
        }
        "vehicle-kit" => crate::vehicle_kit(payload_as_i32(payload)),
        "ambient-agent-count" => wire_int(crate::ambient_agent_count() as i64),
        "ambient-agent-spawn" => {
            let (x, y, z, name) = crate::ambient_agent_spawn(payload_as_i32(payload));
            wire_xyz_name(x, y, z, name)
        }
        "fracture-kit" => crate::fracture_kit(
            payload_str(payload, "voxel"),
            payload_str(payload, "action"),
        ),
        "sound-kit" => crate::sound_kit(payload_str(payload, "action")),
        "evaluate-action" => wire_int(crate::mod_evaluate_action(
            payload_str(payload, "action"),
            payload_i64(payload, "state") as i32,
        ) as i64),
        "should-spawn-agent" => wire_text(crate::mod_should_spawn_agent(
            payload_str(payload, "action"),
            payload_i64(payload, "old") as i32,
            payload_i64(payload, "new") as i32,
        )),
        "wallet-after" => wire_int(crate::mod_wallet_after(
            payload_str(payload, "action"),
            payload_i64(payload, "wallet") as i32,
            payload_i64(payload, "extra") as i32,
        ) as i64),
        "contract-mark" => crate::contract_mark(payload_str(payload, "kind")),
        "action-range" => wire_float(crate::mod_get_action_range(payload_str(payload, "action")) as f64),
        "loot-item" => wire_text(crate::loot_item(payload_str(payload, "voxel"))),
        "craft-result" => wire_text(crate::craft_result(
            payload_str(payload, "a"),
            payload_str(payload, "b"),
        )),
        "can-complete" => wire_int(crate::mod_can_complete(
            payload_str(payload, "action"),
            payload_i64(payload, "state") as i32,
            payload_str(payload, "kind"),
            payload_i64(payload, "danger") as i32,
            payload_str(payload, "held"),
            payload_i64(payload, "y") as i32,
            payload_flag(payload, "vehicle"),
            payload_flag(payload, "near"),
        ) as i64),
        "crash-kit" => crate::crash_kit(
            payload_f32(payload, "speed"),
            payload_flag(payload, "solid") || payload_flag(payload, "into"),
        ),
        "steer" => crate::steer(payload),
        "fire-kit" => crate::fire_kit(
            payload_i64(payload, "age") as i32,
            payload_str(payload, "nearby"),
        ),
        "tick" => wire_int(crate::mod_tick(
            payload_i64(payload, "state") as i32,
            payload_i64(payload, "dt") as i32,
        ) as i64),
        "should-despawn-agent" => wire_int(crate::should_despawn_agent(
            payload_str(payload, "agent"),
            payload_i64(payload, "state") as i32,
        ) as i64),
        "story-event" => wire_text(crate::generate_story_event(payload_as_i32(payload))),
        "event-label" => wire_text(crate::event_label_for(
            payload_str(payload, "locale"),
            payload_str(payload, "event"),
        )),
        "offer-contract" => {
            let (kind, payout, danger) = crate::mod_offer_contract(payload_as_i32(payload));
            if kind.is_empty() {
                wire_empty()
            } else {
                wire_dict(vec![
                    field("kind", atom_text(kind)),
                    field("payout", atom_int(payout as i64)),
                    field("danger", atom_int(danger as i64)),
                ])
            }
        }
        "economy-params" => wire_int(crate::mod_get_economy_params() as i64),
        "economy-price" => wire_int(crate::compute_economy_price(
            payload_i64(payload, "base") as i32,
            payload_i64(payload, "supply") as i32,
            payload_i64(payload, "demand") as i32,
        ) as i64),
        "voxel-label" => wire_text(crate::voxel_label_for(
            payload_str(payload, "locale"),
            payload_str(payload, "voxel"),
        )),
        "contract-label" => wire_text(crate::contract_label_for(
            payload_str(payload, "locale"),
            payload_str(payload, "kind"),
        )),
        "item-label" => wire_text(crate::item_label_for(
            payload_str(payload, "locale"),
            payload_str(payload, "item"),
        )),
        _ => return None,
    })
}
