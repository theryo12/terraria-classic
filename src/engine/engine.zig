const std = @import("std");
const rl = @import("raylib");
const config = @import("config.zig");
const SceneManager = @import("scene.zig").SceneManager;
const Globals = @import("globals/mod.zig").Globals;
const ResourceManager = @import("resources.zig").ResourceManager;
const Window = @import("window.zig").Window;
const AudioEngine = @import("audio/mod.zig").AudioEngine;

pub const Engine = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    scene_manager: SceneManager,
    globals: *Globals,
    resource_manager: ResourceManager,
    window: Window,
    audio: *AudioEngine,

    pub fn init(allocator: std.mem.Allocator) !Self {
        const window = Window.init();

        var resource_manager = try ResourceManager.init(allocator, "resources");
        errdefer resource_manager.deinit();

        var self = Self{
            .allocator = allocator,
            .scene_manager = SceneManager.init(allocator),
            .globals = undefined,
            .resource_manager = resource_manager,
            .window = window,
            .audio = undefined,
        };

        self.globals = try Globals.init(allocator, &self);
        errdefer self.globals.deinit();

        self.audio = try AudioEngine.init(allocator);

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.scene_manager.deinit();
        self.globals.deinit();
        self.resource_manager.deinit();
        self.window.deinit();
        self.audio.deinit();
    }

    pub fn update(self: *Self) !void {
        const delta_time = rl.getFrameTime();
        try self.scene_manager.update(delta_time);
        self.window.update();
        self.globals.update(delta_time);
        self.audio.update();
    }

    pub fn draw(self: *Self) void {
        rl.beginDrawing();
        defer rl.endDrawing();
        // TODO: make it so the draw layer matters, not draw call order
        self.scene_manager.draw();
        self.globals.draw();
    }
};
