// Grub uses multiboot2
// https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html
// https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#OS-image-format
//
pub const multiboot2 = struct {
    pub const MAGIC: u32 = 0xE85250D6;
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
