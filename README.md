> [!NOTE]  
> Dont use this for anything serious

# gc.zig
a [Zig](https://ziglang.org/) garbage collector package that provides a garbage collector interface as well as the [bdwgc Boehm GC](https://github.com/ivmai/bdwgc) garbage collector and more.

## Usage

```zig
const zig_gc = @import("zig_gc");

pub fn main() !void {
    // create a new garbage collector interface
    const gc = zig_gc.BdwGarbageCollector.gc(); 

    // coerce the gc interface to the standard allocator interface before passing it to ArrayList
    var list = std.ArrayList(u8).init(gc.allocator()); 

    try list.appendSlice("Hello");
    try list.appendSlice(" World");

    std.debug.print("{s}\n", .{list.items});
    // the program will exit without memory leaks :D
}
```
Why use a specialized garbage collector interface? (`Gc`) <br>
1. It signals to the caller that the function was made with the intention of using a garbage collector.
2. (not yet implemented) The garbage collector can benefit from more information being passsed in about the allocation for better performance. For example, if the allocationg contains pointers or not. And that is not possible with the standard allocator interface.

otherwise, the BdwGarbageCollector acts similarely to a standard allocator and can be used with the standard allocator interface by using `Gc.allocator(self: Gc)` or `BdwGarbageCollector.allocator()`.

## install

1. Add `zig_gc` to the depency list in `build.zig.zon`: 

```sh
zig fetch --save https://github.com/johan0A/gc.zig/archive/refs/tags/0.2.0.tar.gz
```

2. Config `build.zig`:

```zig
...
const zig_gc = b.dependency("zig_gc", .{
    .target = target,
    .optimize = optimize,
});

exe.root_module.addImport("zig_gc", zig_gc.module("zig_gc"));
...
```


## License

Licensed under the [MIT License](LICENSE).
