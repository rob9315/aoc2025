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
        print("start: {}, end: {}, out: {}\n\n", .{ start, end, outp });
        finalout += outp;
    }
    print("finalout: {}\n", .{finalout});
}

fn signed_type(uT: type) type {
    var typeInfo = @typeInfo(uT);
    typeInfo.int.signedness = .signed;
    return @Type(typeInfo);
}

fn sum_of_invalid_ids(uT: type, numerals: std.math.Log2Int(uT), min: ?uT, max: ?uT) !uT {
    print(">sum_of_invalid_ids(uT: {s}, numerals: {}, min: {?}, max: {?})\n", .{ @typeName(uT), numerals, min, max });
    const iT: type = signed_type(uT);
    var multiplicators: [std.math.maxInt(std.math.Log2Int(uT))]iT = undefined;
    for (1..numerals / 2 + 1) |i| {
        const i_T: std.math.Log2Int(uT) = @intCast(i);
        multiplicators[i] = numerals / i_T * i_T / numerals;
    }
    {
        var i = numerals / 2;
        while (i > 0) : (i -= 1) {
            // print("multiplicators[{}] = {}\n", .{ i, multiplicators[i] });
            if (multiplicators[i] == 0) continue;
            for (1..i) |j| {
                if (i / j * j != i) continue;
                multiplicators[j] -= multiplicators[i];
            }
        }
    }
    var sum: uT = 0;
    for (1..numerals / 2 + 1) |i| {
        print("multiplicators[{}] = {}\n", .{ i, multiplicators[i] });
        if (multiplicators[i] == 0) continue;
        const maxnum = try std.math.powi(uT, 10, @intCast(i));
        var start: uT = undefined;
        if (min) |minimum| {
            start = minimum / try std.math.powi(uT, maxnum, numerals / i - 1);
            print("minimum/maxnum^(numerals/i-1) = {}/{} = {}\n", .{ minimum, try std.math.powi(uT, maxnum, numerals / i - 1), start });
            var offset: uT = 0;
            for (1..numerals / i) |j| {
                const n = minimum / try std.math.powi(uT, maxnum, numerals / i - j - 1);
                if (n % maxnum > start) {
                    offset = 1;
                    break;
                }
                if (n % maxnum < start) {
                    offset = 0;
                    break;
                }
            }
            start += offset;
        } else {
            start = try std.math.powi(uT, 10, i - 1);
        }
        var end: uT = undefined;
        if (max) |maximum| {
            // print("maximum {} maxnum {} numerals {} i {}\n", .{ maximum, maxnum, numerals, i });
            end = maximum / try std.math.powi(uT, maxnum, numerals / i - 1);
            print("maximum/maxnum^(numerals/i-1) = {}/{} = {}\n", .{ maximum, try std.math.powi(uT, maxnum, numerals / i - 1), end });
            var offset: uT = 1;
            for (1..numerals / i) |j| {
                const n = maximum / try std.math.powi(uT, maxnum, numerals / i - j - 1);
                // print("n {} maxnum {} offset {}\n", .{ n, maxnum, offset });
                if (n % maxnum < end) {
                    offset = 0;
                    break;
                }
                if (n % maxnum > end) {
                    offset = 1;
                    break;
                }
            }
            end += offset;
        } else {
            end = try std.math.powi(uT, 10, i);
        }

        var mul: uT = 1;
        for (1..numerals / i) |_| {
            mul = 1 + mul * maxnum;
        }
        print("start {} end {} mul {}\n", .{ start, end, mul });
        if (start >= end) continue;
        const prevsum = sum;

        for (start..end) |num| {
            const number: iT = @as(iT, @bitCast(mul)) * @as(iT, @intCast(num));
            if (min) |minimum| assert(number >= minimum);
            if (max) |maximum| assert(number <= maximum);
            const thing = number * multiplicators[i];
            sum +%= @bitCast(thing);
        }

        print("diff {}\n", .{@as(iT, @bitCast(sum -% prevsum))});
    }
    return sum;
}

pub fn addupthings(start: u64, end: u64) !u64 {
    var numerals: std.math.Log2Int(u64) = std.math.log10_int(start) + 1;
    if (numerals == std.math.log10_int(end) + 1) {
        return sum_of_invalid_ids(u64, numerals, start, end);
    } else {
        var sum = try sum_of_invalid_ids(u64, numerals, start, null);
        while (numerals < std.math.log10_int(end)) : (numerals += 1) {
            sum += try sum_of_invalid_ids(u64, numerals, null, null);
        }
        sum += try sum_of_invalid_ids(u64, numerals + 1, null, end);
        return sum;
    }
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
