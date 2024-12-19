# Zig Collections

Implementation of some common data structures in Zig. Inspired by Python's `collections` module.

TODO:

- [x] Counter
- [ ] defaultdict (DefaultHashMap)

`Counter` usage examples:

```zig
test "test add from slice" {
    var counter = Counter(u8).init(std.testing.allocator);
    defer counter.deinit();

    const array = [_]u8{ 1, 2, 2, 3, 3, 3 };
    try counter.addFromSlice(array[0..]);
    try expectEqual(1, counter.get(1));
    try expectEqual(2, counter.get(2));
    try expectEqual(3, counter.get(3));
}

test "test add from iterator" {
    var counter = Counter([]const u8).init(std.testing.allocator);
    defer counter.deinit();

    const text = "alice bob alice";
    var iterator = std.mem.splitSequence(u8, text, " ");
    try counter.addFromIterator(&iterator);
    try expectEqual(2, counter.get("alice"));
    try expectEqual(1, counter.get("bob"));
}
```
