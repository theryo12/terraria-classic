const std = @import("std");
const rl = @import("raylib");

const SoundEffect = struct {
    sound: rl.Sound,
    volume: f32,
};

pub const AudioEngine = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    current_music: ?rl.Music,
    sounds: std.StringHashMap(SoundEffect),
    is_initialized: bool,
    volume: f32,
    sound_volume: f32,

    pub fn init(allocator: std.mem.Allocator) !*Self {
        const self = try allocator.create(Self);
        self.* = .{
            .allocator = allocator,
            .current_music = null,
            .sounds = std.StringHashMap(SoundEffect).init(allocator),
            .is_initialized = false,
            .volume = 1.0,
            .sound_volume = 1.0,
        };

        rl.initAudioDevice();
        self.is_initialized = true;
        return self;
    }

    pub fn deinit(self: *Self) void {
        if (self.current_music) |*music| {
            self.stopMusic();
            rl.unloadMusicStream(music.*);
        }

        var sound_iter = self.sounds.valueIterator();
        while (sound_iter.next()) |sound_effect| {
            rl.unloadSound(sound_effect.sound);
        }
        self.sounds.deinit();

        if (self.is_initialized) {
            rl.closeAudioDevice();
        }
        self.allocator.destroy(self);
    }

    // Music methods
    pub fn loadMusic(self: *Self, file_path: []const u8) !void {
        // Stop and unload any currently playing music
        if (self.current_music) |*music| {
            self.stopMusic();
            rl.unloadMusicStream(music.*);
            self.current_music = null;
        }

        // Load new music
        const music = rl.loadMusicStream(@ptrCast(file_path));
        self.current_music = music;
        self.setVolume(self.volume);
    }

    pub fn playMusic(self: *Self) void {
        if (self.current_music) |music| {
            rl.playMusicStream(music);
        }
    }

    pub fn pauseMusic(self: *Self) void {
        if (self.current_music) |music| {
            rl.pauseMusicStream(music);
        }
    }

    pub fn resumeMusic(self: *Self) void {
        if (self.current_music) |music| {
            rl.resumeMusicStream(music);
        }
    }

    pub fn stopMusic(self: *Self) void {
        if (self.current_music) |music| {
            rl.stopMusicStream(music);
        }
    }

    pub fn setVolume(self: *Self, volume: f32) void {
        self.volume = volume;
        if (self.current_music) |music| {
            rl.setMusicVolume(music, volume);
        }
    }

    pub fn update(self: *Self) void {
        if (self.current_music) |music| {
            rl.updateMusicStream(music);
        }
    }

    pub fn setLooping(self: *Self, looping: bool) void {
        if (self.current_music) |*music| {
            music.looping = looping;
        }
    }

    pub fn isPlaying(self: *Self) bool {
        return if (self.current_music) |music|
            rl.isMusicStreamPlaying(music)
        else
            false;
    }

    // Sound methods
    pub fn loadSound(self: *Self, name: []const u8, file_path: []const u8) !void {
        const sound = rl.loadSound(@ptrCast(file_path));
        try self.sounds.put(name, .{ .sound = sound, .volume = self.sound_volume });
    }

    pub fn playSound(self: *Self, name: []const u8) void {
        if (self.sounds.get(name)) |sound_effect| {
            rl.playSound(sound_effect.sound);
        }
    }

    pub fn stopSound(self: *Self, name: []const u8) void {
        if (self.sounds.get(name)) |sound_effect| {
            rl.stopSound(sound_effect.sound);
        }
    }

    pub fn setSoundVolume(self: *Self, volume: f32) void {
        self.sound_volume = volume;
        var sound_iter = self.sounds.valueIterator();
        while (sound_iter.next()) |sound_effect| {
            rl.setSoundVolume(sound_effect.sound, volume);
        }
    }

    pub fn setSoundVolumeByName(self: *Self, name: []const u8, volume: f32) void {
        if (self.sounds.getPtr(name)) |sound_effect| {
            sound_effect.volume = volume;
            rl.setSoundVolume(sound_effect.sound, volume);
        }
    }

    pub fn isSoundPlaying(self: *Self, name: []const u8) bool {
        return if (self.sounds.get(name)) |sound_effect|
            rl.isSoundPlaying(sound_effect.sound)
        else
            false;
    }

    pub fn unloadSound(self: *Self, name: []const u8) void {
        if (self.sounds.get(name)) |sound_effect| {
            rl.unloadSound(sound_effect.sound);
            _ = self.sounds.remove(name);
        }
    }
};
