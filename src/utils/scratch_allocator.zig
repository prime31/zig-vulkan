const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;

pub const ScratchAllocator = struct {
    backup_allocator: Allocator,
    end_index: usize,
    buffer: []u8,

    pub fn init(backing_allocator: Allocator, size_in_mb: u64) ScratchAllocator {
        const scratch_buffer = backing_allocator.alloc(u8, size_in_mb * 1024 * 1024) catch unreachable;

        return ScratchAllocator{
            .backup_allocator = backing_allocator,
            .buffer = scratch_buffer,
            .end_index = 0,
        };
    }

    pub fn deinit(self: ScratchAllocator) void {
        self.backup_allocator.free(self.buffer);
    }

    pub fn allocator(self: *ScratchAllocator) Allocator {
        return Allocator.init(self, alloc, Allocator.NoResize(ScratchAllocator).noResize, Allocator.NoOpFree(ScratchAllocator).noOpFree);
    }

    fn alloc(self: *ScratchAllocator, n: usize, ptr_align: u29, _: u29, _: usize) std.mem.Allocator.Error![]u8 {
        const addr = @ptrToInt(self.buffer.ptr) + self.end_index;
        const adjusted_addr = mem.alignForward(addr, ptr_align);
        const adjusted_index = self.end_index + (adjusted_addr - addr);
        const new_end_index = adjusted_index + n;

        if (new_end_index > self.buffer.len) {
            // if more memory is requested then we have in our buffer we can use our backing allocator but we dont
            if (n > self.buffer.len) {
                return std.mem.Allocator.Error.OutOfMemory;
            }

            const result = self.buffer[0..n];
            self.end_index = n;
            return result;
        }
        const result = self.buffer[adjusted_index..new_end_index];
        self.end_index = new_end_index;

        return result;
    }
};

test "ScratchAllocator" {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{ .thread_safe = false }){};
    const gpa = general_purpose_allocator.allocator();
    defer _ = general_purpose_allocator.deinit();

    var tmp_allocator = ScratchAllocator.init(gpa, 1);
    const tmp = tmp_allocator.allocator();
    defer tmp_allocator.deinit();

    _ = tmp.alloc(i32, 10000000000) catch |err| {
        try std.testing.expect(std.mem.Allocator.Error.OutOfMemory == err);
    };

    var slice = try tmp.alloc(u32, 100);
    try std.testing.expect(slice.len == 100);

    _ = try tmp.create(i32);

    slice = try tmp.realloc(slice, 20000);
    try std.testing.expect(slice.len == 20000);
    tmp.free(slice);
}
