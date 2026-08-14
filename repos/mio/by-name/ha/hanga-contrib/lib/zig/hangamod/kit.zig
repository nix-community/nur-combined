const std = @import("std");

pub const Pair = struct { key: []const u8, value: []const u8 };

pub fn nextField(text: []const u8, start: usize) ?struct { pair: Pair, next: usize } {
    var i = start;
    while (i < text.len) {
        const rest = text[i..];
        const rec_end = std.mem.indexOfAny(u8, rest, ";\n") orelse rest.len;
        const rec = std.mem.trim(u8, rest[0..rec_end], " \t\r");
        const after = i + rec_end + @intFromBool(rec_end < rest.len);
        i = after;
        if (rec.len == 0 or rec[0] == '#') continue;
        const eq = std.mem.indexOfScalar(u8, rec, '=') orelse continue;
        return .{
            .pair = .{
                .key = std.mem.trim(u8, rec[0..eq], " \t"),
                .value = std.mem.trim(u8, rec[eq + 1 ..], " \t"),
            },
            .next = after,
        };
    }
    return null;
}

pub fn get(text: []const u8, key: []const u8) ?[]const u8 {
    var i: usize = 0;
    while (nextField(text, i)) |step| {
        if (std.mem.eql(u8, step.pair.key, key)) return step.pair.value;
        i = step.next;
    }
    return null;
}

pub fn flag(value: []const u8) bool {
    const trimmed = std.mem.trim(u8, value, " \t");
    return std.ascii.eqlIgnoreCase(trimmed, "1") or
        std.ascii.eqlIgnoreCase(trimmed, "true") or
        std.ascii.eqlIgnoreCase(trimmed, "yes") or
        std.ascii.eqlIgnoreCase(trimmed, "on");
}

pub fn f32Val(text: []const u8, key: []const u8, default: f32) f32 {
    const raw = get(text, key) orelse return default;
    return std.fmt.parseFloat(f32, raw) catch default;
}

pub fn boolVal(text: []const u8, key: []const u8) bool {
    return flag(get(text, key) orelse "0");
}

test "kit fields" {
    const i: usize = 0;
    const a = nextField("a=1;mystery=nope\nb=2", i).?;
    try std.testing.expectEqualStrings("a", a.pair.key);
    try std.testing.expectEqualStrings("1", a.pair.value);
    const b = nextField("a=1;mystery=nope\nb=2", a.next).?;
    try std.testing.expectEqualStrings("mystery", b.pair.key);
    const c = nextField("a=1;mystery=nope\nb=2", b.next).?;
    try std.testing.expectEqualStrings("b", c.pair.key);
    try std.testing.expect(flag("1"));
    try std.testing.expect(!flag("0"));
    try std.testing.expectEqualStrings("none", get("kind=none;jump=5", "kind").?);
    try std.testing.expectEqual(@as(f32, 10), f32Val("walk=10", "walk", 0));
}
