const std = @import("std");
const stdin = std.io.getStdIn().reader();
const stdout = std.io.getStdOut().writer();

const maxColumns = 80;
const maxRows = 40;

pub var editor: [maxRows][maxColumns]u8 = undefined;

fn intializeEditor() void {
    for (editor, 0..) |row, i| {
        for (row, 0..) |element, j| {
            editor[i][j] = 0;
            _ = element;
        }
    }
}

fn printEditor() void {
    for (editor, 0..) |row, i| {
        for (row, 0..) |element, j| {
            editor[i][j] = 1;
            std.debug.print("{} ", .{element}); // Format each element to take up 3 spaces
        }
        std.debug.print("\n", .{}); // Newline after each row
    }
}

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

fn readTextInput() !?[]const u8 {
    var buffer: [100]u8 = undefined;
    const bytes_read = try stdin.readUntilDelimiterOrEof(buffer[0..], '\n');

    if (bytes_read) |bytes| {
        return buffer[0..bytes.len];
    }

    return null;
}

pub fn main() !void {
    intializeEditor();

    // try stdout.print("Digite a largura da página (valor entre 50 a 80):\n", .{});
    // const columns = readColumnsInput();

    while (true) {
        try stdout.print("Digite um texto de até 100 caracteres:\n", .{});
        const text_read = readTextInput() catch "";

        if (text_read) |text| {
            if (text.len == 0) {
                try stdout.print("Encerrou!\n", .{});
                return;
            }
        }
    }

    printEditor();
}
