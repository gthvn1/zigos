const uart_port: u16 = 0x3F8; // COM1

// Grub uses multiboot2
const multiboot2 = struct {
    pub const MAGIC: u32 = 0xe85250d6;
    pub const ARCH: u32 = 0; // i386 protected mode
    pub const HEADER_LEN: u32 = 64;

    pub const Header = extern struct {
        magic: u32 = MAGIC,
        architecture: u32 = ARCH,
        header_length: u32 = HEADER_LEN,
        checksum: u32 = 0 -% (MAGIC + ARCH + HEADER_LEN),

        // Required end tag
        end_tag_type: u16 = 0,
        end_tag_flags: u16 = 0,
        end_tag_size: u32 = 8,
    };
};

export const multiboot_header linksection(".multiboot") = multiboot2.Header{};

// For debug print to uart
fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "{dx}" (port),
    );
}

fn uart_init() void {
    outb(uart_port + 1, 0x00); // Disable interrupts
    outb(uart_port + 3, 0x80); // Enable DLAB
    outb(uart_port + 0, 0x03); // Baud rate divisor (lo byte)
    outb(uart_port + 1, 0x00); // (hi byte)
    outb(uart_port + 3, 0x03); // 8 bits, no parity, one stop bit
    outb(uart_port + 2, 0xC7); // Enable FIFO
    outb(uart_port + 4, 0x0B); // IRQs enabled, RTS/DSR set
}

fn uart_write_byte(byte: u8) void {
    outb(uart_port, byte);
}

fn uart_write_string(s: []const u8) void {
    for (s) |c| {
        uart_write_byte(c);
    }
}

export fn _start() noreturn {
    uart_init();
    uart_write_string("Hello, world from Zig OS!\n");

    while (true) {
        asm volatile ("hlt");
    }
}
