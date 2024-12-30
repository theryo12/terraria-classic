const std = @import("std");
const rl = @import("raylib");
const ecs = @import("../mod.zig");

/// Function type for behavior update callbacks
pub const BehaviorUpdateFn = *const fn (entity: ecs.Entity, registry: *ecs.Registry, delta_time: f32) void;

/// Function type for behavior draw callbacks
pub const BehaviorDrawFn = *const fn (entity: ecs.Entity, registry: *ecs.Registry) void;

/// Component that holds behavior callbacks
pub const Behavior = struct {
    /// Optional update function
    on_update: ?BehaviorUpdateFn = null,
    /// Optional draw function
    on_draw: ?BehaviorDrawFn = null,
    /// Custom user data
    user_data: ?*anyopaque = null,
};
