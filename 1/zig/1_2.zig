// --- Part Two ---

// The Elves in accounting are thankful for your help; one of them even offers
// you a starfish coin they had left over from a past vacation. They offer you a
// second one if you can find three numbers in your expense report that meet the
// same criteria.

// Using the above example again, the three entries that sum to 2020 are 979,
// 366, and 675. Multiplying them together produces the answer, 241861950.

// In your expense report, what is the product of the three entries that sum to
// 2020?

const std = @import("std");
const Allocator = std.mem.Allocator;

fn solve(comptime nextClosure: type, alloc: *Allocator, next: nextClosure) !i64 {
    var numbers = std.ArrayList(i64).init(alloc);
    defer numbers.deinit();

    while (next.call({})) |a| {
        for (numbers.items) |b, bi| {
            for (numbers.items) |c, ci| {
                if (bi == ci) {
                    continue;
                }
                if (a + b + c == 2020) {
                    return a * b * c;
                }
            }
        }
        try numbers.append(a);
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

    const expected = 241861950;
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
