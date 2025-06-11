pub const Gc = @import("Gc.zig");
pub const bdwgc = @import("bdwgc.zig");

const std = @import("std");

test {
    std.testing.refAllDecls(@This());
}
