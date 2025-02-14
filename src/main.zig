const std = @import("std");
const day1 = @import("day1.zig");

pub fn main() !void {
    const day = try promptUser();

    switch (day) {
        1 => {
            std.debug.print("Running day 1...\n", .{});
            const answer = try day1.solve("day1_input.txt");
            std.debug.print("Answer: {d}\n", .{answer});
        },
        else => {
            std.debug.print("No solution available for day {d}\n", .{day});
        },
    }
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
