const std = @import("std");
const plugin = @import("../plugin.zig");

// Helper to allocate memory on WASM heap via cabi_realloc
fn alloc(comptime T: type, n: usize) [*]T {
    const p = plugin.cabi_realloc(null, 0, @alignOf(T), n * @sizeOf(T));
    return @ptrCast(@alignCast(p));
}

fn ownStr(ret: *plugin.string, value: []const u8) void {
    const ptr = alloc(u8, value.len);
    @memcpy(ptr[0..value.len], value);
    ret.ptr = ptr;
    ret.len = value.len;
}

pub fn text(ret: *plugin.value, value: []const u8) void {
    const cells = alloc(plugin.cell, 1);
    cells[0] = .{
        .tag = @intFromEnum(plugin.cell_tag.text),
        .val = undefined,
    };
    ownStr(&cells[0].val.text, value);
    ret.cells.ptr = cells;
    ret.cells.len = 1;
    ret.root = 0;
}

pub fn flag(ret: *plugin.value, value: bool) void {
    const cells = alloc(plugin.cell, 1);
    cells[0] = .{
        .tag = @intFromEnum(plugin.cell_tag.flag),
        .val = undefined,
    };
    cells[0].val.flag = value;
    ret.cells.ptr = cells;
    ret.cells.len = 1;
    ret.root = 0;
}

pub fn empty(ret: *plugin.value) void {
    const cells = alloc(plugin.cell, 1);
    cells[0] = .{
        .tag = @intFromEnum(plugin.cell_tag.empty),
        .val = undefined,
    };
    ret.cells.ptr = cells;
    ret.cells.len = 1;
    ret.root = 0;
}

pub fn fail(ret: *plugin.value, reason: []const u8) void {
    const cells = alloc(plugin.cell, 1);
    cells[0] = .{
        .tag = @intFromEnum(plugin.cell_tag.fail),
        .val = undefined,
    };
    ownStr(&cells[0].val.fail, reason);
    ret.cells.ptr = cells;
    ret.cells.len = 1;
    ret.root = 0;
}

pub fn gravity(ret: *plugin.value) void {
    const cells = alloc(plugin.cell, 5);
    const fields = alloc(plugin.field, 4);

    cells[0] = .{ .tag = @intFromEnum(plugin.cell_tag.text), .val = undefined };
    ownStr(&cells[0].val.text, "down");
    cells[1] = .{ .tag = @intFromEnum(plugin.cell_tag.float), .val = undefined };
    cells[1].val.float = 9.81;
    cells[2] = .{ .tag = @intFromEnum(plugin.cell_tag.float), .val = undefined };
    cells[2].val.float = 5.0;
    cells[3] = .{ .tag = @intFromEnum(plugin.cell_tag.float), .val = undefined };
    cells[3].val.float = 10.0;

    ownStr(&fields[0].key, "kind");
    fields[0].at = 0;
    ownStr(&fields[1].key, "g");
    fields[1].at = 1;
    ownStr(&fields[2].key, "jump");
    fields[2].at = 2;
    ownStr(&fields[3].key, "walk");
    fields[3].at = 3;

    cells[4] = .{ .tag = @intFromEnum(plugin.cell_tag.dict), .val = undefined };
    cells[4].val.dict.ptr = fields;
    cells[4].val.dict.len = 4;

    ret.cells.ptr = cells;
    ret.cells.len = 5;
    ret.root = 4;
}

pub fn methods(ret: *plugin.value, topics: []const []const u8) void {
    const cells = alloc(plugin.cell, topics.len + 1);
    const items = alloc(u32, topics.len);

    for (topics, 0..) |topic, i| {
        cells[i] = .{ .tag = @intFromEnum(plugin.cell_tag.text), .val = undefined };
        ownStr(&cells[i].val.text, topic);
        items[i] = @intCast(i);
    }

    cells[topics.len] = .{ .tag = @intFromEnum(plugin.cell_tag.items), .val = undefined };
    cells[topics.len].val.items.ptr = items;
    cells[topics.len].val.items.len = topics.len;

    ret.cells.ptr = cells;
    ret.cells.len = topics.len + 1;
    ret.root = @intCast(topics.len);
}

pub fn catalogNames(ret: *plugin.list_string, parts: []const []const u8) void {
    const ptr = alloc(plugin.string, parts.len);
    for (parts, 0..) |p, i| {
        ownStr(&ptr[i], p);
    }
    ret.ptr = ptr;
    ret.len = parts.len;
}

fn getCell(payload: *const plugin.value, at: u32) ?*const plugin.cell {
    if (at >= payload.cells.len) return null;
    return &payload.cells.ptr[at];
}

fn getField(payload: *const plugin.value, root: u32, key: []const u8) ?*const plugin.cell {
    const c = getCell(payload, root) orelse return null;
    if (c.tag != @intFromEnum(plugin.cell_tag.dict)) return null;
    for (0..c.val.dict.len) |i| {
        const f = c.val.dict.ptr[i];
        if (std.mem.eql(u8, f.key.ptr[0..f.key.len], key)) {
            return getCell(payload, f.at);
        }
    }
    return null;
}

pub fn bag_int(payload: *const plugin.value, key: []const u8) i64 {
    const c = getField(payload, payload.root, key) orelse return 0;
    if (c.tag == @intFromEnum(plugin.cell_tag.int)) return c.val.int;
    return 0;
}

pub fn bus_has(payload: *const plugin.value, topics: []const []const u8) bool {
    const c = getCell(payload, payload.root) orelse return false;
    if (c.tag != @intFromEnum(plugin.cell_tag.text)) return false;
    const topic = c.val.text.ptr[0..c.val.text.len];
    for (topics) |t| {
        if (std.mem.eql(u8, topic, t)) return true;
    }
    return false;
}

pub fn greet_peers() void {
    var p: plugin.list_string = undefined;
    plugin.peers(&p);
    for (0..p.len) |i| {
        const peer = p.ptr[i];
        var method = plugin.string{ .ptr = undefined, .len = 0 };
        ownStr(&method, "ping");
        var args = plugin.value{ .cells = undefined, .root = 0 };
        empty(&args);
        plugin.send(&peer, &method, &args);
    }
}
