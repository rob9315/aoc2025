const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");

pub fn main() !void {
    var split = splitSeq(u8, data, "\n\n");
    const ranges = split.first();
    var range_iter = tokenizeSca(u8, ranges, '\n');
    const Range = struct {
        const Self = @This();

        from: u64,
        until: u64,

        fn lessThan(_: void, a: Self, b: Self) bool {
            return a.from < b.from;
        }
    };
    var range_list: std.ArrayList(Range) = .empty;
    while (range_iter.next()) |range| {
        var split_range = splitSca(u8, range, '-');
        (try range_list.addOne(gpa)).* = .{
            .from = try parseInt(u64, split_range.first(), 10),
            .until = try parseInt(u64, split_range.rest(), 10),
        };
    }
    sort(Range, range_list.items, {}, Range.lessThan);

    var fresh_ingredients: usize = 0;
    var last_fresh_id: ?usize = null;
    for (range_list.items) |range| {
        const delta = if (last_fresh_id) |lfid|
            if (lfid >= range.until)
                0
            else if (lfid >= range.from)
                range.until - lfid
            else
                range.until + 1 - range.from
        else
            range.until + 1 - range.from;
        fresh_ingredients += delta;
        if (delta != 0) {
            last_fresh_id = range.until;
        }
    }

    print("fresh ingredients {}\n", .{fresh_ingredients});
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
