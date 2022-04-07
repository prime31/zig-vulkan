const std = @import("std");

pub usingnamespace @import("asset_loader.zig");
pub usingnamespace @import("texture_asset.zig");
pub usingnamespace @import("mesh_asset.zig");

pub const TransparencyMode = enum(u8) {
    @"opaque",
    transparent,
    masked,
};
