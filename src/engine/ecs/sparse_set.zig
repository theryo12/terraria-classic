const std = @import("std");
const Entity = @import("entity.zig").Entity;

/// Sparse set implementation for component storage
pub fn SparseSet(comptime T: type) type {
    return struct {
        const Self = @This();

        /// Page size for sparse array to reduce memory usage
        const PAGE_SIZE: u32 = 1024;
        /// Number of bits for page index
        const PAGE_BITS: u32 = 10;
        /// Mask for extracting offset within page
        const OFFSET_MASK: u32 = PAGE_SIZE - 1;

        /// Sparse array implemented as pages to save memory
        sparse_pages: std.ArrayList([]u32),
        /// Dense array of entity indices
        dense: std.ArrayList(u32),
        /// Component data array
        data: std.ArrayList(T),
        /// Memory allocator
        allocator: std.mem.Allocator,
        /// Number of components
        len: u32,

        /// Initialize a new sparse set
        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .sparse_pages = std.ArrayList([]u32).init(allocator),
                .dense = std.ArrayList(u32).init(allocator),
                .data = std.ArrayList(T).init(allocator),
                .allocator = allocator,
                .len = 0,
            };
        }

        /// Clean up resources
        pub fn deinit(self: *Self) void {
            for (self.sparse_pages.items) |page| {
                self.allocator.free(page);
            }
            self.sparse_pages.deinit();
            self.dense.deinit();
            self.data.deinit();
        }

        /// Get the page and offset for an entity index
        fn getPageAndOffset(entity_index: u32) struct { page: u32, offset: u32 } {
            return .{
                .page = entity_index >> PAGE_BITS,
                .offset = entity_index & OFFSET_MASK,
            };
        }

        /// Ensure page exists for entity index
        fn ensurePage(self: *Self, page_index: u32) !void {
            while (page_index >= self.sparse_pages.items.len) {
                const new_page = try self.allocator.alloc(u32, PAGE_SIZE);
                @memset(new_page, std.math.maxInt(u32));
                try self.sparse_pages.append(new_page);
            }
        }

        /// Add a component to an entity
        pub fn add(self: *Self, entity: Entity, component: T) !void {
            const entity_index = entity.index();
            const page_info = getPageAndOffset(entity_index);

            try self.ensurePage(page_info.page);

            // Check if entity already has component
            const dense_index = self.sparse_pages.items[page_info.page][page_info.offset];
            if (dense_index < self.len and self.dense.items[dense_index] == entity_index) {
                self.data.items[dense_index] = component;
                return;
            }

            // Add new component
            try self.dense.append(entity_index);
            try self.data.append(component);
            self.sparse_pages.items[page_info.page][page_info.offset] = self.len;
            self.len += 1;
        }

        /// Remove a component from an entity
        pub fn remove(self: *Self, entity: Entity) void {
            const entity_index = entity.index();
            const page_info = getPageAndOffset(entity_index);

            if (page_info.page >= self.sparse_pages.items.len) return;

            const dense_index = self.sparse_pages.items[page_info.page][page_info.offset];
            if (dense_index >= self.len) return;
            if (self.dense.items[dense_index] != entity_index) return;

            // Move last element to the removed position
            const last_dense_index = self.len - 1;
            const last_entity_index = self.dense.items[last_dense_index];
            const last_page_info = getPageAndOffset(last_entity_index);

            // Update dense arrays
            self.dense.items[dense_index] = last_entity_index;
            self.data.items[dense_index] = self.data.items[last_dense_index];

            // Update sparse array
            self.sparse_pages.items[last_page_info.page][last_page_info.offset] = dense_index;
            self.sparse_pages.items[page_info.page][page_info.offset] = std.math.maxInt(u32);

            _ = self.dense.pop();
            _ = self.data.pop();
            self.len -= 1;
        }

        /// Get a component for an entity
        pub fn get(self: *const Self, entity: Entity) ?*T {
            const entity_index = entity.index();
            const page_info = getPageAndOffset(entity_index);

            if (page_info.page >= self.sparse_pages.items.len) return null;

            const dense_index = self.sparse_pages.items[page_info.page][page_info.offset];
            if (dense_index >= self.len) return null;
            if (self.dense.items[dense_index] != entity_index) return null;

            return &self.data.items[dense_index];
        }

        /// Check if an entity has a component
        pub fn has(self: *const Self, entity: Entity) bool {
            const entity_index = entity.index();
            const page_info = getPageAndOffset(entity_index);

            if (page_info.page >= self.sparse_pages.items.len) return false;

            const dense_index = self.sparse_pages.items[page_info.page][page_info.offset];
            if (dense_index >= self.len) return false;
            return self.dense.items[dense_index] == entity_index;
        }

        /// Get raw access to component data
        pub fn raw(self: *Self) []T {
            return self.data.items[0..self.len];
        }

        /// Get raw access to entity indices
        pub fn entities(self: *Self) []u32 {
            return self.dense.items[0..self.len];
        }

        /// Clear all components
        pub fn clear(self: *Self) void {
            for (self.sparse_pages.items) |page| {
                @memset(page, std.math.maxInt(u32));
            }
            self.dense.clearRetainingCapacity();
            self.data.clearRetainingCapacity();
            self.len = 0;
        }

        /// Reserve space for components
        pub fn reserve(self: *Self, capacity: u32) !void {
            try self.dense.ensureTotalCapacity(capacity);
            try self.data.ensureTotalCapacity(capacity);
        }

        /// Get the number of components
        pub fn count(self: Self) u32 {
            return self.len;
        }

        /// Iterator for components
        pub const Iterator = struct {
            sparse_set: *const Self,
            index: u32,

            pub fn next(self: *Iterator) ?struct { entity: Entity, component: *T } {
                if (self.index >= self.sparse_set.len) return null;
                const result = .{
                    .entity = Entity.init(self.sparse_set.dense.items[self.index], 0),
                    .component = &self.sparse_set.data.items[self.index],
                };
                self.index += 1;
                return result;
            }
        };

        /// Get an iterator over components
        pub fn iterator(self: *const Self) Iterator {
            return .{
                .sparse_set = self,
                .index = 0,
            };
        }
    };
}
