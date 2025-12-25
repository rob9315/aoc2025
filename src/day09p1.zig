const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

pub fn main() !void {
    var line_iter = tokenizeSca(u8, data, '\n');
    var coords: std.ArrayList(Coord) = .empty;
    while (line_iter.next()) |line| {
        var split = splitSca(u8, line, ',');
        const x = try parseInt(u32, split.first(), 10);
        const y = try parseInt(u32, split.rest(), 10);
        (try coords.addOne(gpa)).* = .{ .x = x, .y = y };
    }

    var largest_area: u64 = 0;
    for (0..coords.items.len) |i| {
        for (0..i) |j| {
            const a = area(coords.items[i], coords.items[j]);
            if (a > largest_area) {
                largest_area = a;
            }
        }
    }

    print("{}\n", .{largest_area});
}

const Coord = struct {
    x: u32,
    y: u32,
};
fn area(a: Coord, b: Coord) u64 {
    const dx: u64 = if (a.x >= b.x) a.x - b.x else b.x - a.x;
    const dy: u64 = if (a.y >= b.y) a.y - b.y else b.y - a.y;
    return (dx + 1) * (dy + 1);
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
