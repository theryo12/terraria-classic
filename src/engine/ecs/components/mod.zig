const std = @import("std");

pub const Transform2D = @import("transform.zig").Transform2D;
pub const Sprite = @import("sprite.zig").Sprite;
pub const Text = @import("text.zig").Text;
pub const Behavior = @import("behavior.zig").Behavior;
/// Component type information for runtime type checking and reflection
pub const ComponentInfo = struct {
    id: u32,
    name: []const u8,
    size: u32,
    alignment: u32,
};

/// Component type registry for dynamic component management
pub const ComponentRegistry = struct {
    const Self = @This();

    /// Maximum number of component types
    pub const MAX_COMPONENTS: u32 = 64;

    components: std.ArrayList(ComponentInfo),
    name_map: std.StringHashMap(u32),
    allocator: std.mem.Allocator,
    next_id: u32,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .components = std.ArrayList(ComponentInfo).init(allocator),
            .name_map = std.StringHashMap(u32).init(allocator),
            .allocator = allocator,
            .next_id = 0,
        };
    }

    pub fn deinit(self: *Self) void {
        self.components.deinit();
        self.name_map.deinit();
    }

    /// Register a component with a specific ID and info
    pub fn registerWithId(self: *Self, info: ComponentInfo) !void {
        if (info.id >= MAX_COMPONENTS) {
            return error.TooManyComponents;
        }

        // Add component info
        try self.components.append(info);
        try self.name_map.put(info.name, info.id);
        self.next_id = @max(self.next_id, info.id + 1);
    }

    /// Register a component type
    pub fn register(self: *Self, comptime T: type) !u32 {
        const type_name = @typeName(T);
        if (self.name_map.get(type_name)) |id| {
            return id;
        }

        if (self.next_id >= MAX_COMPONENTS) {
            return error.TooManyComponents;
        }

        const id = self.next_id;
        const info = ComponentInfo{
            .id = id,
            .name = type_name,
            .size = @sizeOf(T),
            .alignment = @alignOf(T),
        };

        try self.components.append(info);
        try self.name_map.put(type_name, id);
        self.next_id += 1;

        return id;
    }

    pub fn getInfo(self: Self, id: u32) ?ComponentInfo {
        if (id >= self.components.items.len) return null;
        return self.components.items[id];
    }

    pub fn getIdByName(self: *const Self, name: []const u8) ?u32 {
        return self.name_map.get(name);
    }
};
