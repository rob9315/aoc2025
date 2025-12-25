const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day12.txt");

pub fn main() !void {
    var section_iter = tokenizeSeq(u8, data, "\n\n");
    var i: usize = 0;
    var shapes: std.ArrayList(usize) = .empty;
    defer shapes.deinit(gpa);
    const problem_lines: []const u8 = while (section_iter.next()) |section_str| : (i += 1) {
        var index_split = splitSeq(u8, section_str, ":\n");
        const index_str = index_split.first();
        const pattern_str = index_split.next() orelse {
            break section_str;
        };
        const index = try parseInt(usize, index_str, 10);
        assert(index == i);
        const occupied = std.mem.count(u8, pattern_str, "#");
        const free = std.mem.count(u8, pattern_str, ".");
        const lines = std.mem.count(u8, pattern_str, "\n") + 1;
        assert(lines == 3);
        assert(pattern_str.len + 1 == occupied + free + lines);
        assert((occupied + free) == 3 * lines);

        (try shapes.addOne(gpa)).* = occupied;
    } else "";

    var impossible: usize = 0;
    var trivial: usize = 0;
    var who_knows: std.ArrayList([]const u8) = .empty;
    defer who_knows.deinit(gpa);

    var problem_lines_iter = tokenizeSca(u8, problem_lines, '\n');
    while (problem_lines_iter.next()) |problem_line| {
        print("{s}\n", .{problem_line});
        var split = splitSeq(u8, problem_line, ": ");
        const shape_str = split.first();
        var shape_split = splitSca(u8, shape_str, 'x');
        const width = try parseInt(usize, shape_split.first(), 10);
        const height = try parseInt(usize, shape_split.rest(), 10);
        var counts_iter = tokenizeSca(u8, split.rest(), ' ');
        i = 0;
        const counts = try gpa.alloc(usize, shapes.items.len);
        defer gpa.free(counts);
        while (counts_iter.next()) |count_str| : (i += 1) {
            counts[i] = try parseInt(usize, count_str, 10);
        }
        assert(i == shapes.items.len);

        // check if trivially impossible
        var required_squares: usize = 0;
        for (shapes.items, counts) |shape, count| {
            required_squares += shape * count;
        }
        if (required_squares > width * height) {
            impossible += 1;
            print("trivially impossible\n", .{});
            continue;
        }

        // check if trivially solvable
        var free_3x3s = (width / 3) * (height / 3);
        for (shapes.items, counts) |_, count| {
            if (free_3x3s < count) {
                break;
            }
            free_3x3s -= count;
        } else {
            trivial += 1;
            print("trivially solvable\n", .{});
            continue;
        }
        print("who knows...\n", .{});
        (try who_knows.addOne(gpa)).* = problem_line;
    }
    print("trivially solvables = {}\n", .{trivial});
    print("trivially impossibles = {}\n", .{impossible});
    print("who knows about these {} anyways...\n", .{who_knows.items.len});
    for (who_knows.items) |item| {
        print("{s}\n", .{item});
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
