const rl = @import("raylib");

/// Component for rendering text
pub const Text = struct {
    /// Text content to display
    content: []const u8,
    /// Font to use for rendering
    font: rl.Font,
    /// Font size in pixels
    font_size: f32 = 20,
    /// Text color
    color: rl.Color = rl.Color.white,
    /// Letter spacing
    spacing: f32 = 1,
};
