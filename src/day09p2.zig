const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");

pub fn main() !void {
    var line_iter = tokenizeSca(u8, data, '\n');
    var coords: std.ArrayList(Coord) = .empty;
    defer coords.deinit(gpa);
    while (line_iter.next()) |line| {
        var split = splitSca(u8, line, ',');
        const x = try parseInt(u32, split.first(), 10);
        const y = try parseInt(u32, split.rest(), 10);
        (try coords.addOne(gpa)).* = .{ .x = x, .y = y };
    }

    const pg: playground = try .create(gpa, coords.items);

    var largest_area: u64 = 0;
    for (0..coords.items.len) |i| {
        for (0..i) |j| {
            const a, const b = .{ coords.items[i], coords.items[j] };
            const area = calc_area(a, b);
            if (area <= largest_area) continue;

            const min_row, const max_row = if (a.y < b.y) .{ a.y, b.y } else .{ b.y, a.y };
            const min_col, const max_col = if (a.x < b.x) .{ a.x, b.x } else .{ b.x, a.x };

            // validate
            for (min_row..max_row + 1) |row| {
                if (!pg.is_okay(row, min_col, max_col)) {
                    break;
                }
            } else {
                largest_area = area;
            }
        }
    }

    print("largest area {}\n", .{largest_area});
}

const Coord = struct {
    x: u32,
    y: u32,
};
fn calc_area(a: Coord, b: Coord) u64 {
    const dx: u64 = if (a.x >= b.x) a.x - b.x else b.x - a.x;
    const dy: u64 = if (a.y >= b.y) a.y - b.y else b.y - a.y;
    return (dx + 1) * (dy + 1);
}

const playground = struct {
    const Self = @This();
    min_row: usize,
    rows: [][]usize,
    fn get_row(self: *const Self, i: usize) []usize {
        if (i < self.min_row) return &[_]usize{};
        if (i - self.min_row >= self.rows.len) return &[_]usize{};
        return self.rows[i - self.min_row];
    }

    fn create(alloc: Allocator, coords: []Coord) !Self {
        var min = coords[0];
        var max = coords[0];
        for (coords[1..]) |coord| {
            if (min.x > coord.x) min.x = coord.x;
            if (min.y > coord.y) min.y = coord.y;
            if (max.x < coord.x) max.x = coord.x;
            if (max.y < coord.y) max.y = coord.y;
        }
        const min_row = min.y;
        const rows = try alloc.alloc(std.ArrayList(usize), max.y - min.y + 1);
        defer alloc.free(rows);
        for (rows) |*row| row.* = .empty;
        defer for (rows) |*row| row.deinit(alloc);

        const Vert = struct {
            const Dir = enum(u1) { up = 1, down = 0 };
            col: usize,
            row: struct { min: usize, max: usize },
            dir: Dir,
            fn make_vert(a: Coord, b: Coord) ?@This() {
                if (a.x != b.x) return null;
                assert(a.y != b.y);
                const dir: Dir = if (a.y > b.y) .up else .down;
                const row_min, const row_max = if (dir == .down) .{ a.y, b.y } else .{ b.y, a.y };
                return .{ .col = a.x, .row = .{ .min = row_min, .max = row_max }, .dir = dir };
            }
            fn asc_by_col(_: void, a: @This(), b: @This()) bool {
                return a.col < b.col;
            }
        };
        var verts: std.ArrayList(Vert) = .empty;
        defer verts.deinit(alloc);

        for (coords, 0..) |coord1, i| {
            const coord2 = coords[(i + 1) % coords.len];
            if (Vert.make_vert(coord1, coord2)) |vert| {
                (try verts.addOne(alloc)).* = vert;
            }
        }

        std.sort.block(Vert, verts.items, {}, Vert.asc_by_col);

        for (verts.items) |vert| {
            // print("{any}\n", .{vert});
            for (rows[vert.row.min - min_row .. vert.row.max - min_row + 1]) |*row| {
                // print("{any} {any}\n", .{ vert.dir, row.items });
                const item: ?*usize = if (row.items.len > 0 and row.items.len & 1 == @intFromEnum(vert.dir))
                    &row.items[row.items.len - 1]
                else
                    null;
                if (item) |e| {
                    if (switch (vert.dir) {
                        .up => vert.col < e.*,
                        .down => vert.col > e.*,
                    }) {
                        e.* = vert.col;
                        continue;
                    }
                }
                (try row.addOne(alloc)).* = vert.col;
            }
        }

        // print("rows {any}\n", .{rows[0..12]});

        // for (rows, 0..) |*row, ri| {
        //     print("rows[{}] {any}\n", .{ ri + min_row, row.* });
        //     assert(0 == row.items.len & 1);
        //     var paired_indices: std.ArrayList(usize) = .empty;
        //     defer paired_indices.deinit(alloc);
        //     if (row.items.len < 4) continue;
        //     var i: usize = 1;
        //     while (i < row.items.len) : (i += 2) {
        //         if (row.items[i] == row.items[i + 1] - 1) {
        //             (try paired_indices.addManyAsArray(alloc, 2)).* = .{ i, i + 1 };
        //         }
        //     }
        //     row.orderedRemoveMany(paired_indices.items);
        // }

        const self = Self{
            .min_row = min_row,
            .rows = try alloc.alloc([]usize, rows.len),
        };

        for (rows, self.rows) |array_list, *out| {
            out.* = try alloc.dupe(usize, array_list.items);
        }

        return self;
    }
    fn deinit(self: *Self, alloc: Allocator) void {
        alloc.free(self.rows);
    }

    fn is_okay(self: *const Self, row: usize, col_min: usize, col_max: usize) bool {
        // print("is_okay({}, {}..={})\n", .{ row, col_min, col_max });
        const row_indices = self.get_row(row);
        // print("row_indices {any}\n", .{row_indices});
        if (row_indices.len == 0) return false;
        if (col_min < row_indices[0]) return false;
        var i: usize = 0;
        while (i < row_indices.len) : (i += 2) {
            if (row_indices[i] <= col_min) {
                return row_indices[i + 1] >= col_max;
            }
        }
        return false;
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
