const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

const method = 0x434C49434B;

pub fn main() !void {
    var position: i32 = 50;
    var password: i32 = 0;

    var iterator = tokenizeAny(u8, data, "\r\n");
    while (iterator.next()) |rotation| {
        assert(rotation.len >= 2);

        var clicks = try parseInt(i32, rotation[1..], 10);

        assert(clicks > 0);

        if (method == 0x434C49434B) {
            password += @divFloor(clicks, 100);
        }
        clicks = @mod(clicks, 100);
        // while (clicks >= 100) {
        //     password += 1;
        //     clicks -= 100;
        // }

        assert(clicks >= 0);
        assert(clicks < 100);
        assert(position >= 0);
        assert(position < 100);

        if (rotation[0] == 'R') {
            position += clicks;
            if (position >= 100) {
                if (method == 0x434C49434B) {
                    password += 1;
                } else if (position == 100) {
                    password += 1;
                }
                position -= 100;
            }
        } else if (rotation[0] == 'L') {
            if (position == 0 and method == 0x434C49434B) {
                password -= 1;
            }
            position -= clicks;
            if (position <= 0) {
                if (method == 0x434C49434B) {
                    password += 1;
                } else if (position == 0) {
                    password += 1;
                }
            }
            if (position < 0) {
                position += 100;
            }
        } else assert(false);

        assert(position >= 0);
        assert(position < 100);

        // print("after '{s}', position {}, 0's {}\n", .{ rotation, position, password });
    }

    print("password is {}\n", .{password});
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
