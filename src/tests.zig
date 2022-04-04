const std = @import("std");

// include all files with tests
comptime {
    _ = @import("deletion_queue.zig");
    _ = @import("shaders.zig");

    _ = @import("utils/descriptors.zig");
    _ = @import("utils/cvars.zig");

    _ = @import("assetlib/asset_loader.zig");
    _ = @import("assetlib/texture_asset.zig");
}
