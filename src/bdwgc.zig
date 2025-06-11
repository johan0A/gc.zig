const std = @import("std");
const Allocator = std.mem.Allocator;
const Gc = @import("Gc.zig");
pub const c = @import("c");

fn alloc(
    _: *anyopaque,
    len: usize,
    alignment: std.mem.Alignment,
    ret_addr: usize,
) ?[*]u8 {
    _ = ret_addr;
    var ptr: [*]u8 = undefined;
    if (c.GC_posix_memalign(@ptrCast(&ptr), @max(alignment.toByteUnits(), @sizeOf(usize)), len) != 0) return null;
    return ptr;
}

fn resize(
    _: *anyopaque,
    buf: []u8,
    alignment: std.mem.Alignment,
    new_len: usize,
    ret_addr: usize,
) bool {
    _ = alignment;
    _ = ret_addr;
    if (new_len <= buf.len) return true;

    const full_len = c.GC_size(buf.ptr);
    if (new_len <= full_len) return true;

    return false;
}

fn free(
    _: *anyopaque,
    memory: []u8,
    alignment: std.mem.Alignment,
    ret_addr: usize,
) void {
    _ = alignment;
    _ = ret_addr;
    c.GC_free(memory.ptr);
}

pub fn allocator() Allocator {
    if (c.GC_is_init_called() == 0) c.GC_init();

    return Allocator{
        .ptr = undefined,
        .vtable = &.{
            .alloc = alloc,
            .resize = resize,
            .remap = Allocator.noRemap,
            .free = free,
        },
    };
}

pub fn gc() Gc {
    return Gc.init(allocator());
}

pub fn getHeapSize() usize {
    return c.GC_get_heap_size();
}

/// Count total memory use in bytes by all allocated blocks.  Acquires
/// the lock.
pub fn getMemoryUse() usize {
    return c.GC_get_memory_use();
}

///  Trigger a full world-stopped collection.  Abort the collection if
///  and when stopFn returns a nonzero value.  stopFn will be
///  called frequently, and should be reasonably fast.  (stopFn is
///  called with the allocation lock held and the world might be stopped;
///  it's not allowed for stopFn to manipulate pointers to the garbage
///  collected heap or call most of GC functions.)  This works even
///  if virtual dirty bits, and hence incremental collection is not
///  available for this architecture.  Collections can be aborted faster
///  than normal pause times for incremental collection.  However,
///  aborted collections do no useful work; the next collection needs
///  to start from the beginning.  stopFn must not be 0.
///  GC_try_to_collect() returns 0 if the collection was aborted (or the
///  collections are disabled), 1 if it succeeded.
pub fn collect(stopFn: c.GC_stop_func) !void {
    if (c.GC_try_to_collect(stopFn) == 0) {
        return error.CollectionAborted;
    }
}

// Perform the collector shutdown.  (E.g. dispose critical sections on
// Win32 target.)  A duplicate invocation is a no-op.  GC_INIT should
// not be called after the shutdown. See also GC_win32_free_heap().
pub fn deinit() void {
    c.GC_deinit();
}

test "GCAllocator" {
    const gc_alloc = allocator();

    try std.heap.testAllocator(gc_alloc);
    try std.heap.testAllocatorAligned(gc_alloc);
    try std.heap.testAllocatorAlignedShrink(gc_alloc);
    try std.heap.testAllocatorLargeAlignment(gc_alloc);
}
