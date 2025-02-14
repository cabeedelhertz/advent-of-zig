const std = @import("std");

pub fn openFile(input_file_name: []const u8) !std.fs.File {
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.realpath(input_file_name, &path_buffer);
    return try std.fs.openFileAbsolute(path, .{});
}

const Line = struct {
    left: i32,
    right: i32,
};

pub fn parseLeftAndRight(
    line: []const u8,
) !Line {
    var split = std.mem.split(u8, line, "   ");
    var left: i32, var right: i32 = .{ 0, 0 };
    if (split.next()) |left_str| {
        left = try std.fmt.parseInt(i32, left_str, 10);
    } else {
        return error.InvalidInput;
    }
    if (split.next()) |right_str| {
        right = try std.fmt.parseInt(i32, right_str, 10);
    } else {
        return error.InvalidInput;
    }
    return Line{ .left = left, .right = right };
}
