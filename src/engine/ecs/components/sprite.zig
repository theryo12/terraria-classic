const std = @import("std");
const rl = @import("raylib");

/// Component for rendering 2D sprites
pub const Sprite = struct {
    /// The texture to render
    texture: rl.Texture2D,
    /// The source rectangle in the texture
    source_rect: rl.Rectangle,
    /// The origin point for rotation/scale
    origin: rl.Vector2,
    /// The tint color
    tint: rl.Color = rl.Color.white,
    /// The opacity (0.0 to 1.0)
    opacity: f32 = 1.0,
    /// The sprite's scale
    scale: rl.Vector2 = .{ .x = 1.0, .y = 1.0 },
    /// The render layer (higher numbers render on top)
    layer: i32 = 0,
};
