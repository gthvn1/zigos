# ZigOS

## Build
-  `zig build`

## Generate the ISO
- `zig build iso`

## Run & Debug
- To quit Qemu: `Ctrl-A x`

### Run in Qemu
- `zig build run`

### Run and wait for gdb
- `zig build run -Dgdb`
- From another terminal:
```sh
gdb ./zig-out/bin/kernel
(gdb) target remote localhost:1234
```

