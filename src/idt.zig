// IDT: Interrupt Descriptor Table.
// 
// https://wiki.osdev.org/Interrupt_Descriptor_Table
//
// This is the equivalent of IVT but for protected and long mode.
//
// Each entry in the IDT is called a GATE. The table indicates for
// each GATE where is the Interrupt Service Routines (ISR).
//
// Its location is kept in IDTR (IDT Register).
// It is loaded using the LIDT assembly code.
//
// IDT has 256 GATES but the offset differs between 32-bits mode
// and 64-bits mode.
//
// GDT must be set to be able to use ISR...
