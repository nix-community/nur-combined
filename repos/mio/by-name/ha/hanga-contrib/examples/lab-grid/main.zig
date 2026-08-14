const std = @import("std");
// Nix copies `lib/zig/hangamod` next to this file before `zig build-exe`.
const hangamod = @import("hangamod/root.zig");
const c = @cImport({
    @cInclude("plugin.h");
});

const catalog = "air,grid,mark";
const bus_topics = "ping,name,catalog,gravity,has,methods,voxel";

fn cSlice(s: [*c]const c.plugin_string_t) []const u8 {
    if (s == null or s.*.ptr == null or s.*.len == 0) return "";
    return s.*.ptr[0..s.*.len];
}

fn setStr(ret: [*c]c.plugin_string_t, value: [:0]const u8) void {
    c.plugin_string_set(ret, value.ptr);
}

fn emptyStr(ret: [*c]c.plugin_string_t) void {
    setStr(ret, "");
}

fn dupSlice(ret: [*c]c.plugin_string_t, value: []const u8) void {
    if (value.len == 0) {
        emptyStr(ret);
        return;
    }
    c.plugin_string_dup_n(ret, value.ptr, value.len);
}

fn queryVoxel(x: i32, y: i32, z: i32) i32 {
    if (y < 0) return 1;
    if (y == 0) {
        return if ((x + z) & 1 == 0) 1 else 2;
    }
    return 0;
}

fn topicEql(topic: []const u8, want: []const u8) bool {
    return std.mem.eql(u8, topic, want);
}

fn busHas(payload: [*c]const c.exports_hanga_engine_gameplay_payload_t) bool {
    var name: []const u8 = "";
    if (payload.*.tag == c.HANGA_ENGINE_HOST_PAYLOAD_TEXT) {
        const text = payload.*.val.text;
        if (text.ptr != null and text.len > 0) name = text.ptr[0..text.len];
    } else if (payload.*.tag == c.HANGA_ENGINE_HOST_PAYLOAD_BAG) {
        const bag = payload.*.val.bag;
        if (bag.ptr != null) {
            var i: usize = 0;
            while (i < bag.len) : (i += 1) {
                const field = bag.ptr[i];
                const key = if (field.key.ptr != null and field.key.len > 0) field.key.ptr[0..field.key.len] else "";
                if (std.mem.eql(u8, key, "name") or std.mem.eql(u8, key, "method")) {
                    if (field.value.tag == c.HANGA_ENGINE_HOST_ATOM_TEXT) {
                        const text = field.value.val.text;
                        if (text.ptr != null and text.len > 0) name = text.ptr[0..text.len];
                    }
                }
            }
        }
    }
    var it = std.mem.splitScalar(u8, bus_topics, ',');
    while (it.next()) |method| {
        if (std.mem.eql(u8, std.mem.trim(u8, method, " "), name)) return true;
    }
    return false;
}

fn bagInt(payload: [*c]const c.exports_hanga_engine_gameplay_payload_t, key: []const u8) i64 {
    if (payload.*.tag != c.HANGA_ENGINE_HOST_PAYLOAD_BAG) return 0;
    const bag = payload.*.val.bag;
    if (bag.ptr == null) return 0;
    var i: usize = 0;
    while (i < bag.len) : (i += 1) {
        const field = bag.ptr[i];
        const field_key = if (field.key.ptr != null and field.key.len > 0) field.key.ptr[0..field.key.len] else "";
        if (!std.mem.eql(u8, field_key, key)) continue;
        if (field.value.tag == c.HANGA_ENGINE_HOST_ATOM_INT) return field.value.val.int_;
        if (field.value.tag == c.HANGA_ENGINE_HOST_ATOM_TEXT) {
            const text = field.value.val.text;
            const slice = if (text.ptr != null and text.len > 0) text.ptr[0..text.len] else "";
            return std.fmt.parseInt(i64, slice, 10) catch 0;
        }
    }
    return 0;
}

fn payloadText(ret: [*c]c.exports_hanga_engine_gameplay_payload_t, value: [:0]const u8) void {
    ret.*.tag = c.HANGA_ENGINE_HOST_PAYLOAD_TEXT;
    setStr(&ret.*.val.text, value);
}

fn payloadFlag(ret: [*c]c.exports_hanga_engine_gameplay_payload_t, value: bool) void {
    ret.*.tag = c.HANGA_ENGINE_HOST_PAYLOAD_FLAG;
    ret.*.val.flag = value;
}

export fn exports_hanga_engine_gameplay_init_mod() callconv(.c) void {
    var level = c.plugin_string_t{};
    var msg = c.plugin_string_t{};
    setStr(&level, "info");
    setStr(&msg, "lab_grid ready");
    c.hanga_engine_host_log(&level, &msg);
}

