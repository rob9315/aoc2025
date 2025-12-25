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
        print("{s}\n", .{line});
        const machine = try parse_line(gpa, line);
        const presses = try find_minimum_presses(gpa, &machine);
        total_presses += presses;
        print("{} presses\n", .{presses});
    }
    print("total presses {}\n", .{total_presses});
}

const Machine = struct {
    // goal: std.DynamicBitSet,
    buttons: std.ArrayList(std.DynamicBitSet),
    joltages: std.ArrayList(usize),
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

    var buttons: std.ArrayList(std.DynamicBitSet) = .empty;

    const joltages_str: []const u8 = button_loop: while (line_split.next()) |button_str| {
        if (line_split.peek() == null) {
            break :button_loop button_str;
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

fn find_minimum_presses(alloc: std.mem.Allocator, machine: *const Machine) error{ Impossible, OutOfMemory }!usize {
    var joltages = try machine.joltages.clone(alloc);
    defer joltages.deinit(alloc);
    var cumultative_joltage: usize = 0;
    for (machine.joltages.items) |joltage| {
        cumultative_joltage += joltage;
    }
    print("trying presses... 0", .{});
    for (0..cumultative_joltage) |presses| {
        if (recurse(presses + 1, &joltages, &machine.buttons)) {
            return presses + 1;
        }
        print(",{}", .{presses});
    } else {
        return error.Impossible;
    }
}

fn recurse(more_presses: usize, joltages: *std.ArrayList(usize), buttons: *const std.ArrayList(std.DynamicBitSet)) bool {
    if (more_presses == 0) {
        for (joltages.items) |joltage| {
            if (joltage == 0) continue;
            return false;
        } else return true;
    }
    next_button: for (buttons.*.items) |button| {
        var bit_iter = button.iterator(.{});
        while (bit_iter.next()) |bit_index| {
            if (joltages.items[bit_index] == 0) {
                continue :next_button;
            }
        }

        var bit_iter2 = button.iterator(.{});
        while (bit_iter2.next()) |bit_index| {
            joltages.items[bit_index] -= 1;
        }

        if (recurse(more_presses - 1, joltages, buttons)) {
            return true;
        }

        var bit_iter3 = button.iterator(.{});
        while (bit_iter3.next()) |bit_index| {
            joltages.items[bit_index] += 1;
        }
    }
    return false;
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
