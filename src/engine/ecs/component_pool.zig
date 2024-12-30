const std = @import("std");

pub fn ComponentPool(comptime T: type) type {
    return struct {
        const Self = @This();
        const ChunkSize = 1024;

        allocator: std.mem.Allocator,
        chunks: std.ArrayList([]T),
        free_list: std.ArrayList(usize),
        total_count: usize,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .allocator = allocator,
                .chunks = std.ArrayList([]T).init(allocator),
                .free_list = std.ArrayList(usize).init(allocator),
                .total_count = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            for (self.chunks.items) |chunk| {
                self.allocator.free(chunk);
            }
            self.chunks.deinit();
            self.free_list.deinit();
        }

        pub fn create(self: *Self) !*T {
            // Check free list first
            if (self.free_list.items.len > 0) {
                const index = self.free_list.pop();
                const chunk_index = index / ChunkSize;
                const item_index = index % ChunkSize;
                return &self.chunks.items[chunk_index][item_index];
            }

            // Need to allocate new chunk?
            const chunk_index = self.total_count / ChunkSize;
            const item_index = self.total_count % ChunkSize;

            if (chunk_index >= self.chunks.items.len) {
                const new_chunk = try self.allocator.alloc(T, ChunkSize);
                try self.chunks.append(new_chunk);
            }

            self.total_count += 1;
            return &self.chunks.items[chunk_index][item_index];
        }

        pub fn destroy(self: *Self, item: *T) !void {
            // Find the chunk and index
            const item_ptr = @intFromPtr(item);
            var found_index: ?usize = null;

            for (self.chunks.items, 0..) |chunk, chunk_index| {
                const chunk_start = @intFromPtr(&chunk[0]);
                const chunk_end = chunk_start + (ChunkSize * @sizeOf(T));

                if (item_ptr >= chunk_start and item_ptr < chunk_end) {
                    const item_index = (item_ptr - chunk_start) / @sizeOf(T);
                    found_index = chunk_index * ChunkSize + item_index;
                    break;
                }
            }

            if (found_index) |index| {
                try self.free_list.append(index);
            }
        }
    };
}
