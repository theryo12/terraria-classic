const std = @import("std");
const rl = @import("raylib");

pub const ResourceError = error{
    FileNotFound,
    LoadError,
    InvalidResource,
    ResourceNotFound,
    OutOfMemory,
};

pub const ResourceType = enum {
    texture,
    font,
    sound,
    music,
};

pub const ResourceManager = struct {
    const Self = @This();
    const ResourceMap = std.StringHashMap(Resource);

    allocator: std.mem.Allocator,
    resources: ResourceMap,
    base_path: []const u8,

    pub fn init(allocator: std.mem.Allocator, base_path: []const u8) !Self {
        // Ensure resources directory exists
        std.fs.cwd().makePath(base_path) catch |err| {
            if (err != error.PathAlreadyExists) {
                return ResourceError.FileNotFound;
            }
        };

        return Self{
            .allocator = allocator,
            .resources = ResourceMap.init(allocator),
            .base_path = try allocator.dupe(u8, base_path),
        };
    }

    pub fn deinit(self: *Self) void {
        var iter = self.resources.iterator();
        while (iter.next()) |entry| {
            // Free the stored path key
            self.allocator.free(entry.key_ptr.*);
            // Free the resource
            entry.value_ptr.deinit();
        }
        self.resources.deinit();
        self.allocator.free(self.base_path);
    }

    pub fn loadTexture(self: *Self, path: []const u8) !rl.Texture2D {
        // Check if already loaded
        if (self.resources.get(path)) |resource| {
            if (resource.resource_type != .texture) return ResourceError.InvalidResource;
            return resource.data.texture;
        }

        // Build full path
        const full_path = try std.fmt.allocPrintZ(self.allocator, "{s}/{s}", .{ self.base_path, path });
        defer self.allocator.free(full_path);

        // Load texture
        const texture = rl.loadTexture(full_path);
        if (texture.id == 0) return ResourceError.LoadError;

        // Store in cache with duplicated path as key
        const key = try self.allocator.dupe(u8, path);
        errdefer self.allocator.free(key);

        try self.resources.put(key, Resource{
            .resource_type = .texture,
            .data = .{ .texture = texture },
        });

        return texture;
    }

    pub fn loadFont(self: *Self, path: []const u8) !rl.Font {
        // Check if already loaded
        if (self.resources.get(path)) |resource| {
            if (resource.resource_type != .font) return ResourceError.InvalidResource;
            return resource.data.font;
        }

        // Build full path
        const full_path = try std.fmt.allocPrintZ(self.allocator, "{s}/{s}", .{ self.base_path, path });
        defer self.allocator.free(full_path);

        // Load font
        const font = rl.loadFont(full_path);
        if (font.baseSize == 0) return ResourceError.LoadError;

        // Store in cache with duplicated path as key
        const key = try self.allocator.dupe(u8, path);
        errdefer self.allocator.free(key);

        try self.resources.put(key, Resource{
            .resource_type = .font,
            .data = .{ .font = font },
        });

        return font;
    }

    pub fn loadSound(self: *Self, path: []const u8) !rl.Sound {
        // Build full path first
        var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
        const full_path = try std.fmt.bufPrintZ(&path_buffer, "{s}/{s}", .{ self.base_path, path });

        // Load sound first
        const sound = rl.loadSound(full_path);
        if (sound.frameCount == 0) return ResourceError.LoadError;

        // Store in cache with duplicated path as key
        const key = try self.allocator.dupe(u8, path);
        errdefer self.allocator.free(key);

        try self.resources.put(key, Resource{
            .resource_type = .sound,
            .data = .{ .sound = sound },
        });

        return sound;
    }

    pub fn loadMusic(self: *Self, path: []const u8) !rl.Music {
        // Build full path first
        var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
        const full_path = try std.fmt.bufPrintZ(&path_buffer, "{s}/{s}", .{ self.base_path, path });

        std.debug.print("Attempting to load music from path: {s}\n", .{full_path});

        // Load music first
        const music = rl.loadMusicStream(full_path);
        if (music.frameCount == 0) {
            std.debug.print("Failed to load music stream\n", .{});
            return ResourceError.LoadError;
        }

        // Store in cache with duplicated path as key
        const key = try self.allocator.dupe(u8, path);
        errdefer self.allocator.free(key);

        try self.resources.put(key, Resource{
            .resource_type = .music,
            .data = .{ .music = music },
        });

        return music;
    }

    pub fn unloadResource(self: *Self, path: []const u8) void {
        if (self.resources.fetchRemove(path)) |entry| {
            // Free the stored path key
            self.allocator.free(entry.key);
            // Free the resource
            entry.value.deinit();
        }
    }
};

const Resource = struct {
    resource_type: ResourceType,
    data: ResourceData,

    pub fn deinit(self: *Resource) void {
        switch (self.resource_type) {
            .texture => rl.unloadTexture(self.data.texture),
            .font => rl.unloadFont(self.data.font),
            .sound => rl.unloadSound(self.data.sound),
            .music => rl.unloadMusicStream(self.data.music),
        }
    }
};

const ResourceData = union {
    texture: rl.Texture2D,
    font: rl.Font,
    sound: rl.Sound,
    music: rl.Music,
};
