// --- Day 3: Toboggan Trajectory ---

// With the toboggan login problems resolved, you set off toward the airport.
// While travel by toboggan might be easy, it's certainly not safe: there's very
// minimal steering and the area is covered in trees. You'll need to see which
// angles will take you near the fewest trees.

// Due to the local geology, trees in this area only grow on exact integer
// coordinates in a grid. You make a map (your puzzle input) of the open squares
// (.) and trees (#) you can see. For example:

// ..##.......
// #...#...#..
// .#....#..#.
// ..#.#...#.#
// .#...##..#.
// ..#.##.....
// .#.#.#....#
// .#........#
// #.##...#...
// #...##....#
// .#..#...#.#

// These aren't the only trees, though; due to something you read about once
// involving arboreal genetics and biome stability, the same pattern repeats to
// the right many times:

// ..##.........##.........##.........##.........##.........##.......  --->
// #...#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
// .#....#..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
// ..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
// .#...##..#..#...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
// ..#.##.......#.##.......#.##.......#.##.......#.##.......#.##.....  --->
// .#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
// .#........#.#........#.#........#.#........#.#........#.#........#
// #.##...#...#.##...#...#.##...#...#.##...#...#.##...#...#.##...#...
// #...##....##...##....##...##....##...##....##...##....##...##....#
// .#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#.#..#...#.#  --->

// You start on the open square (.) in the top-left corner and need to reach the
// bottom (below the bottom-most row on your map).

// The toboggan can only follow a few specific slopes (you opted for a cheaper
// model that prefers rational numbers); start by counting all the trees you
// would encounter for the slope right 3, down 1:

// From your starting position at the top-left, check the position that is right
// 3 and down 1. Then, check the position that is right 3 and down 1 from there,
// and so on until you go past the bottom of the map.

// The locations you'd check in the above example are marked here with O where
// there was an open square and X where there was a tree:

// ..##.........##.........##.........##.........##.........##.......  --->
// #..O#...#..#...#...#..#...#...#..#...#...#..#...#...#..#...#...#..
// .#....X..#..#....#..#..#....#..#..#....#..#..#....#..#..#....#..#.
// ..#.#...#O#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#..#.#...#.#
// .#...##..#..X...##..#..#...##..#..#...##..#..#...##..#..#...##..#.
// ..#.##.......#.X#.......#.##.......#.##.......#.##.......#.##.....  --->
// .#.#.#....#.#.#.#.O..#.#.#.#....#.#.#.#....#.#.#.#....#.#.#.#....#
// .#........#.#........X.#........#.#........#.#........#.#........#
// #.##...#...#.##...#...#.X#...#...#.##...#...#.##...#...#.##...#...
// #...##....##...##....##...#X....##...##....##...##....##...##....#
// .#..#...#.#.#..#...#.#.#..#...X.#.#..#...#.#.#..#...#.#.#..#...#.#  --->

// In this example, traversing the map using this slope would cause you to
// encounter 7 trees.

// Starting at the top-left corner of your map and following a slope of right 3
// and down 1, how many trees would you encounter?

const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

fn solve(comptime Scanner: type, alloc: *Allocator, scanner: Scanner) !i64 {
    var m = try treeMap.init(alloc);
    defer m.deinit();

    while (scanner.next()) |n| {
        try m.addRow(n);
    }

    var treesFound: i64 = 0;
    var x: usize = 0;
    var y: usize = 0;
    while (m.cell(x, y)) |hasTree| {
        if (hasTree) {
            treesFound += 1;
        }
        x += 3;
        y += 1;
    }

    return treesFound;
}

const treeMap = struct {
    alloc: *Allocator,
    width: usize,
    rows: ArrayList([]bool),

    fn init(alloc: *Allocator) !*treeMap {
        const m = try alloc.create(treeMap);
        m.* = .{
            .alloc = alloc,
            .width = 0,
            .rows = ArrayList([]bool).init(alloc),
        };
        return m;
    }

    fn deinit(self: *@This()) void {
        for (self.rows.items) |r| {
            self.alloc.free(r);
        }
        self.rows.deinit();
        self.alloc.destroy(self);
    }

    fn addRow(self: *@This(), row: []const u8) !void {
        self.width = row.len;
        var trees = try self.alloc.alloc(bool, row.len);
        for (trees) |_, i| trees[i] = false;
        for (row) |c, i| {
            if (c == '#') {
                trees[i] = true;
            }
        }
        try self.rows.append(trees);
    }

    fn cell(self: @This(), x: usize, y: usize) ?bool {
        if (y >= self.rows.items.len) {
            return null;
        }
        // The map repeats indefinitely on the horizontal axis, so, if we go past
        // the width, wrap around.
        const effectiveX = x % self.width;
        return self.rows.items[y][effectiveX];
    }
};

pub fn main() !void {
    try tests();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = &arena.allocator;

    var stdin = std.io.bufferedReader(std.io.getStdIn().reader()).reader();
    var next = readerScanner(@TypeOf(stdin)).init(alloc, stdin);

    const solution = try solve(@TypeOf(&next), alloc, &next);

    try std.io.getStdOut().writer().print("{}\n", .{solution});
}

fn readerScanner(comptime Reader: type) type {
    return struct {
        alloc: *Allocator,
        r: Reader,
        prev: ?[]const u8,

        fn init(alloc: *Allocator, r: Reader) @This() {
            return .{ .alloc = alloc, .r = r, .prev = null };
        }

        fn next(self: *@This()) ?[]const u8 {
            if (self.prev) |prev| {
                self.alloc.free(prev);
            }
            const line = self.r.readUntilDelimiterAlloc(
                self.alloc,
                '\n',
                4096,
            ) catch null orelse return null;
            self.prev = line;
            return line;
        }
    };
}

fn tests() !void {
    var next = constScanner([]const u8).init(([_][]const u8{
        "..##.......",
        "#...#...#..",
        ".#....#..#.",
        "..#.#...#.#",
        ".#...##..#.",
        "..#.##.....",
        ".#.#.#....#",
        ".#........#",
        "#.##...#...",
        "#...##....#",
        ".#..#...#.#",
    })[0..]);

    const expected = 7;
    const got = try solve(@TypeOf(&next), std.testing.allocator, &next);

    std.debug.assert(expected == got);
}

fn constScanner(comptime T: type) type {
    return struct {
        items: []const T,
        i: usize,

        fn init(items: []const T) @This() {
            return .{ .items = items, .i = 0 };
        }

        fn next(self: *@This()) ?T {
            if (self.i >= self.items.len) {
                return null;
            }
            const item = self.items[self.i];
            self.i += 1;
            return item;
        }
    };
}
