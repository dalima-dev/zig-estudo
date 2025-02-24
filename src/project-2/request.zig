const std = @import("std");
const Connection = std.net.Server.Connection;
const Map = std.static_string_map.StaticStringMap;

const MethodMap = Map(Method).initComptime(.{
    .{ "GET", Method.GET },
});

pub const Method = enum {
    GET,
    pub fn init(text: []const u8) !Method {
        return MethodMap.get(text).?;
    }
    pub fn is_supported(m: []const u8) bool {
        const method = MethodMap.get(m);
        if (method) |_| {
            return true;
        }
        return false;
    }
};

pub fn read_request(connection: Connection, buffer: []u8) !void {
    const reader = connection.stream.reader();
    _ = try reader.read(buffer);
}
