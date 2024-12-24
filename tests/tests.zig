const std = @import("std");
const testing = std.testing;
const expectEqual = testing.expectEqual;
const expectEqualDeep = testing.expectEqualDeep;
const ArrayList = std.ArrayList;
const allocator = std.testing.allocator;

const collections = @import("zig-collections");
const Counter = collections.Counter;

test "test add from slice" {
    var counter = Counter(u8).init(allocator);
    defer counter.deinit();

    const array = [_]u8{ 1, 2, 2, 3, 3, 3 };
    try counter.addFromSlice(array[0..]);
    try expectEqual(1, counter.get(1));
    try expectEqual(2, counter.get(2));
    try expectEqual(3, counter.get(3));
}

test "test add from iterator" {
    var counter = Counter([]const u8).init(allocator);
    defer counter.deinit();

    const text = "alice bob alice";
    var iterator = std.mem.splitSequence(u8, text, " ");
    try counter.addFromIterator(&iterator);
    try expectEqual(2, counter.get("alice"));
    try expectEqual(1, counter.get("bob"));
}

test "test defaulthashmap list" {
    const Factory = struct {
        allocator: std.mem.Allocator,

        fn produce(self: @This()) ArrayList(u8) {
            return ArrayList(u8).init(self.allocator);
        }
    };

    var map = collections.DefaultHashMap(
        u8,
        ArrayList(u8),
        Factory{ .allocator = allocator },
        Factory.produce,
    ).init(allocator);

    defer {
        map.deinitValues();
        map.deinit();
    }

    const array = [_]u8{ 3, 3, 1, 2, 3, 2 };
    for (array, 0..) |item, i| {
        map.get(item).append(@intCast(i)) catch unreachable;
    }

    try expectEqualDeep(&[_]u8{2}, map.get(1).items);
    try expectEqualDeep(&[_]u8{ 3, 5 }, map.get(2).items);
    try expectEqualDeep(&[_]u8{ 0, 1, 4 }, map.get(3).items);
}
