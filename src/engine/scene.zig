const std = @import("std");
const rl = @import("raylib");
const ecs = @import("ecs/mod.zig");

pub const Scene = struct {
    const Self = @This();

    name: []const u8,
    registry: *ecs.Registry,
    allocator: std.mem.Allocator,
    is_loaded: bool = false,

    // Virtual method function pointers
    vtable: struct {
        onLoad: *const fn (*Scene) anyerror!void = defaultOnLoad,
        onUnload: *const fn (*Scene) void = defaultOnUnload,
        onUpdate: *const fn (*Scene, f32) void = defaultOnUpdate,
        onDraw: *const fn (*Scene) void = defaultOnDraw,
        onDestroy: *const fn (*Scene, std.mem.Allocator) void = defaultOnDestroy,
    } = .{},

    pub fn init(name: []const u8, allocator: std.mem.Allocator) !Self {
        var self = Self{
            .name = name,
            .registry = undefined,
            .allocator = allocator,
        };

        const registry = try allocator.create(ecs.Registry);
        registry.* = ecs.Registry.init(allocator, &self);
        self.registry = registry;

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.registry.deinit();
        self.allocator.destroy(self.registry);
    }

    pub fn load(self: *Self) !void {
        if (self.is_loaded) return;
        self.is_loaded = true;
        try self.vtable.onLoad(self);
    }

    pub fn unload(self: *Self) void {
        if (!self.is_loaded) return;
        self.vtable.onUnload(self);
        self.is_loaded = false;
    }

    pub fn update(self: *Self, delta_time: f32) void {
        if (!self.is_loaded) return;
        self.vtable.onUpdate(self, delta_time);
    }

    pub fn draw(self: *Self) void {
        if (!self.is_loaded) return;
        self.vtable.onDraw(self);
    }

    // Default implementations of virtual methods
    fn defaultOnLoad(self: *const Self) !void {
        _ = self;
    }

    fn defaultOnUnload(self: *const Self) void {
        _ = self;
    }

    fn defaultOnUpdate(self: *const Self, delta_time: f32) void {
        _ = self;
        _ = delta_time;
    }

    fn defaultOnDraw(self: *const Self) void {
        _ = self;
    }

    fn defaultOnDestroy(self: *Scene, allocator: std.mem.Allocator) void {
        _ = allocator;
        _ = self;
    }

    pub fn destroy(self: *Scene, allocator: std.mem.Allocator) void {
        // First clean up base class resources
        self.registry.deinit();
        self.allocator.destroy(self.registry);
        // Then call the virtual destructor to clean up derived class resources
        self.vtable.onDestroy(self, allocator);
    }
};

pub const SceneManager = struct {
    const Self = @This();
    const SceneMap = std.StringHashMap(*Scene);

    scenes: SceneMap,
    current_scene: ?*Scene,
    next_scene: ?*Scene,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Self {
        return Self{
            .scenes = SceneMap.init(allocator),
            .current_scene = null,
            .next_scene = null,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *Self) void {
        var scene_iter = self.scenes.valueIterator();
        while (scene_iter.next()) |scene| {
            scene.*.destroy(self.allocator);
        }
        self.scenes.deinit();
    }

    pub fn addScene(self: *Self, scene: *Scene) !void {
        try self.scenes.put(scene.name, scene);
    }

    pub fn loadScene(self: *Self, name: []const u8) !void {
        const scene = self.scenes.get(name) orelse return error.SceneNotFound;
        self.next_scene = scene;
    }

    pub fn loadScenePtr(self: *Self, scene: *Scene) !void {
        try self.scenes.put(scene.name, scene);
        self.next_scene = scene;
    }

    pub fn update(self: *Self, delta_time: f32) !void {
        // Handle scene transitions
        if (self.next_scene) |next| {
            if (self.current_scene) |current| {
                current.unload();
            }
            try next.load();
            self.current_scene = next;
            self.next_scene = null;
        }

        // Update current scene
        if (self.current_scene) |scene| {
            scene.update(delta_time);
        }
    }

    pub fn draw(self: *Self) void {
        if (self.current_scene) |scene| {
            scene.draw();
        }
    }
};
