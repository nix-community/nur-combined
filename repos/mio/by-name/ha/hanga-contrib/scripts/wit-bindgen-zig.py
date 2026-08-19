import json
import sys
import os

def generate_zig(wit_json, out_dir):
    zig_code = """// Generated native Zig bindings wrapped around C bindings
const std = @import("std");

pub const string = extern struct {
    ptr: [*]u8,
    len: usize,
};

pub const field = extern struct {
    key: string,
    at: u32,
};

pub const list_u32 = extern struct {
    ptr: [*]u32,
    len: usize,
};

pub const list_field = extern struct {
    ptr: [*]field,
    len: usize,
};

pub const cell_tag = enum(u8) {
    empty = 0,
    flag = 1,
    int = 2,
    float = 3,
    text = 4,
    items = 5,
    dict = 6,
    fail = 7,
};

pub const cell = extern struct {
    tag: u8,
    val: extern union {
        flag: bool,
        int: i64,
        float: f64,
        text: string,
        items: list_u32,
        dict: list_field,
        fail: string,
    },
};

pub const list_cell = extern struct {
    ptr: [*]cell,
    len: usize,
};

pub const value = extern struct {
    cells: list_cell,
    root: u32,
};

pub const list_string = extern struct {
    ptr: [*]string,
    len: usize,
};

extern fn hanga_engine_host_log(level: *const string, message: *const string) void;
pub const log = hanga_engine_host_log;
extern fn hanga_engine_host_now_ms() i64;
pub const @"now-ms" = hanga_engine_host_now_ms;
extern fn hanga_engine_host_id(ret: *string) void;
pub const id = hanga_engine_host_id;
extern fn hanga_engine_host_peers(ret: *list_string) void;
pub const peers = hanga_engine_host_peers;
extern fn hanga_engine_host_has_mod(name: *const string) bool;
pub const @"has-mod" = hanga_engine_host_has_mod;
extern fn hanga_engine_host_invoke(peer: *const string, method: *const string, args: *const value, ret: *value) void;
pub const invoke = hanga_engine_host_invoke;
extern fn hanga_engine_host_send(peer: *const string, method: *const string, args: *const value) void;
pub const send = hanga_engine_host_send;
extern fn hanga_engine_host_emit(method: *const string, args: *const value) bool;
pub const emit = hanga_engine_host_emit;
extern fn hanga_engine_host_voxel(x: i32, y: i32, z: i32, ret: *value) void;
pub const voxel = hanga_engine_host_voxel;
extern fn hanga_engine_host_voxel_set(x: i32, y: i32, z: i32, name: *const string) void;
pub const @"voxel-set" = hanga_engine_host_voxel_set;
extern fn hanga_engine_host_player(ret: *value) void;
pub const player = hanga_engine_host_player;
extern fn hanga_engine_host_after(ms: i32, method: *const string, args: *const value) void;
pub const after = hanga_engine_host_after;

pub extern fn cabi_realloc(orig_ptr: ?*anyopaque, orig_size: usize, align_: usize, new_size: usize) ?*anyopaque;
"""
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(out_dir, "plugin.zig"), "w") as f:
        f.write(zig_code)

if __name__ == "__main__":
    generate_zig(sys.argv[1], sys.argv[2])
