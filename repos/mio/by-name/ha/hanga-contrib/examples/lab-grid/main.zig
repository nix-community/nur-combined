const std = @import("std");
const hangamod = @import("hangamod/root.zig");
const c = @cImport({
    @cInclude("plugin.h");
});

const catalog_csv = "air,grid,mark";
const bus_topics = "ping,name,catalog,gravity,has,methods,voxel,fracture-kit,loot-item";

fn cSlice(s: [*c]const c.plugin_string_t) []const u8 {
    if (s == null or s.*.ptr == null or s.*.len == 0) return "";
    return s.*.ptr[0..s.*.len];
}

fn setStr(ret: [*c]c.plugin_string_t, value: [:0]const u8) void {
    c.plugin_string_set(ret, value.ptr);
}

fn dupSlice(ret: [*c]c.plugin_string_t, value: []const u8) void {
    if (value.len == 0) {
        setStr(ret, "");
        return;
    }
    c.plugin_string_dup_n(ret, value.ptr, value.len);
}

fn queryVoxel(x: i32, y: i32, z: i32) i32 {
    if (y < 0) return 2;
    if (y == 0) {
        return if ((x + z) & 1 == 0) 1 else 2;
    }
    return 0;
}

fn topicEql(topic: []const u8, want: []const u8) bool {
    return std.mem.eql(u8, topic, want);
}

fn rootCell(payload: [*c]const c.hanga_engine_host_value_t) ?c.hanga_engine_host_cell_t {
    const cells = payload.*.cells;
    if (cells.ptr == null or payload.*.root >= cells.len) return null;
    return cells.ptr[payload.*.root];
}

fn busHas(payload: [*c]const c.hanga_engine_host_value_t) bool {
    var name: []const u8 = "";
    if (rootCell(payload)) |cell| {
        if (cell.tag == c.HANGA_ENGINE_HOST_CELL_TEXT) {
            const text = cell.val.text;
            if (text.ptr != null and text.len > 0) name = text.ptr[0..text.len];
        } else if (cell.tag == c.HANGA_ENGINE_HOST_CELL_DICT) {
            const want = bagText(payload, "name");
            name = if (want.len > 0) want else bagText(payload, "method");
        }
    }
    var it = std.mem.splitScalar(u8, bus_topics, ',');
    while (it.next()) |method| {
        if (std.mem.eql(u8, std.mem.trim(u8, method, " "), name)) return true;
    }
    return false;
}

fn bagInt(payload: [*c]const c.hanga_engine_host_value_t, key: []const u8) i64 {
    const cell = rootCell(payload) orelse return 0;
    if (cell.tag != c.HANGA_ENGINE_HOST_CELL_DICT) return 0;
    const bag = cell.val.dict;
    if (bag.ptr == null) return 0;
    const cells = payload.*.cells;
    var i: usize = 0;
    while (i < bag.len) : (i += 1) {
        const field = bag.ptr[i];
        const field_key = if (field.key.ptr != null and field.key.len > 0) field.key.ptr[0..field.key.len] else "";
        if (!std.mem.eql(u8, field_key, key)) continue;
        if (field.at >= cells.len) continue;
        const child = cells.ptr[field.at];
        if (child.tag == c.HANGA_ENGINE_HOST_CELL_INT) return child.val.int_;
        if (child.tag == c.HANGA_ENGINE_HOST_CELL_TEXT) {
            const text = child.val.text;
            const slice = if (text.ptr != null and text.len > 0) text.ptr[0..text.len] else "";
            return std.fmt.parseInt(i64, slice, 10) catch 0;
        }
    }
    return 0;
}

