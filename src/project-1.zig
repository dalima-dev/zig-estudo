// https://pedropark99.github.io/zig-book/Chapters/01-base64

const std = @import("std");

const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";
        return Base64{
            ._table = upper ++ lower ++ numbers_symb,
        };
    }

    pub fn _char_at(self: Base64, index: u8) u8 {
        return self._table[index];
    }
};

pub fn main() !void {
    std.debug.print("Projeto 1 do livro Introduction to Zig.\n", .{});
}
