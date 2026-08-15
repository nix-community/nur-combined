const std = @import("std");

pub fn parse(csv: []const u8, out: [][]const u8) usize {
    var n: usize = 0;
    var it = std.mem.splitScalar(u8, csv, ',');
    while (it.next()) |part| {
        const voxel = std.mem.trim(u8, part, " \t");
        if (voxel.len == 0) continue;
        if (n >= out.len) break;
        out[n] = voxel;
        n += 1;
    }
    return n;
}

pub fn catalogName(entries: []const []const u8, index: usize) []const u8 {
    if (index < entries.len) return entries[index];
    return "air";
}

pub fn indexOf(entries: []const []const u8, voxel: []const u8) usize {
    for (entries, 0..) |entry, i| {
        if (std.mem.eql(u8, entry, voxel)) return i;
    }
    return 0;
}

pub fn checkerFloor(x: i32, y: i32, z: i32) i32 {
    if (y < 0) return 2;
    if (y == 0) return if ((x + z) & 1 == 0) 1 else 2;
    return 0;
}

test "catalog" {
    var buf: [8][]const u8 = undefined;
    const n = parse("air, tile ,lamp", &buf);
    try std.testing.expectEqual(@as(usize, 3), n);
    try std.testing.expectEqualStrings("tile", catalogName(buf[0..n], 1));
    try std.testing.expectEqual(@as(usize, 2), indexOf(buf[0..n], "lamp"));
    try std.testing.expectEqual(@as(i32, 2), checkerFloor(0, -1, 0));
    try std.testing.expectEqual(@as(i32, 1), checkerFloor(0, 0, 0));
    try std.testing.expectEqual(@as(i32, 2), checkerFloor(1, 0, 0));
    try std.testing.expectEqual(@as(i32, 0), checkerFloor(0, 1, 0));
}
