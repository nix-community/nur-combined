const std = @import("std");
const hangamod = @import("hangamod/root.zig");
const c = @cImport({
    @cInclude("payload.h");
});

const catalog_csv = "air,grid,mark";
const bus_topic_list = [_][:0]const u8{
    "ping", "name", "catalog", "gravity", "has", "methods", "voxel", "fracture-kit", "loot-item",
};

fn cSlice(s: [*c]const c.plugin_string_t) []const u8 {
    if (s == null or s.*.ptr == null or s.*.len == 0) return "";
    return s.*.ptr[0..s.*.len];
}

fn setStr(ret: [*c]c.plugin_string_t, value: [:0]const u8) void {
    c.plugin_string_set(ret, value.ptr);
}

fn queryVoxel(x: i32, y: i32, z: i32) i32 {
    return hangamod.catalog.checkerFloor(x, y, z);
}

fn topicEql(topic: []const u8, want: []const u8) bool {
    return std.mem.eql(u8, topic, want);
}

fn cTopics(buf: *[bus_topic_list.len][*c]const u8) [*c]const [*c]const u8 {
    for (bus_topic_list, 0..) |topic, i| buf[i] = topic.ptr;
    return @ptrCast(buf);
}

export fn exports_hanga_engine_guest_abi() callconv(.c) i32 {
    return 6;
}

export fn exports_hanga_engine_guest_ready() callconv(.c) void {
    var level = c.plugin_string_t{};
    var msg = c.plugin_string_t{};
    setStr(&level, "info");
    setStr(&msg, "lab_grid ready");
    c.hanga_engine_host_log(&level, &msg);
    c.greet_peers();
}

export fn exports_hanga_engine_guest_voxel_catalog(ret: [*c]c.plugin_list_string_t) callconv(.c) void {
    const parts = [_][:0]const u8{ "air", "grid", "mark" };
    var ptrs: [parts.len][*c]const u8 = undefined;
    for (parts, 0..) |part, i| ptrs[i] = part.ptr;
    c.payload_catalog(ret, @ptrCast(&ptrs), parts.len);
}

export fn exports_hanga_engine_guest_query_voxel(x: i32, y: i32, z: i32) callconv(.c) i32 {
    return queryVoxel(x, y, z);
}

export fn exports_hanga_engine_guest_invoke(
    caller: [*c]c.plugin_string_t,
    topic: [*c]c.plugin_string_t,
    payload: [*c]c.hanga_engine_host_value_t,
    ret: [*c]c.hanga_engine_host_value_t,
) callconv(.c) void {
    _ = hangamod.kit.get(cSlice(caller), "unused");
    const name = cSlice(topic);
    var topics: [bus_topic_list.len][*c]const u8 = undefined;
    const topic_ptr = cTopics(&topics);
    if (topicEql(name, "ping")) {
        c.payload_text(ret, "pong");
        return;
    }
    if (topicEql(name, "name")) {
        c.payload_text(ret, "lab_grid");
        return;
    }
    if (topicEql(name, "catalog")) {
        c.payload_text(ret, catalog_csv);
        return;
    }
    if (topicEql(name, "gravity")) {
        c.payload_gravity(ret);
        return;
    }
    if (topicEql(name, "has")) {
        c.payload_flag(ret, c.bus_has(payload, topic_ptr, bus_topic_list.len) != 0);
        return;
    }
    if (topicEql(name, "methods")) {
        c.payload_methods(ret, topic_ptr, bus_topic_list.len);
        return;
    }
    if (topicEql(name, "voxel")) {
        const x: i32 = @intCast(c.bag_int(payload, "x"));
        const y: i32 = @intCast(c.bag_int(payload, "y"));
        const z: i32 = @intCast(c.bag_int(payload, "z"));
        var names: [8][]const u8 = undefined;
        const n = hangamod.catalog.parse(catalog_csv, &names);
        const voxel = hangamod.catalog.catalogName(names[0..n], @intCast(queryVoxel(x, y, z)));
        c.payload_text_n(ret, voxel.ptr, voxel.len);
        return;
    }
    if (topicEql(name, "fracture-kit")) {
        if (c.bag_text_eq(payload, "action", "break") == 0 and c.bag_text_eq(payload, "action", "explode") == 0) {
            c.payload_empty(ret);
            return;
        }
        if (c.bag_text_eq(payload, "voxel", "grid") != 0 or c.bag_text_eq(payload, "voxel", "mark") != 0) {
            c.payload_fracture(ret);
            return;
        }
        c.payload_empty(ret);
        return;
    }
    if (topicEql(name, "loot-item")) {
        if (c.bag_text_eq(payload, "voxel", "mark") != 0) {
            c.payload_text(ret, "mark");
            return;
        }
        c.payload_empty(ret);
        return;
    }
    c.payload_empty(ret);
}
