const std = @import("std");
const rl = @import("raylib");
const config = @import("config.zig");

pub const WindowMode = enum {
    windowed,
    borderless,
    fullscreen,
};

pub const WindowState = struct {
    width: i32,
    height: i32,
    mode: WindowMode,
    vsync: bool,
    previous_pos: rl.Vector2,
    previous_size: rl.Vector2,
};

pub const Window = struct {
    const Self = @This();

    state: WindowState,
    on_resize: ?*const fn (i32, i32) void,

    pub fn init() Self {
        const conf = config.WindowConfig;

        if (conf.vsync) {
            rl.setConfigFlags(.{ .vsync_hint = true });
        }

        rl.initWindow(conf.width, conf.height, conf.title);
        rl.setTargetFPS(conf.target_fps);
        rl.setWindowMinSize(conf.min_width, conf.min_height);

        return Self{
            .state = .{
                .width = conf.width,
                .height = conf.height,
                .mode = .windowed,
                .vsync = conf.vsync,
                .previous_pos = .{ .x = 0, .y = 0 },
                .previous_size = .{
                    .x = @floatFromInt(conf.width),
                    .y = @floatFromInt(conf.height),
                },
            },
            .on_resize = null,
        };
    }

    pub fn deinit(_: *Self) void {
        rl.closeWindow();
    }

    pub fn setMode(self: *Self, mode: WindowMode) void {
        if (self.state.mode == mode) return;

        switch (mode) {
            .windowed => {
                if (self.state.mode == .fullscreen) {
                    rl.toggleFullscreen();
                }
                rl.setWindowState(.window_undecorated);
                rl.setWindowPosition(
                    @intFromFloat(self.state.previous_pos.x),
                    @intFromFloat(self.state.previous_pos.y),
                );
                rl.setWindowSize(
                    @intFromFloat(self.state.previous_size.x),
                    @intFromFloat(self.state.previous_size.y),
                );
            },
            .borderless => {
                if (self.state.mode == .fullscreen) {
                    rl.toggleFullscreen();
                }
                // Store current position and size
                self.state.previous_pos = .{
                    .x = @floatFromInt(rl.getWindowPosition().x),
                    .y = @floatFromInt(rl.getWindowPosition().y),
                };
                self.state.previous_size = .{
                    .x = @floatFromInt(rl.getScreenWidth()),
                    .y = @floatFromInt(rl.getScreenHeight()),
                };
                // Make borderless
                rl.setWindowState(.window_undecorated);
                rl.setWindowState(.window_maximized);
            },
            .fullscreen => {
                if (self.state.mode != .fullscreen) {
                    // Store current position and size if coming from windowed
                    if (self.state.mode == .windowed) {
                        self.state.previous_pos = .{
                            .x = @floatFromInt(rl.getWindowPosition().x),
                            .y = @floatFromInt(rl.getWindowPosition().y),
                        };
                        self.state.previous_size = .{
                            .x = @floatFromInt(rl.getScreenWidth()),
                            .y = @floatFromInt(rl.getScreenHeight()),
                        };
                    }
                    rl.toggleFullscreen();
                }
            },
        }

        self.state.mode = mode;
    }

    pub fn toggleFullscreen(self: *Self) void {
        if (self.state.mode == .fullscreen) {
            self.setMode(.windowed);
        } else {
            self.setMode(.fullscreen);
        }
    }

    pub fn setVsync(self: *Self, enabled: bool) void {
        if (self.state.vsync == enabled) return;
        rl.setConfigFlags(.{ .vsync_hint = enabled });
        self.state.vsync = enabled;
    }

    pub fn update(self: *Self) void {
        const new_width = rl.getScreenWidth();
        const new_height = rl.getScreenHeight();

        if (new_width != self.state.width or new_height != self.state.height) {
            self.state.width = new_width;
            self.state.height = new_height;

            if (self.on_resize) |callback| {
                callback(new_width, new_height);
            }
        }
    }

    pub fn getSize(self: *const Self) rl.Vector2 {
        return .{
            .x = @floatFromInt(self.state.width),
            .y = @floatFromInt(self.state.height),
        };
    }
};
