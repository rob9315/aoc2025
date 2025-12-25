const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day10.txt");

// Ax = b
// A ~ {0,1}^(m,n)
// b ~ Z^m
// x ~ Z^n

// n ~ number of buttons
// m ~ number of joltages

// [###.] (0,1,3) (0,1,2) {9,9,5,4}
// b = (9,9,5,4)
// x = (?,?)
// A = (1,1,0,1; 1,1,1,0)

// augmented
// (0,1,1,0; 1,0,0,1)

pub fn main() !void {
    var line_iter = tokenizeSca(u8, data, '\n');

    var total_presses: usize = 0;
    while (line_iter.next()) |line| {
        print("{s}\n", .{line});
        var machine = try parse_line(gpa, line);
        defer machine.deinit(gpa);
        var presses: ?usize = null;
        try dfs(gpa, machine.buttons.items, machine.joltages.items, 0, &presses);
        print("{?} presses\n", .{presses});
        total_presses += presses orelse {
            print("couldn't solve\n", .{});
            continue;
        };
    }
    print("total presses {}\n", .{total_presses});
}

const Machine = struct {
    const Self = @This();
    // goal: std.DynamicBitSet,
    buttons: std.ArrayList([]bool),
    joltages: std.ArrayList(usize),
    fn deinit(self: *Self, alloc: Allocator) void {
        for (self.*.buttons.items) |button| {
            alloc.free(button);
        }
        self.*.buttons.deinit(alloc);
        self.*.buttons = .empty;
        self.*.joltages.deinit(alloc);
        self.*.joltages = .empty;
    }
};

fn parse_line(alloc: std.mem.Allocator, line: []const u8) !Machine {
    var line_split = splitSca(u8, line, ' ');

    const goal_str = line_split.first();
    std.debug.assert(goal_str[0] == '[');
    std.debug.assert(goal_str[goal_str.len - 1] == ']');
    const max_len = goal_str.len - 2;

    // var goal: std.DynamicBitSet = try .initEmpty(alloc, max_len);
    // for (1..goal_str.len - 1) |i| {
    //     if (goal_str[i] == '#') {
    //         goal.set(i - 1);
    //     }
    // }

    var buttons: std.ArrayList([]bool) = .empty;

    const joltages_str: []const u8 = button_loop: while (line_split.next()) |button_str| {
        if (line_split.peek() == null) {
            break :button_loop button_str;
        }

        std.debug.assert(button_str[0] == '(');
        std.debug.assert(button_str[button_str.len - 1] == ')');

        var button: []bool = try alloc.alloc(bool, max_len);
        @memset(button, false);
        var number_iter = tokenizeSca(u8, button_str[1 .. button_str.len - 1], ',');
        while (number_iter.next()) |number_str| {
            const number = try parseInt(usize, number_str, 10);
            std.debug.assert(number < max_len);
            std.debug.assert(!button[number]);
            button[number] = true;
        }

        (try buttons.addOne(gpa)).* = button;
    } else unreachable;

    std.debug.assert(joltages_str[0] == '{');
    std.debug.assert(joltages_str[joltages_str.len - 1] == '}');

    var joltage_iter = tokenizeSca(u8, joltages_str[1 .. joltages_str.len - 1], ',');
    var joltages: std.ArrayList(usize) = .empty;
    while (joltage_iter.next()) |joltage_str| {
        const joltage = try parseInt(usize, joltage_str, 10);
        (try joltages.addOne(alloc)).* = joltage;
    }
    assert(joltages.items.len == max_len);

    return .{
        // .goal = goal,
        .buttons = buttons,
        .joltages = joltages,
    };
}

fn dfs(alloc: Allocator, buttons_stack: [][]bool, rem: []usize, used: usize, best: *?usize) !void {
    if (if (best.*) |b| used >= b else false) return;
    if (buttons_stack.len == 0) {
        for (rem) |e| if (e != 0) return;
        best.* = used;
        return;
    }

    const button = buttons_stack[buttons_stack.len - 1];
    var min: ?usize = null;
    for (button, 0..) |bit, i| {
        if (!bit) continue;
        if (if (min) |mp| mp > rem[i] else true) {
            min = rem[i];
        }
    }
    const max_presses = min orelse return;

    var r = max_presses;
    const next = try alloc.alloc(usize, rem.len);
    defer alloc.free(next);
    while (r != std.math.maxInt(usize)) : (r -%= 1) {
        @memcpy(next, rem);
        for (next, 0..) |*e, i| {
            if (!button[i]) continue;
            e.* -= r;
        }
        try dfs(alloc, buttons_stack[0 .. buttons_stack.len - 1], next, used + r, best);
    }
}
std.math.big.

const rat = struct {

};

fn simplex(A: [][]usize, )

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
