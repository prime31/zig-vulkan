const std = @import("std");

// include all files with tests
comptime {
    _ = @import("utils/descriptors.zig");
    _ = @import("utils/cvars.zig");

    _ = @import("assetlib/asset_loader.zig");
    _ = @import("assetlib/texture_asset.zig");
}
