const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs/mod.zig");

/// System for handling cursor movement
const CursorSystem = struct {
    base: ecs.System,
    allocator: std.mem.Allocator,

    const vtable = ecs.System.VTable{
        .update = update,
        .init = init,
        .deinit = deinit,
        .draw = draw,
    };

    pub fn create(registry: *ecs.Registry, allocator: std.mem.Allocator) !*CursorSystem {
        const self = try allocator.create(CursorSystem);
        self.* = .{
            .base = .{
                .vtable = &vtable,
                .registry = registry,
            },
            .allocator = allocator,
        };
        return self;
    }

    fn init(system_base: *ecs.System) void {
        _ = system_base;
    }

    fn update(system_base: *ecs.System, delta_time: f32) void {
        _ = delta_time;
        const self: *CursorSystem = @ptrCast(@alignCast(system_base));
        const mouse_pos = rl.getMousePosition();

        // Update cursor position
        const Components = struct {
            transform: ecs.Transform2D,
        };
        var view = self.base.registry.query(Components);

        while (view.next()) |entity| {
            if (self.base.registry.getComponent(entity, ecs.Transform2D)) |transform| {
                transform.position.x = mouse_pos.x;
                transform.position.y = mouse_pos.y;
            }
        }
    }

    fn draw(system_base: *ecs.System) void {
        _ = system_base;
    }

    fn deinit(system_base: *ecs.System) void {
        const self: *CursorSystem = @ptrCast(@alignCast(system_base));
        self.allocator.destroy(self);
    }
};

/// Global state that persists across all scenes
pub const Globals = struct {
    const Self = @This();

    registry: *ecs.Registry,
    render_system: *ecs.RenderSystem,
    cursor_system: *CursorSystem,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) !*Self {
        const self = try allocator.create(Self);

        // Create a global registry (not tied to any scene)
        const registry = try allocator.create(ecs.Registry);
        registry.* = ecs.Registry.init(allocator, null);

        self.* = .{
            .registry = registry,
            .render_system = try ecs.RenderSystem.create(registry, allocator),
            .cursor_system = try CursorSystem.create(registry, allocator),
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
