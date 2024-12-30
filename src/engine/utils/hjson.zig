const std = @import("std");

pub const HjsonParser = struct {
    allocator: std.mem.Allocator,
    current_section: []const u8 = "",
    sections: std.ArrayList([]const u8),
    section_buf: std.ArrayList(u8),
    indent_buf: std.ArrayList(u8),
    dots_buf: std.ArrayList(u8),
    first_line: bool = true,

    pub fn init(allocator: std.mem.Allocator) HjsonParser {
        return .{
            .allocator = allocator,
            .sections = std.ArrayList([]const u8).init(allocator),
            .section_buf = std.ArrayList(u8).init(allocator),
            .indent_buf = std.ArrayList(u8).init(allocator),
            .dots_buf = std.ArrayList(u8).init(allocator),
            .first_line = true,
        };
    }

    pub fn deinit(self: *HjsonParser) void {
        self.sections.deinit();
        self.section_buf.deinit();
        self.indent_buf.deinit();
        self.dots_buf.deinit();
    }

    fn getIndentation(self: *HjsonParser, depth: usize) ![]const u8 {
        try self.indent_buf.resize(0);
        var i: usize = 0;
        while (i < depth) : (i += 1) {
            try self.indent_buf.appendSlice("    ");
        }
        return self.indent_buf.items;
    }

    fn getDots(self: *HjsonParser, key: []const u8) ![]const u8 {
        const max_dots = 12;
        try self.dots_buf.resize(0);

        if (key.len >= max_dots) {
            try self.dots_buf.append('.');
            return self.dots_buf.items;
        }

        var i: usize = 0;
        while (i < max_dots - key.len) : (i += 1) {
            try self.dots_buf.append('.');
        }
        return self.dots_buf.items;
    }

    /// Parse a string value, trimming whitespace and optional quotes
    fn parseValue(value: []const u8) []const u8 {
        var start: usize = 0;
        var end: usize = value.len;

        // Trim whitespace from start
        while (start < value.len and std.ascii.isWhitespace(value[start])) {
            start += 1;
        }

        // Trim whitespace from end
        while (end > start and std.ascii.isWhitespace(value[end - 1])) {
            end -= 1;
        }

        // Remove quotes if present
        if (end - start >= 2 and value[start] == '"' and value[end - 1] == '"') {
            start += 1;
            end -= 1;
        }

        return value[start..end];
    }

    /// Parse a line and return key-value if found
    pub fn parseLine(self: *HjsonParser, line: []const u8) !?struct { key: []const u8, value: []const u8 } {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        if (trimmed.len == 0 or trimmed[0] == '#') return null;

        if (self.first_line) {
            self.first_line = false;
        }

        // Handle section start
        if (std.mem.indexOf(u8, trimmed, "{")) |_| {
            const section_name = std.mem.trim(u8, trimmed[0..std.mem.indexOf(u8, trimmed, "{").?], " \t:");
            try self.sections.append(section_name);
            return null;
        }

        // Handle section end
        if (std.mem.indexOf(u8, trimmed, "}")) |_| {
            if (self.sections.items.len > 0) {
                _ = self.sections.pop();
            }
            return null;
        }

        // Handle key-value pairs
        if (std.mem.indexOf(u8, trimmed, ":")) |colon_pos| {
            const key = std.mem.trim(u8, trimmed[0..colon_pos], " \t");
            const value = HjsonParser.parseValue(trimmed[colon_pos + 1 ..]);
            return .{ .key = key, .value = value };
        }

        return null;
    }

    /// Get current full section path
    pub fn getCurrentSection(self: *HjsonParser) ![]const u8 {
        if (self.sections.items.len == 0) return "";

        try self.section_buf.resize(0);
        for (self.sections.items, 0..) |section, i| {
            if (i > 0) try self.section_buf.append('.');
            try self.section_buf.appendSlice(section);
        }
        return self.section_buf.items;
    }

    /// Format a value for HJSON output
    pub fn formatValue(comptime T: type, value: T, allocator: std.mem.Allocator) []const u8 {
        switch (T) {
            bool => return if (value) "true" else "false",
            comptime_int, i32, i64 => return std.fmt.allocPrint(allocator, "{d}", .{value}) catch return "0",
            f32, f64 => return std.fmt.allocPrint(allocator, "{d}", .{value}) catch return "0",
            []const u8 => return value,
            else => return "",
        }
    }
};
