const Terminal = @This();

const std = @import("std");
const ColorScheme = @import("ColorScheme.zig");

tty: std.Io.Terminal,

pub fn init(io: std.Io, environ_map: *const std.process.Environ.Map, file: std.Io.File, writer: *std.Io.Writer) Terminal {
    const NO_COLOR = if (environ_map.get("NO_COLOR")) |v| v.len > 0 else false;
    const CLICOLOR_FORCE = if (environ_map.get("CLICOLOR_FORCE")) |v| v.len > 0 else false;
    return .{
        .tty = .{
            .writer = writer,
            .mode = std.Io.Terminal.Mode.detect(io, file, NO_COLOR, CLICOLOR_FORCE) catch .no_color,
        },
    };
}

pub fn print(
    terminal: Terminal,
    style: ColorScheme.Style,
    comptime format: []const u8,
    args: anytype,
) void {
    for (style) |color| {
        terminal.tty.setColor(color) catch {};
    }

    terminal.tty.writer.print(format, args) catch {};

    if (style.len > 0) {
        terminal.tty.setColor(.reset) catch {};
    }
}
