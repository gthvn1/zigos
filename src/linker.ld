ENTRY(kmain)  /* kernel main entry point */

SECTIONS {
	/* Start at 1MB, it is required to be loaded by bootloader */
	. = 1M;

	.text : ALIGN(4096) {
		/* multiboot header must be at the beginning */
		KEEP(*(.multiboot))
		*(.text)
	}

	/* Read-only data */
	.rodata : ALIGN(4096) {
		*(.rodata)

	}

	/* Read-write data (initialized) */
	.data : ALIGN(4096) {
		*(.data)
	}

	/* Read-write data (uninitialized) and stack */
	.bss : ALIGN(4096) {
		*(.bss)
	}
}
