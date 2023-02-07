const mem = @import("std").mem;

// screen properties
const VGA_ADDR = 0xB8000;
const VGA_WIDTH = 80;
const VGA_HEIGHT = 25;
const VGA_SIZE = VGA_WIDTH * VGA_HEIGHT;

// colors definitions
pub const VGAColor = enum(u4) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
};

const VGAEntry = packed struct {
    char: u8,
    foreground: VGAColor, // u4
    background: VGAColor, // u4
};

// Terminal state
var term_row: u8 = undefined;
var term_column: u8 = undefined;
var term_buff = @intToPtr([*]VGAEntry, VGA_ADDR);

fn putEntryAt(entry: VGAEntry, x: u8, y: u8) void {
    const index: u8 = y * VGA_WIDTH + x;
    term_buff[index] = entry;
}

fn putChar(c: u8, fg: VGAColor, bg: VGAColor) void {
    var entry = VGAEntry{
        .char = c,
        .foreground = fg,
        .background = bg,
    };
    putEntryAt(entry, term_column, term_row);
    // Update row and columns
    term_column += 1;
    if (term_column == VGA_WIDTH) {
        nextLine();
    }
}

pub fn initialize() void {
    var space_entry = VGAEntry{
        .char = ' ',
        .foreground = VGAColor.Green,
        .background = VGAColor.Black,
    };
    term_row = 0;
    term_column = 0;
    mem.set(VGAEntry, term_buff[0..VGA_SIZE], space_entry);
}

pub fn nextLine() void {
    term_column = 0;
    term_row += 1;
    if (term_row == VGA_HEIGHT) {
        term_row = 0;
    }
}

pub fn write(s: []const u8, fg: VGAColor, bg: VGAColor) void {
    for (s) |c| {
        putChar(c, fg, bg);
    }
}
