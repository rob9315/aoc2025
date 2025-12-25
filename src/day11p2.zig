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

    const svr_fft = try paths(&graph, ("svr")[0..], ("fft")[0..]);
    print("svr_fft {} * ", .{svr_fft});
    const fft_dac = try paths(&graph, ("fft")[0..], ("dac")[0..]);
    print("fft_dac {} * ", .{fft_dac});
    const dac_out = try paths(&graph, ("dac")[0..], ("out")[0..]);
    print("dac_out {}\n", .{dac_out});
    const svr_fft_dac_out = svr_fft * fft_dac * dac_out;
    print("= svr_fft_dac_out {}\n", .{svr_fft_dac_out});

    const svr_dac = try paths(&graph, ("svr")[0..], ("dac")[0..]);
    print("svr_dac {} *", .{svr_dac});
    const dac_fft = try paths(&graph, ("dac")[0..], ("fft")[0..]);
    print("dac_fft {} *", .{dac_fft});
    const fft_out = try paths(&graph, ("fft")[0..], ("out")[0..]);
    print("fft_out {}\n", .{fft_out});
    const svr_dac_fft_out = svr_dac * dac_fft * fft_out;
    print("= svr_dac_fft_out {}\n", .{svr_dac_fft_out});

    const total_paths = svr_fft_dac_out + svr_dac_fft_out;
    print("paths {}\n", .{total_paths});
}

const PathStorage = std.StringHashMap(usize);

fn paths(graph: *const Graph, from: []const u8, to: []const u8) !usize {
    var storage: PathStorage = .init(gpa);
    defer storage.deinit();
    return recurse(graph, &storage, from, to);
}

fn recurse(graph: *const Graph, storage: *PathStorage, key: []const u8, goal: []const u8) !usize {
    if (storage.get(key)) |ret| return ret;

    if (std.mem.eql(u8, key, goal)) {
        return 1;
    }

    const keys = graph.get(key) orelse return 0;

    var ret: usize = 0;
    for (keys.items) |k| {
        ret += try recurse(graph, storage, k, goal);
    }
    try storage.put(key, ret);
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