fn bagText(payload: [*c]const c.hanga_engine_host_value_t, key: []const u8) []const u8 {
    if (rootCell(payload)) |cell| {
        if (cell.tag == c.HANGA_ENGINE_HOST_CELL_TEXT and std.mem.eql(u8, key, "voxel")) {
            const text = cell.val.text;
            if (text.ptr != null and text.len > 0) return text.ptr[0..text.len];
            return "";
        }
        if (cell.tag != c.HANGA_ENGINE_HOST_CELL_DICT) return "";
        const bag = cell.val.dict;
        if (bag.ptr == null) return "";
        const cells = payload.*.cells;
        var i: usize = 0;
        while (i < bag.len) : (i += 1) {
            const field = bag.ptr[i];
            const field_key = if (field.key.ptr != null and field.key.len > 0) field.key.ptr[0..field.key.len] else "";
            if (!std.mem.eql(u8, field_key, key)) continue;
            if (field.at >= cells.len) continue;
            const child = cells.ptr[field.at];
            if (child.tag == c.HANGA_ENGINE_HOST_CELL_TEXT) {
                const text = child.val.text;
                if (text.ptr != null and text.len > 0) return text.ptr[0..text.len];
            }
        }
    }
    return "";
}

fn allocCells(n: usize) [*]c.hanga_engine_host_cell_t {
    const bytes = n * @sizeOf(c.hanga_engine_host_cell_t);
    const raw = cabi_realloc(null, 0, @alignOf(c.hanga_engine_host_cell_t), bytes) orelse unreachable;
    return @ptrCast(@alignCast(raw));
}

fn allocFields(n: usize) [*]c.hanga_engine_host_field_t {
    const bytes = n * @sizeOf(c.hanga_engine_host_field_t);
    const raw = cabi_realloc(null, 0, @alignOf(c.hanga_engine_host_field_t), bytes) orelse unreachable;
    return @ptrCast(@alignCast(raw));
}

fn payloadText(ret: [*c]c.hanga_engine_host_value_t, value: [:0]const u8) void {
    const cells = allocCells(1);
    cells[0].tag = c.HANGA_ENGINE_HOST_CELL_TEXT;
    setStr(&cells[0].val.text, value);
    ret.*.cells.ptr = cells;
    ret.*.cells.len = 1;
    ret.*.root = 0;
}

fn payloadFlag(ret: [*c]c.hanga_engine_host_value_t, value: bool) void {
    const cells = allocCells(1);
    cells[0].tag = c.HANGA_ENGINE_HOST_CELL_FLAG;
    cells[0].val.flag = value;
    ret.*.cells.ptr = cells;
    ret.*.cells.len = 1;
    ret.*.root = 0;
}

fn payloadEmpty(ret: [*c]c.hanga_engine_host_value_t) void {
    const cells = allocCells(1);
    cells[0].tag = c.HANGA_ENGINE_HOST_CELL_EMPTY;
    ret.*.cells.ptr = cells;
    ret.*.cells.len = 1;
    ret.*.root = 0;
}

fn payloadGravity(ret: [*c]c.hanga_engine_host_value_t) void {
    const cells = allocCells(5);
    const fields = allocFields(4);
    cells[0].tag = c.HANGA_ENGINE_HOST_CELL_TEXT;
    setStr(&cells[0].val.text, "down");
    cells[1].tag = c.HANGA_ENGINE_HOST_CELL_FLOAT;
    cells[1].val.float_ = 9.81;
    cells[2].tag = c.HANGA_ENGINE_HOST_CELL_FLOAT;
    cells[2].val.float_ = 5;
    cells[3].tag = c.HANGA_ENGINE_HOST_CELL_FLOAT;
    cells[3].val.float_ = 10;
    setStr(&fields[0].key, "kind");
    fields[0].at = 0;
    setStr(&fields[1].key, "g");
    fields[1].at = 1;
    setStr(&fields[2].key, "jump");
    fields[2].at = 2;
    setStr(&fields[3].key, "walk");
    fields[3].at = 3;
    cells[4].tag = c.HANGA_ENGINE_HOST_CELL_DICT;
    cells[4].val.dict.ptr = fields;
    cells[4].val.dict.len = 4;
    ret.*.cells.ptr = cells;
    ret.*.cells.len = 5;
    ret.*.root = 4;
}

