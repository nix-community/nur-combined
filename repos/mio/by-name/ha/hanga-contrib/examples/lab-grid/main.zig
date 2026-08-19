const std = @import("std");
const hangamod = @import("hangamod/root.zig");
const plugin = @import("plugin.zig");
const payload = @import("hangamod/payload.zig");

const catalog_csv = "air,grid,mark";
const bus_topic_list = [_][]const u8{
    "ping", "name", "catalog", "gravity", "has", "methods", "voxel", "fracture-kit", "loot-item",
    "refuse",
};

fn cSlice(s: *const plugin.string) []const u8 {
    if (s.len == 0) return "";
    return s.ptr[0..s.len];
}

fn setStr(ret: *plugin.string, value: []const u8) void {
    const ptr = plugin.cabi_realloc(null, 0, 1, value.len) orelse return;
    const ptr_u8: [*]u8 = @ptrCast(ptr);
    @memcpy(ptr_u8[0..value.len], value);
    ret.ptr = ptr_u8;
    ret.len = value.len;
}

fn queryVoxel(x: i32, y: i32, z: i32) i32 {
    return hangamod.catalog.checkerFloor(x, y, z);
}

fn topicEql(topic: []const u8, want: []const u8) bool {
    return std.mem.eql(u8, topic, want);
}

export fn exports_hanga_engine_guest_abi() i32 {
    return 6;
}

export fn exports_hanga_engine_guest_ready() void {
    var level = plugin.string{ .ptr = undefined, .len = 0 };
    var msg = plugin.string{ .ptr = undefined, .len = 0 };
    setStr(&level, "info");
    setStr(&msg, "lab_grid ready");
    plugin.log(&level, &msg);
    payload.greet_peers();
}

export fn exports_hanga_engine_guest_voxel_catalog(ret: *plugin.list_string) void {
    const parts = [_][]const u8{ "air", "grid", "mark" };
    payload.catalogNames(ret, &parts);
}

export fn exports_hanga_engine_guest_query_voxel(x: i32, y: i32, z: i32) i32 {
    return queryVoxel(x, y, z);
}

export fn exports_hanga_engine_guest_invoke(
    caller: *const plugin.string,
    topic: *const plugin.string,
    args: *const plugin.value,
    ret: *plugin.value,
) void {
    _ = hangamod.kit.get(cSlice(caller), "unused");
    const name = cSlice(topic);
    
    if (topicEql(name, "ping")) {
        payload.text(ret, "pong");
        return;
    }
    if (topicEql(name, "name")) {
        payload.text(ret, "lab_grid");
        return;
    }
    if (topicEql(name, "catalog")) {
        payload.text(ret, catalog_csv);
        return;
    }
    if (topicEql(name, "gravity")) {
        payload.gravity(ret);
        return;
    }
    if (topicEql(name, "has")) {
        payload.flag(ret, payload.bus_has(args, &bus_topic_list));
        return;
    }
    if (topicEql(name, "methods")) {
        payload.methods(ret, &bus_topic_list);
        return;
    }
    if (topicEql(name, "voxel")) {
        const x: i32 = @intCast(payload.bag_int(args, "x"));
        const y: i32 = @intCast(payload.bag_int(args, "y"));
        const z: i32 = @intCast(payload.bag_int(args, "z"));
        var names: [8][]const u8 = undefined;
        const n = hangamod.catalog.parse(catalog_csv, &names);
        const voxel = hangamod.catalog.catalogName(names[0..n], @intCast(queryVoxel(x, y, z)));
        payload.text(ret, voxel);
        return;
    }
    payload.empty(ret);
}
