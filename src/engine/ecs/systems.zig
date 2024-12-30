const std = @import("std");
const rl = @import("raylib");
const components = @import("components.zig");
const Entity = @import("entity.zig").Entity;
const Registry = @import("registry.zig").Registry;

/// Base system interface
pub const System = struct {
    pub const UpdateFn = *const fn (*System, f32) void;
    pub const InitFn = *const fn (*System) void;
    pub const DeinitFn = *const fn (*System) void;

    vtable: *const VTable,
    registry: *Registry,

    pub const VTable = struct {
        update: UpdateFn,
        init: InitFn,
        deinit: DeinitFn,
    };

    pub fn init(self: *System) void {
        self.vtable.init(self);
    }

    pub fn deinit(self: *System) void {
        self.vtable.deinit(self);
    }

    pub fn update(self: *System, delta_time: f32) void {
        self.vtable.update(self, delta_time);
    }
};

/// Render system for drawing sprites
pub const RenderSystem = @import("systems/render.zig").RenderSystem;
pub const ButtonSystem = @import("systems/button_system.zig").ButtonSystem;
pub const CursorSystem = @import("systems/cursor_system.zig").CursorSystem;
