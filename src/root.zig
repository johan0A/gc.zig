pub const bdwgc = @import("bdwgc.zig");

test {
    const std = @import("std");
    std.testing.refAllDecls(@This());
}
