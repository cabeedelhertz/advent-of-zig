const std = @import("std");
const utils = @import("utils.zig");

pub fn solveSafeReports(input_file: []const u8) !i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        std.debug.assert(gpa.deinit() == .ok);
    }
    const allocator = gpa.allocator();

    const file = try utils.openFile(input_file);
    defer file.close();

    var safe_reports_count: i32 = 0;
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var split = std.mem.split(u8, line, " ");
        var reports = std.ArrayList(i32).init(allocator);
        defer reports.deinit();
        while (split.next()) |level_str| {
            const level = try std.fmt.parseInt(i32, level_str, 10);
            try reports.append(level);
        }
        if (isValid(reports.items)) {
            safe_reports_count += 1;
            continue;
        }
    }
    return safe_reports_count;
}

pub fn solveSafeReportsWithFt(input_file: []const u8) !i32 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        std.debug.assert(gpa.deinit() == .ok);
    }
    const allocator = gpa.allocator();

    const file = try utils.openFile(input_file);
    defer file.close();

    var safe_reports_count: i32 = 0;
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var reports = std.ArrayList(i32).init(allocator);
        defer reports.deinit();

        var split = std.mem.split(u8, line, " ");
        while (split.next()) |level_str| {
            const level = try std.fmt.parseInt(i32, level_str, 10);
            try reports.append(level);
        }

        if (isValid(reports.items)) {
            safe_reports_count += 1;
            continue;
        } else {
            for (0..reports.items.len) |i| {
                const new_len = reports.items.len - 1;
                var new_reports = try allocator.alloc(i32, new_len);
                defer allocator.free(new_reports);

                @memcpy(new_reports[0..i], reports.items[0..i]);
                if (i != new_len) {
                    @memcpy(new_reports[i..new_len], reports.items[i + 1 ..]);
                }

                if (isValid(new_reports)) {
                    safe_reports_count += 1;
                    break;
                }
            }
        }
    }
    return safe_reports_count;
}

fn isValid(reports: []i32) bool {
    var trend: i8 = 0;
    for (1..reports.len) |i| {
        const prev, const curr = .{ reports[i - 1], reports[i] };
        if (@abs(curr - prev) > 3 or @abs(curr - prev) == 0) {
            return false;
        }
        if (curr > prev) {
            if (trend == -1) {
                return false;
            }
            trend = 1;
        } else if (prev > curr) {
            if (trend == 1) {
                return false;
            }
            trend = -1;
        }
    }
    return true;
}
