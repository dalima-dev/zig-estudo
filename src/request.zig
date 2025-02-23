const std = @import("std");
const Connection = std.net.Server.Connection;

pub fn read_request(connection: Connection, buffer: []u8) !void {
    const reader = connection.stream.reader();
    _ = try reader.read(buffer);
}
