// GDT: Global Descriptor Table
//
// https://wiki.osdev.org/GDT_Tutorial
//
// As said GDT is a table of DESCRIPTORS.
//
// At least in the GDT you need to store:
//      - An enty0: Null Descriptor
//      - A DPL0 Code Segment descriptor for the kernel
//      - A Data Segment descriptor
//      - A Task State Segment descriptor
//          - holds information about a task (used for HW task
//            switching for example).
//      - Room for more segments...
//
// When Setup interruptions must be turned off (CLI)
// The access bytes meaning is related to the kind of the segement.
//
// GDTR (GDT register) as a size and an offset.
const tty = @import("tty.zig");

const AccessByte = packed struct {
    a: u1, // Accessed bit
    rw: u1, // Readable/Writeable bit
    dc: u1, // Direction bit
    e: u1, // Executable bit
    s: u1, // 0:System Segment, 1:code or data segment
    dpl: u2, // Privilege level
    p: u1, // Present
};

const FlagsByte = packed struct {
    r: u1, // Reserved
    l: u1, // Long mode
    db: u1, // Size flag
    g: u1, // Granularity
};

const GDTEntry = packed struct {
    limit_low: u16,
    base_low: u16,
    base_mid: u8,
    access: AccessByte,
    limit_hi: u4,
    flags: FlagsByte,
    base_hi: u8,
};

pub fn makeGDTEntry(limit: u32, base: u32, ab: AccessByte, fb: FlagsByte) GDTEntry {
    return GDTEntry{
        .limit_low = @truncate(u16, limit),
        .base_low = @truncate(u16, base),
        .base_mid = @truncate(u8, base >> 16),
        .access = ab,
        .limit_hi = @truncate(u4, limit >> 16),
        .flags = fb,
        .base_hi = @truncate(u8, base >> 24),
    };
}

// Let's define the 32-bits segment descriptors as explained in
// https://wiki.osdev.org/GDT_Tutorial#How_to_Set_Up_The_GDT

// Kernel code access byte: 0x9A -> 1001_1010
const KC_AB = AccessByte{
    .a = 0,
    .rw = 1, // Read access is allowed
    .dc = 0, // Can only be executed for DPL == 0
    .e = 1, // Define code segment
    .s = 1, // Define code or data segment
    .dpl = 0, // Descriptor Privilege level
    .p = 1, // Valid segment
};

// Kernel data access byte: 0x92 -> 1001_0010
const KD_AB = AccessByte{
    .a = 0,
    .rw = 1, // Write access is allowed
    .dc = 0, // Segments grows up
    .e = 0, // Define a data segment
    .s = 1, // Code or Data segment
    .dpl = 0,
    .p = 1,
};

// User code access byte: 0xFA -> 1111_1010
const UC_AB = AccessByte{
    .a = 0,
    .rw = 1, // Read access is allowed
    .dc = 0, // Can only be executed for DPL <= 3
    .e = 1, // Define code segment
    .s = 1, // Define code or data segment
    .dpl = 3,
    .p = 1,
};

// User data access byte: 0xF2 -> 1111_0010
const UD_AB = AccessByte{
    .a = 0,
    .rw = 1, // Write access is allowed
    .dc = 0, // Segments grows up
    .e = 0, // Define a data segment
    .s = 1, // Code or Data segment
    .dpl = 3,
    .p = 1,
};

// Task State access byte: 0x89 -> 1000_1001
const TSS_AB = AccessByte{
    .a = 1,
    .rw = 0, // read access not allowed
    .dc = 0, // can only be executed from the ring set in DPL
    .e = 1, // can be executed
    .s = 0, // System segment
    .dpl = 0,
    .p = 1,
};

const NULL_AB = AccessByte{
    .a = 0,
    .rw = 0,
    .dc = 0,
    .e = 0,
    .s = 0,
    .dpl = 0,
    .p = 0,
};

// Same flags is used for all but TSS : 0xC -> 1100
const FLAGS = FlagsByte{
    .r = 0,
    .l = 0, // 32-bit mode
    .db = 1, // Defined 32-bit protected mode
    .g = 1, // Limit is in 4KB (page granularity)
};

const NULL_FLAGS = FlagsByte{
    .r = 0,
    .l = 0,
    .db = 0,
    .g = 0,
};

// Declare our GDT.
// First entry must be NULL
var gdt = [_]GDTEntry{
    makeGDTEntry(0x0, 0x0000, NULL_AB, NULL_FLAGS),
    makeGDTEntry(0x0, 0xFFFF, KC_AB, FLAGS), // offset: 0x8
    makeGDTEntry(0x0, 0xFFFF, KD_AB, FLAGS), // offset: 0x10
    makeGDTEntry(0x0, 0xFFFF, UC_AB, FLAGS), // offset: 0x18
    makeGDTEntry(0x0, 0xFFFF, UD_AB, FLAGS), // offset: 0x20
    makeGDTEntry(0x0, 0x0000, TSS_AB, NULL_FLAGS), // limit & base will be set later
};

const GDTRegister = packed struct {
    limit: u16,
    base: *const GDTEntry,
};

var gdtr = GDTRegister{
    .limit = gdt.len * @sizeOf(GDTEntry),
    .base = &gdt[0],
};

extern fn setGdt(gdtr: *const GDTRegister) void;

pub fn setup() void {
    tty.write("Setup up gdt ... ", tty.VGAColor.White, tty.VGAColor.Black);

    setGdt(&gdtr);

    tty.write("done", tty.VGAColor.Green, tty.VGAColor.Black);
}
