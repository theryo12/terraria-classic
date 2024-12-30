const std = @import("std");
const rl = @import("raylib");
const ecs = @import("../mod.zig");
const Transform2D = @import("../components/transform.zig").Transform2D;
const Sprite = @import("../components/sprite.zig").Sprite;

const SpriteInstance = struct {
    texture: rl.Texture2D,
    source_rect: rl.Rectangle,
    dest_rect: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color,
    layer: i32,

    fn lessThan(_: void, a: SpriteInstance, b: SpriteInstance) bool {
        return a.layer < b.layer;
    }
};

/// System for rendering sprites
pub const RenderSystem = struct {
    base: ecs.System,
    allocator: std.mem.Allocator,

    const vtable = ecs.System.VTable{
        .update = RenderSystem.update,
        .init = RenderSystem.init,
        .deinit = RenderSystem.deinit,
        .draw = RenderSystem.draw,
    };

    pub fn create(registry: *ecs.Registry, allocator: std.mem.Allocator) !*RenderSystem {
        const self = try allocator.create(RenderSystem);
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
        _ = system_base;
        _ = delta_time;
    }

    fn draw(system_base: *ecs.System) void {
        const self: *RenderSystem = @ptrCast(@alignCast(system_base));

        const Components = struct {
            transform: Transform2D,
            sprite: Sprite,
        };

        var view = self.base.registry.query(Components);
        var sprites = std.ArrayList(SpriteInstance).init(self.allocator);
        defer sprites.deinit();

        while (view.next()) |entity| {
            if (self.base.registry.getComponent(entity, Transform2D)) |transform| {
                if (self.base.registry.getComponent(entity, Sprite)) |sprite| {
                    const dest_rect = rl.Rectangle{
                        .x = transform.position.x,
                        .y = transform.position.y,
                        .width = sprite.source_rect.width * transform.scale.x * sprite.scale.x,
                        .height = sprite.source_rect.height * transform.scale.y * sprite.scale.y,
                    };

                    var tint = sprite.tint;
                    tint.a = @as(u8, @intFromFloat(sprite.opacity * 255.0));

                    sprites.append(.{
                        .texture = sprite.texture,
                        .source_rect = sprite.source_rect,
                        .dest_rect = dest_rect,
                        .origin = sprite.origin,
                        .rotation = transform.rotation,
                        .tint = tint,
                        .layer = sprite.layer,
                    }) catch continue;
                }
            }
        }

        std.sort.insertion(SpriteInstance, sprites.items, {}, SpriteInstance.lessThan);

        for (sprites.items) |sprite| {
            rl.drawTexturePro(
                sprite.texture,
                sprite.source_rect,
                sprite.dest_rect,
                sprite.origin,
                sprite.rotation,
                sprite.tint,
            );
        }
    }

    fn deinit(system_base: *ecs.System) void {
        const self: *RenderSystem = @ptrCast(@alignCast(system_base));
        self.allocator.destroy(self);
    }
};
