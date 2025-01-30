const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

const maxColumns = 80;
const maxRows = 40;

pub var editor: [maxRows][maxColumns]u8 = undefined;

fn readColumnsInput() !u8 {
    var buffer: [256]u8 = undefined;
    var columns: u8 = 0;

    while ((columns < 50) or (columns > maxColumns)) {
        const bytes_read = try stdin.readUntilDelimiterOrEof(buffer[0..], '\n');

        if (bytes_read) |slice| {
            columns = try std.fmt.parseInt(u8, slice, 10);
        }
    }

    return columns;
}

pub fn main() !void {
    try stdout.print("Digite a largura da página (valor entre 50 a 80):\n", .{});

    const columns = readColumnsInput();

    std.debug.print("{!}\n", .{columns});
}
