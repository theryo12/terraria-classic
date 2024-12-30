const std = @import("std");

/// Entity identifier with version for safe handling and recycling
pub const Entity = struct {
    const Self = @This();

    /// Maximum number of entities that can exist simultaneously
    pub const MAX_ENTITIES: u32 = 1 << 22; // 4 million entities
    /// Number of bits used for version
    pub const VERSION_BITS: u32 = 10;
    /// Maximum version number before wrap-around
    pub const MAX_VERSION: u32 = (1 << VERSION_BITS) - 1;
    /// Mask for extracting the index
    pub const INDEX_MASK: u32 = MAX_ENTITIES - 1;
    /// Mask for extracting the version
    pub const VERSION_MASK: u32 = MAX_VERSION << 22;

    /// Combined ID and version for efficient storage
    raw: u32,

    /// Create a new entity with index and version
    pub fn init(entity_index: u32, entity_version: u32) Self {
        std.debug.assert(entity_index < MAX_ENTITIES);
        std.debug.assert(entity_version <= MAX_VERSION);
        return .{
            .raw = (entity_version << 22) | entity_index,
        };
    }

    /// Get a null entity (invalid)
    pub fn null_entity() Self {
        return .{ .raw = std.math.maxInt(u32) };
    }

    /// Check if entity is null
    pub fn isNull(self: Self) bool {
        return self.raw == std.math.maxInt(u32);
    }

    /// Get the index part of the entity
    pub fn index(self: Self) u32 {
        return self.raw & INDEX_MASK;
    }

    /// Get the version part of the entity
    pub fn version(self: Self) u32 {
        return (self.raw & VERSION_MASK) >> 22;
    }

    /// Compare two entities for equality
    pub fn eql(self: Self, other: Self) bool {
        return self.raw == other.raw;
    }
};

/// Entity manager for creating and recycling entities
pub const EntityManager = struct {
    const Self = @This();

    /// Pool of available entity indices
    available_indices: std.ArrayList(u32),
    /// Current versions for each entity index
    versions: std.ArrayList(u32),
    /// Total number of alive entities
    alive_count: u32,
    /// Allocator for memory management
    allocator: std.mem.Allocator,

    /// Iterator for entities
    pub const Iterator = struct {
        manager: *const EntityManager,
        current_index: usize,

        pub fn next(self: *Iterator) ?Entity {
            while (self.current_index < self.manager.versions.items.len) {
                const index = @as(u32, @intCast(self.current_index));
                self.current_index += 1;

                const entity = Entity.init(index, self.manager.versions.items[index]);
                if (self.manager.isAlive(entity)) {
                    return entity;
                }
            }
            return null;
        }

        pub fn reset(self: *Iterator) void {
            self.current_index = 0;
        }
    };

    /// Initialize the entity manager
    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .available_indices = std.ArrayList(u32).init(allocator),
            .versions = std.ArrayList(u32).init(allocator),
            .alive_count = 0,
            .allocator = allocator,
        };
    }

    /// Get an iterator over alive entities
    pub fn iterator(self: *const Self) Iterator {
        return .{
            .manager = self,
            .current_index = 0,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *Self) void {
        self.available_indices.deinit();
        self.versions.deinit();
    }

    /// Create a new entity
    pub fn create(self: *Self) !Entity {
        var index: u32 = undefined;
        var version: u32 = 0;

        if (self.available_indices.items.len > 0) {
            // Reuse a recycled entity index
            index = self.available_indices.pop();
            version = self.versions.items[index];
        } else {
            // Create a new entity index
            index = @intCast(self.versions.items.len);
            try self.versions.append(0);
        }

        self.alive_count += 1;
        return Entity.init(index, version);
    }

    /// Destroy an entity and recycle its index
    pub fn destroy(self: *Self, entity: Entity) !void {
        const index = entity.index();
        if (index >= self.versions.items.len) return;

        const current_version = self.versions.items[index];
        if (current_version != entity.version()) return;

        // Increment version and recycle index
        self.versions.items[index] = if (current_version == Entity.MAX_VERSION) 0 else current_version + 1;
        try self.available_indices.append(index);
        self.alive_count -= 1;
    }

    /// Check if an entity is alive
    pub fn isAlive(self: Self, entity: Entity) bool {
        const index = entity.index();
        if (index >= self.versions.items.len) return false;
        return self.versions.items[index] == entity.version();
    }

    /// Get the current number of alive entities
    pub fn aliveCount(self: Self) u32 {
        return self.alive_count;
    }

    /// Get the capacity (maximum number of entities that have existed)
    pub fn capacity(self: Self) u32 {
        return @intCast(self.versions.items.len);
    }

    /// Reserve space for a specific number of entities
    pub fn reserve(self: *Self, requested_capacity: u32) !void {
        try self.versions.ensureTotalCapacity(requested_capacity);
    }

    /// Clear all entities
    pub fn clear(self: *Self) void {
        self.available_indices.clearRetainingCapacity();
        self.versions.clearRetainingCapacity();
        self.alive_count = 0;
    }
};
