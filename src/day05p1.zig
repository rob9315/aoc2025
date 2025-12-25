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

    var id_list: std.ArrayList(u64) = .empty;
    const ids = split.rest();
    var id_iter = tokenizeSca(u8, ids, '\n');
    while (id_iter.next()) |id_str| {
        (try id_list.addOne(gpa)).* = try parseInt(u64, id_str, 10);
    }
    sort(u64, id_list.items, {}, asc(u64));

    var range_idx: usize = 0;
    var fresh_ingredients: usize = 0;
    for (id_list.items) |id| {
        if (while (range_list.items[range_idx].until < id) {
            range_idx += 1;
            if (range_idx >= range_list.items.len) break true;
        } else false) break;
        if (id >= range_list.items[range_idx].from) {
            fresh_ingredients += 1;
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
