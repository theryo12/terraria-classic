const std = @import("std");
const ecs = @import("../mod.zig");
const Behavior = @import("../components/behavior.zig").Behavior;

/// System for handling entity behaviors
pub const BehaviorSystem = struct {
    base: ecs.System,
    allocator: std.mem.Allocator,

    const vtable = ecs.System.VTable{
        .update = BehaviorSystem.update,
        .init = BehaviorSystem.init,
        .deinit = BehaviorSystem.deinit,
        .draw = BehaviorSystem.draw,
    };

    pub fn create(registry: *ecs.Registry, allocator: std.mem.Allocator) !*BehaviorSystem {
        const self = try allocator.create(BehaviorSystem);
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
        const self: *BehaviorSystem = @ptrCast(@alignCast(system_base));

        const Components = struct {
            behavior: Behavior,
        };
        var view = self.base.registry.query(Components);

        while (view.next()) |entity| {
            if (self.base.registry.getComponent(entity, Behavior)) |behavior| {
                if (behavior.on_update) |update_fn| {
                    update_fn(entity, self.base.registry, delta_time);
                }
            }
        }
    }

    fn draw(system_base: *ecs.System) void {
        const self: *BehaviorSystem = @ptrCast(@alignCast(system_base));

        const Components = struct {
            behavior: Behavior,
        };
        var view = self.base.registry.query(Components);

        while (view.next()) |entity| {
            if (self.base.registry.getComponent(entity, Behavior)) |behavior| {
                if (behavior.on_draw) |draw_fn| {
                    draw_fn(entity, self.base.registry);
                }
            }
        }
    }

    fn deinit(system_base: *ecs.System) void {
        const self: *BehaviorSystem = @ptrCast(@alignCast(system_base));
        self.allocator.destroy(self);
    }
};
