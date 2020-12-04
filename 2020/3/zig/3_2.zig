// --- Part Two ---

// Time to check the rest of the slopes - you need to minimize the probability
// of a sudden arboreal stop, after all.

// Determine the number of trees you would encounter if, for each of the
// following slopes, you start at the top-left corner and traverse the map all
// the way to the bottom:

//     Right 1, down 1. Right 3, down 1. (This is the slope you already checked.)
//     Right 5, down 1. Right 7, down 1. Right 1, down 2.

// In the above example, these slopes would find 2, 7, 3, 4, and 2 tree(s)
// respectively; multiplied together, these produce the answer 336.

// What do you get if you multiply together the number of trees encountered on
// each of the listed slopes?

const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

fn solve(comptime Scanner: type, alloc: *Allocator, scanner: Scanner) !i64 {
    var m = try treeMap.init(alloc);
    defer m.deinit();

    while (scanner.next()) |n| {
        try m.addRow(n);
    }

    const vec2 = struct {
        x: usize,
        y: usize,
    };
    const directions = [_]vec2{
        .{ .x = 1, .y = 1 },
        .{ .x = 3, .y = 1 },
        .{ .x = 5, .y = 1 },
        .{ .x = 7, .y = 1 },
        .{ .x = 1, .y = 2 },
    };

    var treesFoundMultiplied: i64 = 1;
    for (directions) |d| {
        var treesFound: i64 = 0;
        var x: usize = 0;
        var y: usize = 0;
        while (m.cell(x, y)) |hasTree| {
            if (hasTree) {
                treesFound += 1;
            }
            x += d.x;
            y += d.y;
        }
        treesFoundMultiplied *= treesFound;
    }

    return treesFoundMultiplied;
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

    const expected = 336;
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
