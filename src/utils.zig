const std = @import("std");

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
