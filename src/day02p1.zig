const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

pub fn main() !void {
    var out = tokenizeSca(u8, data, ',');
    var finalout: u64 = 0;
    while (out.next()) |seq| {
        var split = splitSca(u8, seq, '-');
        const start = try parseInt(u64, split.first(), 10);
        const end = try parseInt(u64, split.rest(), 10);
        const outp = try addupthings(start, end);
        print("start: {}, end: {}, out: {}\n", .{ start, end, outp });
        finalout += outp;
    }
    print("finalout: {}\n", .{finalout});
}

pub fn addupthings(start: u64, end: u64) !u64 {
    var numerals: u64 = std.math.log10_int(start) + 1;
    var topnum: u64 = undefined;
    var mul: u64 = undefined;
    print("numerals = {}\n", .{numerals});
    if (numerals & 1 == 1) {
        numerals += 1;
        mul = try std.math.powi(u64, 10, numerals / 2);
        topnum = mul / 10;
    } else {
        mul = try std.math.powi(u64, 10, numerals / 2);
        topnum = try std.math.divFloor(u64, start, mul);
        const botnum = start - topnum * mul;
        if (topnum < botnum) {
            // go to next one
            topnum += 1;
            if (topnum >= mul) {
                topnum = mul;
                mul *= 10;
            }
        }
    }
    var output: u64 = 0;
    print("[start] mul = {}, topnum = {}\n", .{ mul, topnum });
    while (topnum * mul + topnum <= end) {
        print("mul = {}, topnum = {}\n", .{ mul, topnum });
        output += topnum * mul + topnum;
        topnum += 1;
        if (topnum >= mul) {
            topnum = mul;
            mul *= 10;
        }
    }
    return output;
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
