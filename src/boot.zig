const tty = @import("tty.zig");

const ALIGN = 1 << 0; // align loaded modules on page boundaries
const MEMINFO = 1 << 1; // provide memory map
const FLAGS = ALIGN | MEMINFO; // this is the Multiboot 'flag' field
const MAGIC = 0x1BADB002; // 'magic' lets bootloader find the header
const CHECKSUM = -(MAGIC + FLAGS); // checksum to prove we are multiboot

const MultibootHeader = packed struct {
    magic: i32 = MAGIC,
    flags: i32 = FLAGS,
    checksum: i32 = CHECKSUM,
};

export var multiboot align(4) linksection(".multiboot") = MultibootHeader{};

export fn kmain() callconv(.Naked) noreturn {
    const banner = "-= ZigOS 0.1 =-";

    tty.initialize();
    tty.write(banner, tty.VGAColor.Green, tty.VGAColor.Black);
    tty.nextLine();
    tty.nextLine();
    tty.write("Hello, World!", tty.VGAColor.White, tty.VGAColor.Black);

    while (true) {}
}
