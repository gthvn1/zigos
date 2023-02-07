const std = @import("std");
const Builder = @import("std").build.Builder;
const Target = @import("std").Target;
const CrossTarget = @import("std").zig.CrossTarget;
const Feature = @import("std").Target.Cpu.Feature;

pub fn build(b: *Builder) void {

    const kernel = b.addExecutable("kernel.elf", "src/boot.zig");

    const target = CrossTarget{
        .cpu_arch = Target.Cpu.Arch.i386,
        .os_tag = Target.Os.Tag.freestanding,
        .abi = Target.Abi.none
    };
    kernel.setTarget(target);

    const mode = b.standardReleaseOptions();
    kernel.setBuildMode(mode);

    kernel.setLinkerScriptPath(.{ .path = "src/linker.ld" });
    kernel.code_model = .kernel;
    kernel.install();

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.install_step.?.step);

    const iso_dir = b.fmt("{s}/iso", .{b.cache_root});
    const kernel_path = b.getInstallPath(kernel.install_step.?.dest_dir, kernel.out_filename);
    const iso_path = b.fmt("{s}/zigos.iso", .{b.exe_dir});

    const iso_cmd_str = &[_][]const u8{
        "/bin/sh", "-c",
        std.mem.concat(b.allocator, u8, &[_][]const u8{
            "mkdir -p ", iso_dir, "/boot/grub && ",
            "cp ", kernel_path, " ", iso_dir, "/boot && ",
            "cp src/grub.cfg ", iso_dir, "/boot/grub && ",
            "grub2-mkrescue -o ", iso_path, " ", iso_dir
        }) catch unreachable
    };

    const iso_cmd = b.addSystemCommand(iso_cmd_str);
    iso_cmd.step.dependOn(kernel_step);

    const iso_step = b.step("iso", "Build an ISO image");
    iso_step.dependOn(&iso_cmd.step);
    b.default_step.dependOn(iso_step);
}