const std = @import("std");
const rl = if (@import("builtin").is_test) @import("../test.zig").MockRaylib else @import("raylib");

pub const Transform2D = struct {
    position: rl.Vector2 = .{ .x = 0, .y = 0 },
    rotation: f32 = 0,
    scale: rl.Vector2 = .{ .x = 1, .y = 1 },
};
