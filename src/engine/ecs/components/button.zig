const std = @import("std");
const rl = @import("raylib");
const ecs = @import("../mod.zig");
const Text = @import("text.zig").Text;

/// Button states for animation and interaction
pub const ButtonState = enum {
    normal,
    hover,
    pressed,
};

/// Button event types
pub const ButtonEvent = enum {
    hover_start,
    hover_end,
    click_start,
    click_end,
    click,
};

/// Button event callback type
pub const ButtonCallback = *const fn (entity: ecs.Entity, event: ButtonEvent, user_data: ?*anyopaque) void;

/// Button component for interactive text buttons
pub const Button = struct {
    /// Normal color
    normal_color: rl.Color = rl.Color.white,
    /// Hover color
    hover_color: rl.Color = rl.Color.yellow,
    /// Current button state
    state: ButtonState = .normal,
    /// Animation progress (0.0 to 1.0)
    animation_progress: f32 = 0.0,
    /// Animation speed (seconds)
    animation_speed: f32 = 0.2,
    /// Scale factor when hovered
    hover_scale: f32 = 1.2,
    /// Event callback
    on_event: ?ButtonCallback = null,
    /// Whether the button was pressed last frame
    was_pressed: bool = false,
    /// Custom user data that will be passed to the callback
    user_data: ?*anyopaque = null,

    /// Get the bounds of the button for collision detection
    pub fn getBounds(self: *const Button, position: rl.Vector2, text: *const Text) rl.Rectangle {
        _ = self; // self is unused since we only need the text component for measurements
        const text_size = rl.measureTextEx(text.font, @ptrCast(text.content), text.font_size, text.spacing);
        return .{
            .x = position.x - text_size.x / 2,
            .y = position.y - text_size.y / 2,
            .width = text_size.x,
            .height = text_size.y,
        };
    }

    /// Calculate current color based on animation progress
    pub fn getCurrentColor(self: *const Button) rl.Color {
        return rl.Color{
            .r = @as(u8, @intFromFloat(@as(f32, @floatFromInt(self.normal_color.r)) + ((@as(f32, @floatFromInt(self.hover_color.r)) - @as(f32, @floatFromInt(self.normal_color.r))) * self.animation_progress))),
            .g = @as(u8, @intFromFloat(@as(f32, @floatFromInt(self.normal_color.g)) + ((@as(f32, @floatFromInt(self.hover_color.g)) - @as(f32, @floatFromInt(self.normal_color.g))) * self.animation_progress))),
            .b = @as(u8, @intFromFloat(@as(f32, @floatFromInt(self.normal_color.b)) + ((@as(f32, @floatFromInt(self.hover_color.b)) - @as(f32, @floatFromInt(self.normal_color.b))) * self.animation_progress))),
            .a = @as(u8, @intFromFloat(@as(f32, @floatFromInt(self.normal_color.a)) + ((@as(f32, @floatFromInt(self.hover_color.a)) - @as(f32, @floatFromInt(self.normal_color.a))) * self.animation_progress))),
        };
    }

    /// Calculate current font size based on animation progress
    pub fn getCurrentFontSize(self: *const Button, base_font_size: f32) f32 {
        const scale_factor = 1.0 + (self.hover_scale - 1.0) * self.animation_progress;
        return base_font_size * scale_factor;
    }

    /// Trigger an event callback if one is set
    pub fn triggerEvent(self: *const Button, entity: ecs.Entity, event: ButtonEvent) void {
        if (self.on_event) |callback| {
            callback(entity, event, self.user_data);
        }
    }
};
