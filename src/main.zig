const std = @import("std");
const day1 = @import("day1.zig");
const day2 = @import("day2.zig");
pub fn main() !void {
    const day = try promptUser();

    const start_time = try std.time.Instant.now();
    switch (day) {
        1 => {
            std.debug.print("Running day 1...\n", .{});
            std.debug.print("Part 1: What is the total distance between your lists?\n", .{});
            const total_distance = try day1.solveTotalDistance("day1_input.txt");
            std.debug.print("Answer: {d}\n", .{total_distance});
            std.debug.print("Part 2: What is their similarity score?\n", .{});
            const similarity_score = try day1.solveSimilarityScore("day1_input.txt"); // uses the same input file
            std.debug.print("Answer: {d}\n", .{similarity_score});
        },
        2 => {
            std.debug.print("Running day 2...\n", .{});
            std.debug.print("Part 1: How many reports are safe?\n", .{});
            const safe_reports_count = try day2.solveSafeReports("day2_input.txt");
            std.debug.print("Answer: {d}\n", .{safe_reports_count});
            std.debug.print("Part 2: How many reports are safe with fault tolerance?\n", .{});
            const safe_reports_count_with_ft = try day2.solveSafeReportsWithFt("day2_input.txt");
            std.debug.print("Answer: {d}\n", .{safe_reports_count_with_ft});
        },
        else => {
            std.debug.print("No solution available for day {d}\n", .{day});
        },
    }
    const end_time = try std.time.Instant.now();
    const elapsed: f64 = @floatFromInt(end_time.since(start_time));

    std.debug.print("time to solve: {d:.3}ms\n", .{elapsed / std.time.ns_per_ms});
}

fn promptUser() !u8 {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Enter the day number (1-25): ", .{});

    var buf: [10]u8 = undefined;
    if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
        const resp = std.fmt.parseInt(u8, user_input, 10) catch {
            try stdout.writeAll("Invalid input. Try again.\n");
            return promptUser();
        };
        return resp;
    } else {
        try stdout.writeAll("Invalid input. Please enter a number between 1 and 25.\n");
        return error.InvalidInput;
    }
}
