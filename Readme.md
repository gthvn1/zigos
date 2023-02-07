# ZigOS

An experimental micro kernel written in Zig

## Overview

The only purpose of this "operating system" is the exploration of this universe.
There is many really good tutorials and blogs that explain how to setup your own
operating system. So this one and the related blog posts are more some milestones
for me but maybe it can be usefull for someone else so I will try to keep things
simple and working.

So we will try to follow tutorials from OS dev and also get inspired by existing
Zig and others existing operating system. All links that we use are available in
the next section.

## Links

### Bare Bones tutorial

Try the tutorial [Bare Bones](https://wiki.osdev.org/Bare_Bones) from OS dev.
We try to use [zig](https://ziglang.org/) because there are some facilites to
build low level stuff and use some cool keyword like `linksection`...

The goal is to
 - [X] boot
 - [X] print message (tagged "step1_banner")
 - [ ] switch to long mode (not sure yet about steps)
    - [X] introduce some opcodes
    - [ ] setup gdt ???
    - [ ] setup interrupt vector
    - [ ] setup page table

### Existing Zig Operating System

- [Zig Bare Bones](https://wiki.osdev.org/Zig_Bare_Bones)
- [Pluto](https://github.com/ZystemOS/pluto)
- [Zen](https://github.com/AndreaOrru/zen)
- [BoksOS](https://boksos.com/)

### Related blogs

TODO

## Build

- `zig build`

## Run & debug

- `qemu-system-i386 -cdrom zig-out/bin/zigos.iso`
- if you want to attach a debugger add `-s -S`
- check with `nm -s` the address of **kmain**
    - In my case it is 0x001000c0
```
gdb -ex 'target remote localhost:1234' \
    -ex 'set disassembly-flavor intel' \
    -ex 'break *0x001000c0' \
    -ex 'continue'

```

## It is cool but...

- At this point we can boot and print messages on the screen but
  - we are still in 32 bits mode
  - we don't know how grub sets GDT
  - we don't know what is the stack used

- So I think that we need to figure out how to set up this things.