fn payloadFracture(ret: [*c]c.hanga_engine_host_value_t) void {
    const cells = allocCells(4);
    const fields = allocFields(3);
    cells[0].tag = c.HANGA_ENGINE_HOST_CELL_FLAG;
    cells[0].val.flag = true;
    cells[1].tag = c.HANGA_ENGINE_HOST_CELL_INT;
    cells[1].val.int_ = 1;
    cells[2].tag = c.HANGA_ENGINE_HOST_CELL_FLOAT;
    cells[2].val.float_ = 4;
    setStr(&fields[0].key, "can");
    fields[0].at = 0;
    setStr(&fields[1].key, "spread");
    fields[1].at = 1;
    setStr(&fields[2].key, "impulse");
    fields[2].at = 2;
    cells[3].tag = c.HANGA_ENGINE_HOST_CELL_DICT;
    cells[3].val.dict.ptr = fields;
    cells[3].val.dict.len = 3;
    ret.*.cells.ptr = cells;
    ret.*.cells.len = 4;
    ret.*.root = 3;
}

extern fn cabi_realloc(ptr: ?*anyopaque, old_size: usize, alignment: usize, new_size: usize) callconv(.c) ?*anyopaque;

fn methodsBag(ret: [*c]c.hanga_engine_host_value_t) void {
    payloadText(ret, bus_topics);
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
}

export fn exports_hanga_engine_guest_voxel_catalog(ret: [*c]c.plugin_list_string_t) callconv(.c) void {
    const parts = [_][:0]const u8{ "air", "grid", "mark" };
    const bytes = parts.len * @sizeOf(c.plugin_string_t);
    const raw = cabi_realloc(null, 0, @alignOf(c.plugin_string_t), bytes) orelse unreachable;
    const strings: [*]c.plugin_string_t = @ptrCast(@alignCast(raw));
    for (parts, 0..) |part, i| {
        c.plugin_string_set(&strings[i], part.ptr);
    }
    ret.*.ptr = strings;
    ret.*.len = parts.len;
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
    if (topicEql(name, "ping")) {
        payloadText(ret, "pong");
        return;
    }
    if (topicEql(name, "name")) {
        payloadText(ret, "lab_grid");
        return;
    }
    if (topicEql(name, "catalog")) {
        payloadText(ret, catalog_csv);
        return;
    }
    if (topicEql(name, "gravity")) {
        payloadGravity(ret);
        return;
    }
    if (topicEql(name, "has")) {
        payloadFlag(ret, busHas(payload));
        return;
    }
    if (topicEql(name, "methods")) {
        methodsBag(ret);
        return;
    }
    if (topicEql(name, "voxel")) {
        const x: i32 = @intCast(bagInt(payload, "x"));
        const y: i32 = @intCast(bagInt(payload, "y"));
        const z: i32 = @intCast(bagInt(payload, "z"));
        var names: [8][]const u8 = undefined;
        const n = hangamod.catalog.parse(catalog_csv, &names);
        const voxel = hangamod.catalog.catalogName(names[0..n], @intCast(queryVoxel(x, y, z)));
        payloadText(ret, "grid");
        dupSlice(&ret.*.cells.ptr[0].val.text, voxel);
        return;
    }
    if (topicEql(name, "fracture-kit")) {
        const act = bagText(payload, "action");
        if (!std.mem.eql(u8, act, "break") and !std.mem.eql(u8, act, "explode")) {
            payloadEmpty(ret);
            return;
        }
        const voxel = bagText(payload, "voxel");
        if (std.mem.eql(u8, voxel, "grid") or std.mem.eql(u8, voxel, "mark")) {
            payloadFracture(ret);
            return;
        }
        payloadEmpty(ret);
        return;
    }
    if (topicEql(name, "loot-item")) {
        const voxel = bagText(payload, "voxel");
        if (std.mem.eql(u8, voxel, "mark")) {
            payloadText(ret, "mark");
            return;
        }
        payloadEmpty(ret);
        return;
    }
    payloadEmpty(ret);
}
