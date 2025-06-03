# Zig Collections

![Zig 0.14.0](https://img.shields.io/badge/Zig-0.14.0-orange) [![zig build test](https://github.com/insolor/zig-collections/actions/workflows/zig-build-test.yml/badge.svg)](https://github.com/insolor/zig-collections/actions/workflows/zig-build-test.yml)

Implementation of some useful data structures in Zig. Inspired by Python's `collections` module.

## Installation

1. In the root directory of your project, run the following command to add `zig_collections` to your `build.zig.zon` file:

    ```bash
    zig fetch --save https://github.com/insolor/zig-collections/archive/refs/heads/main.zip
    ```

    Replace `main` in the URL with the tag you want to use.

2. Add zig_collections as a dependency module in your `build.zig` file, example:

    ```zig
    const zig_collections = b.dependency("zig_collections", .{});
    exe.root_module.addImport("zig_collections", zig_collections.module("zig_collections"));
    ```

After that, you'll be able to import `zig_collections` namespace from your code:

```zig
const zig_collections = @import("zig_collections");
const Counter = zig_collections.Counter;
const DefaultHashMap = zig_collections.DefaultHashMap;
```

## Usage examples

Implemented so far:

- ✅ `Counter`:
  - a minimal functionality is implemented: increment of a value of a key, counting of duplicate values from a slice or an iterator
- ✅ `defaultdict` (`DefaultHashMap`)

`Counter` usage examples:

```zig
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
```

`DefaultHashMap` example:

```zig
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
        try map.get(item).append(@intCast(i));
    }

    try expectEqualDeep(&[_]u8{2}, map.get(1).items);
    try expectEqualDeep(&[_]u8{ 3, 5 }, map.get(2).items);
    try expectEqualDeep(&[_]u8{ 0, 1, 4 }, map.get(3).items);
}
```
