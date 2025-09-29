# gc.zig

The [bdwgc Boehm GC](https://github.com/ivmai/bdwgc) garbage coollector packaged for zig.

## Usage

```zig
const gc = @import("gc");

pub fn main() !void {
    const allocator = gc.bdwgc.allocator();

    var list: std.ArrayListUnmanaged(u8) = .empty;

    try list.appendSlice(allocator, "Hello");
    try list.appendSlice(allocator, " World");

    std.debug.print("{s}\n", .{list.items});
    // the program will exit without memory leaks :D
}
```

## install

1. Add `gc` to the depency list in `build.zig.zon`: 

```sh
zig fetch --save git+https://github.com/johan0A/gc.zig
```

2. Config `build.zig`:

```zig
const gc_dep = b.dependency("gc", .{
    .target = target,
    .optimize = optimize,
});

root_module.addImport("gc", gc_dep.module("gc"));
```
