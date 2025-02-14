const std = @import("std");

pub fn solve(input_file: []const u8) !u32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        std.debug.assert(gpa.deinit() == .ok);
    }

    const allocator = gpa.allocator();

    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.realpath(input_file, &path_buffer);
    var file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    const length = 1000;

    var left_list = try std.ArrayList(u32).initCapacity(allocator, length);
    defer left_list.deinit();
    var right_list = try std.ArrayList(u32).initCapacity(allocator, length);
    defer right_list.deinit();

    var line_no: usize = 0;

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        defer line_no += 1;
        var split = std.mem.split(u8, line, "   ");
        var left: u32, var right: u32 = .{ 0, 0 };
        if (split.next()) |left_str| {
            left = try std.fmt.parseInt(u32, left_str, 10);
        } else {
            return error.InvalidInput;
        }
        if (split.next()) |right_str| {
            right = try std.fmt.parseInt(u32, right_str, 10);
        } else {
            return error.InvalidInput;
        }

        if (line_no == 0) {
            try left_list.append(left);
            try right_list.append(right);
            continue;
        }

        var proccessed_left: bool = false;
        var proccessed_right: bool = false;
        for (0..line_no) |i| {
            if (proccessed_left and proccessed_right) {
                break;
            }
            if (!proccessed_left) {
                if (left <= left_list.items[i]) {
                    try left_list.insert(i, left);
                    proccessed_left = true;
                } else if (i == line_no - 1) {
                    try left_list.append(left);
                    proccessed_left = true;
                }
            }
            if (!proccessed_right) {
                if (right <= right_list.items[i]) {
                    try right_list.insert(i, right);
                    proccessed_right = true;
                } else if (i == line_no - 1) {
                    try right_list.append(right);
                    proccessed_right = true;
                }
            }
        }
    }

    var totalDistance: u32 = 0;
    for (0..length) |i| {
        totalDistance += @max(left_list.items[i], right_list.items[i]) - @min(left_list.items[i], right_list.items[i]);
    }
    return totalDistance;
}
