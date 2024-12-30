const std = @import("std");
const rl = @import("raylib");

pub const GameConfig = struct {
    window: WindowConfig = .{},
    graphics: GraphicsConfig = .{},
    audio: AudioConfig = .{},
    input: InputConfig = .{},
};

pub const WindowConfig = struct {
    pub const width: i32 = 800;
    pub const height: i32 = 600;
    pub const title: [:0]const u8 = "Terraria Classic";
    pub const target_fps: i32 = 60;
    pub const resizable: bool = true;
    pub const fullscreen: bool = false;
    pub const vsync: bool = true;
    pub const min_width: i32 = 640;
    pub const min_height: i32 = 480;
};

pub const GraphicsConfig = struct {
    background_color: rl.Color = rl.Color.black,
    msaa_4x: bool = true,
};

pub const AudioConfig = struct {
    master_volume: f32 = 1.0,
    music_volume: f32 = 1.0,
    sfx_volume: f32 = 1.0,
    sample_rate: i32 = 48000,
};

pub const InputConfig = struct {
    exit_key: rl.KeyboardKey = .key_escape,
    gamepad_enabled: bool = true,
};

/// Load configuration from a file
pub fn loadConfig(allocator: std.mem.Allocator, path: []const u8) !GameConfig {
    _ = allocator;
    _ = path;
    // TODO: Implement config loading from file
    return GameConfig{};
}

/// Save configuration to a file
pub fn saveConfig(config: GameConfig, allocator: std.mem.Allocator, path: []const u8) !void {
    _ = config;
    _ = allocator;
    _ = path;
    // TODO: Implement config saving to file
}

/// Get default configuration
pub fn getDefaultConfig() GameConfig {
    return GameConfig{};
}
