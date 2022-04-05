pub extern fn LZ4_versionNumber() c_int;
pub extern fn LZ4_versionString() [*c]const u8;
pub extern fn LZ4_compress_default(src: [*c]const u8, dst: [*c]u8, srcSize: c_int, dstCapacity: c_int) c_int;
pub extern fn LZ4_decompress_safe(src: [*c]const u8, dst: [*c]u8, compressedSize: c_int, dstCapacity: c_int) c_int;
pub extern fn LZ4_compressBound(inputSize: c_int) c_int;
pub extern fn LZ4_compress_fast(src: [*c]const u8, dst: [*c]u8, srcSize: c_int, dstCapacity: c_int, acceleration: c_int) c_int;
pub extern fn LZ4_sizeofState() c_int;
pub extern fn LZ4_compress_fast_extState(state: ?*anyopaque, src: [*c]const u8, dst: [*c]u8, srcSize: c_int, dstCapacity: c_int, acceleration: c_int) c_int;
pub extern fn LZ4_compress_destSize(src: [*c]const u8, dst: [*c]u8, srcSizePtr: [*c]c_int, targetDstSize: c_int) c_int;
pub extern fn LZ4_decompress_safe_partial(src: [*c]const u8, dst: [*c]u8, srcSize: c_int, targetOutputSize: c_int, dstCapacity: c_int) c_int;
pub const LZ4_u32 = u32;
pub const LZ4_byte = u8;
pub const struct_LZ4_stream_t_internal = extern struct {
    hashTable: [4096]LZ4_u32,
    currentOffset: LZ4_u32,
    tableType: LZ4_u32,
    dictionary: [*c]const LZ4_byte,
    dictCtx: [*c]const LZ4_stream_t_internal,
    dictSize: LZ4_u32,
};
pub const LZ4_stream_t_internal = struct_LZ4_stream_t_internal;
pub const union_LZ4_stream_u = extern union {
    table: [2052]?*anyopaque,
    internal_donotuse: LZ4_stream_t_internal,
};
pub const LZ4_stream_t = union_LZ4_stream_u;
pub extern fn LZ4_createStream() [*c]LZ4_stream_t;
pub extern fn LZ4_freeStream(streamPtr: [*c]LZ4_stream_t) c_int;
pub extern fn LZ4_resetStream_fast(streamPtr: [*c]LZ4_stream_t) void;
pub extern fn LZ4_loadDict(streamPtr: [*c]LZ4_stream_t, dictionary: [*c]const u8, dictSize: c_int) c_int;
pub extern fn LZ4_compress_fast_continue(streamPtr: [*c]LZ4_stream_t, src: [*c]const u8, dst: [*c]u8, srcSize: c_int, dstCapacity: c_int, acceleration: c_int) c_int;
pub extern fn LZ4_saveDict(streamPtr: [*c]LZ4_stream_t, safeBuffer: [*c]u8, maxDictSize: c_int) c_int;
pub const union_LZ4_streamDecode_u = extern union {
    table: [4]c_ulonglong,
    internal_donotuse: LZ4_streamDecode_t_internal,
};
pub const LZ4_streamDecode_t = union_LZ4_streamDecode_u;
pub extern fn LZ4_createStreamDecode() [*c]LZ4_streamDecode_t;
pub extern fn LZ4_freeStreamDecode(LZ4_stream: [*c]LZ4_streamDecode_t) c_int;
pub extern fn LZ4_setStreamDecode(LZ4_streamDecode: [*c]LZ4_streamDecode_t, dictionary: [*c]const u8, dictSize: c_int) c_int;
pub extern fn LZ4_decoderRingBufferSize(maxBlockSize: c_int) c_int;
pub extern fn LZ4_decompress_safe_continue(LZ4_streamDecode: [*c]LZ4_streamDecode_t, src: [*c]const u8, dst: [*c]u8, srcSize: c_int, dstCapacity: c_int) c_int;
pub extern fn LZ4_decompress_safe_usingDict(src: [*c]const u8, dst: [*c]u8, srcSize: c_int, dstCapcity: c_int, dictStart: [*c]const u8, dictSize: c_int) c_int;

