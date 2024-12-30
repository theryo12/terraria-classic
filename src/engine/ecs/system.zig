const std = @import("std");
const Registry = @import("registry.zig").Registry;

pub const SystemPriority = enum(u8) {
    lowest = 0,
    low = 64,
    normal = 128,
    high = 192,
    highest = 255,
};

pub const System = struct {
    const Self = @This();

    registry: *Registry,
    allocator: std.mem.Allocator,
    priority: SystemPriority = .normal,
    dependencies: std.ArrayList(*System),
    enabled: bool = true,

    pub fn init(registry: *Registry, allocator: std.mem.Allocator) !Self {
        return Self{
            .registry = registry,
            .allocator = allocator,
            .dependencies = std.ArrayList(*System).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.dependencies.deinit();
    }

    pub fn addDependency(self: *Self, dependency: *System) !void {
        try self.dependencies.append(dependency);
    }

    pub fn update(self: *Self, delta_time: f32) !void {
        if (!self.enabled) return;

        // Update dependencies first
        for (self.dependencies.items) |dep| {
            try dep.update(delta_time);
        }

        try self.onUpdate(delta_time);
    }

    pub fn draw(self: *Self) void {
        if (!self.enabled) return;

        // Draw dependencies first
        for (self.dependencies.items) |dep| {
            dep.draw();
        }

        self.onDraw();
    }

    // Virtual methods to be overridden by concrete systems
    pub fn onUpdate(self: *Self, delta_time: f32) !void {
        _ = self;
        _ = delta_time;
    }

    pub fn onDraw(self: *Self) void {
        _ = self;
    }
};
