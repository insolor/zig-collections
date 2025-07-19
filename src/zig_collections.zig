const std = @import("std");
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const Allocator = std.mem.Allocator;

fn CounterMapType(comptime T: type) type {
    return if (T == []const u8) StringHashMap(usize) else AutoHashMap(T, usize);
}

/// Generic counter collection for counting occurrences of elements.
/// For string keys ([]const u8), uses optimized StringHashMap.
/// For other types, uses general-purpose AutoHashMap.
/// Factory function must be compatible with the context parameter type.
pub fn Counter(comptime T: type) type {
    return struct {
        map: CounterMapType(T),

        /// Creates new counter with given allocator
        pub inline fn init(allocator: Allocator) Counter(T) {
            return Counter(T){
                .map = CounterMapType(T).init(allocator),
            };
        }

        /// Frees all allocated memory
        pub inline fn deinit(self: *Counter(T)) void {
            self.map.deinit();
        }

        /// Increments count for item by 1
        pub inline fn inc(self: *Counter(T), item: T) !void {
            const value = self.map.get(item) orelse 0;
            try self.map.put(item, value + 1);
        }

        /// Counts all items in slice
        pub inline fn addFromSlice(self: *Counter(T), slice: []const T) !void {
            for (slice) |item| {
                try self.inc(item);
            }
        }

        /// Counts all items from iterator
        pub inline fn addFromIterator(self: *Counter(T), iterator: anytype) !void {
            while (iterator.next()) |item| {
                try self.inc(item);
            }
        }

        /// Returns current count for key (0 if not present)
        pub inline fn get(self: Counter(T), key: T) usize {
            return self.map.get(key) orelse 0;
        }
    };
}

/// Auto-initializing map with default value factory.
pub fn DefaultHashMap(
    comptime K: type,
    comptime V: type,
    comptime context: anytype,
    comptime defaultFactory: fn (@TypeOf(context)) V,
) type {
    return struct {
        const Self = @This();

        map: AutoHashMap(K, V),

        /// Creates new map with given allocator
        pub inline fn init(allocator: Allocator) Self {
            return .{
                .map = AutoHashMap(K, V).init(allocator),
            };
        }

        /// Deinitializes values of the map. Do not use directly.
        inline fn deinitValues(self: *Self) void {
            var value_iterator = self.map.valueIterator();
            while (value_iterator.next()) |positions| {
                positions.deinit();
            }
        }

        /// Properly deinitializes map and all values
        pub inline fn deinit(self: *Self) void {
            self.deinitValues();
            self.map.deinit();
        }

        /// Returns pointer to value (creates default if missing)
        pub inline fn get(self: *Self, key: K) *V {
            const value: ?*V = self.map.getPtr(key);
            if (value) |v| {
                return v;
            }

            const new_value = defaultFactory(context);
            self.map.put(key, new_value) catch unreachable;
            return self.map.getPtr(key).?;
        }
    };
}
