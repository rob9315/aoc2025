const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");

pub fn main() !void {
    var lines_iter = tokenizeSca(u8, data, '\n');

    var lines: std.ArrayList([]const u8) = .empty;
    const op_line: []const u8 = while (lines_iter.next()) |next| {
        if (lines_iter.peek() == null) {
            break next;
        } else {
            (try lines.addOne(gpa)).* = next;
        }
    } else unreachable;

    var finalsum: u64 = 0;
    var operations = tokenizeSca(u8, op_line, ' ');

    while (operations.next()) |op_text| {
        const start_idx = operations.index - op_text.len;
        const next = operations.peek();
        const end_idx = operations.index - if (next) |x| x.len else 0;
        const op: Op = try .from_char(op_text[0]);
        var variable = op.init();
        for (lines.items) |line| {
            const slice = line[start_idx..end_idx];
            const trimmed = trim(u8, slice, " ");
            const arg = try parseInt(u64, trimmed, 10);
            variable = op.run(variable, arg);
        }
        finalsum += variable;
    }

    print("finalsum = {}\n", .{finalsum});
}

const Op = enum {
    const Self = @This();

    Sum,
    Prod,

    fn init(self: *const Self) u64 {
        return switch (self.*) {
            .Sum => 0,
            .Prod => 1,
        };
    }
    fn run(self: *const Self, a: u64, b: u64) u64 {
        return switch (self.*) {
            .Sum => a + b,
            .Prod => a * b,
        };
    }
    fn from_char(char: u8) error{UnexpectedOp}!Self {
        return switch (char) {
            '+' => Self.Sum,
            '*' => Self.Prod,
            else => error.UnexpectedOp,
        };
    }
};

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
