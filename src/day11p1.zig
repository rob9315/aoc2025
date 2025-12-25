const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day11.txt");

const Graph = std.StringHashMap(std.ArrayList([]const u8));

pub fn main() !void {
    var graph: Graph = .init(gpa);
    defer graph.deinit();

    var lines_iter = tokenizeSca(u8, data, '\n');
    while (lines_iter.next()) |line| {
        var split = splitSeq(u8, line, ": ");
        const key = split.first();
        const entry = try graph.getOrPutValue(key, .empty);
        var child_iter = tokenizeSca(u8, split.rest(), ' ');
        while (child_iter.next()) |child| {
            (try entry.value_ptr.addOne(gpa)).* = child;
        }
    }

    const paths = recurse(&graph, ("you")[0..]);
    print("paths {}\n", .{paths});
}

fn recurse(graph: *const Graph, key: []const u8) usize {
    if (std.mem.eql(u8, key, "out")) {
        return 1;
    }

    const keys = graph.get(key) orelse {
        const errs = std.fmt.allocPrint(gpa, "unknown key {s}", .{key}) catch @panic("oom");
        @panic(errs);
    };

    var ret: usize = 0;
    for (keys.items) |k| {
        ret += recurse(graph, k);
    }
    return ret;
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
