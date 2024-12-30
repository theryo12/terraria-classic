const std = @import("std");
const rl = @import("raylib");
const Engine = @import("engine/engine.zig").Engine;
const MenuScene = @import("engine/scenes/menu.zig").MenuScene;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn main() !void {
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Initialize engine
    var engine = try Engine.init(allocator);
    defer engine.deinit();

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
