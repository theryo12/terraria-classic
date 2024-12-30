const std = @import("std");
const rl = @import("raylib");
const AudioConfig = @import("../config.zig").AudioConfig;

pub const SoundEffect = struct {
    sound: rl.Sound,
    volume: f32,
};

pub const AudioEngine = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    current_music: ?rl.Music,
    sounds: std.StringHashMap(SoundEffect),
    is_initialized: bool,
    config: AudioConfig,

    pub fn init(allocator: std.mem.Allocator) !*Self {
        return initWithConfig(allocator, .{});
    }

    pub fn initWithConfig(allocator: std.mem.Allocator, audio_config: AudioConfig) !*Self {
        const self = try allocator.create(Self);
        self.* = .{
            .allocator = allocator,
            .current_music = null,
            .sounds = std.StringHashMap(SoundEffect).init(allocator),
            .is_initialized = false,
            .config = audio_config,
        };

        rl.initAudioDevice();
        rl.setAudioStreamBufferSizeDefault(4096);
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
        if (self.current_music) |*music| {
            self.stopMusic();
            rl.unloadMusicStream(music.*);
            self.current_music = null;
        }

        const music = rl.loadMusicStream(@ptrCast(file_path));
        self.current_music = music;
        self.updateMusicVolume();
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

    fn updateMusicVolume(self: *Self) void {
        if (self.current_music) |music| {
            const effective_volume = self.config.volume.music * self.config.volume.master;
            rl.setMusicVolume(music, effective_volume);
        }
    }

    fn updateAllSoundVolumes(self: *Self) void {
        var sound_iter = self.sounds.valueIterator();
        while (sound_iter.next()) |sound_effect| {
            const effective_volume = sound_effect.volume * self.config.volume.master * self.config.volume.sfx;
            rl.setSoundVolume(sound_effect.sound, effective_volume);
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
        try self.sounds.put(name, .{ .sound = sound, .volume = 1.0 });
        if (self.sounds.getPtr(name)) |sound_effect| {
            const effective_volume = sound_effect.volume * self.config.volume.master * self.config.volume.sfx;
            rl.setSoundVolume(sound_effect.sound, effective_volume);
        }
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

    // Set volume for all sounds
    pub fn setSoundVolume(self: *Self, volume: f32) void {
        self.config.volume.sfx = volume;
        self.updateAllSoundVolumes();
    }

    // Set volume for a specific sound by name
    pub fn setSound(self: *Self, name: []const u8, volume: f32) void {
        if (self.sounds.getPtr(name)) |sound_effect| {
            sound_effect.volume = volume;
            const effective_volume = volume * self.config.volume.master * self.config.volume.sfx;
            rl.setSoundVolume(sound_effect.sound, effective_volume);
        }
    }

    // Set volume for a specific sound by pointer
    pub fn setSoundPtr(self: *Self, sound_effect: *SoundEffect, volume: f32) void {
        sound_effect.volume = volume;
        const effective_volume = volume * self.config.volume.master * self.config.volume.sfx;
        rl.setSoundVolume(sound_effect.sound, effective_volume);
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

    // Get a pointer to a sound effect
    pub fn getSound(self: *Self, name: []const u8) ?*SoundEffect {
        return self.sounds.getPtr(name);
    }

    // Config methods
    pub fn setMasterVolume(self: *Self, volume: f32) void {
        self.config.volume.master = volume;
        self.updateMusicVolume();
        self.updateAllSoundVolumes();
    }

    pub fn setConfig(self: *Self, new_config: AudioConfig) void {
        const old_config = self.config;
        self.config = new_config;

        // Update volumes if they changed
        if (old_config.volume.master != new_config.volume.master or
            old_config.volume.music != new_config.volume.music or
            old_config.volume.sfx != new_config.volume.sfx)
        {
            self.updateMusicVolume();
            self.updateAllSoundVolumes();
        }
    }

    pub fn getConfig(self: *Self) AudioConfig {
        return self.config;
    }
};
