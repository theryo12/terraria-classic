const std = @import("std");
const rl = @import("raylib");
const ecs = @import("../mod.zig");
const Transform2D = @import("../components/transform.zig").Transform2D;
const Sprite = @import("../components/sprite.zig").Sprite;

const INITIAL_SPRITE_CAPACITY = 128;

const SpriteInstance = struct {
    texture: rl.Texture2D,
    source_rect: rl.Rectangle,
    dest_rect: rl.Rectangle,
    origin: rl.Vector2,
    rotation: f32,
    tint: rl.Color,
    layer: i32,
    entity_id: ecs.Entity,

    fn lessThan(_: void, a: SpriteInstance, b: SpriteInstance) bool {
        // Sort by layer in descending order (higher layers last)
        return a.layer > b.layer;
    }
};

const SpriteBatch = struct {
    texture: rl.Texture2D,
    layer: i32,
    instances: []const SpriteInstance,

    fn lessThan(_: void, a: SpriteBatch, b: SpriteBatch) bool {
        // Sort batches by layer in descending order (higher layers last)
        return a.layer > b.layer;
    }
};

/// System for rendering sprites with optimized batching and caching
pub const RenderSystem = struct {
    base: ecs.System,
    allocator: std.mem.Allocator,
    sprites: std.ArrayList(SpriteInstance),
    last_frame_hash: u64, // Hash of sprite states from last frame
    needs_sort: bool,

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
            .sprites = try std.ArrayList(SpriteInstance).initCapacity(allocator, INITIAL_SPRITE_CAPACITY),
            .last_frame_hash = 0,
            .needs_sort = true,
        };
        return self;
    }

    fn init(system_base: *ecs.System) void {
        _ = system_base;
    }

    fn update(system_base: *ecs.System, delta_time: f32) void {
        _ = delta_time;
        const self: *RenderSystem = @ptrCast(@alignCast(system_base));
        self.sprites.clearRetainingCapacity();
    }

    fn calculateFrameHash(sprites: []const SpriteInstance) u64 {
        var hasher = std.hash.Wyhash.init(0);
        for (sprites) |sprite| {
            std.hash.autoHash(&hasher, sprite.layer);
            std.hash.autoHash(&hasher, sprite.entity_id);
            std.hash.autoHash(&hasher, sprite.texture.id);
        }
        return hasher.final();
    }

    fn createBatches(allocator: std.mem.Allocator, sprites: []const SpriteInstance) ![]SpriteBatch {
        if (sprites.len == 0) return &[_]SpriteBatch{};

        var batches = std.ArrayList(SpriteBatch).init(allocator);
        defer batches.deinit();

        var current_texture = sprites[0].texture;
        var current_layer = sprites[0].layer;
        var batch_start: usize = 0;

        for (sprites, 0..) |sprite, i| {
            const is_last = i == sprites.len - 1;
            // Start new batch if texture or layer changes
            if (sprite.texture.id != current_texture.id or
                sprite.layer != current_layer or
                is_last)
            {
                const batch_end = if (is_last) i + 1 else i;
                try batches.append(.{
                    .texture = current_texture,
                    .layer = current_layer,
                    .instances = sprites[batch_start..batch_end],
                });

                if (!is_last) {
                    batch_start = i;
                    current_texture = sprite.texture;
                    current_layer = sprite.layer;
                }
            }
        }

        return try batches.toOwnedSlice();
    }

    fn draw(system_base: *ecs.System) void {
        const self: *RenderSystem = @ptrCast(@alignCast(system_base));

        const Components = struct {
            transform: Transform2D,
            sprite: Sprite,
        };

        var view = self.base.registry.query(Components);
        self.sprites.clearRetainingCapacity();

        // Collect sprites
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

                    self.sprites.append(.{
                        .texture = sprite.texture,
                        .source_rect = sprite.source_rect,
                        .dest_rect = dest_rect,
                        .origin = sprite.origin,
                        .rotation = transform.rotation,
                        .tint = tint,
                        .layer = sprite.layer,
                        .entity_id = entity,
                    }) catch continue;
                }
            }
        }

        // Sort sprites by layer
        std.sort.pdq(SpriteInstance, self.sprites.items, {}, SpriteInstance.lessThan);

        // Create and render batches
        if (createBatches(self.allocator, self.sprites.items)) |batches| {
            defer self.allocator.free(batches);

            // Sort batches by layer
            std.sort.pdq(SpriteBatch, batches, {}, SpriteBatch.lessThan);

            // Draw batches in layer order
            for (batches) |batch| {
                for (batch.instances) |sprite| {
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
        } else |_| {
            // Fallback to non-batched rendering
            for (self.sprites.items) |sprite| {
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
    }

    fn deinit(system_base: *ecs.System) void {
        const self: *RenderSystem = @ptrCast(@alignCast(system_base));
        self.sprites.deinit();
        self.allocator.destroy(self);
    }
};
