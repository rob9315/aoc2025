const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day10.txt");

pub fn main() !void {
    var line_iter = tokenizeSca(u8, data, '\n');

    var total_presses: usize = 0;
    while (line_iter.next()) |line| {
        const machine = try parse_line(gpa, line);
        const presses = try find_minimum_presses(gpa, &machine);
        total_presses += presses;
    }
    print("total presses {}\n", .{total_presses});
}

const Machine = struct {
    goal: std.DynamicBitSet,
    buttons: std.ArrayList(std.DynamicBitSet),
};

fn parse_line(alloc: std.mem.Allocator, line: []const u8) !Machine {
    var line_split = splitSca(u8, line, ' ');

    const goal_str = line_split.first();
    std.debug.assert(goal_str[0] == '[');
    std.debug.assert(goal_str[goal_str.len - 1] == ']');
    const max_len = goal_str.len - 2;

    var goal: std.DynamicBitSet = try .initEmpty(alloc, max_len);
    for (1..goal_str.len - 1) |i| {
        if (goal_str[i] == '#') {
            goal.set(i - 1);
        }
    }

    var buttons: std.ArrayList(std.DynamicBitSet) = .empty;

    while (line_split.next()) |button_str| {
        if (line_split.peek() == null) {
            break;
        }

        std.debug.assert(button_str[0] == '(');
        std.debug.assert(button_str[button_str.len - 1] == ')');

        var button: std.DynamicBitSet = try .initEmpty(alloc, max_len);
        var number_iter = tokenizeSca(u8, button_str[1 .. button_str.len - 1], ',');
        while (number_iter.next()) |number_str| {
            const number = try parseInt(usize, number_str, 10);
            std.debug.assert(number < max_len);
            std.debug.assert(!button.isSet(number));
            button.set(number);
        }

        (try buttons.addOne(gpa)).* = button;
    }

    return .{ .goal = goal, .buttons = buttons };
}

fn find_minimum_presses(alloc: std.mem.Allocator, machine: *const Machine) error{ Impossible, OutOfMemory }!usize {
    var presses: std.DynamicBitSet = try .initEmpty(alloc, machine.*.buttons.items.len);
    var goal = try machine.*.goal.clone(alloc);

    for (1..machine.*.goal.unmanaged.bit_length + 1) |bits_set| {
        if (!recurse(bits_set, &presses, &goal, machine.buttons.items)) {
            assert(goal.eql(machine.*.goal));
            continue;
        }
        return bits_set;
    }

    return error.Impossible;
}

fn recurse(bits: usize, presses: *std.DynamicBitSet, goal: *std.DynamicBitSet, buttons: []const std.DynamicBitSet) bool {
    if (bits == 0) {
        return solves(presses, goal, buttons);
    }

    for (0..presses.*.unmanaged.bit_length) |i| {
        if (presses.*.isSet(i)) continue;
        presses.*.set(i);
        defer presses.*.unset(i);

        if (recurse(bits - 1, presses, goal, buttons)) {
            return true;
        }
    }
    return false;
}

fn solves(presses: *const std.DynamicBitSet, goal: *std.DynamicBitSet, buttons: []const std.DynamicBitSet) bool {
    var press_iter = presses.unmanaged.iterator(.{});
    while (press_iter.next()) |press| {
        goal.unmanaged.toggleSet(buttons[press].unmanaged);
    }
    const solved = goal.findLastSet() == null;
    press_iter = presses.unmanaged.iterator(.{});
    while (press_iter.next()) |press| {
        goal.unmanaged.toggleSet(buttons[press].unmanaged);
    }
    return solved;
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
