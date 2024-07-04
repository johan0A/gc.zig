pub const Gc = @import("Gc.zig");
pub const BdwGarbageCollector = @import("bdwgc.zig");

const PrivateImports = struct {
    pub const gc_utils = @import("gc_utils.zig");
};

const std = @import("std");
test {
    std.testing.refAllDeclsRecursive(@This());
    std.testing.refAllDeclsRecursive(PrivateImports);
}
