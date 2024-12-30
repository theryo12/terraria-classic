const std = @import("std");
const rl = @import("raylib");
const Scene = @import("../scene.zig").Scene;
const SceneManager = @import("../scene.zig").SceneManager;
const ecs = @import("../ecs/mod.zig");
const Button = @import("../ecs/components/button.zig").Button;
const ButtonEvent = @import("../ecs/components/button.zig").ButtonEvent;
const EmptyScene = @import("empty.zig").EmptyScene;
const Engine = @import("../engine.zig").Engine;

pub const MenuScene = struct {
    const Self = @This();

    scene: Scene,
    render_system: *ecs.RenderSystem,
    button_system: *ecs.ButtonSystem,
    behavior_system: *ecs.BehaviorSystem,
    logo_texture: rl.Texture2D,
    logo_entity: ecs.Entity,
    menu_font: rl.Font,
    allocator: std.mem.Allocator,
    engine: *Engine,

    pub fn create(allocator: std.mem.Allocator, engine: *Engine) !*Self {
        const self = try allocator.create(Self);
        self.* = Self{
            .scene = try Scene.init("menu", allocator),
            .render_system = undefined,
            .button_system = undefined,
            .behavior_system = undefined,
            .logo_texture = undefined,
            .logo_entity = undefined,
            .menu_font = undefined,
            .allocator = allocator,
            .engine = engine,
        };

        self.render_system = try ecs.RenderSystem.create(self.scene.registry, allocator);
        self.button_system = try ecs.ButtonSystem.create(self.scene.registry, allocator);
        self.behavior_system = try ecs.BehaviorSystem.create(self.scene.registry, allocator);

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

    fn buttonClickHandler(entity: ecs.Entity, event: ButtonEvent, user_data: ?*anyopaque) void {
        _ = entity;
        if (event == .click) {
            if (user_data) |data| {
                const engine: *Engine = @ptrCast(@alignCast(data));
                const empty_scene = EmptyScene.create(engine.allocator) catch return;
                engine.scene_manager.loadScenePtr(&empty_scene.scene) catch return;
            }
        }
    }

    fn onLoad(scene_base: *Scene) !void {
        const scene_ptr: *MenuScene = @alignCast(@ptrCast(scene_base));

        scene_ptr.menu_font = try scene_ptr.engine.resource_manager.loadFont("fonts/Andy Bold.ttf");

        const logo_num = (std.crypto.random.intRangeAtMost(u8, 1, 5));
        const logo_path = try std.fmt.allocPrint(scene_ptr.allocator, "images/Logo_{d}.png", .{logo_num});
        defer scene_ptr.allocator.free(logo_path);

        scene_ptr.logo_texture = try scene_ptr.engine.resource_manager.loadTexture(logo_path);

        const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const screen_height = @as(f32, @floatFromInt(rl.getScreenHeight()));
        const logo_width = @as(f32, @floatFromInt(scene_ptr.logo_texture.width));
        const logo_height = @as(f32, @floatFromInt(scene_ptr.logo_texture.height));

        const padding_top: f32 = 20;

        scene_ptr.logo_entity = try scene_base.registry.create();

        try scene_base.registry.add(scene_ptr.logo_entity, ecs.Transform2D{
            .position = .{
                .x = (screen_width - logo_width) / 2,
                .y = padding_top,
            },
            .rotation = 0,
            .scale = .{ .x = 1, .y = 1 },
        });

        try scene_base.registry.add(scene_ptr.logo_entity, ecs.Sprite{
            .texture = scene_ptr.logo_texture,
            .source_rect = .{
                .x = 0,
                .y = 0,
                .width = logo_width,
                .height = logo_height,
            },
            .origin = .{ .x = 0, .y = 0 },
            .layer = 0,
        });

        const play_button = try scene_base.registry.create();

        try scene_base.registry.add(play_button, ecs.Transform2D{
            .position = .{
                .x = screen_width / 2,
                .y = screen_height / 2,
            },
            .rotation = 0,
            .scale = .{ .x = 1, .y = 1 },
        });

        try scene_base.registry.add(play_button, Button{
            .normal_color = rl.Color.white,
            .hover_color = rl.Color.yellow,
            .hover_scale = 1.2,
            .animation_speed = 0.2,
            .on_event = buttonClickHandler,
            .user_data = scene_ptr.engine,
        });

        try scene_base.registry.add(play_button, ecs.Text{
            .content = "Play",
            .font = scene_ptr.menu_font,
            .font_size = 40,
            .spacing = 2,
        });
    }

    fn onUnload(scene_base: *Scene) void {
        _ = scene_base;
    }

    fn onUpdate(scene_base: *Scene, delta_time: f32) void {
        const scene_ptr: *MenuScene = @alignCast(@ptrCast(scene_base));

        scene_ptr.render_system.base.vtable.update(&scene_ptr.render_system.base, delta_time);
        scene_ptr.button_system.base.vtable.update(&scene_ptr.button_system.base, delta_time);
        scene_ptr.behavior_system.base.vtable.update(&scene_ptr.behavior_system.base, delta_time);

        const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const logo_width = @as(f32, @floatFromInt(scene_ptr.logo_texture.width));

        if (scene_base.registry.getComponent(scene_ptr.logo_entity, ecs.Transform2D)) |transform| {
            transform.position.x = (screen_width - logo_width) / 2;
        }
    }

    fn onDraw(scene_base: *Scene) void {
        const scene_ptr: *MenuScene = @alignCast(@ptrCast(scene_base));
        rl.clearBackground(rl.Color.black);

        scene_ptr.button_system.base.vtable.draw(&scene_ptr.button_system.base);
        scene_ptr.render_system.base.vtable.draw(&scene_ptr.render_system.base);
        scene_ptr.behavior_system.base.vtable.draw(&scene_ptr.behavior_system.base);
    }

    fn onDestroy(scene_base: *Scene, allocator: std.mem.Allocator) void {
        const scene_ptr: *MenuScene = @alignCast(@ptrCast(scene_base));

        scene_ptr.render_system.base.vtable.deinit(&scene_ptr.render_system.base);
        scene_ptr.button_system.base.vtable.deinit(&scene_ptr.button_system.base);
        scene_ptr.behavior_system.base.vtable.deinit(&scene_ptr.behavior_system.base);

        allocator.destroy(scene_ptr);
    }
};
