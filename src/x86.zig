/// Sometimes we really need to use assembly opcode.
/// For example to load a new interrupt descriptor table...
/// Opcodes can be found here: https://shell-storm.org/x86doc/
/// Here is the list of opcodes available.
///     - cli: Clear the interrupt flag
///     - hlt: Stops instruction execution and places the processor in HALT state.
pub inline fn cli() void {
    asm volatile ("cli");
}

pub inline fn hlt() void {
    asm volatile ("hlt");
}

pub inline fn black_hole() noreturn {
    // We clear interrupts flags and loop forever
    cli();
    while (true) {
        hlt();
    }
}
