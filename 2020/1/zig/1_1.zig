// --- Day 1: Report Repair ---

// After saving Christmas five years in a row, you've decided to take a vacation
// at a nice resort on a tropical island. Surely, Christmas will go on without
// you.

// The tropical island has its own currency and is entirely cash-only. The gold
// coins used there have a little picture of a starfish; the locals just call
// them stars. None of the currency exchanges seem to have heard of them, but
// somehow, you'll need to find fifty of these coins by the time you arrive so
// you can pay the deposit on your room.

// To save your vacation, you need to get all fifty stars by December 25th.

// Collect stars by solving puzzles. Two puzzles will be made available on each
// day in the Advent calendar; the second puzzle is unlocked when you complete
// the first. Each puzzle grants one star. Good luck!

// Before you leave, the Elves in accounting just need you to fix your expense
// report (your puzzle input); apparently, something isn't quite adding up.

// Specifically, they need you to find the two entries that sum to 2020 and then
// multiply those two numbers together.

// For example, suppose your expense report contained the following:

// 1721 979 366 299 675 1456

// In this list, the two entries that sum to 2020 are 1721 and 299. Multiplying
// them together produces 1721 * 299 = 514579, so the correct answer is 514579.

// Of course, your expense report is much larger. Find the two entries that sum
// to 2020; what do you get if you multiply them together?

const std = @import("std");
const Allocator = std.mem.Allocator;

fn solve(comptime nextClosure: type, alloc: *Allocator, next: nextClosure) !i64 {
    var numbers = std.ArrayList(i64).init(alloc);
    defer numbers.deinit();

    while (next.call({})) |n| {
        for (numbers.items) |m| {
            if (n + m == 2020) {
                return n * m;
            }
        }
        try numbers.append(n);
    }

    unreachable;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = &arena.allocator;

    var stdin = std.io.bufferedReader(std.io.getStdIn().reader()).reader();

    // So, I wanted to emulate what I did in Go, ie. passing a next function
    // that solve can call to get the next number. Turns out Zig doesn't have
    // closures, so I kind of emulated them with this Closure thing. There's
    // probably a more elegant way of doing it, though.

    const nextEnv = .{ .stdin = stdin, .alloc = alloc };
    const nextEnvType = @TypeOf(nextEnv);
    var next = Closure(nextEnvType, void, ?i64).init(nextEnv, struct {
        fn call(env: *nextEnvType, arg: void) ?i64 {
            const line = env.stdin.readUntilDelimiterAlloc(env.alloc, '\n', 4096) catch null orelse return null;
            defer env.alloc.free(line);
            return std.fmt.parseInt(i64, line, 10) catch null;
        }
    }.call);

    const solution = try solve(@TypeOf(&next), alloc, &next);

    try std.io.getStdOut().writer().print("{}\n", .{solution});
}

test "example" {
    const nextEnv: struct {
        numbers: [6]i64,
        i: usize,
    } = .{
        .numbers = .{
            1721,
            979,
            366,
            299,
            675,
            1456,
        },
        .i = 0,
    };
    const nextEnvType = @TypeOf(nextEnv);
    var next = Closure(nextEnvType, void, ?i64).init(nextEnv, struct {
        fn call(env: *nextEnvType, arg: void) ?i64 {
            if (env.i >= env.numbers.len) {
                return null;
            }
            const n = env.numbers[env.i];
            env.i += 1;
            return n;
        }
    }.call);

    const expected = 514579;
    const got = try solve(@TypeOf(&next), std.testing.allocator, &next);

    std.debug.assert(expected == got);
}

pub fn Closure(
    comptime Env: type,
    comptime Arg: type,
    comptime Result: type,
) type {
    return struct {
        env: Env,
        f: fn (*Env, Arg) Result,

        pub fn init(env: Env, f: fn (*Env, Arg) Result) @This() {
            return .{ .env = env, .f = f };
        }

        pub fn call(self: *@This(), arg: Arg) Result {
            return self.f(&self.env, arg);
        }
    };
}
