const std = @import("std");
const config = @import("config.zig");
const req = @import("request.zig");
const res = @import("response.zig");
const stdout = std.io.getStdOut().writer();

pub fn initialize_buffer() [1000]u8 {
    var buffer: [1000]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }

    return buffer;
}

pub fn main() !void {
    const socket = try config.Socket.init();
    try stdout.print("Server Addr: {any}\n", .{socket._address});

    var server = try socket._address.listen(.{});
    const connection = try server.accept();

    var buffer = initialize_buffer();
    try req.read_request(connection, &buffer);
    const request = req.parse_request(&buffer);

    if (request.method == req.Method.GET) {
        if (std.mem.eql(u8, request.uri, "/")) {
            try res.send_200(connection);
        } else {
            try res.send_404(connection);
        }
    }

    try stdout.print("{any}\n", .{request});
}
