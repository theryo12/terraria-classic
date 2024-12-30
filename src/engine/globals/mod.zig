const std = @import("std");
const rl = @import("raylib");
const ecs = @import("../ecs/mod.zig");
const cursor = @import("cursor.zig");
pub const Engine = @import("../engine.zig").Engine;

/// Global state that persists across all scenes
pub const Globals = struct {
    const Self = @This();

    registry: *ecs.Registry,
    /// Needed to render any sprites
    render_system: *ecs.RenderSystem,
    cursor: *cursor.Global,
    allocator: std.mem.Allocator,
    engine: *Engine,

    pub fn init(allocator: std.mem.Allocator, engine: *Engine) !*Self {
        const self = try allocator.create(Self);

        const registry = try allocator.create(ecs.Registry);
        registry.* = ecs.Registry.init(allocator, null);

        const render_system = try ecs.RenderSystem.create(registry, allocator);
        const cursor_global = try cursor.Global.init(registry, allocator, engine);

        self.* = .{
            .registry = registry,
            .render_system = render_system,
            .cursor = cursor_global,
            .allocator = allocator,
            .engine = engine,
        };

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.cursor.deinit();
        self.render_system.base.vtable.deinit(&self.render_system.base);
        self.registry.deinit();
        self.allocator.destroy(self.registry);
        self.allocator.destroy(self);
    }

    pub fn update(self: *Self, delta_time: f32) void {
        self.cursor.update(delta_time);
        self.render_system.base.vtable.update(&self.render_system.base, delta_time);
    }

    pub fn draw(self: *Self) void {
        self.render_system.base.vtable.draw(&self.render_system.base);
    }
};
