const std = @import("std");
const testing = std.testing;

// Mock raylib types for testing
pub const MockRaylib = struct {
    pub const Vector2 = struct {
        x: f32 = 0,
        y: f32 = 0,
    };

    pub const Rectangle = struct {
        x: f32 = 0,
        y: f32 = 0,
        width: f32 = 0,
        height: f32 = 0,
    };

    pub const Color = struct {
        r: u8 = 0,
        g: u8 = 0,
        b: u8 = 0,
        a: u8 = 255,

        pub const white = Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
        pub const black = Color{ .r = 0, .g = 0, .b = 0, .a = 255 };
    };

    pub const Matrix = struct {
        m0: f32 = 0,
        m4: f32 = 0,
        m8: f32 = 0,
        m12: f32 = 0,
        m1: f32 = 0,
        m5: f32 = 0,
        m9: f32 = 0,
        m13: f32 = 0,
        m2: f32 = 0,
        m6: f32 = 0,
        m10: f32 = 0,
        m14: f32 = 0,
        m3: f32 = 0,
        m7: f32 = 0,
        m11: f32 = 0,
        m15: f32 = 0,
    };

    pub const Texture2D = struct {
        id: u32 = 0,
        width: i32 = 0,
        height: i32 = 0,
        mipmaps: i32 = 0,
        format: i32 = 0,
    };
};

// Test the Entity system
test "Entity creation and management" {
    const EntityManager = @import("entity.zig").EntityManager;

    var manager = EntityManager.init(testing.allocator);
    defer manager.deinit();

    // Test entity creation
    const entity1 = try manager.create();
    try testing.expect(!entity1.isNull());
    try testing.expectEqual(@as(u32, 0), entity1.index());
    try testing.expectEqual(@as(u32, 0), entity1.version());

    // Test entity is alive
    try testing.expect(manager.isAlive(entity1));

    // Test entity destruction
    try manager.destroy(entity1);
    try testing.expect(!manager.isAlive(entity1));

    // Test entity recycling
    const entity2 = try manager.create();
    try testing.expectEqual(@as(u32, 0), entity2.index());
    try testing.expectEqual(@as(u32, 1), entity2.version());
}

// Test the SparseSet
test "SparseSet operations" {
    const SparseSet = @import("sparse_set.zig").SparseSet;
    const Entity = @import("entity.zig").Entity;

    var sparse_set = SparseSet(i32).init(testing.allocator);
    defer sparse_set.deinit();

    const entity = Entity.init(0, 0);

    // Test adding component
    try sparse_set.add(entity, 42);
    try testing.expect(sparse_set.has(entity));

    // Test getting component
    if (sparse_set.get(entity)) |value| {
        try testing.expectEqual(@as(i32, 42), value.*);
    } else {
        try testing.expect(false);
    }

    // Test removing component
    sparse_set.remove(entity);
    try testing.expect(!sparse_set.has(entity));
}

// Test the Registry
test "Registry component management" {
    const Registry = @import("registry.zig").Registry;

    var registry = Registry.init(testing.allocator);
    defer registry.deinit();

    const entity = try registry.create();

    // Test adding and getting components
    try registry.add(entity, @as(i32, 42));
    try registry.add(entity, @as(f32, 3.14));

    if (registry.getComponent(entity, i32)) |value| {
        try testing.expectEqual(@as(i32, 42), value.*);
    } else {
        try testing.expect(false);
    }

    if (registry.getComponent(entity, f32)) |value| {
        try testing.expectEqual(@as(f32, 3.14), value.*);
    } else {
        try testing.expect(false);
    }

    // Test component removal
    registry.remove(entity, i32);
    try testing.expect(registry.getComponent(entity, i32) == null);
    try testing.expect(registry.getComponent(entity, f32) != null);
}

// Test the Query system
test "Registry query system" {
    const Registry = @import("registry.zig").Registry;

    var registry = Registry.init(testing.allocator);
    defer registry.deinit();

    // Create test entities
    const e1 = try registry.create();
    try registry.add(e1, @as(i32, 1));
    try registry.add(e1, @as(f32, 1.0));

    const e2 = try registry.create();
    try registry.add(e2, @as(i32, 2));

    const e3 = try registry.create();
    try registry.add(e3, @as(i32, 3));
    try registry.add(e3, @as(f32, 3.0));

    // Test basic query
    const QueryComponents = struct {
        int: i32,
        float: f32,
    };
    var query = registry.query(QueryComponents);

    var count: u32 = 0;
    while (query.next()) |_| {
        count += 1;
    }
    try testing.expectEqual(@as(u32, 2), count);

    // Test query with exclusion
    const IncludeComponents = struct {
        int: i32,
    };
    const ExcludeComponents = struct {
        float: f32,
    };
    var exclude_query = registry.queryExclude(IncludeComponents, ExcludeComponents);

    count = 0;
    while (exclude_query.next()) |_| {
        count += 1;
    }
    try testing.expectEqual(@as(u32, 1), count);
}