export fn exports_hanga_engine_gameplay_voxel_catalog(ret: [*c]c.plugin_string_t) callconv(.c) void {
    setStr(ret, catalog);
}

export fn exports_hanga_engine_gameplay_query_voxel(x: i32, y: i32, z: i32) callconv(.c) i32 {
    return queryVoxel(x, y, z);
}

export fn exports_hanga_engine_gameplay_mod_get_action_range(action: [*c]c.plugin_string_t) callconv(.c) f32 {
    _ = hangamod.kit.get(cSlice(action), "unused");
    return 20;
}

export fn exports_hanga_engine_gameplay_mod_evaluate_action(action: [*c]c.plugin_string_t, state: i32) callconv(.c) i32 {
    _ = action;
    return state;
}

export fn exports_hanga_engine_gameplay_mod_should_spawn_agent(action: [*c]c.plugin_string_t, old_state: i32, new_state: i32, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = action;
    _ = old_state;
    _ = new_state;
    emptyStr(ret);
}

export fn exports_hanga_engine_gameplay_steer(role: [*c]c.plugin_string_t, context: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = role;
    _ = hangamod.kit.get(cSlice(context), "blocked");
    emptyStr(ret);
}

export fn exports_hanga_engine_gameplay_mod_get_storyteller_level() callconv(.c) i32 {
    return 0;
}

export fn exports_hanga_engine_gameplay_generate_story_event(player_level: i32, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = player_level;
    setStr(ret, "void");
}

export fn exports_hanga_engine_gameplay_mod_get_economy_params() callconv(.c) i32 {
    return (1 << 16) | 1;
}

export fn exports_hanga_engine_gameplay_compute_economy_price(base: i32, supply: i32, demand: i32) callconv(.c) i32 {
    if (supply == 0) return base;
    const n = @divTrunc(base * demand, supply);
    return if (n < 1) 1 else n;
}

export fn exports_hanga_engine_gameplay_player_spawn(ret: [*c]c.plugin_tuple3_s32_s32_s32_t) callconv(.c) void {
    ret.*.f0 = 0;
    ret.*.f1 = 4;
    ret.*.f2 = 0;
}

export fn exports_hanga_engine_gameplay_vehicle_spawn_count() callconv(.c) i32 {
    return 0;
}

export fn exports_hanga_engine_gameplay_vehicle_spawn(index: i32, ret: [*c]c.plugin_tuple3_s32_s32_s32_t) callconv(.c) void {
    ret.*.f0 = index;
    ret.*.f1 = 2;
    ret.*.f2 = 0;
}

export fn exports_hanga_engine_gameplay_vehicle_kit(index: i32, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = index;
    emptyStr(ret);
}

export fn exports_hanga_engine_gameplay_gravity(ret: [*c]c.plugin_string_t) callconv(.c) void {
    setStr(ret, "kind=down;g=9.81;jump=5;walk=10");
}

export fn exports_hanga_engine_gameplay_fracture_kit(voxel: [*c]c.plugin_string_t, action: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    const act = cSlice(action);
    if (!std.mem.eql(u8, act, "break") and !std.mem.eql(u8, act, "explode")) {
        emptyStr(ret);
        return;
    }
    const name = cSlice(voxel);
    if (std.mem.eql(u8, name, "grid") or std.mem.eql(u8, name, "mark")) {
        setStr(ret, "can=1;spread=1;impulse=4");
        return;
    }
    emptyStr(ret);
}

export fn exports_hanga_engine_gameplay_mod_tick(state: i32, dt_ms: i32) callconv(.c) i32 {
    _ = dt_ms;
    return state;
}

export fn exports_hanga_engine_gameplay_should_despawn_agent(agent: [*c]c.plugin_string_t, state: i32) callconv(.c) i32 {
    _ = agent;
    _ = state;
    return 0;
}

export fn exports_hanga_engine_gameplay_ambient_agent_count() callconv(.c) i32 {
    return 0;
}

export fn exports_hanga_engine_gameplay_ambient_agent_spawn(index: i32, ret: [*c]c.plugin_tuple4_s32_s32_s32_string_t) callconv(.c) void {
    _ = index;
    ret.*.f0 = 0;
    ret.*.f1 = 0;
    ret.*.f2 = 0;
    emptyStr(&ret.*.f3);
}

export fn exports_hanga_engine_gameplay_voxel_label(voxel: [*c]c.plugin_string_t, locale: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = locale;
    dupSlice(ret, cSlice(voxel));
}

