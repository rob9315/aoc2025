const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");

pub fn main() !void {
    var lines = tokenizeSca(u8, data, '\n');
    var prev_line: ?[]const u8 = null;
    var accessible: u32 = 0;
    while (lines.next()) |line| {
        const next_line: ?[]const u8 = lines.peek();
        for (0..line.len) |i| {
            if (line[i] != '@') continue;
            const range_start = i -| 1;
            const range_end = min(i + 2, line.len);
            var count: u8 = 0;
            if (prev_line) |prev| {
                count += count_ats(prev[range_start..range_end]);
            }
            count += count_ats(line[range_start..range_end]) - 1;
            if (next_line) |next| {
                count += count_ats(next[range_start..range_end]);
            }
            if (count < 4) accessible += 1;
        }
        prev_line = line;
    }
    print("accessible {}\n", .{accessible});
}
fn count_ats(slice: []const u8) u8 {
    var count: u8 = 0;
    for (slice) |elem| {
        if (elem == '@') count += 1;
    }
    return count;
}
fn min(a: usize, b: usize) usize {
    return if (a < b) a else b;
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
