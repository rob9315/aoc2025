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
        var machine = try parse_line(gpa, line);
        defer machine.deinit(gpa);
        const presses: ?usize = try recurse(gpa, machine.buttons.items, machine.joltages.items);
        print("{?} presses\n", .{presses});
        total_presses += presses orelse {
            @panic("couldn't solve\n");
        };
    }
    print("total presses {}\n", .{total_presses});
}

const Machine = struct {
    const Self = @This();
    // goal: std.DynamicBitSet,
    buttons: std.ArrayList(u16),
    joltages: std.ArrayList(usize),
    fn deinit(self: *Self, alloc: Allocator) void {
        self.*.buttons.deinit(alloc);
        self.*.joltages.deinit(alloc);
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

    var buttons: std.ArrayList(u16) = .empty;

    const joltages_str: []const u8 = button_loop: while (line_split.next()) |button_str| {
        if (line_split.peek() == null) {
            break :button_loop button_str;
        }

        std.debug.assert(button_str[0] == '(');
        std.debug.assert(button_str[button_str.len - 1] == ')');

        var button: u16 = 0;
        var number_iter = tokenizeSca(u8, button_str[1 .. button_str.len - 1], ',');
        while (number_iter.next()) |number_str| {
            const number = try parseInt(u4, number_str, 10);
            std.debug.assert(number < max_len);
            std.debug.assert((button >> number) & 1 == 0);
            button |= @as(u16, 1) << number;
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

fn recurse(alloc: Allocator, buttons: []u16, rem: []usize) !?usize {
    // print("recurse({any})\n", .{rem});
    assert(rem.len <= @bitSizeOf(@TypeOf(buttons[0])));
    var solved = true;
    const mask = mask: {
        var mask: u16 = 0;
        for (rem, 0..) |int, i| {
            solved &= int == 0;
            mask |= @as(u16, @intCast(@intFromBool(1 == int & 1))) << @intCast(i);
        }
        break :mask mask;
    };
    if (solved) return 0;

    var best_solution: ?usize = if (mask == 0) sol: {
        // print("presses 0\n", .{});
        const next_rem = try alloc.dupe(usize, rem);
        for (next_rem) |*nr| {
            assert(0 == (nr.* & 1));
            nr.* /= 2;
        }
        break :sol if (try recurse(alloc, buttons, next_rem)) |sol| sol * 2 else null;
    } else null;

    for (1..buttons.len + 1) |presses| {
        // print("presses {}\n", .{presses});
        var press_mask = start(@intCast(presses));

        next_mask: while (valid(press_mask, @intCast(buttons.len))) : (press_mask = next(press_mask)) {
            if (!solves_mask(press_mask, buttons, mask)) continue;

            const next_rem = try alloc.dupe(usize, rem);
            defer alloc.free(next_rem);
            for (buttons, 0..) |button, i| {
                if (0 == (press_mask >> @intCast(i)) & 1) continue;
                for (0..16) |j| {
                    if (0 == (button >> @intCast(j)) & 1) continue;
                    next_rem[j], const of: u1 = @subWithOverflow(next_rem[j], 1);
                    if (of == 1) continue :next_mask;
                }
            }
            for (next_rem) |*nr| {
                assert(0 == (nr.* & 1));
                nr.* /= 2;
            }
            const recursed_presses = try recurse(alloc, buttons, next_rem) orelse {
                continue :next_mask;
            };
            if (if (best_solution) |prev_sol| prev_sol > recursed_presses * 2 + presses else true) {
                best_solution = recursed_presses * 2 + presses;
            }
        }
    }
    if (best_solution) |solution| {
        return solution;
    }
    return null;
}

// https://stackoverflow.com/a/40892739
fn start(k: u6) usize {
    return (@as(usize, 1) << k) - 1;
}
fn next(x: usize) usize {
    const u = x & (1 + ~x);
    const v = u +% x;
    const y = v +% (((v ^ x) / u) >> 2);
    return y;
}
fn valid(x: usize, bits: u6) bool {
    return x >> bits == 0;
}
fn solves_mask(x: usize, buttons: []u16, mask: u16) bool {
    var workmask = mask;
    for (buttons, 0..) |button, i| {
        if (0 == (x >> @intCast(i)) & 1) continue;
        workmask ^= button;
    }
    return workmask == 0;
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
