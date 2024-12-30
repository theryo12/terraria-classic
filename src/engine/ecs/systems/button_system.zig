const std = @import("std");
const rl = @import("raylib");
const ecs = @import("../mod.zig");
const System = @import("system.zig").System;
const Button = @import("../components/button.zig").Button;
const ButtonState = @import("../components/button.zig").ButtonState;
const ButtonEvent = @import("../components/button.zig").ButtonEvent;
const Transform2D = @import("../components/transform.zig").Transform2D;
const Text = @import("../components/text.zig").Text;

const Components = struct {
    transform: Transform2D,
    button: Button,
    text: Text,
};

pub const ButtonSystem = struct {
    base: System,
    allocator: std.mem.Allocator,

    const vtable = System.VTable{
        .update = update,
        .init = init,
        .deinit = deinit,
        .draw = draw,
    };

    pub fn create(registry: *ecs.Registry, allocator: std.mem.Allocator) !*ButtonSystem {
        const self = try allocator.create(ButtonSystem);
        self.* = .{
            .base = .{
                .vtable = &vtable,
                .registry = registry,
            },
            .allocator = allocator,
        };
        return self;
    }

    fn init(system_base: *System) void {
        _ = system_base;
    }

    fn update(system_base: *System, delta_time: f32) void {
        const self: *ButtonSystem = @ptrCast(@alignCast(system_base));
        const mouse_pos = rl.getMousePosition();

        var view = self.base.registry.query(Components);

        while (view.next()) |entity| {
            const transform = self.base.registry.getComponent(entity, Transform2D) orelse continue;
            const button = self.base.registry.getComponent(entity, Button) orelse continue;
            const text = self.base.registry.getComponent(entity, Text) orelse continue;

            // Get button bounds for collision detection
            const bounds = button.*.getBounds(.{ .x = transform.*.position.x, .y = transform.*.position.y }, text);
            const is_hovered = rl.checkCollisionPointRec(mouse_pos, bounds);
            const is_pressed = is_hovered and rl.isMouseButtonDown(.mouse_button_left);
            const is_clicked = is_hovered and rl.isMouseButtonReleased(.mouse_button_left);

            // Update button state and trigger events
            switch (button.*.state) {
                .normal => {
                    if (is_hovered) {
                        button.*.state = .hover;
                        button.*.triggerEvent(entity, .hover_start);
                    }
                },
                .hover => {
                    if (!is_hovered) {
                        button.*.state = .normal;
                        button.*.triggerEvent(entity, .hover_end);
                    } else if (is_pressed) {
                        button.*.state = .pressed;
                        button.*.triggerEvent(entity, .click_start);
                    }
                },
                .pressed => {
                    if (!is_pressed) {
                        button.*.state = if (is_hovered) .hover else .normal;
                        button.*.triggerEvent(entity, .click_end);
                        if (is_clicked) {
                            button.*.triggerEvent(entity, .click);
                        }
                    }
                },
            }

            // Update animation progress
            const target_progress: f32 = if (button.*.state == .normal) 0.0 else 1.0;
            if (button.*.animation_progress < target_progress) {
                button.*.animation_progress = @min(button.*.animation_progress + delta_time / button.*.animation_speed, 1.0);
            } else if (button.*.animation_progress > target_progress) {
                button.*.animation_progress = @max(button.*.animation_progress - delta_time / button.*.animation_speed, 0.0);
            }
        }
    }

    fn draw(system_base: *System) void {
        const self: *ButtonSystem = @ptrCast(@alignCast(system_base));

        var view = self.base.registry.query(Components);

        while (view.next()) |entity| {
            const transform = self.base.registry.getComponent(entity, Transform2D) orelse continue;
            const button = self.base.registry.getComponent(entity, Button) orelse continue;
            const text = self.base.registry.getComponent(entity, Text) orelse continue;

            const font_size = button.*.getCurrentFontSize(text.font_size);
            const color = button.*.getCurrentColor();
            const text_size = rl.measureTextEx(text.font, @ptrCast(text.content), font_size, text.spacing);

            // Draw text centered at position
            rl.drawTextEx(
                text.font,
                @ptrCast(text.content),
                .{
                    .x = transform.*.position.x - text_size.x / 2,
                    .y = transform.*.position.y - text_size.y / 2,
                },
                font_size,
                text.spacing,
                color,
            );
        }
    }

    fn deinit(system_base: *System) void {
        const self: *ButtonSystem = @ptrCast(@alignCast(system_base));
        self.allocator.destroy(self);
    }
};
