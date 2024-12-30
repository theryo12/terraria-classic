const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs/mod.zig");
const cursor = @import("globals/cursor.zig");

/// Global state that persists across all scenes
pub const Globals = struct {
    const Self = @This();

    registry: *ecs.Registry,
    render_system: *ecs.RenderSystem,
    cursor_system: *cursor.CursorSystem,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*Self {
        const self = try allocator.create(Self);

        // Create a global registry (not tied to any scene)
        const registry = try allocator.create(ecs.Registry);
        registry.* = ecs.Registry.init(allocator, null);

        self.* = .{
            .registry = registry,
            .render_system = try ecs.RenderSystem.create(registry, allocator),
            .cursor_system = try cursor.CursorSystem.create(registry, allocator),
            .allocator = allocator,
        };

        try self.setupGlobals();
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.render_system.base.vtable.deinit(&self.render_system.base);
        self.cursor_system.base.vtable.deinit(&self.cursor_system.base);
        self.registry.deinit();
        self.allocator.destroy(self.registry);
        self.allocator.destroy(self);
    }

    pub fn update(self: *Self, delta_time: f32) void {
        self.render_system.base.vtable.update(&self.render_system.base, delta_time);
        self.cursor_system.base.vtable.update(&self.cursor_system.base, delta_time);
    }

    pub fn draw(self: *Self) void {
        self.render_system.base.vtable.draw(&self.render_system.base);
    }
};
