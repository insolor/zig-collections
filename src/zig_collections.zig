const std = @import("std");
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const Allocator = std.mem.Allocator;

fn CounterMapType(comptime T: type) type {
    return if (T == []const u8) StringHashMap(usize) else AutoHashMap(T, usize);
}

pub fn Counter(comptime T: type) type {
    return struct {
        map: CounterMapType(T),

        pub inline fn init(allocator: Allocator) Counter(T) {
            return Counter(T){
                .map = CounterMapType(T).init(allocator),
            };
        }

        pub inline fn deinit(self: *Counter(T)) void {
            self.map.deinit();
        }

        pub inline fn inc(self: *Counter(T), item: T) !void {
            const value = self.map.get(item) orelse 0;
            try self.map.put(item, value + 1);
        }

        pub inline fn addFromSlice(self: *Counter(T), slice: []const T) !void {
            for (slice) |item| {
                try self.inc(item);
            }
        }

        pub inline fn addFromIterator(self: *Counter(T), iterator: anytype) !void {
            while (iterator.next()) |item| {
                try self.inc(item);
            }
        }

        pub inline fn get(self: Counter(T), key: T) usize {
            return self.map.get(key) orelse 0;
        }
    };
}

pub fn DefaultHashMap(
    comptime K: type,
    comptime V: type,
    comptime context: anytype,
    comptime defaultFactory: fn (@TypeOf(context)) V,
) type {
    return struct {
        const Self = @This();

        map: AutoHashMap(K, V),

        pub inline fn init(allocator: Allocator) Self {
            return .{
                .map = AutoHashMap(K, V).init(allocator),
            };
        }

        inline fn deinitValues(self: *Self) void {
            var value_iterator = self.map.valueIterator();
            while (value_iterator.next()) |positions| {
                positions.deinit();
            }
        }

        pub inline fn deinit(self: *Self) void {
            self.deinitValues();
            self.map.deinit();
        }

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
