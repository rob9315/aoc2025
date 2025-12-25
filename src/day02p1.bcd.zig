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
        const start = try parseInt(u64, split.first(), 16);
        const end = try parseInt(u64, split.rest(), 16);
        const outp = try addupthings(start, end);
        print("start: {x}, end: {x}, out: {x}\n", .{ start, end, outp });
        finalout = bcdadd64(finalout, outp);
    }
    print("finalout: {x}\n", .{finalout});
}

//https://stackoverflow.com/q/78246054
fn median64(x: u64, y: u64, z: u64) u64 {
    return (x | (y & z)) & (y | z);
}
fn bcdadd64(x: u64, y: u64) u64 {
    const z = y + 0x6666666666666666;
    const u = x + z;
    const t = median64(x, z, ~u) & 0x8888888888888888;
    return (x + y) + (t - (t >> 2));
}

fn bcdinc(x: *u64) void {
    x.* = bcdadd64(x.*, 1);
}

pub fn addupthings(start: u64, end: u64) !u64 {
    var shift: u6 = @intCast((std.math.log2_int_ceil(u64, start) + 1) >> 1);
    const unevendigits: bool = std.math.log2_int(u64, start) & 0b100 == 0;
    // round up
    shift += 3;
    shift &= ~@as(u6, 0b011);
    var top: u64 = undefined;

    if (unevendigits) {
        // starting number has uneven amount of digits
        top = (@as(u64, 0x1) << shift) >> 4;
    } else {
        // starting number has even amount of digits
        top = start >> shift;
        if (top < (start & ~(@as(u64, std.math.maxInt(u64)) << shift))) {
            bcdinc(&top);
            if ((top >> shift) != 0) {
                shift += 0b100;
            }
        }
    }
    print("[start] top: {x} *10^{}\n", .{ top, (shift >> 2) });

    var output: u64 = 0;
    while ((top << shift) | top <= end) {
        print("top = {x}\n", .{top});
        output = bcdadd64(output, (top << shift) | top);
        bcdinc(&top);
        if ((top >> shift) != 0) {
            shift += 0b100;
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
