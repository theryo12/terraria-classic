const std = @import("std");
const config = @import("../config.zig");
const Engine = @import("../engine.zig").Engine;

pub const SettingsManager = struct {
    allocator: std.mem.Allocator,
    settings_path: []const u8,
    last_modified: i128,
    last_content_hash: u64,
    game_config: config.GameConfig,
    watcher_thread: ?std.Thread = null,
    should_stop: std.atomic.Value(bool),
    sleep_duration: u64, // nanoseconds
    check_interval: u64 = std.time.ns_per_s, // 1 second default
    min_check_interval: u64 = std.time.ns_per_s, // 1 second minimum
    max_check_interval: u64 = 5 * std.time.ns_per_s, // 5 seconds maximum
    consecutive_no_changes: u32 = 0,
    engine: ?*Engine = null,

    pub fn init(allocator: std.mem.Allocator, settings_path: []const u8) !*SettingsManager {
        const self = try allocator.create(SettingsManager);
        errdefer allocator.destroy(self);

        self.* = .{
            .allocator = allocator,
            .settings_path = try allocator.dupe(u8, settings_path),
            .last_modified = 0,
            .last_content_hash = 0,
            .game_config = undefined,
            .should_stop = std.atomic.Value(bool).init(false),
            .sleep_duration = std.time.ns_per_s,
            .engine = null,
        };
        errdefer self.allocator.free(self.settings_path);

        // Create default settings file if it doesn't exist
        if (!try fileExists(settings_path)) {
            self.game_config = config.getDefaultConfig();
            try config.saveConfig(self.game_config, allocator, settings_path);
        }

        try self.loadSettings();
        try self.startWatcher();
        return self;
    }

    pub fn deinit(self: *SettingsManager) void {
        if (self.watcher_thread != null) {
            self.should_stop.store(true, .seq_cst);
            self.watcher_thread.?.join();
        }
        self.allocator.free(self.settings_path);
        self.allocator.destroy(self);
    }

    pub fn setEngine(self: *SettingsManager, engine: *Engine) void {
        self.engine = engine;
    }

    fn fileExists(path: []const u8) !bool {
        std.fs.cwd().access(path, .{}) catch |err| {
            return switch (err) {
                error.FileNotFound => false,
                else => err,
            };
        };
        return true;
    }

    fn getFileHash(bytes: []const u8) u64 {
        var hasher = std.hash.Wyhash.init(0);
        hasher.update(bytes);
        return hasher.final();
    }

    fn loadSettings(self: *SettingsManager) !void {
        const stat = try std.fs.cwd().statFile(self.settings_path);
        const file_contents = try std.fs.cwd().readFileAlloc(self.allocator, self.settings_path, 1024 * 1024);
        defer self.allocator.free(file_contents);

        const content_hash = getFileHash(file_contents);

        // Only reload if content actually changed
        if (content_hash != self.last_content_hash) {
            self.last_modified = stat.mtime;
            self.last_content_hash = content_hash;
            self.game_config = try config.loadConfig(self.allocator, self.settings_path);

            // Notify engine of config changes
            if (self.engine) |engine| {
                engine.updateConfig(self.game_config);
            }
        }
    }

    fn watcherThread(self: *SettingsManager) void {
        while (!self.should_stop.load(.seq_cst)) {
            std.time.sleep(self.sleep_duration);

            const stat = std.fs.cwd().statFile(self.settings_path) catch continue;

            if (stat.mtime != self.last_modified) {
                self.loadSettings() catch continue;

                // Reset sleep duration on change
                self.sleep_duration = self.min_check_interval;
                self.consecutive_no_changes = 0;
            } else {
                // Gradually increase sleep duration if no changes
                self.consecutive_no_changes += 1;
                if (self.consecutive_no_changes > 5) {
                    self.sleep_duration = @min(self.sleep_duration * 2, self.max_check_interval);
                }
            }
        }
    }

    fn startWatcher(self: *SettingsManager) !void {
        self.watcher_thread = try std.Thread.spawn(.{}, watcherThread, .{self});
    }

    pub fn getConfig(self: *const SettingsManager) config.GameConfig {
        return self.game_config;
    }
};
