const std = @import("std");

pub const AtomKind = enum { flag, int, float, text };

pub const Atom = union(AtomKind) {
    flag: bool,
    int: i64,
    float: f64,
    text: []const u8,
};

pub const Field = struct {
    key: []const u8,
    value: Atom,
};

pub const WireKind = enum { empty, flag, int, float, text, bag };

pub const Wire = union(WireKind) {
    empty: void,
    flag: bool,
    int: i64,
    float: f64,
    text: []const u8,
    bag: []const Field,

    pub fn asText(self: Wire) ?[]const u8 {
        return switch (self) {
            .text => |value| value,
            else => null,
        };
    }

    pub fn bagText(self: Wire, key: []const u8) ?[]const u8 {
        const fields = switch (self) {
            .bag => |list| list,
            else => return null,
        };
        for (fields) |field| {
            if (std.mem.eql(u8, field.key, key)) {
                return switch (field.value) {
                    .text => |value| value,
                    else => null,
                };
            }
        }
        return null;
    }

    pub fn bagFlag(self: Wire, key: []const u8) bool {
        const fields = switch (self) {
            .bag => |list| list,
            else => return false,
        };
        for (fields) |field| {
            if (!std.mem.eql(u8, field.key, key)) continue;
            return switch (field.value) {
                .flag => |value| value,
                .int => |value| value == 1,
                else => false,
            };
        }
        return false;
    }
};

pub fn text(value: []const u8) Wire {
    return .{ .text = value };
}

pub fn voxelProbe(voxel: []const u8, edit: bool) [2]Field {
    return .{
        .{ .key = "name", .value = .{ .text = voxel } },
        .{ .key = "edit", .value = .{ .flag = edit } },
    };
}

test "wire probe" {
    const fields = voxelProbe("glass", true);
    const probe = Wire{ .bag = &fields };
    try std.testing.expectEqualStrings("glass", probe.bagText("name").?);
    try std.testing.expect(probe.bagFlag("edit"));
}
