const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");
const digits = 12;

pub fn main() !void {
    var banks = tokenizeSca(u8, data, '\n');
    var combined_joltage: u64 = 0;
    while (banks.next()) |bank| {
        if (bank.len < 12) continue;
        const prev = combined_joltage;
        var from: usize = 0;
        for (0..digits) |i| {
            const pow: u32 = digits - @as(u32, @intCast(i)) - 1;
            const max_i = try find_largest(from, bank[0 .. bank.len - pow]);
            combined_joltage += (bank[max_i] & 0xf) * try std.math.powi(u64, 10, pow);
            from = max_i + 1;
        }
        print("diff {}\n", .{combined_joltage - prev});
    }
    print("combined_joltage {}\n", .{combined_joltage});
}

fn find_largest(from: usize, bank: []const u8) !usize {
    var max_index: ?usize = null;
    for (bank[from..], from..) |num, i| {
        if (max_index) |max_i| {
            if (bank[max_i] >= num) continue;
        }
        max_index = i;
    }
    return max_index.?;
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
