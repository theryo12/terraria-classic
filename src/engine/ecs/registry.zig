const std = @import("std");
const Entity = @import("entity.zig").Entity;
const EntityManager = @import("entity.zig").EntityManager;
const SparseSet = @import("sparse_set.zig").SparseSet;
const components = @import("components.zig");
const Scene = @import("../scene.zig").Scene;

/// Registry for managing entities and components
pub const Registry = struct {
    const Self = @This();

    /// Component storage container
    const ComponentContainer = struct {
        ptr: *anyopaque,
        vtable: *const ComponentVTable,
        type_id: u32,
    };

    /// Virtual table for type-erased component operations
    const ComponentVTable = struct {
        deinit: *const fn (ptr: *anyopaque) void,
        remove: *const fn (ptr: *anyopaque, entity: Entity) void,
        clear: *const fn (ptr: *anyopaque) void,
    };

    /// Query result for component iteration
    pub const QueryResult = struct {
        registry: *Registry,
        entity_iter: EntityManager.Iterator,
        component_mask: u64,
        exclude_mask: u64,

        pub fn next(self: *QueryResult) ?Entity {
            while (self.entity_iter.next()) |entity| {
                if (self.matches(entity)) {
                    return entity;
                }
            }
            return null;
        }

        pub fn matches(self: *const QueryResult, entity: Entity) bool {
            const entity_mask = self.registry.getEntityComponentMask(entity);
            return (entity_mask & self.component_mask) == self.component_mask and
                (entity_mask & self.exclude_mask) == 0;
        }

        pub fn reset(self: *QueryResult) void {
            self.entity_iter.reset();
        }
    };

    /// Component iterator result
    pub const ComponentIteratorResult = struct {
        id: u32,
        ptr: *anyopaque,
    };

    /// Component iterator
    pub const ComponentIterator = struct {
        registry: *const Registry,
        entity: Entity,
        current_id: u32,

        pub fn next(self: *ComponentIterator) ?ComponentIteratorResult {
            while (self.current_id < self.registry.components.items.len) {
                const id = self.current_id;
                self.current_id += 1;

                const container = self.registry.components.items[id];
                const storage = @as(*SparseSet(anyopaque), @ptrCast(@alignCast(container.ptr)));
                if (storage.has(self.entity)) {
                    if (storage.get(self.entity)) |ptr| {
                        return ComponentIteratorResult{
                            .id = id,
                            .ptr = ptr,
                        };
                    }
                }
            }
            return null;
        }
    };

    component_registry: components.ComponentRegistry,
    entity_manager: EntityManager,
    components: std.ArrayList(ComponentContainer),
    component_masks: std.AutoHashMap(u32, u64),
    allocator: std.mem.Allocator,
    scene: ?*Scene,

    /// Initialize the registry
    pub fn init(allocator: std.mem.Allocator, scene: ?*Scene) Self {
        return .{
            .component_registry = components.ComponentRegistry.init(allocator),
            .entity_manager = EntityManager.init(allocator),
            .components = std.ArrayList(ComponentContainer).init(allocator),
            .component_masks = std.AutoHashMap(u32, u64).init(allocator),
            .allocator = allocator,
            .scene = scene,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *Self) void {
        for (self.components.items) |container| {
            container.vtable.deinit(container.ptr);
        }
        self.components.deinit();
        self.component_masks.deinit();
        self.component_registry.deinit();
        self.entity_manager.deinit();
    }

    /// Create a new entity
    pub fn create(self: *Self) !Entity {
        return self.entity_manager.create();
    }

    /// Destroy an entity and all its components
    pub fn destroy(self: *Self, entity: Entity) !void {
        if (!self.entity_manager.isAlive(entity)) return;

        // Remove all components
        for (self.components.items) |container| {
            container.vtable.remove(container.ptr, entity);
        }

        try self.entity_manager.destroy(entity);
        _ = self.component_masks.remove(entity.index());
    }

    /// Register a component type
    fn registerComponent(self: *Self, comptime T: type) !u32 {
        const type_id = try self.component_registry.register(T);
        if (type_id >= self.components.items.len) {
            const storage = try self.allocator.create(SparseSet(T));
            storage.* = SparseSet(T).init(self.allocator);

            const vtable = &ComponentVTable{
                .deinit = struct {
                    fn deinit(ptr: *anyopaque) void {
                        const s = @as(*SparseSet(T), @ptrCast(@alignCast(ptr)));
                        s.deinit();
                        s.allocator.destroy(s);
                    }
                }.deinit,
                .remove = struct {
                    fn remove(ptr: *anyopaque, entity: Entity) void {
                        const s = @as(*SparseSet(T), @ptrCast(@alignCast(ptr)));
                        s.remove(entity);
                    }
                }.remove,
                .clear = struct {
                    fn clear(ptr: *anyopaque) void {
                        const s = @as(*SparseSet(T), @ptrCast(@alignCast(ptr)));
                        s.clear();
                    }
                }.clear,
            };

            try self.components.append(.{
                .ptr = storage,
                .vtable = vtable,
                .type_id = type_id,
            });
        }
        return type_id;
    }

    /// Add a component to an entity
    pub fn add(self: *Self, entity: Entity, component: anytype) !void {
        if (!self.entity_manager.isAlive(entity)) return;

        const T = @TypeOf(component);
        const type_id = try self.registerComponent(T);
        const storage = @as(*SparseSet(T), @ptrCast(@alignCast(self.components.items[type_id].ptr)));
        try storage.add(entity, component);

        // Update component mask
        var mask = self.component_masks.get(entity.index()) orelse 0;
        mask |= @as(u64, 1) << @intCast(type_id);
        try self.component_masks.put(entity.index(), mask);
    }

    /// Remove a component from an entity
    pub fn remove(self: *Self, entity: Entity, comptime T: type) void {
        if (!self.entity_manager.isAlive(entity)) return;

        if (self.component_registry.getIdByName(@typeName(T))) |type_id| {
            if (type_id < self.components.items.len) {
                const storage = @as(*SparseSet(T), @ptrCast(@alignCast(self.components.items[type_id].ptr)));
                storage.remove(entity);

                // Update component mask
                if (self.component_masks.getPtr(entity.index())) |mask| {
                    mask.* &= ~(@as(u64, 1) << @intCast(type_id));
                }
            }
        }
    }

    /// Get a component from an entity
    pub fn getComponent(self: *Self, entity: Entity, comptime T: type) ?*T {
        if (!self.entity_manager.isAlive(entity)) return null;

        if (self.component_registry.getIdByName(@typeName(T))) |type_id| {
            if (type_id < self.components.items.len) {
                const storage = @as(*SparseSet(T), @ptrCast(@alignCast(self.components.items[type_id].ptr)));
                return storage.get(entity);
            }
        }
        return null;
    }

    /// Check if an entity has a component
    pub fn hasComponent(self: *Self, entity: Entity, comptime T: type) bool {
        return if (self.getComponent(entity, T)) |_| true else false;
    }

    /// Get entity's component mask
    fn getEntityComponentMask(self: *const Self, entity: Entity) u64 {
        return self.component_masks.get(entity.index()) orelse 0;
    }

    /// Create a query for entities with specific components
    pub fn query(self: *Self, comptime Components: type) QueryResult {
        var component_mask: u64 = 0;
        const exclude_mask: u64 = 0;

        const fields = std.meta.fields(Components);
        inline for (fields) |field| {
            const type_name = @typeName(field.type);
            if (self.component_registry.getIdByName(type_name)) |type_id| {
                component_mask |= @as(u64, 1) << @intCast(type_id);
            }
        }

        return .{
            .registry = self,
            .entity_iter = self.entity_manager.iterator(),
            .component_mask = component_mask,
            .exclude_mask = exclude_mask,
        };
    }

    /// Create a query that excludes specific components
    pub fn queryExclude(self: *Self, comptime Include: type, comptime Exclude: type) QueryResult {
        var component_mask: u64 = 0;
        var exclude_mask: u64 = 0;

        const include_fields = std.meta.fields(Include);
        inline for (include_fields) |field| {
            const type_name = @typeName(field.type);
            if (self.component_registry.getIdByName(type_name)) |type_id| {
                component_mask |= @as(u64, 1) << @intCast(type_id);
            }
        }

        const exclude_fields = std.meta.fields(Exclude);
        inline for (exclude_fields) |field| {
            const type_name = @typeName(field.type);
            if (self.component_registry.getIdByName(type_name)) |type_id| {
                exclude_mask |= @as(u64, 1) << @intCast(type_id);
            }
        }

        return .{
            .registry = self,
            .entity_iter = self.entity_manager.iterator(),
            .component_mask = component_mask,
            .exclude_mask = exclude_mask,
        };
    }

    /// Clear all entities and components
    pub fn clear(self: *Self) void {
        for (self.components.items) |container| {
            container.vtable.clear(container.ptr);
        }
        self.component_masks.clearRetainingCapacity();
        self.entity_manager.clear();
    }

    /// Get the number of alive entities
    pub fn aliveCount(self: *const Self) u32 {
        return self.entity_manager.aliveCount();
    }

    /// Reserve space for entities
    pub fn reserve(self: *Self, capacity: u32) !void {
        try self.entity_manager.reserve(capacity);
    }

    /// Get an iterator over all components of an entity
    pub fn getComponentIterator(self: *const Self, entity: Entity) ComponentIterator {
        return ComponentIterator{
            .registry = self,
            .entity = entity,
            .current_id = 0,
        };
    }

    /// Add a raw component to an entity
    pub fn addRaw(self: *Self, entity: Entity, type_id: u32, component_ptr: *anyopaque) !void {
        if (!self.entity_manager.isAlive(entity)) return;

        const container = self.components.items[type_id];
        const storage = @as(*SparseSet(*anyopaque), @ptrCast(@alignCast(container.ptr)));
        try storage.add(entity, component_ptr);

        // Update component mask
        var mask = self.component_masks.get(entity.index()) orelse 0;
        mask |= @as(u64, 1) << @intCast(type_id);
        try self.component_masks.put(entity.index(), mask);
    }

    /// Ensure storage exists for a component type
    pub fn ensureStorage(self: *Self, type_id: u32) !void {
        if (type_id >= self.components.items.len) {
            const storage = try self.allocator.create(SparseSet(*anyopaque));
            storage.* = SparseSet(*anyopaque).init(self.allocator);

            const vtable = &ComponentVTable{
                .deinit = struct {
                    fn deinit(ptr: *anyopaque) void {
                        const s = @as(*SparseSet(*anyopaque), @ptrCast(@alignCast(ptr)));
                        s.deinit();
                        s.allocator.destroy(s);
                    }
                }.deinit,
                .remove = struct {
                    fn remove(ptr: *anyopaque, entity: Entity) void {
                        const s = @as(*SparseSet(*anyopaque), @ptrCast(@alignCast(ptr)));
                        s.remove(entity);
                    }
                }.remove,
                .clear = struct {
                    fn clear(ptr: *anyopaque) void {
                        const s = @as(*SparseSet(*anyopaque), @ptrCast(@alignCast(ptr)));
                        s.clear();
                    }
                }.clear,
            };

            try self.components.append(.{
                .ptr = storage,
                .vtable = vtable,
                .type_id = type_id,
            });
        }
    }
};
