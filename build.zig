const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
        .abi = .none,
    });

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/kernel.zig"),
            .target = target,
        }),
    });

    kernel.setLinkerScript(b.path("linker.ld"));
    kernel.pie = false;

    b.installArtifact(kernel);

    // Copy the kernel into iso/boot/kernel
    const cp_kernel = b.addInstallFile(
        kernel.getEmittedBin(),
        "iso/boot/kernel",
    );

    cp_kernel.step.dependOn(&kernel.step);

    // Generate the iso
    const iso = "zigos.iso";

    const gen_iso = b.addSystemCommand(&.{
        "grub-mkrescue",
        "-o",
        iso,
        "iso",
    });
    gen_iso.step.dependOn(&cp_kernel.step);

    // Expose the copy & gen iso as `zig build iso`
    const iso_step = b.step("iso", "Build a bootable ISO image");
    iso_step.dependOn(&gen_iso.step);

    // Run in qemu:
    //   - using "-nographic" redirect serial to stdio
    //   - "-boot d" skip BIOS logo
    const gdb = b.option(bool, "gdb", "Wait for GDB") orelse false;

    const run_qemu = b.addSystemCommand(&.{
        "qemu-system-x86_64",
        "-boot",
        "d",
        "-cdrom",
        iso,
        "-no-reboot",
        "-nographic",
    });

    if (gdb) {
        run_qemu.addArgs(&.{ "-S", "-s" });
    }

    run_qemu.step.dependOn(&gen_iso.step);

    // Expose as run step
    const run_step = b.step("run", "Run OS in Qemu");
    run_step.dependOn(&run_qemu.step);
}
