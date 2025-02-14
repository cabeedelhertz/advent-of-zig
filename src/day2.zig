const std = @import("std");
const utils = @import("utils.zig");

pub fn solve(input_file: []const u8) !i32 {
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

    var left_list = try std.ArrayList(i32).initCapacity(allocator, length);
    defer left_list.deinit();

    var right_map = std.AutoHashMap(i32, i32).init(allocator);
    defer right_map.deinit();
    try right_map.ensureTotalCapacity(1000);

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const parsed_line = try utils.parseLeftAndRight(line);

        try left_list.append(parsed_line.left);
        if (right_map.get(parsed_line.right)) |v| {
            try right_map.put(parsed_line.right, v + 1);
        } else {
            try right_map.put(parsed_line.right, 1);
        }
    }

    var similarity_score: i32 = 0;
    for (left_list.items) |left| {
        if (right_map.get(left)) |v| {
            similarity_score += left * v;
        }
    }
    return similarity_score;
}
