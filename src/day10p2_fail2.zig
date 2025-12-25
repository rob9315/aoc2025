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
        const presses = try recurse(gpa, machine.joltages.items, machine.buttons.items) orelse {
            print("couldn't solve\n", .{});
            return;
        };
        total_presses += presses;
        print("{} presses\n", .{presses});
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

fn recurse(alloc: std.mem.Allocator, joltages: []usize, buttons: [][]bool) !?usize {
    // print("joltages {any}, buttons[{}] {any}\n", .{ joltages, buttons.len, buttons });
    // test for solve
    for (joltages) |joltage| {
        if (joltage != 0) break;
    } else {
        return 0;
    }
    // filter buttons
    var removal_indices: std.ArrayList(usize) = .empty;
    defer removal_indices.deinit(alloc);
    for (joltages, 0..) |joltage, i| {
        if (joltage != 0) continue;
        for (buttons, 0..) |button, j| {
            if (button[i]) {
                (try removal_indices.addOne(alloc)).* = j;
            }
        }
    }
    std.mem.sort(usize, removal_indices.items, {}, asc(usize));
    var usable_buttons: std.ArrayList([]bool) = try .initCapacity(alloc, buttons.len);
    @memcpy(usable_buttons.items.ptr, buttons);
    usable_buttons.items.len = buttons.len;
    defer usable_buttons.deinit(alloc);
    usable_buttons.orderedRemoveMany(removal_indices.items);

    if (usable_buttons.items.len == 0) {
        return null;
    }

    // sort buttons (tbd)
    std.mem.sort([]bool, usable_buttons.items, {}, struct {
        fn desc_by_joltage(_: void, a: []bool, b: []bool) bool {
            const a_count = std.mem.count(bool, a, &[_]bool{true});
            const b_count = std.mem.count(bool, b, &[_]bool{true});
            return a_count > b_count;
        }
    }.desc_by_joltage);

    const sorted_joltages = try alloc.dupe(usize, joltages);
    defer alloc.free(sorted_joltages);
    std.mem.sort(usize, sorted_joltages, {}, asc(usize));
    var bitindices: std.ArrayList(usize) = .empty;
    defer bitindices.deinit(alloc);
    // print("joltages {any}\n", .{joltages});
    // print("sorted_joltages {any}\n", .{sorted_joltages});
    var prev_joltage: ?usize = null;
    for (sorted_joltages) |joltage| {
        if (joltage == 0) continue;
        if (prev_joltage) |pj| {
            if (pj == joltage) {
                continue;
            }
        }
        prev_joltage = joltage;
        var start_index: usize = 0;
        // print("searching for {}\n", .{joltage});
        while (std.mem.indexOfScalarPos(usize, joltages, start_index, joltage)) |index| {
            // print("found {} at {}, priority {}\n", .{ joltage, index, bitindices.items.len });
            (try bitindices.addOne(alloc)).* = index;
            start_index = index + 1;
        }
    }
    // print("usable_buttons={any}\n", .{usable_buttons.items});
    std.mem.sort([]bool, usable_buttons.items, bitindices.items, struct {
        fn desc_by_min_presses(ctx: []usize, a: []bool, b: []bool) bool {
            const a_count: usize = for (ctx, 0..) |min_i, i| {
                if (a[min_i]) break i;
            } else {
                print("ctx={any}, a={any}\n", .{ ctx, a });
                unreachable;
            };
            const b_count: usize = for (ctx, 0..) |min_i, i| {
                if (b[min_i]) break i;
            } else {
                print("ctx={any}, b={any}\n", .{ ctx, b });
                unreachable;
            };
            return a_count > b_count;
        }
    }.desc_by_min_presses);

    // recurse
    var buttons_excl_one: [][]bool = try alloc.dupe([]bool, usable_buttons.items[1..]);
    defer alloc.free(buttons_excl_one);
    for (usable_buttons.items, 0..) |_, i| {
        const button = usable_buttons.items[i];
        var min: ?usize = null;
        for (button, 0..) |bit, joltage_i| {
            if (!bit) continue;
            if (min) |old_min| {
                if (old_min > joltages[joltage_i]) {
                    min = joltages[joltage_i];
                }
            } else {
                min = joltages[joltage_i];
            }
        }
        const max_presses = min orelse unreachable;
        var presses = max_presses;
        while (presses > 0) : (presses -= 1) {
            var new_joltages: []usize = try alloc.dupe(usize, joltages);
            defer alloc.free(new_joltages);
            for (button, 0..) |bit, j| {
                if (!bit) continue;
                new_joltages[j] -= presses;
            }
            // print(">\n", .{});
            if (try recurse(alloc, new_joltages, buttons_excl_one)) |x| {
                print("{}x {any}\n", .{ presses, button });
                return x + presses;
            }
        }

        // swap out old button for next one
        if (i < buttons_excl_one.len) {
            buttons_excl_one[i] = usable_buttons.items[i];
        }
    }
    // print("<\n", .{});
    return null;
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
