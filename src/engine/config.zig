const std = @import("std");
const rl = @import("raylib");
const HjsonParser = @import("utils/hjson.zig").HjsonParser;

pub const WindowConfig = struct {
    width: i32 = 800,
    height: i32 = 600,
    title: [:0]const u8 = "Terraria Classic",
    target_fps: i32 = 60,
    resizable: bool = true,
    fullscreen: bool = false,
    min_width: i32 = 640,
    min_height: i32 = 480,
};

pub const GraphicsConfig = struct {
    background_color: rl.Color = rl.Color.black,
    msaa_4x: bool = true,
    vsync: bool = true,
};

pub const AudioConfig = struct {
    pub const VolumeConfig = struct {
        master: f32 = 0.0,
        music: f32 = 0.0,
        sfx: f32 = 0.0,
    };

    volume: VolumeConfig = .{},
    sample_rate: i32 = 48000,
};

pub const InputConfig = struct {
    exit_key: rl.KeyboardKey = .key_escape,
    gamepad_enabled: bool = true,
};

pub const GameConfig = struct {
    window: WindowConfig = .{},
    graphics: GraphicsConfig = .{},
    audio: AudioConfig = .{},
    input: InputConfig = .{},
};

/// Load configuration from a file
pub fn loadConfig(allocator: std.mem.Allocator, path: []const u8) !GameConfig {
    const file_contents = try std.fs.cwd().readFileAlloc(allocator, path, 1024 * 1024);
    defer allocator.free(file_contents);

    var config = GameConfig{};
    var parser = HjsonParser.init(allocator);
    defer parser.deinit();

    var lines = std.mem.splitScalar(u8, file_contents, '\n');
    while (lines.next()) |line| {
        if (try parser.parseLine(line)) |kv| {
            const section = try parser.getCurrentSection();

            if (std.mem.eql(u8, section, ".window")) {
                if (std.mem.eql(u8, kv.key, "width")) {
                    config.window.width = try std.fmt.parseInt(i32, kv.value, 10);
                } else if (std.mem.eql(u8, kv.key, "height")) {
                    config.window.height = try std.fmt.parseInt(i32, kv.value, 10);
                } else if (std.mem.eql(u8, kv.key, "fullscreen")) {
                    config.window.fullscreen = std.mem.eql(u8, kv.value, "true");
                } else if (std.mem.eql(u8, kv.key, "resizable")) {
                    config.window.resizable = std.mem.eql(u8, kv.value, "true");
                }
            } else if (std.mem.eql(u8, section, ".graphics")) {
                if (std.mem.eql(u8, kv.key, "msaa_4x")) {
                    config.graphics.msaa_4x = std.mem.eql(u8, kv.value, "true");
                } else if (std.mem.eql(u8, kv.key, "vsync")) {
                    config.graphics.vsync = std.mem.eql(u8, kv.value, "true");
                }
            } else if (std.mem.eql(u8, section, ".audio.volume")) {
                if (std.mem.eql(u8, kv.key, "master")) {
                    config.audio.volume.master = try std.fmt.parseFloat(f32, kv.value);
                } else if (std.mem.eql(u8, kv.key, "music")) {
                    config.audio.volume.music = try std.fmt.parseFloat(f32, kv.value);
                } else if (std.mem.eql(u8, kv.key, "sfx")) {
                    config.audio.volume.sfx = try std.fmt.parseFloat(f32, kv.value);
                }
            } else if (std.mem.eql(u8, section, ".audio")) {
                if (std.mem.eql(u8, kv.key, "sample_rate")) {
                    config.audio.sample_rate = try std.fmt.parseInt(i32, kv.value, 10);
                }
            } else if (std.mem.eql(u8, section, ".input")) {
                if (std.mem.eql(u8, kv.key, "exit_key")) {
                    const key_value = try std.fmt.parseInt(i32, kv.value, 10);
                    config.input.exit_key = @enumFromInt(key_value);
                } else if (std.mem.eql(u8, kv.key, "gamepad_enabled")) {
                    config.input.gamepad_enabled = std.mem.eql(u8, kv.value, "true");
                }
            }
        }
    }

    return config;
}

/// Save configuration to a file
pub fn saveConfig(config: GameConfig, allocator: std.mem.Allocator, path: []const u8) !void {
    var json_string = std.ArrayList(u8).init(allocator);
    defer json_string.deinit();

    const writer = json_string.writer();
    try writer.writeAll("{\n");

    // Write window config
    try writer.writeAll("  window: {\n");
    try writer.print("    width: {d}\n", .{config.window.width});
    try writer.print("    height: {d}\n", .{config.window.height});
    try writer.print("    fullscreen: {}\n", .{config.window.fullscreen});
    try writer.print("    resizable: {}\n", .{config.window.resizable});
    try writer.writeAll("  }\n\n");

    // Write graphics config
    try writer.writeAll("  graphics: {\n");
    try writer.print("    msaa_4x: {}\n", .{config.graphics.msaa_4x});
    try writer.print("    vsync: {}\n", .{config.graphics.vsync});
    try writer.writeAll("  }\n\n");

    // Write audio config
    try writer.writeAll("  audio: {\n");
    try writer.writeAll("    volume: {\n");
    try writer.print("      master: {d}\n", .{config.audio.volume.master});
    try writer.print("      music: {d}\n", .{config.audio.volume.music});
    try writer.print("      sfx: {d}\n", .{config.audio.volume.sfx});
    try writer.writeAll("    }\n");
    try writer.print("    sample_rate: {d}\n", .{config.audio.sample_rate});
    try writer.writeAll("  }\n\n");

    // Write input config
    try writer.writeAll("  input: {\n");
    try writer.print("    exit_key: {d}\n", .{@intFromEnum(config.input.exit_key)});
    try writer.print("    gamepad_enabled: {}\n", .{config.input.gamepad_enabled});
    try writer.writeAll("  }\n");

    try writer.writeAll("}\n");

    // Write to file
    try std.fs.cwd().writeFile(.{ .sub_path = path, .data = json_string.items });
}

/// Get default configuration
pub fn getDefaultConfig() GameConfig {
    return GameConfig{};
}
