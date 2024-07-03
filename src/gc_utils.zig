const std = @import("std");

fn hasValueFields(T: type) bool {
    const fields = switch (@typeInfo(T)) {
        .Struct => |info| info.fields,
        .Union => |info| info.fields,
        else => return false,
    };
    if (fields.len > 0) return true;
    return false;
}

/// Returns true if the type or any of its fields and subfields have a pointer type.
pub fn hasPointer(T: type) bool {
    inline for (std.meta.fields(T)) |field| {
        if (@typeInfo(field.type) == .Pointer) return true;
        if (comptime hasValueFields(field.type)) {
            if (hasPointer(field.type)) return true;
        }
    }
    return false;
}

test "hasValueFields" {
    const test_type_a = struct {
        a: usize,
    };

    const test_type_b = struct {
        a: usize,
        b: usize,
    };

    const test_type_c = usize;

    try std.testing.expectEqual(true, hasValueFields(test_type_a));
    try std.testing.expectEqual(true, hasValueFields(test_type_b));
    try std.testing.expectEqual(false, hasValueFields(test_type_c));
}

test "hasPointer" {
    const test_type_a = struct {
        a: *usize,
    };

    const test_type_b = union {
        a: *usize,
        b: usize,
    };

    const test_type_c = union {
        a: isize,
        b: usize,
    };

    try std.testing.expectEqual(true, hasPointer(test_type_a));
    try std.testing.expectEqual(true, hasPointer(test_type_b));
    try std.testing.expectEqual(false, hasPointer(test_type_c));
}