export fn exports_hanga_engine_gameplay_mod_wallet_after(action: [*c]c.plugin_string_t, wallet: i32, extra: i32) callconv(.c) i32 {
    _ = action;
    var n = wallet + extra;
    if (n < 0) n = 0;
    if (n > 1_000_000) n = 1_000_000;
    return n;
}

export fn exports_hanga_engine_gameplay_mod_offer_contract(player_state: i32, ret: [*c]c.plugin_tuple3_string_s32_s32_t) callconv(.c) void {
    _ = player_state;
    emptyStr(&ret.*.f0);
    ret.*.f1 = 0;
    ret.*.f2 = 0;
}

export fn exports_hanga_engine_gameplay_mod_can_complete(action: [*c]c.plugin_string_t, player_state: i32, kind: [*c]c.plugin_string_t, danger: i32, context: [*c]c.plugin_string_t) callconv(.c) i32 {
    _ = action;
    _ = player_state;
    _ = kind;
    _ = danger;
    _ = hangamod.kit.get(cSlice(context), "held");
    return 0;
}

export fn exports_hanga_engine_gameplay_contract_mark(kind: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = kind;
    emptyStr(ret);
}

export fn exports_hanga_engine_gameplay_event_label(event: [*c]c.plugin_string_t, locale: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = locale;
    dupSlice(ret, cSlice(event));
}

export fn exports_hanga_engine_gameplay_contract_label(kind: [*c]c.plugin_string_t, locale: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = locale;
    dupSlice(ret, cSlice(kind));
}

export fn exports_hanga_engine_gameplay_supported_locales(ret: [*c]c.plugin_string_t) callconv(.c) void {
    setStr(ret, "en");
}

export fn exports_hanga_engine_gameplay_loot_item(voxel: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    if (std.mem.eql(u8, cSlice(voxel), "mark")) {
        setStr(ret, "mark");
        return;
    }
    emptyStr(ret);
}

export fn exports_hanga_engine_gameplay_item_label(item: [*c]c.plugin_string_t, locale: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = locale;
    dupSlice(ret, cSlice(item));
}

export fn exports_hanga_engine_gameplay_craft_result(item_a: [*c]c.plugin_string_t, item_b: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    var names: [4][]const u8 = undefined;
    _ = hangamod.catalog.parse(cSlice(item_a), names[0..2]);
    _ = hangamod.catalog.parse(cSlice(item_b), names[2..4]);
    emptyStr(ret);
}

export fn exports_hanga_engine_gameplay_crash_kit(speed: f32, into_solid: bool, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = hangamod.kit.f32Val("s=0", "s", speed);
    _ = hangamod.kit.flag(if (into_solid) "1" else "0");
    emptyStr(ret);
}

export fn exports_hanga_engine_gameplay_fire_kit(age_ms: i32, nearby: [*c]c.plugin_string_t, ret: [*c]c.plugin_string_t) callconv(.c) void {
    _ = age_ms;
    _ = nearby;
    emptyStr(ret);
}

export fn exports_hanga_engine_gameplay_on_message(
    caller: [*c]c.plugin_string_t,
    topic: [*c]c.plugin_string_t,
    payload: [*c]c.exports_hanga_engine_gameplay_payload_t,
    ret: [*c]c.exports_hanga_engine_gameplay_payload_t,
) callconv(.c) void {
    _ = hangamod.kit.get(cSlice(caller), "unused");
    const name = cSlice(topic);
    if (topicEql(name, "ping")) {
        payloadText(ret, "pong");
        return;
    }
    if (topicEql(name, "name")) {
        payloadText(ret, "lab_grid");
        return;
    }
    if (topicEql(name, "catalog")) {
        payloadText(ret, catalog);
        return;
    }
    if (topicEql(name, "gravity")) {
        payloadText(ret, "kind=down;g=9.81;jump=5;walk=10");
        return;
    }
    if (topicEql(name, "has")) {
        payloadFlag(ret, busHas(payload));
        return;
    }
    if (topicEql(name, "methods")) {
        payloadText(ret, bus_topics);
        return;
    }
    if (topicEql(name, "voxel")) {
        const x: i32 = @intCast(bagInt(payload, "x"));
        const y: i32 = @intCast(bagInt(payload, "y"));
        const z: i32 = @intCast(bagInt(payload, "z"));
        var names: [8][]const u8 = undefined;
        const n = hangamod.catalog.parse(catalog, &names);
        const voxel = hangamod.catalog.catalogName(names[0..n], @intCast(queryVoxel(x, y, z)));
        ret.*.tag = c.HANGA_ENGINE_HOST_PAYLOAD_TEXT;
        dupSlice(&ret.*.val.text, voxel);
        return;
    }
    ret.*.tag = c.HANGA_ENGINE_HOST_PAYLOAD_EMPTY;
}
