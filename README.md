# Zig Collections

[![Zig 0.14.0, 0.14.1, 0.15.1, 0.15.2, master](https://img.shields.io/badge/Zig-0.14.0%20%7C%200.14.1%20%7C%200.15.1%20%7C%200.15.2%20%7C%20master-color?logo=zig&color=%23f3ab20)](https://github.com/ziglang/zig) <!-- see zig tag examples at https://github.com/KurtWagner/what-the-zig -->
[![zig build test](https://github.com/insolor/zig-collections/actions/workflows/zig-build-test.yml/badge.svg)](https://github.com/insolor/zig-collections/actions/workflows/zig-build-test.yml)
[![documentation](https://img.shields.io/badge/docs-mkdocs-708FCC.svg?style=flat)](https://insolor.github.io/zig-collections/)

Implementation of some useful data structures in Zig. Inspired by Python's [`collections`](https://docs.python.org/3/library/collections.html) module.

## Installation

1. In the root directory of your project, run the following command to add `zig_collections` to your `build.zig.zon` file (replace 0.0.2 with the latest release number):

    ```bash
    zig fetch --save https://github.com/insolor/zig-collections/archive/refs/tags/0.0.2.zip
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

### `Counter` usage examples

```zig
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
```

### `DefaultHashMap` example

```zig
test "DefaultHashMap with list" {
    const EmptyArrayListFactory = struct {
        allocator: std.mem.Allocator,

        fn produce(self: @This()) ArrayList(u8) {
            return ArrayList(u8).init(self.allocator);
        }
    };

    var map = collections.DefaultHashMap(
        u8,
        ArrayList(u8),
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
```

Corresponding Python code:

```python
from collections import defaultdict

dmap = defaultdict(list)

array = [3, 3, 1, 2, 3, 2]
for i, item in enumerate(array):
    dmap[item].append(i)

assert [2] == dmap[1]
assert [3, 5] == dmap[2]
assert [0, 1, 4] == dmap[3]
```
