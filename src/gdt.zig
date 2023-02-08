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
        .flags = fb,
        .base_hi = @truncate(u8, base >> 24),
    };
}

const KERNEL_CODE = AccessByte{
    .a = 0,
    .rw = 1, // Read access is allowed
    .dc = 0, // Can only be executed for DPL == 0
    .e = 1, // Define code segment
    .s = 1, // Define code or data segment
    .dpl = 0, // Descriptor Privilege level
    .p = 1, // Valid segment
};

const KERNEL_DATA = AccessByte{
    .a = 0,
    .rw = 1, // Write access is allowed
    .dc = 0, // Segments grows up
    .e = 0, // Define a data segment
    .s = 1, // Code or Data segment
    .dpl = 0,
    .p = 1,
};

const USER_CODE = AccessByte{
    .a = 0,
    .rw = 1, // Read access is allowed
    .dc = 0, // Can only be executed for DPL <= 3
    .e = 1, // Define code segment
    .s = 1, // Define code or data segment
    .dpl = 3, // Descriptor Privilege level
    .p = 1, // Valid segment
};

const USER_DATA = AccessByte{
    .a = 0,
    .rw = 1, // Write access is allowed
    .dc = 0, // Segments grows up
    .e = 0, // Define a data segment
    .s = 1, // Code or Data segment
    .dpl = 3,
    .p = 1,
};

const FLAGS = FlagsByte{
    .r = 0,
    .l = 0, // 32-bit mode
    .db = 1, // Defined 32-bit protected mode
    .g = 1, // Limit is in 4KB (page granularity)
};

// Declare our GDT.
// First entry must be NULL
var gdt = []GDTEntry{
    makeGDTEntry(0, 0, 0, 0),
    makeGDTEntry(0, 0xFFFF, KERNEL_CODE, FLAGS),
    makeGDTEntry(0, 0xFFFF, KERNEL_DATA, FLAGS),
    makeGDTEntry(0, 0xFFFF, USER_CODE, FLAGS),
    makeGDTEntry(0, 0xFFFF, USER_DATA, FLAGS),
};
