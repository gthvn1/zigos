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
//  When Setup interruptions must be turned off (CLI)
