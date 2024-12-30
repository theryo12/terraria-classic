const std = @import("std");
const rl = @import("raylib");
const Engine = @import("engine/engine.zig").Engine;
const MenuScene = @import("engine/scenes/menu.zig").MenuScene;
const config = @import("engine/config.zig");
const SettingsManager = @import("engine/utils/settings.zig").SettingsManager;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Initialize settings manager and load config
    const settings_path = "settings.hjson";
    var settings_manager = try SettingsManager.init(allocator, settings_path);
    defer settings_manager.deinit();

    // Get the loaded config
    const loaded_config = settings_manager.getConfig();

    // Initialize engine with loaded config
    var engine = try Engine.initWithConfig(allocator, loaded_config);
    defer engine.deinit();

    settings_manager.setEngine(&engine);

    // Create and add menu scene
    var menu_scene = try MenuScene.create(allocator, &engine);
    try engine.scene_manager.addScene(&menu_scene.scene);
    try engine.scene_manager.loadScene("menu");

    // Main game loop
    while (!rl.windowShouldClose()) {
        try engine.update();
        engine.draw();
    }
}
