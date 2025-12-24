const multiboot2 = @import("multiboot2.zig").multiboot2;
const serial = @import("serial.zig");

export const multiboot_header linksection(".multiboot") = multiboot2.Header{};

export fn _start() noreturn {
    serial.uart_init();
    serial.uart_write_string("Hello, world from Zig OS!\n");

    while (true) {
        asm volatile ("hlt");
    }
}
