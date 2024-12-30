const std = @import("std");
const Scene = @import("../scene.zig").Scene;

pub const entity = @import("entity.zig");
pub const Entity = entity.Entity;
pub const EntityManager = entity.EntityManager;

pub const sparse_set = @import("sparse_set.zig");
pub const SparseSet = sparse_set.SparseSet;

pub const components = @import("components/mod.zig");
pub const Transform2D = components.Transform2D;
pub const Sprite = components.Sprite;
pub const ComponentRegistry = components.ComponentRegistry;
pub const Text = components.Text;
pub const Behavior = components.Behavior;

pub const registry = @import("registry.zig");
pub const Registry = registry.Registry;

pub const systems = @import("systems/mod.zig");
pub const System = systems.System;
pub const RenderSystem = systems.RenderSystem;
pub const ButtonSystem = systems.ButtonSystem;
pub const BehaviorSystem = systems.BehaviorSystem;

/// Initialize the ECS system
pub fn init(allocator: std.mem.Allocator, scene: *Scene) !Registry {
    return Registry.init(allocator, scene);
}

test "ECS basic functionality" {
    const testing = std.testing;
    const allocator = testing.allocator;

    var ecs = try init(allocator);
    defer ecs.deinit();

    // Create an entity
    const test_entity = try ecs.create();
    try testing.expect(!test_entity.isNull());

    // Add components
    try ecs.add(test_entity, Transform2D{
        .position = .{ .x = 100, .y = 100 },
        .rotation = 45,
    });

    try ecs.add(test_entity, Sprite{
        .texture = undefined,
        .source_rect = .{ .x = 0, .y = 0, .width = 32, .height = 32 },
    });

    // Test component access
    const transform = ecs.getComponent(test_entity, Transform2D) orelse unreachable;
    try testing.expectEqual(@as(f32, 100), transform.position.x);
    try testing.expectEqual(@as(f32, 100), transform.position.y);
    try testing.expectEqual(@as(f32, 45), transform.rotation);

    const sprite = ecs.getComponent(test_entity, Sprite) orelse unreachable;
    try testing.expectEqual(@as(f32, 32), sprite.source_rect.width);
    try testing.expectEqual(@as(f32, 32), sprite.source_rect.height);

    // Test component removal
    ecs.remove(test_entity, Sprite);
    try testing.expect(ecs.getComponent(test_entity, Sprite) == null);
    try testing.expect(ecs.getComponent(test_entity, Transform2D) != null);

    // Test entity destruction
    try ecs.destroy(test_entity);
    try testing.expect(ecs.getComponent(test_entity, Transform2D) == null);
}

test "ECS query system" {
    const testing = std.testing;
    const allocator = testing.allocator;

    var ecs = try init(allocator);
    defer ecs.deinit();

    // Create multiple entities with different component combinations
    const e1 = try ecs.create();
    try ecs.add(e1, Transform2D{});
    try ecs.add(e1, Sprite{ .texture = undefined, .source_rect = undefined });

    const e2 = try ecs.create();
    try ecs.add(e2, Transform2D{});

    const e3 = try ecs.create();
    try ecs.add(e3, Transform2D{});
    try ecs.add(e3, Sprite{ .texture = undefined, .source_rect = undefined });

    // Test basic query
    const QueryComponents = struct {
        transform: Transform2D,
        sprite: Sprite,
    };
    var query = ecs.query(QueryComponents);

    var count: u32 = 0;
    while (query.next()) |_| {
        count += 1;
    }
    try testing.expectEqual(@as(u32, 2), count);

    // Test query with exclusion
    const IncludeComponents = struct {
        transform: Transform2D,
    };
    const ExcludeComponents = struct {
        sprite: Sprite,
    };
    var exclude_query = ecs.queryExclude(IncludeComponents, ExcludeComponents);

    count = 0;
    while (exclude_query.next()) |_| {
        count += 1;
    }
    try testing.expectEqual(@as(u32, 1), count);
}
