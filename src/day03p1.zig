const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");

pub fn main() !void {
    var banks = tokenizeSca(u8, data, '\n');
    var combined_joltage: u32 = 0;
    while (banks.next()) |bank| {
        const max_i = find_largest(0, bank) catch continue;
        var max_joltage: u8 = undefined;
        if (max_i + 1 == bank.len) {
            const start_i = try find_largest(0, bank[0..max_i]);
            max_joltage = (bank[start_i] & 0xf) * 10 + (bank[max_i] & 0xf);
        } else {
            const end_i = try find_largest(max_i + 1, bank);
            max_joltage = (bank[max_i] & 0xf) * 10 + (bank[end_i] & 0xf);
        }
        print("max_joltage {}\n", .{max_joltage});
        combined_joltage += max_joltage;
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