pub const LZ4_i8 = i8;
pub const LZ4_u16 = u16;
pub const LZ4_streamDecode_t_internal = extern struct {
    externalDict: [*c]const LZ4_byte,
    extDictSize: usize,
    prefixEnd: [*c]const LZ4_byte,
    prefixSize: usize,
};
pub extern fn LZ4_initStream(buffer: ?*anyopaque, size: usize) [*c]LZ4_stream_t;
pub extern fn LZ4_compress(src: [*c]const u8, dest: [*c]u8, srcSize: c_int) c_int;
pub extern fn LZ4_compress_limitedOutput(src: [*c]const u8, dest: [*c]u8, srcSize: c_int, maxOutputSize: c_int) c_int;
pub extern fn LZ4_compress_withState(state: ?*anyopaque, source: [*c]const u8, dest: [*c]u8, inputSize: c_int) c_int;
pub extern fn LZ4_compress_limitedOutput_withState(state: ?*anyopaque, source: [*c]const u8, dest: [*c]u8, inputSize: c_int, maxOutputSize: c_int) c_int;
pub extern fn LZ4_compress_continue(LZ4_streamPtr: [*c]LZ4_stream_t, source: [*c]const u8, dest: [*c]u8, inputSize: c_int) c_int;
pub extern fn LZ4_compress_limitedOutput_continue(LZ4_streamPtr: [*c]LZ4_stream_t, source: [*c]const u8, dest: [*c]u8, inputSize: c_int, maxOutputSize: c_int) c_int;
pub extern fn LZ4_uncompress(source: [*c]const u8, dest: [*c]u8, outputSize: c_int) c_int;
pub extern fn LZ4_uncompress_unknownOutputSize(source: [*c]const u8, dest: [*c]u8, @"isize": c_int, maxOutputSize: c_int) c_int;
pub extern fn LZ4_create(inputBuffer: [*c]u8) ?*anyopaque;
pub extern fn LZ4_sizeofStreamState() c_int;
pub extern fn LZ4_resetStreamState(state: ?*anyopaque, inputBuffer: [*c]u8) c_int;
pub extern fn LZ4_slideInputBuffer(state: ?*anyopaque) [*c]u8;
pub extern fn LZ4_decompress_safe_withPrefix64k(src: [*c]const u8, dst: [*c]u8, compressedSize: c_int, maxDstSize: c_int) c_int;
pub extern fn LZ4_decompress_fast_withPrefix64k(src: [*c]const u8, dst: [*c]u8, originalSize: c_int) c_int;
pub extern fn LZ4_decompress_fast(src: [*c]const u8, dst: [*c]u8, originalSize: c_int) c_int;
pub extern fn LZ4_decompress_fast_continue(LZ4_streamDecode: [*c]LZ4_streamDecode_t, src: [*c]const u8, dst: [*c]u8, originalSize: c_int) c_int;
pub extern fn LZ4_decompress_fast_usingDict(src: [*c]const u8, dst: [*c]u8, originalSize: c_int, dictStart: [*c]const u8, dictSize: c_int) c_int;
pub extern fn LZ4_resetStream(streamPtr: [*c]LZ4_stream_t) void;

pub const LZ4_VERSION_MAJOR = @as(c_int, 1);
pub const LZ4_VERSION_MINOR = @as(c_int, 9);
pub const LZ4_VERSION_RELEASE = @as(c_int, 3);
pub const LZ4_VERSION_NUMBER = (((LZ4_VERSION_MAJOR * @as(c_int, 100)) * @as(c_int, 100)) + (LZ4_VERSION_MINOR * @as(c_int, 100))) + LZ4_VERSION_RELEASE;
pub const LZ4_LIB_VERSION = LZ4_VERSION_MAJOR.LZ4_VERSION_MINOR.LZ4_VERSION_RELEASE;
pub const LZ4_MEMORY_USAGE_MIN = @as(c_int, 10);
pub const LZ4_MEMORY_USAGE_DEFAULT = @as(c_int, 14);
pub const LZ4_MEMORY_USAGE_MAX = @as(c_int, 20);
pub const LZ4_MEMORY_USAGE = LZ4_MEMORY_USAGE_DEFAULT;
pub const LZ4_MAX_INPUT_SIZE = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7E000000, .hexadecimal);
pub const LZ4_STREAMSIZE = (@as(c_ulong, 1) << LZ4_MEMORY_USAGE) + @as(c_int, 32);
pub const LZ4_STREAMSIZE_VOIDP = LZ4_STREAMSIZE / @import("std").zig.c_translation.sizeof(?*anyopaque);
pub const LZ4_STREAMDECODESIZE_U64 = @as(c_int, 4) + (if (@import("std").zig.c_translation.sizeof(?*anyopaque) == @as(c_int, 16)) @as(c_int, 2) else @as(c_int, 0));
pub const LZ4_STREAMDECODESIZE = LZ4_STREAMDECODESIZE_U64 * @import("std").zig.c_translation.sizeof(c_ulonglong);
pub const LZ4_stream_u = union_LZ4_stream_u;
pub const LZ4_streamDecode_u = union_LZ4_streamDecode_u;
