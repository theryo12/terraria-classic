const std = @import("std");
const rl = @import("raylib");
const Scene = @import("../scene.zig").Scene;
const ecs = @import("../ecs/mod.zig");

pub const EmptyScene = struct {
    const Self = @This();

    scene: Scene,
    render_system: *ecs.RenderSystem,
    allocator: std.mem.Allocator,

    pub fn create(allocator: std.mem.Allocator) !*Self {
        const self = try allocator.create(Self);
        self.* = Self{
            .scene = try Scene.init("empty", allocator),
            .render_system = undefined,
            .allocator = allocator,
        };

        // Initialize systems
        self.render_system = try ecs.RenderSystem.create(self.scene.registry, allocator);

        self.scene.vtable = .{
            .onLoad = onLoad,
            .onUnload = onUnload,
            .onUpdate = onUpdate,
            .onDraw = onDraw,
            .onDestroy = onDestroy,
        };

        try self.scene.load();
        return self;
    }

    fn onLoad(scene_base: *Scene) !void {
        _ = scene_base;
    }

    fn onUnload(scene_base: *Scene) void {
        _ = scene_base;
    }

    fn onUpdate(scene_base: *Scene, delta_time: f32) void {
        const scene_ptr: *EmptyScene = @alignCast(@ptrCast(scene_base));
        scene_ptr.render_system.base.vtable.update(&scene_ptr.render_system.base, delta_time);
    }

    fn onDraw(scene_base: *Scene) void {
        const scene_ptr: *EmptyScene = @alignCast(@ptrCast(scene_base));
        rl.clearBackground(rl.Color.gray);

        scene_ptr.render_system.base.vtable.draw(&scene_ptr.render_system.base);
    }

    fn onDestroy(scene_base: *Scene, allocator: std.mem.Allocator) void {
        const scene_ptr: *EmptyScene = @alignCast(@ptrCast(scene_base));
        scene_ptr.render_system.base.vtable.deinit(&scene_ptr.render_system.base);
        allocator.destroy(scene_ptr);
    }
};
