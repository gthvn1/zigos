const uart_port: u16 = 0x3F8; // COM1

fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "{dx}" (port),
    );
}

pub fn uart_init() void {
    outb(uart_port + 1, 0x00); // Disable interrupts
    outb(uart_port + 3, 0x80); // Enable DLAB
    outb(uart_port + 0, 0x03); // Baud rate divisor (lo byte)
    outb(uart_port + 1, 0x00); // (hi byte)
    outb(uart_port + 3, 0x03); // 8 bits, no parity, one stop bit
    outb(uart_port + 2, 0xC7); // Enable FIFO
    outb(uart_port + 4, 0x0B); // IRQs enabled, RTS/DSR set
}

pub fn uart_write_byte(byte: u8) void {
    outb(uart_port, byte);
}

pub fn uart_write_string(s: []const u8) void {
    for (s) |c| {
        uart_write_byte(c);
    }
}
