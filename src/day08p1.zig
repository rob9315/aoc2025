const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");
const items = 1000;
const mul = 3;

pub fn main() !void {
    var line_iter = tokenizeSca(u8, data, '\n');
    var coordinates: std.ArrayList(Coord) = .empty;
    defer coordinates.deinit(gpa);

    while (line_iter.next()) |line| {
        var num_iter = splitSca(u8, line, ',');
        const x = try parseInt(u32, num_iter.first(), 10);
        const y = try parseInt(u32, num_iter.next().?, 10);
        const z = try parseInt(u32, num_iter.rest(), 10);
        (try coordinates.addOne(gpa)).* = .from_xyz(x, y, z);
    }

    var distances: [items]Dist = undefined;
    var highest_index: ?usize = null;
    for (coordinates.items, 0..) |coord, i| {
        for (coordinates.items[0..i], 0..) |coord2, j| {
            const dist2 = coord.dist2_to(coord2);
            const distance = Dist{ .dist2 = dist2, .i_1 = i, .i_2 = j };
            const end = if (highest_index) |idx| idx + 1 else 0;
            const overflow = if (end < distances.len) &distances[end] else null;
            try insert_from_back(Dist, distances[0..end], overflow, distance, Dist.lt);
            // print("{any}\n", .{distances[0..end]});
            if (overflow) |_| {
                highest_index = end;
            }
        }
    }

    const coord_group: []?usize = try gpa.alloc(?usize, coordinates.items.len);
    defer gpa.free(coord_group);
    @memset(coord_group, null);

    for (distances) |dist| {
        const i_1 = dist.i_1;
        const i_2 = dist.i_2;
        // print("dist {any}\n", .{dist});
        if (coord_group[i_1]) |l1| {
            if (coord_group[i_2]) |l2| {
                if (try find_in_ref_loop(coord_group, l1, l2)) |_| {
                    // print("connection already made");
                } else {
                    std.mem.swap(?usize, &coord_group[l2], &coord_group[l1]);
                }
            } else {
                coord_group[i_2] = coord_group[l1];
                coord_group[l1] = i_2;
            }
        } else if (coord_group[i_2]) |l2| {
            coord_group[i_1] = coord_group[l2];
            coord_group[l2] = i_1;
        } else {
            coord_group[i_1] = i_2;
            coord_group[i_2] = i_1;
        }
        // print("{any}\n", .{coord_group});
    }

    var biggest_nets: [mul]usize = undefined;
    @memset(&biggest_nets, 1);
    highest_index = null;

    for (coord_group) |cg| {
        const start = if (cg) |c| c else continue;

        // print("arr {any}\n", .{coord_group});
        const netsize = try erase_ref_loop(coord_group, start);
        // print("net with {}\n", .{netsize});

        const end = if (highest_index) |idx| idx + 1 else 0;
        const overflow = if (end != biggest_nets.len) &biggest_nets[end] else null;
        // print("of: {any} = biggest_nets[{}]\n", .{ overflow, end });
        try insert_from_back(usize, biggest_nets[0..end], overflow, netsize, usize_desc);
        // print("biggest nets {any}\n", .{biggest_nets[0..if (end + 1 > biggest_nets.len) biggest_nets.len else end + 1]});
        if (overflow) |_| {
            highest_index = end;
        }
    }

    var product: usize = 1;
    for (biggest_nets) |net| {
        product *= net;
        print("product {}\n", .{product});
    }
}
fn usize_desc(a: usize, b: usize) bool {
    return a > b;
}
fn erase_ref_loop(arr: []?usize, start: usize) error{Empty}!usize {
    var netsize: usize = 0;
    var next = arr[start];
    while (next) |this| {
        next = arr[this];
        netsize += 1;
        arr[this] = null;
        if (this == start) {
            return netsize;
        }
    } else return error.Empty;
}
fn find_in_ref_loop(arr: []?usize, start: usize, elem: usize) error{Empty}!?usize {
    var netsize: usize = 1;
    var next = arr[start];
    while (next) |this| {
        if (this == start) {
            if (elem != start) return null;
            return netsize;
        }
        if (this == elem) return netsize;
        next = arr[this];
        netsize += 1;
    } else return error.Empty;
}
fn insert_from_back(T: type, list: []T, overflow: ?*T, item: T, lt: *const fn (T, T) bool) error{NoSpace}!void {
    if (list.len == 0) {
        // print("of {any}\n", .{overflow});
        if (overflow) |of| {
            of.* = item;
            return;
        } else {
            return error.NoSpace;
        }
    }

    if (!lt(item, list[list.len - 1])) {
        if (overflow) |of| of.* = item;
        return;
    }
    var elem_iter = std.mem.reverseIterator(list[0 .. list.len - 1]);
    while (elem_iter.nextPtr()) |elem| {
        if (lt(item, elem.*)) {
            @as([*]T, @ptrCast(elem))[1] = elem.*;
        } else {
            @as([*]T, @ptrCast(elem))[1] = item;
            break;
        }
    } else {
        if (list.len == 1) {
            if (overflow) |of| of.* = list[0];
        }
        list[0] = item;
    }
}
const Dist = struct {
    dist2: u64,
    i_1: usize,
    i_2: usize,
    fn lt(d1: Dist, d2: Dist) bool {
        return d1.dist2 < d2.dist2;
    }
};
const Coord = struct {
    const Self = @This();
    x: u32,
    y: u32,
    z: u32,
    fn from_xyz(x: u32, y: u32, z: u32) Self {
        return .{ .x = x, .y = y, .z = z };
    }
    fn dist2_to(self: *const Self, other: Self) u64 {
        const dx: u64 = @abs(@as(i64, @intCast(self.*.x)) - @as(i64, @intCast(other.x)));
        const dy: u64 = @abs(@as(i64, @intCast(self.*.y)) - @as(i64, @intCast(other.y)));
        const dz: u64 = @abs(@as(i64, @intCast(self.*.z)) - @as(i64, @intCast(other.z)));
        return dx * dx + dy * dy + dz * dz;
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
