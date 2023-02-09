// Zig relies on LLVM for assembly...
.type setGdt, @function

// GDTR is passed on the stack
setGdt:
	mov +4(%esp), %eax
	lgdt (%eax)
	
	// To setup the Code segment we need to perform a jmp
	ljmp $0x08, $1f // 0x08: offset of Kernel Code
1:
	// Set up segment to point to kernel data
	mov $0x10, %ax	// 0x10: offset of Kernel Data
	mov %ax, ds
	mov %ax, es
	mov %ax, fs
	mov %ax, gs
	mov %ax, ss
	ret

