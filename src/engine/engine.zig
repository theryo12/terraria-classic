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
    game_config: config.GameConfig,

    pub fn init(allocator: std.mem.Allocator) !Self {
        return initWithConfig(allocator, config.getDefaultConfig());
    }

    pub fn initWithConfig(allocator: std.mem.Allocator, game_config: config.GameConfig) !Self {
        const window = Window.init(game_config);

        var resource_manager = try ResourceManager.init(allocator, "resources");
        errdefer resource_manager.deinit();

        var audio = try AudioEngine.initWithConfig(allocator, game_config.audio);
        errdefer audio.deinit();
        // no need to set config again since we passed it during initialization
        // audio.setConfig(game_config.audio);

        var self = Self{
            .allocator = allocator,
            .scene_manager = SceneManager.init(allocator),
            .globals = undefined,
            .resource_manager = resource_manager,
            .window = window,
            .audio = audio,
            .game_config = game_config,
        };

        self.globals = try Globals.init(allocator, &self);
        errdefer self.globals.deinit();

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

    pub fn updateConfig(self: *Self, new_config: config.GameConfig) void {
        self.game_config = new_config;
        self.audio.setConfig(new_config.audio);
    }
};
