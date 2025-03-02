const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Stack(comptime T: type) type {
    return struct {
        items: []T,
        capacity: usize,
        length: usize,
        allocator: Allocator,
        const Self = @This();

        pub fn init(allocator: Allocator, capacity: usize) !Stack(T) {
            var buf = try allocator.alloc(T, capacity);

            return .{
                .items = buf[0..],
                .capacity = capacity,
                .length = 0,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, val: T) !void {
            if ((self.length + 1) > self.capacity) {
                const capacity = self.capacity * 2;
                var buffer = try self.allocator.alloc(T, capacity);
                @memcpy(buffer[0..self.capacity], self.items);

                self.allocator.free(self.items);
                self.items = buffer;
                self.capacity = capacity;
            }

            self.items[self.length] = val;
            self.length += 1;
        }

        pub fn pop(self: *Self) void {
            if (self.length == 0) return;

            self.length -= 1;
            self.items[self.length] = undefined;
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const Stacku8 = Stack(u8);
    var stack = try Stacku8.init(allocator, 10);
    defer stack.deinit();

    while (stack.length < 15) {
        try stack.push(1);

        std.debug.print("Stack len: {d}\n", .{stack.length});
        std.debug.print("Stack capacity: {d}\n", .{stack.capacity});
    }

    std.debug.print("Stack state: {any}\n", .{stack.items[0..stack.length]});

    while (stack.length == 0) {
        stack.pop();

        std.debug.print("Stack len: {d}\n", .{stack.length});
        std.debug.print("Stack capacity: {d}\n", .{stack.capacity});
    }

    std.debug.print("Stack state: {any}\n", .{stack.items[0..stack.length]});
}
