const std = @import("std");
const rl = @import("raylib");
const ecs = @import("../ecs/mod.zig");
const Engine = @import("mod.zig").Engine;

/// The cursor global state
pub const Global = struct {
    system: *CursorSystem,
    registry: *ecs.Registry,
    allocator: std.mem.Allocator,
    engine: *Engine,

    pub fn init(registry: *ecs.Registry, allocator: std.mem.Allocator, engine: *Engine) !*Global {
        const self = try allocator.create(Global);
        self.* = .{
            .system = try CursorSystem.create(registry, allocator),
            .registry = registry,
            .allocator = allocator,
            .engine = engine,
        };

        try initCursor(registry, engine);
        return self;
    }

    pub fn deinit(self: *Global) void {
        self.system.base.vtable.deinit(&self.system.base);
        self.allocator.destroy(self);
    }

    pub fn update(self: *Global, delta_time: f32) void {
        self.system.base.vtable.update(&self.system.base, delta_time);
    }

    pub fn draw(self: *Global) void {
        self.system.base.vtable.draw(&self.system.base);
    }
};

/// System for handling cursor movement
pub const CursorSystem = struct {
    base: ecs.System,
    allocator: std.mem.Allocator,

    const vtable = ecs.System.VTable{
        .update = CursorSystem.update,
        .init = CursorSystem.init,
        .deinit = CursorSystem.deinit,
        .draw = CursorSystem.draw,
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

/// Initialize cursor entity
fn initCursor(registry: *ecs.Registry, engine: *Engine) !void {
    const cursor_entity = try registry.create();
    const cursor_texture = try engine.resource_manager.loadTexture("images/cursor.png");
    std.debug.print("Cursor texture loaded: {d}x{d}\n", .{ cursor_texture.width, cursor_texture.height });

    try registry.add(cursor_entity, ecs.Transform2D{
        .position = .{ .x = 0, .y = 0 },
        .rotation = 0,
        .scale = .{ .x = 1, .y = 1 },
    });

    try registry.add(cursor_entity, ecs.Sprite{
        .texture = cursor_texture,
        .source_rect = .{
            .x = 0,
            .y = 0,
            .width = @floatFromInt(cursor_texture.width),
            .height = @floatFromInt(cursor_texture.height),
        },
        .origin = .{ .x = 0, .y = 0 },
        .tint = rl.Color.red,
        .layer = 10000,
    });

    rl.hideCursor();
}
