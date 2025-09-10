const std = @import("std");
const testing = std.testing;
const expectEqual = testing.expectEqual;
const expectEqualDeep = testing.expectEqualDeep;
const ArrayListManaged = if (@hasDecl(std, "array_list")) std.array_list.Managed else std.ArrayList;
const ArrayListUnmanaged = if (@hasDecl(std, "ArrayListUnmanaged")) std.ArrayListUnmanaged else std.ArrayList;
const allocator = std.testing.allocator;

const collections = @import("zig_collections");
const Counter = collections.Counter;

const _ = ArrayListUnmanaged;  // FIXME

test "add from slice" {
    var counter = Counter(u8).init(allocator);
    defer counter.deinit();

    const array = [_]u8{ 1, 2, 2, 3, 3, 3 };
    try counter.addFromSlice(array[0..]);
    try expectEqual(1, counter.get(1));
    try expectEqual(2, counter.get(2));
    try expectEqual(3, counter.get(3));
}

test "add from iterator" {
    var counter = Counter([]const u8).init(allocator);
    defer counter.deinit();

    const text = "alice bob alice";
    var iterator = std.mem.splitScalar(u8, text, ' ');
    try counter.addFromIterator(&iterator);
    try expectEqual(2, counter.get("alice"));
    try expectEqual(1, counter.get("bob"));
}

test "DefaultHashMap with list" {
    const EmptyArrayListFactory = struct {
        allocator: std.mem.Allocator,

        fn produce(self: @This()) ArrayListManaged(u8) {
            return ArrayListManaged(u8).init(self.allocator);
        }
    };

    var map = collections.DefaultHashMap(
        u8,
        ArrayListManaged(u8),
        EmptyArrayListFactory{ .allocator = allocator },
        EmptyArrayListFactory.produce,
    ).init(allocator);

    defer map.deinit();

    const array = [_]u8{ 3, 3, 1, 2, 3, 2 };
    for (array, 0..) |item, i| {
        try map.get(item).append(@intCast(i));
    }

    try expectEqualDeep(&[_]u8{2}, map.get(1).items);
    try expectEqualDeep(&[_]u8{ 3, 5 }, map.get(2).items);
    try expectEqualDeep(&[_]u8{ 0, 1, 4 }, map.get(3).items);
}
