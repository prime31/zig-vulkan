const vk = @import("vulkan");

// pub const VMA_NOT_NULL = _Nonnull;
// pub const VMA_NULLABLE = _Nullable;

pub const struct_VmaAllocator_T = opaque {};
pub const VmaAllocator = ?*struct_VmaAllocator_T;
pub const PFN_vmaAllocateDeviceMemoryFunction = ?fn (VmaAllocator, u32, vk.DeviceMemory, vk.DeviceSize, ?*anyopaque) callconv(.C) void;
pub const PFN_vmaFreeDeviceMemoryFunction = ?fn (VmaAllocator, u32, vk.DeviceMemory, vk.DeviceSize, ?*anyopaque) callconv(.C) void;
pub const struct_VmaDeviceMemoryCallbacks = extern struct {
    pfnAllocate: PFN_vmaAllocateDeviceMemoryFunction,
    pfnFree: PFN_vmaFreeDeviceMemoryFunction,
    pUserData: ?*anyopaque,
};
pub const VmaDeviceMemoryCallbacks = struct_VmaDeviceMemoryCallbacks;
pub const VMA_ALLOCATOR_CREATE_EXTERNALLY_SYNCHRONIZED_BIT: c_int = 1;
pub const VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT: c_int = 2;
pub const VMA_ALLOCATOR_CREATE_KHR_BIND_MEMORY2_BIT: c_int = 4;
pub const VMA_ALLOCATOR_CREATE_EXT_MEMORY_BUDGET_BIT: c_int = 8;
pub const VMA_ALLOCATOR_CREATE_AMD_DEVICE_COHERENT_MEMORY_BIT: c_int = 16;
pub const VMA_ALLOCATOR_CREATE_BUFFER_DEVICE_ADDRESS_BIT: c_int = 32;
pub const VMA_ALLOCATOR_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaAllocatorCreateFlagBits = c_uint;
pub const VmaAllocatorCreateFlagBits = enum_VmaAllocatorCreateFlagBits;
pub const VmaAllocatorCreateFlags = VkFlags;
pub const struct_VmaVulkanFunctions = extern struct {
    vkGetPhysicalDeviceProperties: PFN_vkGetPhysicalDeviceProperties,
    vkGetPhysicalDeviceMemoryProperties: PFN_vkGetPhysicalDeviceMemoryProperties,
    vkAllocateMemory: PFN_vkAllocateMemory,
    vkFreeMemory: PFN_vkFreeMemory,
    vkMapMemory: PFN_vkMapMemory,
    vkUnmapMemory: PFN_vkUnmapMemory,
    vkFlushMappedMemoryRanges: PFN_vkFlushMappedMemoryRanges,
    vkInvalidateMappedMemoryRanges: PFN_vkInvalidateMappedMemoryRanges,
    vkBindBufferMemory: PFN_vkBindBufferMemory,
    vkBindImageMemory: PFN_vkBindImageMemory,
    vkGetBufferMemoryRequirements: PFN_vkGetBufferMemoryRequirements,
    vkGetImageMemoryRequirements: PFN_vkGetImageMemoryRequirements,
    vkCreateBuffer: PFN_vkCreateBuffer,
    vkDestroyBuffer: PFN_vkDestroyBuffer,
    vkCreateImage: PFN_vkCreateImage,
    vkDestroyImage: PFN_vkDestroyImage,
    vkCmdCopyBuffer: PFN_vkCmdCopyBuffer,
    vkGetBufferMemoryRequirements2KHR: PFN_vkGetBufferMemoryRequirements2KHR,
    vkGetImageMemoryRequirements2KHR: PFN_vkGetImageMemoryRequirements2KHR,
    vkBindBufferMemory2KHR: PFN_vkBindBufferMemory2KHR,
    vkBindImageMemory2KHR: PFN_vkBindImageMemory2KHR,
    vkGetPhysicalDeviceMemoryProperties2KHR: PFN_vkGetPhysicalDeviceMemoryProperties2KHR,
};
pub const VmaVulkanFunctions = struct_VmaVulkanFunctions;
pub const VMA_RECORD_FLUSH_AFTER_CALL_BIT: c_int = 1;
pub const VMA_RECORD_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaRecordFlagBits = c_uint;
pub const VmaRecordFlagBits = enum_VmaRecordFlagBits;
pub const VmaRecordFlags = VkFlags;
pub const struct_VmaRecordSettings = extern struct {
    flags: VmaRecordFlags,
    pFilePath: [*c]const u8,
};
pub const VmaRecordSettings = struct_VmaRecordSettings;
pub const struct_VmaAllocatorCreateInfo = extern struct {
    flags: VmaAllocatorCreateFlags,
    physicalDevice: vk.PhysicalDevice,
    device: vk.Device,
    preferredLargeHeapBlockSize: vk.DeviceSize,
    pAllocationCallbacks: [*c]const VkAllocationCallbacks,
    pDeviceMemoryCallbacks: [*c]const VmaDeviceMemoryCallbacks,
    frameInUseCount: u32,
    pHeapSizeLimit: [*c]const vk.DeviceSize,
    pVulkanFunctions: [*c]const VmaVulkanFunctions,
    pRecordSettings: [*c]const VmaRecordSettings,
    instance: vk.Instance,
    vulkanApiVersion: u32,
};
pub const VmaAllocatorCreateInfo = struct_VmaAllocatorCreateInfo;
pub extern fn vmaCreateAllocator(pCreateInfo: [*c]const VmaAllocatorCreateInfo, pAllocator: [*c]VmaAllocator) vk.Result;
pub extern fn vmaDestroyAllocator(allocator: VmaAllocator) void;
pub const struct_VmaAllocatorInfo = extern struct {
    instance: vk.Instance,
    physicalDevice: vk.PhysicalDevice,
    device: vk.Device,
};
pub const VmaAllocatorInfo = struct_VmaAllocatorInfo;
pub extern fn vmaGetAllocatorInfo(allocator: VmaAllocator, pAllocatorInfo: [*c]VmaAllocatorInfo) void;
pub extern fn vmaGetPhysicalDeviceProperties(allocator: VmaAllocator, ppPhysicalDeviceProperties: [*c][*c]const vk.PhysicalDeviceProperties) void;
pub extern fn vmaGetMemoryProperties(allocator: VmaAllocator, ppPhysicalDeviceMemoryProperties: [*c][*c]const vk.PhysicalDeviceMemoryProperties) void;
pub extern fn vmaGetMemoryTypeProperties(allocator: VmaAllocator, memoryTypeIndex: u32, pFlags: [*c]VkMemoryPropertyFlags) void;
pub extern fn vmaSetCurrentFrameIndex(allocator: VmaAllocator, frameIndex: u32) void;
pub const struct_VmaStatInfo = extern struct {
    blockCount: u32,
    allocationCount: u32,
    unusedRangeCount: u32,
    usedBytes: vk.DeviceSize,
    unusedBytes: vk.DeviceSize,
    allocationSizeMin: vk.DeviceSize,
    allocationSizeAvg: vk.DeviceSize,
    allocationSizeMax: vk.DeviceSize,
    unusedRangeSizeMin: vk.DeviceSize,
    unusedRangeSizeAvg: vk.DeviceSize,
    unusedRangeSizeMax: vk.DeviceSize,
};
pub const VmaStatInfo = struct_VmaStatInfo;
pub const struct_VmaStats = extern struct {
    memoryType: [32]VmaStatInfo,
    memoryHeap: [16]VmaStatInfo,
    total: VmaStatInfo,
};
pub const VmaStats = struct_VmaStats;
pub extern fn vmaCalculateStats(allocator: VmaAllocator, pStats: [*c]VmaStats) void;
pub const struct_VmaBudget = extern struct {
    blockBytes: vk.DeviceSize,
    allocationBytes: vk.DeviceSize,
    usage: vk.DeviceSize,
    budget: vk.DeviceSize,
};
pub const VmaBudget = struct_VmaBudget;
pub extern fn vmaGetBudget(allocator: VmaAllocator, pBudget: [*c]VmaBudget) void;
pub extern fn vmaBuildStatsString(allocator: VmaAllocator, ppStatsString: [*c][*c]u8, detailedMap: VkBool32) void;
pub extern fn vmaFreeStatsString(allocator: VmaAllocator, pStatsString: [*c]u8) void;
pub const struct_VmaPool_T = opaque {};
pub const VmaPool = ?*struct_VmaPool_T;
pub const VMA_MEMORY_USAGE_UNKNOWN: c_int = 0;
pub const VMA_MEMORY_USAGE_GPU_ONLY: c_int = 1;
pub const VMA_MEMORY_USAGE_CPU_ONLY: c_int = 2;
pub const VMA_MEMORY_USAGE_CPU_TO_GPU: c_int = 3;
pub const VMA_MEMORY_USAGE_GPU_TO_CPU: c_int = 4;
pub const VMA_MEMORY_USAGE_CPU_COPY: c_int = 5;
pub const VMA_MEMORY_USAGE_GPU_LAZILY_ALLOCATED: c_int = 6;
pub const VMA_MEMORY_USAGE_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaMemoryUsage = c_uint;
pub const VmaMemoryUsage = enum_VmaMemoryUsage;
pub const VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT: c_int = 1;
pub const VMA_ALLOCATION_CREATE_NEVER_ALLOCATE_BIT: c_int = 2;
pub const VMA_ALLOCATION_CREATE_MAPPED_BIT: c_int = 4;
pub const VMA_ALLOCATION_CREATE_CAN_BECOME_LOST_BIT: c_int = 8;
pub const VMA_ALLOCATION_CREATE_CAN_MAKE_OTHER_LOST_BIT: c_int = 16;
pub const VMA_ALLOCATION_CREATE_USER_DATA_COPY_STRING_BIT: c_int = 32;
pub const VMA_ALLOCATION_CREATE_UPPER_ADDRESS_BIT: c_int = 64;
pub const VMA_ALLOCATION_CREATE_DONT_BIND_BIT: c_int = 128;
pub const VMA_ALLOCATION_CREATE_WITHIN_BUDGET_BIT: c_int = 256;
pub const VMA_ALLOCATION_CREATE_STRATEGY_BEST_FIT_BIT: c_int = 65536;
pub const VMA_ALLOCATION_CREATE_STRATEGY_WORST_FIT_BIT: c_int = 131072;
pub const VMA_ALLOCATION_CREATE_STRATEGY_FIRST_FIT_BIT: c_int = 262144;
pub const VMA_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT: c_int = 65536;
pub const VMA_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT: c_int = 262144;
pub const VMA_ALLOCATION_CREATE_STRATEGY_MIN_FRAGMENTATION_BIT: c_int = 131072;
pub const VMA_ALLOCATION_CREATE_STRATEGY_MASK: c_int = 458752;
pub const VMA_ALLOCATION_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaAllocationCreateFlagBits = c_uint;
pub const VmaAllocationCreateFlagBits = enum_VmaAllocationCreateFlagBits;
pub const VmaAllocationCreateFlags = VkFlags;
pub const struct_VmaAllocationCreateInfo = extern struct {
    flags: VmaAllocationCreateFlags,
    usage: VmaMemoryUsage,
    requiredFlags: VkMemoryPropertyFlags,
    preferredFlags: VkMemoryPropertyFlags,
    memoryTypeBits: u32,
    pool: VmaPool,
    pUserData: ?*anyopaque,
};
pub const VmaAllocationCreateInfo = struct_VmaAllocationCreateInfo;
pub extern fn vmaFindMemoryTypeIndex(allocator: VmaAllocator, memoryTypeBits: u32, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pMemoryTypeIndex: [*c]u32) VkResult;
pub extern fn vmaFindMemoryTypeIndexForBufferInfo(allocator: VmaAllocator, pBufferCreateInfo: [*c]const VkBufferCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pMemoryTypeIndex: [*c]u32) VkResult;
pub extern fn vmaFindMemoryTypeIndexForImageInfo(allocator: VmaAllocator, pImageCreateInfo: [*c]const VkImageCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pMemoryTypeIndex: [*c]u32) VkResult;
pub const VMA_POOL_CREATE_IGNORE_BUFFER_IMAGE_GRANULARITY_BIT: c_int = 2;
pub const VMA_POOL_CREATE_LINEAR_ALGORITHM_BIT: c_int = 4;
pub const VMA_POOL_CREATE_BUDDY_ALGORITHM_BIT: c_int = 8;
pub const VMA_POOL_CREATE_ALGORITHM_MASK: c_int = 12;
pub const VMA_POOL_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaPoolCreateFlagBits = c_uint;
pub const VmaPoolCreateFlagBits = enum_VmaPoolCreateFlagBits;
pub const VmaPoolCreateFlags = VkFlags;
pub const struct_VmaPoolCreateInfo = extern struct {
    memoryTypeIndex: u32,
    flags: VmaPoolCreateFlags,
    blockSize: vk.DeviceSize,
    minBlockCount: usize,
    maxBlockCount: usize,
    frameInUseCount: u32,
};
pub const VmaPoolCreateInfo = struct_VmaPoolCreateInfo;
pub const struct_VmaPoolStats = extern struct {
    size: vk.DeviceSize,
    unusedSize: vk.DeviceSize,
    allocationCount: usize,
    unusedRangeCount: usize,
    unusedRangeSizeMax: vk.DeviceSize,
    blockCount: usize,
};
pub const VmaPoolStats = struct_VmaPoolStats;
pub extern fn vmaCreatePool(allocator: VmaAllocator, pCreateInfo: [*c]const VmaPoolCreateInfo, pPool: [*c]VmaPool) VkResult;
pub extern fn vmaDestroyPool(allocator: VmaAllocator, pool: VmaPool) void;
pub extern fn vmaGetPoolStats(allocator: VmaAllocator, pool: VmaPool, pPoolStats: [*c]VmaPoolStats) void;
pub extern fn vmaMakePoolAllocationsLost(allocator: VmaAllocator, pool: VmaPool, pLostAllocationCount: [*c]usize) void;
pub extern fn vmaCheckPoolCorruption(allocator: VmaAllocator, pool: VmaPool) VkResult;
pub extern fn vmaGetPoolName(allocator: VmaAllocator, pool: VmaPool, ppName: [*c][*c]const u8) void;
pub extern fn vmaSetPoolName(allocator: VmaAllocator, pool: VmaPool, pName: [*c]const u8) void;
pub const struct_VmaAllocation_T = opaque {};
pub const VmaAllocation = ?*struct_VmaAllocation_T;
pub const struct_VmaAllocationInfo = extern struct {
    memoryType: u32,
    deviceMemory: vk.DeviceMemory,
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
    pMappedData: ?*anyopaque,
    pUserData: ?*anyopaque,
};
pub const VmaAllocationInfo = struct_VmaAllocationInfo;
pub extern fn vmaAllocateMemory(allocator: VmaAllocator, pVkMemoryRequirements: [*c]const VkMemoryRequirements, pCreateInfo: [*c]const VmaAllocationCreateInfo, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaAllocateMemoryPages(allocator: VmaAllocator, pVkMemoryRequirements: [*c]const VkMemoryRequirements, pCreateInfo: [*c]const VmaAllocationCreateInfo, allocationCount: usize, pAllocations: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaAllocateMemoryForBuffer(allocator: VmaAllocator, buffer: VkBuffer, pCreateInfo: [*c]const VmaAllocationCreateInfo, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaAllocateMemoryForImage(allocator: VmaAllocator, image: VkImage, pCreateInfo: [*c]const VmaAllocationCreateInfo, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaFreeMemory(allocator: VmaAllocator, allocation: VmaAllocation) void;
pub extern fn vmaFreeMemoryPages(allocator: VmaAllocator, allocationCount: usize, pAllocations: [*c]const VmaAllocation) void;
pub extern fn vmaResizeAllocation(allocator: VmaAllocator, allocation: VmaAllocation, newSize: vk.DeviceSize) VkResult;
pub extern fn vmaGetAllocationInfo(allocator: VmaAllocator, allocation: VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) void;
pub extern fn vmaTouchAllocation(allocator: VmaAllocator, allocation: VmaAllocation) VkBool32;
pub extern fn vmaSetAllocationUserData(allocator: VmaAllocator, allocation: VmaAllocation, pUserData: ?*anyopaque) void;
pub extern fn vmaCreateLostAllocation(allocator: VmaAllocator, pAllocation: [*c]VmaAllocation) void;
pub extern fn vmaMapMemory(allocator: VmaAllocator, allocation: VmaAllocation, ppData: [*c]?*anyopaque) VkResult;
pub extern fn vmaUnmapMemory(allocator: VmaAllocator, allocation: VmaAllocation) void;
pub extern fn vmaFlushAllocation(allocator: VmaAllocator, allocation: VmaAllocation, offset: vk.DeviceSize, size: vk.DeviceSize) VkResult;
pub extern fn vmaInvalidateAllocation(allocator: VmaAllocator, allocation: VmaAllocation, offset: vk.DeviceSize, size: vk.DeviceSize) VkResult;
pub extern fn vmaFlushAllocations(allocator: VmaAllocator, allocationCount: u32, allocations: [*c]const VmaAllocation, offsets: [*c]const vk.DeviceSize, sizes: [*c]const vk.DeviceSize) VkResult;
pub extern fn vmaInvalidateAllocations(allocator: VmaAllocator, allocationCount: u32, allocations: [*c]const VmaAllocation, offsets: [*c]const vk.DeviceSize, sizes: [*c]const vk.DeviceSize) VkResult;
pub extern fn vmaCheckCorruption(allocator: VmaAllocator, memoryTypeBits: u32) VkResult;
pub const struct_VmaDefragmentationContext_T = opaque {};
pub const VmaDefragmentationContext = ?*struct_VmaDefragmentationContext_T;
pub const VMA_DEFRAGMENTATION_FLAG_INCREMENTAL: c_int = 1;
pub const VMA_DEFRAGMENTATION_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaDefragmentationFlagBits = c_uint;
pub const VmaDefragmentationFlagBits = enum_VmaDefragmentationFlagBits;
pub const VmaDefragmentationFlags = VkFlags;
pub const struct_VmaDefragmentationInfo2 = extern struct {
    flags: VmaDefragmentationFlags,
    allocationCount: u32,
    pAllocations: [*c]const VmaAllocation,
    pAllocationsChanged: [*c]VkBool32,
    poolCount: u32,
    pPools: [*c]const VmaPool,
    maxCpuBytesToMove: vk.DeviceSize,
    maxCpuAllocationsToMove: u32,
    maxGpuBytesToMove: vk.DeviceSize,
    maxGpuAllocationsToMove: u32,
    commandBuffer: VkCommandBuffer,
};
pub const VmaDefragmentationInfo2 = struct_VmaDefragmentationInfo2;
pub const struct_VmaDefragmentationPassMoveInfo = extern struct {
    allocation: VmaAllocation,
    memory: vk.DeviceMemory,
    offset: vk.DeviceSize,
};
pub const VmaDefragmentationPassMoveInfo = struct_VmaDefragmentationPassMoveInfo;
pub const struct_VmaDefragmentationPassInfo = extern struct {
    moveCount: u32,
    pMoves: [*c]VmaDefragmentationPassMoveInfo,
};
pub const VmaDefragmentationPassInfo = struct_VmaDefragmentationPassInfo;
pub const struct_VmaDefragmentationInfo = extern struct {
    maxBytesToMove: vk.DeviceSize,
    maxAllocationsToMove: u32,
};
pub const VmaDefragmentationInfo = struct_VmaDefragmentationInfo;
pub const struct_VmaDefragmentationStats = extern struct {
    bytesMoved: vk.DeviceSize,
    bytesFreed: vk.DeviceSize,
    allocationsMoved: u32,
    deviceMemoryBlocksFreed: u32,
};
pub const VmaDefragmentationStats = struct_VmaDefragmentationStats;
pub extern fn vmaDefragmentationBegin(allocator: VmaAllocator, pInfo: [*c]const VmaDefragmentationInfo2, pStats: [*c]VmaDefragmentationStats, pContext: [*c]VmaDefragmentationContext) VkResult;
pub extern fn vmaDefragmentationEnd(allocator: VmaAllocator, context: VmaDefragmentationContext) VkResult;
pub extern fn vmaBeginDefragmentationPass(allocator: VmaAllocator, context: VmaDefragmentationContext, pInfo: [*c]VmaDefragmentationPassInfo) VkResult;
pub extern fn vmaEndDefragmentationPass(allocator: VmaAllocator, context: VmaDefragmentationContext) VkResult;
pub extern fn vmaDefragment(allocator: VmaAllocator, pAllocations: [*c]const VmaAllocation, allocationCount: usize, pAllocationsChanged: [*c]VkBool32, pDefragmentationInfo: [*c]const VmaDefragmentationInfo, pDefragmentationStats: [*c]VmaDefragmentationStats) VkResult;
pub extern fn vmaBindBufferMemory(allocator: VmaAllocator, allocation: VmaAllocation, buffer: VkBuffer) VkResult;
pub extern fn vmaBindBufferMemory2(allocator: VmaAllocator, allocation: VmaAllocation, allocationLocalOffset: vk.DeviceSize, buffer: VkBuffer, pNext: ?*const anyopaque) VkResult;
pub extern fn vmaBindImageMemory(allocator: VmaAllocator, allocation: VmaAllocation, image: VkImage) VkResult;
pub extern fn vmaBindImageMemory2(allocator: VmaAllocator, allocation: VmaAllocation, allocationLocalOffset: vk.DeviceSize, image: VkImage, pNext: ?*const anyopaque) VkResult;
pub extern fn vmaCreateBuffer(allocator: VmaAllocator, pBufferCreateInfo: [*c]const VkBufferCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pBuffer: [*c]VkBuffer, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaDestroyBuffer(allocator: VmaAllocator, buffer: VkBuffer, allocation: VmaAllocation) void;
pub extern fn vmaCreateImage(allocator: VmaAllocator, pImageCreateInfo: [*c]const VkImageCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pImage: [*c]VkImage, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaDestroyImage(allocator: VmaAllocator, image: VkImage, allocation: VmaAllocation) void;


pub const VMA_RECORDING_ENABLED = @as(c_int, 0);
pub const VMA_VULKAN_VERSION = @import("std").zig.c_translation.promoteIntLiteral(c_int, 1002000, .decimal);
pub const VMA_DEDICATED_ALLOCATION = @as(c_int, 1);
pub const VMA_BIND_MEMORY2 = @as(c_int, 1);
pub const VMA_MEMORY_BUDGET = @as(c_int, 1);
pub const VMA_BUFFER_DEVICE_ADDRESS = @as(c_int, 1);
pub const VMA_CALL_PRE = "";
pub const VMA_CALL_POST = "";
// pub const VMA_NOT_NULL_NON_DISPATCHABLE = VMA_NOT_NULL;
// pub const VMA_NULLABLE_NON_DISPATCHABLE = VMA_NULLABLE;
pub const VMA_STATS_STRING_ENABLED = @as(c_int, 1);


pub const VmaAllocator_T = struct_VmaAllocator_T;
pub const VmaPool_T = struct_VmaPool_T;
pub const VmaAllocation_T = struct_VmaAllocation_T;
pub const VmaDefragmentationContext_T = struct_VmaDefragmentationContext_T;




pub const __llvm__ = @as(c_int, 1);
pub const __clang__ = @as(c_int, 1);
pub const __clang_major__ = @as(c_int, 13);
pub const __clang_minor__ = @as(c_int, 0);
pub const __clang_patchlevel__ = @as(c_int, 0);
pub const __clang_version__ = "13.0.0 (git@github.com:ziglang/zig-bootstrap.git 6a5bc3f4a88cc446baad6b0d8677c287f77d9393)";
pub const __GNUC__ = @as(c_int, 4);
pub const __GNUC_MINOR__ = @as(c_int, 2);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
pub const __GXX_ABI_VERSION = @as(c_int, 1002);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
pub const __VERSION__ = "Clang 13.0.0 (git@github.com:ziglang/zig-bootstrap.git 6a5bc3f4a88cc446baad6b0d8677c287f77d9393)";
pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 1);
pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
pub const __BLOCKS__ = @as(c_int, 1);
pub const __clang_literal_encoding__ = "UTF-8";
pub const __clang_wide_literal_encoding__ = "UTF-32";
pub const __OPTIMIZE__ = @as(c_int, 1);
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __LONG_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __SIZE_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __PTRDIFF_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __UINTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_WINT_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_FMTd__ = "ld";
pub const __INTMAX_FMTi__ = "li";
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_FMTo__ = "lo";
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINTMAX_FMTX__ = "lX";
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_TYPE__ = c_long;
pub const __PTRDIFF_FMTd__ = "ld";
pub const __PTRDIFF_FMTi__ = "li";
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_TYPE__ = c_long;
pub const __INTPTR_FMTd__ = "ld";
pub const __INTPTR_FMTi__ = "li";
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIZE_TYPE__ = c_ulong;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZE_FMTx__ = "lx";
pub const __SIZE_FMTX__ = "lX";
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __WCHAR_TYPE__ = c_int;
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __WINT_TYPE__ = c_int;
pub const __WINT_WIDTH__ = @as(c_int, 32);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __UINTPTR_FMTo__ = "lo";
pub const __UINTPTR_FMTu__ = "lu";
pub const __UINTPTR_FMTx__ = "lx";
pub const __UINTPTR_FMTX__ = "lX";
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __FLT16_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT16_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = 4.9406564584124654e-324;
pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = 2.2204460492503131e-16;
pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = 1.7976931348623157e+308;
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = 2.2250738585072014e-308;
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 4.9406564584124654e-324);
pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
pub const __LDBL_DIG__ = @as(c_int, 15);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 2.2204460492503131e-16);
pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __LDBL_MANT_DIG__ = @as(c_int, 53);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __LDBL_MAX_EXP__ = @as(c_int, 1024);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.7976931348623157e+308);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __LDBL_MIN__ = @as(c_longdouble, 2.2250738585072014e-308);
pub const __POINTER_WIDTH__ = @as(c_int, 64);
pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 8);
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub const __INT64_TYPE__ = c_longlong;
pub const __INT64_FMTd__ = "lld";
pub const __INT64_FMTi__ = "lli";
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulonglong;
pub const __UINT64_FMTo__ = "llo";
pub const __UINT64_FMTu__ = "llu";
pub const __UINT64_FMTx__ = "llx";
pub const __UINT64_FMTX__ = "llX";
pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_longlong;
pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST64_FMTd__ = "lld";
pub const __INT_LEAST64_FMTi__ = "lli";
pub const __UINT_LEAST64_TYPE__ = c_ulonglong;
pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_LEAST64_FMTo__ = "llo";
pub const __UINT_LEAST64_FMTu__ = "llu";
pub const __UINT_LEAST64_FMTx__ = "llx";
pub const __UINT_LEAST64_FMTX__ = "llX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_TYPE__ = c_longlong;
pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_FAST64_FMTd__ = "lld";
pub const __INT_FAST64_FMTi__ = "lli";
pub const __UINT_FAST64_TYPE__ = c_ulonglong;
pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINT_FAST64_FMTo__ = "llo";
pub const __UINT_FAST64_FMTu__ = "llu";
pub const __UINT_FAST64_FMTx__ = "llx";
pub const __UINT_FAST64_FMTX__ = "llX";
pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __PIC__ = @as(c_int, 2);
pub const __pic__ = @as(c_int, 2);
pub const __FLT_EVAL_METHOD__ = @as(c_int, 0);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __SSP_STRONG__ = @as(c_int, 2);
pub const __AARCH64EL__ = @as(c_int, 1);
pub const __aarch64__ = @as(c_int, 1);
pub const __AARCH64_CMODEL_SMALL__ = @as(c_int, 1);
pub const __ARM_ACLE = @as(c_int, 200);
pub const __ARM_ARCH = @as(c_int, 8);
pub const __ARM_ARCH_PROFILE = 'A';
pub const __ARM_64BIT_STATE = @as(c_int, 1);
pub const __ARM_PCS_AAPCS64 = @as(c_int, 1);
pub const __ARM_ARCH_ISA_A64 = @as(c_int, 1);
pub const __ARM_FEATURE_CLZ = @as(c_int, 1);
pub const __ARM_FEATURE_FMA = @as(c_int, 1);
pub const __ARM_FEATURE_LDREX = @as(c_int, 0xF);
pub const __ARM_FEATURE_IDIV = @as(c_int, 1);
pub const __ARM_FEATURE_DIV = @as(c_int, 1);
pub const __ARM_FEATURE_NUMERIC_MAXMIN = @as(c_int, 1);
pub const __ARM_FEATURE_DIRECTED_ROUNDING = @as(c_int, 1);
pub const __ARM_ALIGN_MAX_STACK_PWR = @as(c_int, 4);
pub const __ARM_FP = @as(c_int, 0xE);
pub const __ARM_FP16_FORMAT_IEEE = @as(c_int, 1);
pub const __ARM_FP16_ARGS = @as(c_int, 1);
pub const __ARM_SIZEOF_WCHAR_T = @as(c_int, 4);
pub const __ARM_SIZEOF_MINIMAL_ENUM = @as(c_int, 4);
pub const __ARM_NEON = @as(c_int, 1);
pub const __ARM_NEON_FP = @as(c_int, 0xE);
pub const __ARM_FEATURE_CRC32 = @as(c_int, 1);
pub const __ARM_FEATURE_CRYPTO = @as(c_int, 1);
pub const __ARM_FEATURE_AES = @as(c_int, 1);
pub const __ARM_FEATURE_SHA2 = @as(c_int, 1);
pub const __ARM_FEATURE_SHA3 = @as(c_int, 1);
pub const __ARM_FEATURE_SHA512 = @as(c_int, 1);
pub const __ARM_FEATURE_UNALIGNED = @as(c_int, 1);
pub const __ARM_FEATURE_FP16_VECTOR_ARITHMETIC = @as(c_int, 1);
pub const __ARM_FEATURE_FP16_SCALAR_ARITHMETIC = @as(c_int, 1);
pub const __ARM_FEATURE_DOTPROD = @as(c_int, 1);
pub const __ARM_FEATURE_ATOMICS = @as(c_int, 1);
pub const __ARM_FEATURE_FP16_FML = @as(c_int, 1);
pub const __ARM_FEATURE_COMPLEX = @as(c_int, 1);
pub const __ARM_FEATURE_JCVT = @as(c_int, 1);
pub const __ARM_FEATURE_QRDMX = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __AARCH64_SIMD__ = @as(c_int, 1);
pub const __ARM64_ARCH_8__ = @as(c_int, 1);
pub const __ARM_NEON__ = @as(c_int, 1);
pub const __REGISTER_PREFIX__ = "";
pub const __arm64 = @as(c_int, 1);
pub const __arm64__ = @as(c_int, 1);
pub const __APPLE_CC__ = @as(c_int, 6000);
pub const __APPLE__ = @as(c_int, 1);
pub const __STDC_NO_THREADS__ = @as(c_int, 1);
pub const __strong = "";
pub const __unsafe_unretained = "";
pub const __DYNAMIC__ = @as(c_int, 1);
pub const __ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 120300, .decimal);
pub const __MACH__ = @as(c_int, 1);
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const _LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS = @as(c_int, 1);
pub const _LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS = @as(c_int, 1);
pub const _LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS = @as(c_int, 1);
pub const _DEBUG = @as(c_int, 1);
pub const __GCC_HAVE_DWARF2_CFI_ASM = @as(c_int, 1);
pub const AMD_VULKAN_MEMORY_ALLOCATOR_H = "";
pub const NOMINMAX = "";
pub const VULKAN_H_ = @as(c_int, 1);
pub const VK_PLATFORM_H_ = "";
pub const VKAPI_ATTR = "";
pub const VKAPI_CALL = "";
pub const VKAPI_PTR = "";
pub const _LIBCPP_STDDEF_H = "";
pub const _LIBCPP_CONFIG = "";
pub const __STDDEF_H = "";
pub const __need_ptrdiff_t = "";
pub const __need_size_t = "";
pub const __need_wchar_t = "";
pub const __need_NULL = "";
pub const __need_STDDEF_H_misc = "";
pub const _PTRDIFF_T = "";
pub const _SIZE_T = "";
pub const _WCHAR_T = "";
pub const NULL = @import("std").zig.c_translation.cast(?*anyopaque, @as(c_int, 0));
pub const __CLANG_MAX_ALIGN_T_DEFINED = "";
pub const _LIBCPP_STDINT_H = "";
pub const __CLANG_STDINT_H = "";
pub const _STDINT_H_ = "";
pub const __WORDSIZE = @as(c_int, 64);
pub const _INT8_T = "";
pub const _INT16_T = "";
pub const _INT32_T = "";
pub const _INT64_T = "";
pub const _UINT8_T = "";
pub const _UINT16_T = "";
pub const _UINT32_T = "";
pub const _UINT64_T = "";
pub const _SYS__TYPES_H_ = "";
pub const _CDEFS_H_ = "";
pub const __BEGIN_DECLS = "";
pub const __END_DECLS = "";
pub inline fn __P(protos: anytype) @TypeOf(protos) {
    return protos;
}
pub const __signed = c_int;
// pub inline fn __deprecated_enum_msg(_msg: anytype) @TypeOf(__deprecated_msg(_msg)) {
//     return __deprecated_msg(_msg);
// }
pub const __kpi_unavailable = "";
pub const __kpi_deprecated_arm64_macos_unavailable = "";
pub const __dead = "";
pub const __pure = "";
// pub const __abortlike = __dead2 ++ __cold ++ __not_tail_called;
pub const __DARWIN_ONLY_64_BIT_INO_T = @as(c_int, 1);
pub const __DARWIN_ONLY_UNIX_CONFORMANCE = @as(c_int, 1);
pub const __DARWIN_ONLY_VERS_1050 = @as(c_int, 1);
pub const __DARWIN_UNIX03 = @as(c_int, 1);
pub const __DARWIN_64_BIT_INO_T = @as(c_int, 1);
pub const __DARWIN_VERS_1050 = @as(c_int, 1);
pub const __DARWIN_NON_CANCELABLE = @as(c_int, 0);
pub const __DARWIN_SUF_UNIX03 = "";
pub const __DARWIN_SUF_64_BIT_INO_T = "";
pub const __DARWIN_SUF_1050 = "";
pub const __DARWIN_SUF_NON_CANCELABLE = "";
pub const __DARWIN_SUF_EXTSN = "$DARWIN_EXTSN";
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_0(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_3(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_5(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_6(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_7(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_8(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_9(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_10(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_10_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_10_3(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_11(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_11_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_11_3(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_11_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_12(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_12_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_12_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_12_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_13(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_13_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_13_2(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_13_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14_4(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14_5(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_14_6(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_15(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_15_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_10_16(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_11_0(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_11_1(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_11_3(x: anytype) @TypeOf(x) {
    return x;
}
pub inline fn __DARWIN_ALIAS_STARTING_MAC___MAC_12_0(x: anytype) @TypeOf(x) {
    return x;
}
pub const ___POSIX_C_DEPRECATED_STARTING_198808L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_199009L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_199209L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_199309L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_199506L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_200112L = "";
pub const ___POSIX_C_DEPRECATED_STARTING_200809L = "";
pub const __DARWIN_C_ANSI = @as(c_long, 0o10000);
pub const __DARWIN_C_FULL = @as(c_long, 900000);
pub const __DARWIN_C_LEVEL = __DARWIN_C_FULL;
pub const __STDC_WANT_LIB_EXT1__ = @as(c_int, 1);
pub const __DARWIN_NO_LONG_LONG = @as(c_int, 0);
pub const _DARWIN_FEATURE_64_BIT_INODE = @as(c_int, 1);
pub const _DARWIN_FEATURE_ONLY_64_BIT_INODE = @as(c_int, 1);
pub const _DARWIN_FEATURE_ONLY_VERS_1050 = @as(c_int, 1);
pub const _DARWIN_FEATURE_ONLY_UNIX_CONFORMANCE = @as(c_int, 1);
pub const _DARWIN_FEATURE_UNIX_CONFORMANCE = @as(c_int, 3);
pub inline fn __CAST_AWAY_QUALIFIER(variable: anytype, qualifier: anytype, @"type": anytype) @TypeOf(@"type"(c_long)(variable)) {
    _ = qualifier;
    return @"type"(c_long)(variable);
}
pub const __kernel_ptr_semantics = "";
pub const __kernel_data_semantics = "";
pub const __kernel_dual_semantics = "";
pub const _BSD_MACHINE__TYPES_H_ = "";
pub const _BSD_ARM__TYPES_H_ = "";
pub const __DARWIN_NULL = @import("std").zig.c_translation.cast(?*anyopaque, @as(c_int, 0));
pub const _SYS__PTHREAD_TYPES_H_ = "";
pub const __PTHREAD_SIZE__ = @as(c_int, 8176);
pub const __PTHREAD_ATTR_SIZE__ = @as(c_int, 56);
pub const __PTHREAD_MUTEXATTR_SIZE__ = @as(c_int, 8);
pub const __PTHREAD_MUTEX_SIZE__ = @as(c_int, 56);
pub const __PTHREAD_CONDATTR_SIZE__ = @as(c_int, 8);
pub const __PTHREAD_COND_SIZE__ = @as(c_int, 40);
pub const __PTHREAD_ONCE_SIZE__ = @as(c_int, 8);
pub const __PTHREAD_RWLOCK_SIZE__ = @as(c_int, 192);
pub const __PTHREAD_RWLOCKATTR_SIZE__ = @as(c_int, 16);
pub const _INTPTR_T = "";
pub const _BSD_MACHINE_TYPES_H_ = "";
pub const _ARM_MACHTYPES_H_ = "";
pub const _MACHTYPES_H_ = "";
pub const _U_INT8_T = "";
pub const _U_INT16_T = "";
pub const _U_INT32_T = "";
pub const _U_INT64_T = "";
pub const _UINTPTR_T = "";
pub const USER_ADDR_NULL = @import("std").zig.c_translation.cast(user_addr_t, @as(c_int, 0));
pub inline fn CAST_USER_ADDR_T(a_ptr: anytype) user_addr_t {
    return @import("std").zig.c_translation.cast(user_addr_t, @import("std").zig.c_translation.cast(usize, a_ptr));
}
pub const _INTMAX_T = "";
pub const _UINTMAX_T = "";
pub inline fn INT8_C(v: anytype) @TypeOf(v) {
    return v;
}
pub inline fn INT16_C(v: anytype) @TypeOf(v) {
    return v;
}
pub inline fn INT32_C(v: anytype) @TypeOf(v) {
    return v;
}
pub const INT64_C = @import("std").zig.c_translation.Macros.LL_SUFFIX;
pub inline fn UINT8_C(v: anytype) @TypeOf(v) {
    return v;
}
pub inline fn UINT16_C(v: anytype) @TypeOf(v) {
    return v;
}
pub const UINT32_C = @import("std").zig.c_translation.Macros.U_SUFFIX;
pub const UINT64_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
pub const INTMAX_C = @import("std").zig.c_translation.Macros.L_SUFFIX;
pub const UINTMAX_C = @import("std").zig.c_translation.Macros.UL_SUFFIX;
pub const INT8_MAX = @as(c_int, 127);
pub const INT16_MAX = @as(c_int, 32767);
pub const INT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const INT64_MAX = @as(c_longlong, 9223372036854775807);
pub const INT8_MIN = -@as(c_int, 128);
pub const INT16_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 32768, .decimal);
pub const INT32_MIN = -INT32_MAX - @as(c_int, 1);
pub const INT64_MIN = -INT64_MAX - @as(c_int, 1);
pub const UINT8_MAX = @as(c_int, 255);
pub const UINT16_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT64_MAX = @as(c_ulonglong, 18446744073709551615);
pub const INT_LEAST8_MIN = INT8_MIN;
pub const INT_LEAST16_MIN = INT16_MIN;
pub const INT_LEAST32_MIN = INT32_MIN;
pub const INT_LEAST64_MIN = INT64_MIN;
pub const INT_LEAST8_MAX = INT8_MAX;
pub const INT_LEAST16_MAX = INT16_MAX;
pub const INT_LEAST32_MAX = INT32_MAX;
pub const INT_LEAST64_MAX = INT64_MAX;
pub const UINT_LEAST8_MAX = UINT8_MAX;
pub const UINT_LEAST16_MAX = UINT16_MAX;
pub const UINT_LEAST32_MAX = UINT32_MAX;
pub const UINT_LEAST64_MAX = UINT64_MAX;
pub const INT_FAST8_MIN = INT8_MIN;
pub const INT_FAST16_MIN = INT16_MIN;
pub const INT_FAST32_MIN = INT32_MIN;
pub const INT_FAST64_MIN = INT64_MIN;
pub const INT_FAST8_MAX = INT8_MAX;
pub const INT_FAST16_MAX = INT16_MAX;
pub const INT_FAST32_MAX = INT32_MAX;
pub const INT_FAST64_MAX = INT64_MAX;
pub const UINT_FAST8_MAX = UINT8_MAX;
pub const UINT_FAST16_MAX = UINT16_MAX;
pub const UINT_FAST32_MAX = UINT32_MAX;
pub const UINT_FAST64_MAX = UINT64_MAX;
pub const INTPTR_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const INTPTR_MIN = -INTPTR_MAX - @as(c_int, 1);
pub const UINTPTR_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const INTMAX_MAX = INTMAX_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 9223372036854775807, .decimal));
pub const UINTMAX_MAX = UINTMAX_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 18446744073709551615, .decimal));
pub const INTMAX_MIN = -INTMAX_MAX - @as(c_int, 1);
pub const PTRDIFF_MIN = INTMAX_MIN;
pub const PTRDIFF_MAX = INTMAX_MAX;
pub const SIZE_MAX = UINTPTR_MAX;
pub const RSIZE_MAX = SIZE_MAX >> @as(c_int, 1);
pub const WCHAR_MAX = __WCHAR_MAX__;
pub const WCHAR_MIN = -WCHAR_MAX - @as(c_int, 1);
pub const WINT_MIN = INT32_MIN;
pub const WINT_MAX = INT32_MAX;
pub const SIG_ATOMIC_MIN = INT32_MIN;
pub const SIG_ATOMIC_MAX = INT32_MAX;
pub const VULKAN_CORE_H_ = @as(c_int, 1);
pub const VK_VERSION_1_0 = @as(c_int, 1);
pub const VK_USE_64_BIT_PTR_DEFINES = @as(c_int, 1);
pub const VK_NULL_HANDLE = @import("std").zig.c_translation.cast(?*anyopaque, @as(c_int, 0));
pub inline fn VK_MAKE_VERSION(major: anytype, minor: anytype, patch: anytype) @TypeOf(((@import("std").zig.c_translation.cast(u32, major) << @as(c_int, 22)) | (@import("std").zig.c_translation.cast(u32, minor) << @as(c_int, 12))) | @import("std").zig.c_translation.cast(u32, patch)) {
    return ((@import("std").zig.c_translation.cast(u32, major) << @as(c_int, 22)) | (@import("std").zig.c_translation.cast(u32, minor) << @as(c_int, 12))) | @import("std").zig.c_translation.cast(u32, patch);
}
pub inline fn VK_MAKE_API_VERSION(variant: anytype, major: anytype, minor: anytype, patch: anytype) @TypeOf((((@import("std").zig.c_translation.cast(u32, variant) << @as(c_int, 29)) | (@import("std").zig.c_translation.cast(u32, major) << @as(c_int, 22))) | (@import("std").zig.c_translation.cast(u32, minor) << @as(c_int, 12))) | @import("std").zig.c_translation.cast(u32, patch)) {
    return (((@import("std").zig.c_translation.cast(u32, variant) << @as(c_int, 29)) | (@import("std").zig.c_translation.cast(u32, major) << @as(c_int, 22))) | (@import("std").zig.c_translation.cast(u32, minor) << @as(c_int, 12))) | @import("std").zig.c_translation.cast(u32, patch);
}
pub const VK_API_VERSION_1_0 = VK_MAKE_API_VERSION(@as(c_int, 0), @as(c_int, 1), @as(c_int, 0), @as(c_int, 0));
pub const VK_HEADER_VERSION = @as(c_int, 203);
pub const VK_HEADER_VERSION_COMPLETE = VK_MAKE_API_VERSION(@as(c_int, 0), @as(c_int, 1), @as(c_int, 2), VK_HEADER_VERSION);
pub inline fn VK_VERSION_MAJOR(version: anytype) @TypeOf(@import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 22)) {
    return @import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 22);
}
pub inline fn VK_VERSION_MINOR(version: anytype) @TypeOf((@import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 12)) & @as(c_uint, 0x3FF)) {
    return (@import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 12)) & @as(c_uint, 0x3FF);
}
pub inline fn VK_VERSION_PATCH(version: anytype) @TypeOf(@import("std").zig.c_translation.cast(u32, version) & @as(c_uint, 0xFFF)) {
    return @import("std").zig.c_translation.cast(u32, version) & @as(c_uint, 0xFFF);
}
pub inline fn VK_API_VERSION_VARIANT(version: anytype) @TypeOf(@import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 29)) {
    return @import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 29);
}
pub inline fn VK_API_VERSION_MAJOR(version: anytype) @TypeOf((@import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 22)) & @as(c_uint, 0x7F)) {
    return (@import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 22)) & @as(c_uint, 0x7F);
}
pub inline fn VK_API_VERSION_MINOR(version: anytype) @TypeOf((@import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 12)) & @as(c_uint, 0x3FF)) {
    return (@import("std").zig.c_translation.cast(u32, version) >> @as(c_int, 12)) & @as(c_uint, 0x3FF);
}
pub inline fn VK_API_VERSION_PATCH(version: anytype) @TypeOf(@import("std").zig.c_translation.cast(u32, version) & @as(c_uint, 0xFFF)) {
    return @import("std").zig.c_translation.cast(u32, version) & @as(c_uint, 0xFFF);
}
pub const VK_UUID_SIZE = @as(c_uint, 16);
pub const VK_ATTACHMENT_UNUSED = ~@as(c_uint, 0);
pub const VK_FALSE = @as(c_uint, 0);
pub const VK_LOD_CLAMP_NONE = @as(f32, 1000.0);
pub const VK_QUEUE_FAMILY_IGNORED = ~@as(c_uint, 0);
pub const VK_REMAINING_ARRAY_LAYERS = ~@as(c_uint, 0);
pub const VK_REMAINING_MIP_LEVELS = ~@as(c_uint, 0);
pub const VK_SUBPASS_EXTERNAL = ~@as(c_uint, 0);
pub const VK_TRUE = @as(c_uint, 1);
pub const VK_WHOLE_SIZE = ~@as(c_ulonglong, 0);
pub const VK_MAX_MEMORY_TYPES = @as(c_uint, 32);
pub const VK_MAX_MEMORY_HEAPS = @as(c_uint, 16);
pub const VK_MAX_PHYSICAL_DEVICE_NAME_SIZE = @as(c_uint, 256);
pub const VK_MAX_EXTENSION_NAME_SIZE = @as(c_uint, 256);
pub const VK_MAX_DESCRIPTION_SIZE = @as(c_uint, 256);
pub const VK_VERSION_1_1 = @as(c_int, 1);
pub const VK_API_VERSION_1_1 = VK_MAKE_API_VERSION(@as(c_int, 0), @as(c_int, 1), @as(c_int, 1), @as(c_int, 0));
pub const VK_MAX_DEVICE_GROUP_SIZE = @as(c_uint, 32);
pub const VK_LUID_SIZE = @as(c_uint, 8);
pub const VK_QUEUE_FAMILY_EXTERNAL = ~@as(c_uint, 1);
pub const VK_VERSION_1_2 = @as(c_int, 1);
pub const VK_API_VERSION_1_2 = VK_MAKE_API_VERSION(@as(c_int, 0), @as(c_int, 1), @as(c_int, 2), @as(c_int, 0));
pub const VK_MAX_DRIVER_NAME_SIZE = @as(c_uint, 256);
pub const VK_MAX_DRIVER_INFO_SIZE = @as(c_uint, 256);
pub const VK_KHR_surface = @as(c_int, 1);
pub const VK_KHR_SURFACE_SPEC_VERSION = @as(c_int, 25);
pub const VK_KHR_SURFACE_EXTENSION_NAME = "VK_KHR_surface";
pub const VK_KHR_swapchain = @as(c_int, 1);
pub const VK_KHR_SWAPCHAIN_SPEC_VERSION = @as(c_int, 70);
pub const VK_KHR_SWAPCHAIN_EXTENSION_NAME = "VK_KHR_swapchain";
pub const VK_KHR_display = @as(c_int, 1);
pub const VK_KHR_DISPLAY_SPEC_VERSION = @as(c_int, 23);
pub const VK_KHR_DISPLAY_EXTENSION_NAME = "VK_KHR_display";
pub const VK_KHR_display_swapchain = @as(c_int, 1);
pub const VK_KHR_DISPLAY_SWAPCHAIN_SPEC_VERSION = @as(c_int, 10);
pub const VK_KHR_DISPLAY_SWAPCHAIN_EXTENSION_NAME = "VK_KHR_display_swapchain";
pub const VK_KHR_sampler_mirror_clamp_to_edge = @as(c_int, 1);
pub const VK_KHR_SAMPLER_MIRROR_CLAMP_TO_EDGE_SPEC_VERSION = @as(c_int, 3);
pub const VK_KHR_SAMPLER_MIRROR_CLAMP_TO_EDGE_EXTENSION_NAME = "VK_KHR_sampler_mirror_clamp_to_edge";
pub const VK_KHR_dynamic_rendering = @as(c_int, 1);
pub const VK_KHR_DYNAMIC_RENDERING_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_DYNAMIC_RENDERING_EXTENSION_NAME = "VK_KHR_dynamic_rendering";
pub const VK_KHR_multiview = @as(c_int, 1);
pub const VK_KHR_MULTIVIEW_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_MULTIVIEW_EXTENSION_NAME = "VK_KHR_multiview";
pub const VK_KHR_get_physical_device_properties2 = @as(c_int, 1);
pub const VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_SPEC_VERSION = @as(c_int, 2);
pub const VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME = "VK_KHR_get_physical_device_properties2";
pub const VK_KHR_device_group = @as(c_int, 1);
pub const VK_KHR_DEVICE_GROUP_SPEC_VERSION = @as(c_int, 4);
pub const VK_KHR_DEVICE_GROUP_EXTENSION_NAME = "VK_KHR_device_group";
pub const VK_KHR_shader_draw_parameters = @as(c_int, 1);
pub const VK_KHR_SHADER_DRAW_PARAMETERS_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHADER_DRAW_PARAMETERS_EXTENSION_NAME = "VK_KHR_shader_draw_parameters";
pub const VK_KHR_maintenance1 = @as(c_int, 1);
pub const VK_KHR_MAINTENANCE_1_SPEC_VERSION = @as(c_int, 2);
pub const VK_KHR_MAINTENANCE_1_EXTENSION_NAME = "VK_KHR_maintenance1";
pub const VK_KHR_MAINTENANCE1_SPEC_VERSION = VK_KHR_MAINTENANCE_1_SPEC_VERSION;
pub const VK_KHR_MAINTENANCE1_EXTENSION_NAME = VK_KHR_MAINTENANCE_1_EXTENSION_NAME;
pub const VK_KHR_device_group_creation = @as(c_int, 1);
pub const VK_KHR_DEVICE_GROUP_CREATION_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_DEVICE_GROUP_CREATION_EXTENSION_NAME = "VK_KHR_device_group_creation";
pub const VK_MAX_DEVICE_GROUP_SIZE_KHR = VK_MAX_DEVICE_GROUP_SIZE;
pub const VK_KHR_external_memory_capabilities = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_MEMORY_CAPABILITIES_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_MEMORY_CAPABILITIES_EXTENSION_NAME = "VK_KHR_external_memory_capabilities";
pub const VK_LUID_SIZE_KHR = VK_LUID_SIZE;
pub const VK_KHR_external_memory = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_MEMORY_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_MEMORY_EXTENSION_NAME = "VK_KHR_external_memory";
pub const VK_QUEUE_FAMILY_EXTERNAL_KHR = VK_QUEUE_FAMILY_EXTERNAL;
pub const VK_KHR_external_memory_fd = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_MEMORY_FD_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_MEMORY_FD_EXTENSION_NAME = "VK_KHR_external_memory_fd";
pub const VK_KHR_external_semaphore_capabilities = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_SEMAPHORE_CAPABILITIES_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_SEMAPHORE_CAPABILITIES_EXTENSION_NAME = "VK_KHR_external_semaphore_capabilities";
pub const VK_KHR_external_semaphore = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_SEMAPHORE_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_SEMAPHORE_EXTENSION_NAME = "VK_KHR_external_semaphore";
pub const VK_KHR_external_semaphore_fd = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_SEMAPHORE_FD_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_SEMAPHORE_FD_EXTENSION_NAME = "VK_KHR_external_semaphore_fd";
pub const VK_KHR_push_descriptor = @as(c_int, 1);
pub const VK_KHR_PUSH_DESCRIPTOR_SPEC_VERSION = @as(c_int, 2);
pub const VK_KHR_PUSH_DESCRIPTOR_EXTENSION_NAME = "VK_KHR_push_descriptor";
pub const VK_KHR_shader_float16_int8 = @as(c_int, 1);
pub const VK_KHR_SHADER_FLOAT16_INT8_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHADER_FLOAT16_INT8_EXTENSION_NAME = "VK_KHR_shader_float16_int8";
pub const VK_KHR_16bit_storage = @as(c_int, 1);
pub const VK_KHR_16BIT_STORAGE_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_16BIT_STORAGE_EXTENSION_NAME = "VK_KHR_16bit_storage";
pub const VK_KHR_incremental_present = @as(c_int, 1);
pub const VK_KHR_INCREMENTAL_PRESENT_SPEC_VERSION = @as(c_int, 2);
pub const VK_KHR_INCREMENTAL_PRESENT_EXTENSION_NAME = "VK_KHR_incremental_present";
pub const VK_KHR_descriptor_update_template = @as(c_int, 1);
pub const VK_KHR_DESCRIPTOR_UPDATE_TEMPLATE_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_DESCRIPTOR_UPDATE_TEMPLATE_EXTENSION_NAME = "VK_KHR_descriptor_update_template";
pub const VK_KHR_imageless_framebuffer = @as(c_int, 1);
pub const VK_KHR_IMAGELESS_FRAMEBUFFER_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_IMAGELESS_FRAMEBUFFER_EXTENSION_NAME = "VK_KHR_imageless_framebuffer";
pub const VK_KHR_create_renderpass2 = @as(c_int, 1);
pub const VK_KHR_CREATE_RENDERPASS_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_CREATE_RENDERPASS_2_EXTENSION_NAME = "VK_KHR_create_renderpass2";
pub const VK_KHR_shared_presentable_image = @as(c_int, 1);
pub const VK_KHR_SHARED_PRESENTABLE_IMAGE_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHARED_PRESENTABLE_IMAGE_EXTENSION_NAME = "VK_KHR_shared_presentable_image";
pub const VK_KHR_external_fence_capabilities = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_FENCE_CAPABILITIES_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_FENCE_CAPABILITIES_EXTENSION_NAME = "VK_KHR_external_fence_capabilities";
pub const VK_KHR_external_fence = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_FENCE_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_FENCE_EXTENSION_NAME = "VK_KHR_external_fence";
pub const VK_KHR_external_fence_fd = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_FENCE_FD_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_EXTERNAL_FENCE_FD_EXTENSION_NAME = "VK_KHR_external_fence_fd";
pub const VK_KHR_performance_query = @as(c_int, 1);
pub const VK_KHR_PERFORMANCE_QUERY_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_PERFORMANCE_QUERY_EXTENSION_NAME = "VK_KHR_performance_query";
pub const VK_KHR_maintenance2 = @as(c_int, 1);
pub const VK_KHR_MAINTENANCE_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_MAINTENANCE_2_EXTENSION_NAME = "VK_KHR_maintenance2";
pub const VK_KHR_MAINTENANCE2_SPEC_VERSION = VK_KHR_MAINTENANCE_2_SPEC_VERSION;
pub const VK_KHR_MAINTENANCE2_EXTENSION_NAME = VK_KHR_MAINTENANCE_2_EXTENSION_NAME;
pub const VK_KHR_get_surface_capabilities2 = @as(c_int, 1);
pub const VK_KHR_GET_SURFACE_CAPABILITIES_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_GET_SURFACE_CAPABILITIES_2_EXTENSION_NAME = "VK_KHR_get_surface_capabilities2";
pub const VK_KHR_variable_pointers = @as(c_int, 1);
pub const VK_KHR_VARIABLE_POINTERS_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_VARIABLE_POINTERS_EXTENSION_NAME = "VK_KHR_variable_pointers";
pub const VK_KHR_get_display_properties2 = @as(c_int, 1);
pub const VK_KHR_GET_DISPLAY_PROPERTIES_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_GET_DISPLAY_PROPERTIES_2_EXTENSION_NAME = "VK_KHR_get_display_properties2";
pub const VK_KHR_dedicated_allocation = @as(c_int, 1);
pub const VK_KHR_DEDICATED_ALLOCATION_SPEC_VERSION = @as(c_int, 3);
pub const VK_KHR_DEDICATED_ALLOCATION_EXTENSION_NAME = "VK_KHR_dedicated_allocation";
pub const VK_KHR_storage_buffer_storage_class = @as(c_int, 1);
pub const VK_KHR_STORAGE_BUFFER_STORAGE_CLASS_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_STORAGE_BUFFER_STORAGE_CLASS_EXTENSION_NAME = "VK_KHR_storage_buffer_storage_class";
pub const VK_KHR_relaxed_block_layout = @as(c_int, 1);
pub const VK_KHR_RELAXED_BLOCK_LAYOUT_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_RELAXED_BLOCK_LAYOUT_EXTENSION_NAME = "VK_KHR_relaxed_block_layout";
pub const VK_KHR_get_memory_requirements2 = @as(c_int, 1);
pub const VK_KHR_GET_MEMORY_REQUIREMENTS_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_GET_MEMORY_REQUIREMENTS_2_EXTENSION_NAME = "VK_KHR_get_memory_requirements2";
pub const VK_KHR_image_format_list = @as(c_int, 1);
pub const VK_KHR_IMAGE_FORMAT_LIST_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_IMAGE_FORMAT_LIST_EXTENSION_NAME = "VK_KHR_image_format_list";
pub const VK_KHR_sampler_ycbcr_conversion = @as(c_int, 1);
pub const VK_KHR_SAMPLER_YCBCR_CONVERSION_SPEC_VERSION = @as(c_int, 14);
pub const VK_KHR_SAMPLER_YCBCR_CONVERSION_EXTENSION_NAME = "VK_KHR_sampler_ycbcr_conversion";
pub const VK_KHR_bind_memory2 = @as(c_int, 1);
pub const VK_KHR_BIND_MEMORY_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_BIND_MEMORY_2_EXTENSION_NAME = "VK_KHR_bind_memory2";
pub const VK_KHR_maintenance3 = @as(c_int, 1);
pub const VK_KHR_MAINTENANCE_3_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_MAINTENANCE_3_EXTENSION_NAME = "VK_KHR_maintenance3";
pub const VK_KHR_MAINTENANCE3_SPEC_VERSION = VK_KHR_MAINTENANCE_3_SPEC_VERSION;
pub const VK_KHR_MAINTENANCE3_EXTENSION_NAME = VK_KHR_MAINTENANCE_3_EXTENSION_NAME;
pub const VK_KHR_draw_indirect_count = @as(c_int, 1);
pub const VK_KHR_DRAW_INDIRECT_COUNT_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_DRAW_INDIRECT_COUNT_EXTENSION_NAME = "VK_KHR_draw_indirect_count";
pub const VK_KHR_shader_subgroup_extended_types = @as(c_int, 1);
pub const VK_KHR_SHADER_SUBGROUP_EXTENDED_TYPES_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHADER_SUBGROUP_EXTENDED_TYPES_EXTENSION_NAME = "VK_KHR_shader_subgroup_extended_types";
pub const VK_KHR_8bit_storage = @as(c_int, 1);
pub const VK_KHR_8BIT_STORAGE_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_8BIT_STORAGE_EXTENSION_NAME = "VK_KHR_8bit_storage";
pub const VK_KHR_shader_atomic_int64 = @as(c_int, 1);
pub const VK_KHR_SHADER_ATOMIC_INT64_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHADER_ATOMIC_INT64_EXTENSION_NAME = "VK_KHR_shader_atomic_int64";
pub const VK_KHR_shader_clock = @as(c_int, 1);
pub const VK_KHR_SHADER_CLOCK_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHADER_CLOCK_EXTENSION_NAME = "VK_KHR_shader_clock";
pub const VK_KHR_driver_properties = @as(c_int, 1);
pub const VK_KHR_DRIVER_PROPERTIES_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_DRIVER_PROPERTIES_EXTENSION_NAME = "VK_KHR_driver_properties";
pub const VK_MAX_DRIVER_NAME_SIZE_KHR = VK_MAX_DRIVER_NAME_SIZE;
pub const VK_MAX_DRIVER_INFO_SIZE_KHR = VK_MAX_DRIVER_INFO_SIZE;
pub const VK_KHR_shader_float_controls = @as(c_int, 1);
pub const VK_KHR_SHADER_FLOAT_CONTROLS_SPEC_VERSION = @as(c_int, 4);
pub const VK_KHR_SHADER_FLOAT_CONTROLS_EXTENSION_NAME = "VK_KHR_shader_float_controls";
pub const VK_KHR_depth_stencil_resolve = @as(c_int, 1);
pub const VK_KHR_DEPTH_STENCIL_RESOLVE_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_DEPTH_STENCIL_RESOLVE_EXTENSION_NAME = "VK_KHR_depth_stencil_resolve";
pub const VK_KHR_swapchain_mutable_format = @as(c_int, 1);
pub const VK_KHR_SWAPCHAIN_MUTABLE_FORMAT_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SWAPCHAIN_MUTABLE_FORMAT_EXTENSION_NAME = "VK_KHR_swapchain_mutable_format";
pub const VK_KHR_timeline_semaphore = @as(c_int, 1);
pub const VK_KHR_TIMELINE_SEMAPHORE_SPEC_VERSION = @as(c_int, 2);
pub const VK_KHR_TIMELINE_SEMAPHORE_EXTENSION_NAME = "VK_KHR_timeline_semaphore";
pub const VK_KHR_vulkan_memory_model = @as(c_int, 1);
pub const VK_KHR_VULKAN_MEMORY_MODEL_SPEC_VERSION = @as(c_int, 3);
pub const VK_KHR_VULKAN_MEMORY_MODEL_EXTENSION_NAME = "VK_KHR_vulkan_memory_model";
pub const VK_KHR_shader_terminate_invocation = @as(c_int, 1);
pub const VK_KHR_SHADER_TERMINATE_INVOCATION_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHADER_TERMINATE_INVOCATION_EXTENSION_NAME = "VK_KHR_shader_terminate_invocation";
pub const VK_KHR_fragment_shading_rate = @as(c_int, 1);
pub const VK_KHR_FRAGMENT_SHADING_RATE_SPEC_VERSION = @as(c_int, 2);
pub const VK_KHR_FRAGMENT_SHADING_RATE_EXTENSION_NAME = "VK_KHR_fragment_shading_rate";
pub const VK_KHR_spirv_1_4 = @as(c_int, 1);
pub const VK_KHR_SPIRV_1_4_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SPIRV_1_4_EXTENSION_NAME = "VK_KHR_spirv_1_4";
pub const VK_KHR_surface_protected_capabilities = @as(c_int, 1);
pub const VK_KHR_SURFACE_PROTECTED_CAPABILITIES_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SURFACE_PROTECTED_CAPABILITIES_EXTENSION_NAME = "VK_KHR_surface_protected_capabilities";
pub const VK_KHR_separate_depth_stencil_layouts = @as(c_int, 1);
pub const VK_KHR_SEPARATE_DEPTH_STENCIL_LAYOUTS_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SEPARATE_DEPTH_STENCIL_LAYOUTS_EXTENSION_NAME = "VK_KHR_separate_depth_stencil_layouts";
pub const VK_KHR_present_wait = @as(c_int, 1);
pub const VK_KHR_PRESENT_WAIT_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_PRESENT_WAIT_EXTENSION_NAME = "VK_KHR_present_wait";
pub const VK_KHR_uniform_buffer_standard_layout = @as(c_int, 1);
pub const VK_KHR_UNIFORM_BUFFER_STANDARD_LAYOUT_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_UNIFORM_BUFFER_STANDARD_LAYOUT_EXTENSION_NAME = "VK_KHR_uniform_buffer_standard_layout";
pub const VK_KHR_buffer_device_address = @as(c_int, 1);
pub const VK_KHR_BUFFER_DEVICE_ADDRESS_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME = "VK_KHR_buffer_device_address";
pub const VK_KHR_deferred_host_operations = @as(c_int, 1);
pub const VK_KHR_DEFERRED_HOST_OPERATIONS_SPEC_VERSION = @as(c_int, 4);
pub const VK_KHR_DEFERRED_HOST_OPERATIONS_EXTENSION_NAME = "VK_KHR_deferred_host_operations";
pub const VK_KHR_pipeline_executable_properties = @as(c_int, 1);
pub const VK_KHR_PIPELINE_EXECUTABLE_PROPERTIES_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_PIPELINE_EXECUTABLE_PROPERTIES_EXTENSION_NAME = "VK_KHR_pipeline_executable_properties";
pub const VK_KHR_shader_integer_dot_product = @as(c_int, 1);
pub const VK_KHR_SHADER_INTEGER_DOT_PRODUCT_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHADER_INTEGER_DOT_PRODUCT_EXTENSION_NAME = "VK_KHR_shader_integer_dot_product";
pub const VK_KHR_pipeline_library = @as(c_int, 1);
pub const VK_KHR_PIPELINE_LIBRARY_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_PIPELINE_LIBRARY_EXTENSION_NAME = "VK_KHR_pipeline_library";
pub const VK_KHR_shader_non_semantic_info = @as(c_int, 1);
pub const VK_KHR_SHADER_NON_SEMANTIC_INFO_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHADER_NON_SEMANTIC_INFO_EXTENSION_NAME = "VK_KHR_shader_non_semantic_info";
pub const VK_KHR_present_id = @as(c_int, 1);
pub const VK_KHR_PRESENT_ID_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_PRESENT_ID_EXTENSION_NAME = "VK_KHR_present_id";
pub const VK_KHR_synchronization2 = @as(c_int, 1);
pub const VK_KHR_SYNCHRONIZATION_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SYNCHRONIZATION_2_EXTENSION_NAME = "VK_KHR_synchronization2";
pub const VK_KHR_shader_subgroup_uniform_control_flow = @as(c_int, 1);
pub const VK_KHR_SHADER_SUBGROUP_UNIFORM_CONTROL_FLOW_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_SHADER_SUBGROUP_UNIFORM_CONTROL_FLOW_EXTENSION_NAME = "VK_KHR_shader_subgroup_uniform_control_flow";
pub const VK_KHR_zero_initialize_workgroup_memory = @as(c_int, 1);
pub const VK_KHR_ZERO_INITIALIZE_WORKGROUP_MEMORY_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_ZERO_INITIALIZE_WORKGROUP_MEMORY_EXTENSION_NAME = "VK_KHR_zero_initialize_workgroup_memory";
pub const VK_KHR_workgroup_memory_explicit_layout = @as(c_int, 1);
pub const VK_KHR_WORKGROUP_MEMORY_EXPLICIT_LAYOUT_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_WORKGROUP_MEMORY_EXPLICIT_LAYOUT_EXTENSION_NAME = "VK_KHR_workgroup_memory_explicit_layout";
pub const VK_KHR_copy_commands2 = @as(c_int, 1);
pub const VK_KHR_COPY_COMMANDS_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_COPY_COMMANDS_2_EXTENSION_NAME = "VK_KHR_copy_commands2";
pub const VK_KHR_format_feature_flags2 = @as(c_int, 1);
pub const VK_KHR_FORMAT_FEATURE_FLAGS_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_FORMAT_FEATURE_FLAGS_2_EXTENSION_NAME = "VK_KHR_format_feature_flags2";
pub const VK_KHR_maintenance4 = @as(c_int, 1);
pub const VK_KHR_MAINTENANCE_4_SPEC_VERSION = @as(c_int, 2);
pub const VK_KHR_MAINTENANCE_4_EXTENSION_NAME = "VK_KHR_maintenance4";
pub const VK_EXT_debug_report = @as(c_int, 1);
pub const VK_EXT_DEBUG_REPORT_SPEC_VERSION = @as(c_int, 10);
pub const VK_EXT_DEBUG_REPORT_EXTENSION_NAME = "VK_EXT_debug_report";
pub const VK_NV_glsl_shader = @as(c_int, 1);
pub const VK_NV_GLSL_SHADER_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_GLSL_SHADER_EXTENSION_NAME = "VK_NV_glsl_shader";
pub const VK_EXT_depth_range_unrestricted = @as(c_int, 1);
pub const VK_EXT_DEPTH_RANGE_UNRESTRICTED_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_DEPTH_RANGE_UNRESTRICTED_EXTENSION_NAME = "VK_EXT_depth_range_unrestricted";
pub const VK_IMG_filter_cubic = @as(c_int, 1);
pub const VK_IMG_FILTER_CUBIC_SPEC_VERSION = @as(c_int, 1);
pub const VK_IMG_FILTER_CUBIC_EXTENSION_NAME = "VK_IMG_filter_cubic";
pub const VK_AMD_rasterization_order = @as(c_int, 1);
pub const VK_AMD_RASTERIZATION_ORDER_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_RASTERIZATION_ORDER_EXTENSION_NAME = "VK_AMD_rasterization_order";
pub const VK_AMD_shader_trinary_minmax = @as(c_int, 1);
pub const VK_AMD_SHADER_TRINARY_MINMAX_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_SHADER_TRINARY_MINMAX_EXTENSION_NAME = "VK_AMD_shader_trinary_minmax";
pub const VK_AMD_shader_explicit_vertex_parameter = @as(c_int, 1);
pub const VK_AMD_SHADER_EXPLICIT_VERTEX_PARAMETER_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_SHADER_EXPLICIT_VERTEX_PARAMETER_EXTENSION_NAME = "VK_AMD_shader_explicit_vertex_parameter";
pub const VK_EXT_debug_marker = @as(c_int, 1);
pub const VK_EXT_DEBUG_MARKER_SPEC_VERSION = @as(c_int, 4);
pub const VK_EXT_DEBUG_MARKER_EXTENSION_NAME = "VK_EXT_debug_marker";
pub const VK_AMD_gcn_shader = @as(c_int, 1);
pub const VK_AMD_GCN_SHADER_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_GCN_SHADER_EXTENSION_NAME = "VK_AMD_gcn_shader";
pub const VK_NV_dedicated_allocation = @as(c_int, 1);
pub const VK_NV_DEDICATED_ALLOCATION_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_DEDICATED_ALLOCATION_EXTENSION_NAME = "VK_NV_dedicated_allocation";
pub const VK_EXT_transform_feedback = @as(c_int, 1);
pub const VK_EXT_TRANSFORM_FEEDBACK_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_TRANSFORM_FEEDBACK_EXTENSION_NAME = "VK_EXT_transform_feedback";
pub const VK_NVX_binary_import = @as(c_int, 1);
pub const VK_NVX_BINARY_IMPORT_SPEC_VERSION = @as(c_int, 1);
pub const VK_NVX_BINARY_IMPORT_EXTENSION_NAME = "VK_NVX_binary_import";
pub const VK_NVX_image_view_handle = @as(c_int, 1);
pub const VK_NVX_IMAGE_VIEW_HANDLE_SPEC_VERSION = @as(c_int, 2);
pub const VK_NVX_IMAGE_VIEW_HANDLE_EXTENSION_NAME = "VK_NVX_image_view_handle";
pub const VK_AMD_draw_indirect_count = @as(c_int, 1);
pub const VK_AMD_DRAW_INDIRECT_COUNT_SPEC_VERSION = @as(c_int, 2);
pub const VK_AMD_DRAW_INDIRECT_COUNT_EXTENSION_NAME = "VK_AMD_draw_indirect_count";
pub const VK_AMD_negative_viewport_height = @as(c_int, 1);
pub const VK_AMD_NEGATIVE_VIEWPORT_HEIGHT_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_NEGATIVE_VIEWPORT_HEIGHT_EXTENSION_NAME = "VK_AMD_negative_viewport_height";
pub const VK_AMD_gpu_shader_half_float = @as(c_int, 1);
pub const VK_AMD_GPU_SHADER_HALF_FLOAT_SPEC_VERSION = @as(c_int, 2);
pub const VK_AMD_GPU_SHADER_HALF_FLOAT_EXTENSION_NAME = "VK_AMD_gpu_shader_half_float";
pub const VK_AMD_shader_ballot = @as(c_int, 1);
pub const VK_AMD_SHADER_BALLOT_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_SHADER_BALLOT_EXTENSION_NAME = "VK_AMD_shader_ballot";
pub const VK_AMD_texture_gather_bias_lod = @as(c_int, 1);
pub const VK_AMD_TEXTURE_GATHER_BIAS_LOD_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_TEXTURE_GATHER_BIAS_LOD_EXTENSION_NAME = "VK_AMD_texture_gather_bias_lod";
pub const VK_AMD_shader_info = @as(c_int, 1);
pub const VK_AMD_SHADER_INFO_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_SHADER_INFO_EXTENSION_NAME = "VK_AMD_shader_info";
pub const VK_AMD_shader_image_load_store_lod = @as(c_int, 1);
pub const VK_AMD_SHADER_IMAGE_LOAD_STORE_LOD_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_SHADER_IMAGE_LOAD_STORE_LOD_EXTENSION_NAME = "VK_AMD_shader_image_load_store_lod";
pub const VK_NV_corner_sampled_image = @as(c_int, 1);
pub const VK_NV_CORNER_SAMPLED_IMAGE_SPEC_VERSION = @as(c_int, 2);
pub const VK_NV_CORNER_SAMPLED_IMAGE_EXTENSION_NAME = "VK_NV_corner_sampled_image";
pub const VK_IMG_format_pvrtc = @as(c_int, 1);
pub const VK_IMG_FORMAT_PVRTC_SPEC_VERSION = @as(c_int, 1);
pub const VK_IMG_FORMAT_PVRTC_EXTENSION_NAME = "VK_IMG_format_pvrtc";
pub const VK_NV_external_memory_capabilities = @as(c_int, 1);
pub const VK_NV_EXTERNAL_MEMORY_CAPABILITIES_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_EXTERNAL_MEMORY_CAPABILITIES_EXTENSION_NAME = "VK_NV_external_memory_capabilities";
pub const VK_NV_external_memory = @as(c_int, 1);
pub const VK_NV_EXTERNAL_MEMORY_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_EXTERNAL_MEMORY_EXTENSION_NAME = "VK_NV_external_memory";
pub const VK_EXT_validation_flags = @as(c_int, 1);
pub const VK_EXT_VALIDATION_FLAGS_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_VALIDATION_FLAGS_EXTENSION_NAME = "VK_EXT_validation_flags";
pub const VK_EXT_shader_subgroup_ballot = @as(c_int, 1);
pub const VK_EXT_SHADER_SUBGROUP_BALLOT_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SHADER_SUBGROUP_BALLOT_EXTENSION_NAME = "VK_EXT_shader_subgroup_ballot";
pub const VK_EXT_shader_subgroup_vote = @as(c_int, 1);
pub const VK_EXT_SHADER_SUBGROUP_VOTE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SHADER_SUBGROUP_VOTE_EXTENSION_NAME = "VK_EXT_shader_subgroup_vote";
pub const VK_EXT_texture_compression_astc_hdr = @as(c_int, 1);
pub const VK_EXT_TEXTURE_COMPRESSION_ASTC_HDR_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_TEXTURE_COMPRESSION_ASTC_HDR_EXTENSION_NAME = "VK_EXT_texture_compression_astc_hdr";
pub const VK_EXT_astc_decode_mode = @as(c_int, 1);
pub const VK_EXT_ASTC_DECODE_MODE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_ASTC_DECODE_MODE_EXTENSION_NAME = "VK_EXT_astc_decode_mode";
pub const VK_EXT_conditional_rendering = @as(c_int, 1);
pub const VK_EXT_CONDITIONAL_RENDERING_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_CONDITIONAL_RENDERING_EXTENSION_NAME = "VK_EXT_conditional_rendering";
pub const VK_NV_clip_space_w_scaling = @as(c_int, 1);
pub const VK_NV_CLIP_SPACE_W_SCALING_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_CLIP_SPACE_W_SCALING_EXTENSION_NAME = "VK_NV_clip_space_w_scaling";
pub const VK_EXT_direct_mode_display = @as(c_int, 1);
pub const VK_EXT_DIRECT_MODE_DISPLAY_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_DIRECT_MODE_DISPLAY_EXTENSION_NAME = "VK_EXT_direct_mode_display";
pub const VK_EXT_display_surface_counter = @as(c_int, 1);
pub const VK_EXT_DISPLAY_SURFACE_COUNTER_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_DISPLAY_SURFACE_COUNTER_EXTENSION_NAME = "VK_EXT_display_surface_counter";
pub const VK_EXT_display_control = @as(c_int, 1);
pub const VK_EXT_DISPLAY_CONTROL_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_DISPLAY_CONTROL_EXTENSION_NAME = "VK_EXT_display_control";
pub const VK_GOOGLE_display_timing = @as(c_int, 1);
pub const VK_GOOGLE_DISPLAY_TIMING_SPEC_VERSION = @as(c_int, 1);
pub const VK_GOOGLE_DISPLAY_TIMING_EXTENSION_NAME = "VK_GOOGLE_display_timing";
pub const VK_NV_sample_mask_override_coverage = @as(c_int, 1);
pub const VK_NV_SAMPLE_MASK_OVERRIDE_COVERAGE_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_SAMPLE_MASK_OVERRIDE_COVERAGE_EXTENSION_NAME = "VK_NV_sample_mask_override_coverage";
pub const VK_NV_geometry_shader_passthrough = @as(c_int, 1);
pub const VK_NV_GEOMETRY_SHADER_PASSTHROUGH_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_GEOMETRY_SHADER_PASSTHROUGH_EXTENSION_NAME = "VK_NV_geometry_shader_passthrough";
pub const VK_NV_viewport_array2 = @as(c_int, 1);
pub const VK_NV_VIEWPORT_ARRAY_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_VIEWPORT_ARRAY_2_EXTENSION_NAME = "VK_NV_viewport_array2";
pub const VK_NV_VIEWPORT_ARRAY2_SPEC_VERSION = VK_NV_VIEWPORT_ARRAY_2_SPEC_VERSION;
pub const VK_NV_VIEWPORT_ARRAY2_EXTENSION_NAME = VK_NV_VIEWPORT_ARRAY_2_EXTENSION_NAME;
pub const VK_NVX_multiview_per_view_attributes = @as(c_int, 1);
pub const VK_NVX_MULTIVIEW_PER_VIEW_ATTRIBUTES_SPEC_VERSION = @as(c_int, 1);
pub const VK_NVX_MULTIVIEW_PER_VIEW_ATTRIBUTES_EXTENSION_NAME = "VK_NVX_multiview_per_view_attributes";
pub const VK_NV_viewport_swizzle = @as(c_int, 1);
pub const VK_NV_VIEWPORT_SWIZZLE_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_VIEWPORT_SWIZZLE_EXTENSION_NAME = "VK_NV_viewport_swizzle";
pub const VK_EXT_discard_rectangles = @as(c_int, 1);
pub const VK_EXT_DISCARD_RECTANGLES_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_DISCARD_RECTANGLES_EXTENSION_NAME = "VK_EXT_discard_rectangles";
pub const VK_EXT_conservative_rasterization = @as(c_int, 1);
pub const VK_EXT_CONSERVATIVE_RASTERIZATION_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_CONSERVATIVE_RASTERIZATION_EXTENSION_NAME = "VK_EXT_conservative_rasterization";
pub const VK_EXT_depth_clip_enable = @as(c_int, 1);
pub const VK_EXT_DEPTH_CLIP_ENABLE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_DEPTH_CLIP_ENABLE_EXTENSION_NAME = "VK_EXT_depth_clip_enable";
pub const VK_EXT_swapchain_colorspace = @as(c_int, 1);
pub const VK_EXT_SWAPCHAIN_COLOR_SPACE_SPEC_VERSION = @as(c_int, 4);
pub const VK_EXT_SWAPCHAIN_COLOR_SPACE_EXTENSION_NAME = "VK_EXT_swapchain_colorspace";
pub const VK_EXT_hdr_metadata = @as(c_int, 1);
pub const VK_EXT_HDR_METADATA_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_HDR_METADATA_EXTENSION_NAME = "VK_EXT_hdr_metadata";
pub const VK_EXT_external_memory_dma_buf = @as(c_int, 1);
pub const VK_EXT_EXTERNAL_MEMORY_DMA_BUF_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_EXTERNAL_MEMORY_DMA_BUF_EXTENSION_NAME = "VK_EXT_external_memory_dma_buf";
pub const VK_EXT_queue_family_foreign = @as(c_int, 1);
pub const VK_EXT_QUEUE_FAMILY_FOREIGN_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_QUEUE_FAMILY_FOREIGN_EXTENSION_NAME = "VK_EXT_queue_family_foreign";
pub const VK_QUEUE_FAMILY_FOREIGN_EXT = ~@as(c_uint, 2);
pub const VK_EXT_debug_utils = @as(c_int, 1);
pub const VK_EXT_DEBUG_UTILS_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_DEBUG_UTILS_EXTENSION_NAME = "VK_EXT_debug_utils";
pub const VK_EXT_sampler_filter_minmax = @as(c_int, 1);
pub const VK_EXT_SAMPLER_FILTER_MINMAX_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_SAMPLER_FILTER_MINMAX_EXTENSION_NAME = "VK_EXT_sampler_filter_minmax";
pub const VK_AMD_gpu_shader_int16 = @as(c_int, 1);
pub const VK_AMD_GPU_SHADER_INT16_SPEC_VERSION = @as(c_int, 2);
pub const VK_AMD_GPU_SHADER_INT16_EXTENSION_NAME = "VK_AMD_gpu_shader_int16";
pub const VK_AMD_mixed_attachment_samples = @as(c_int, 1);
pub const VK_AMD_MIXED_ATTACHMENT_SAMPLES_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_MIXED_ATTACHMENT_SAMPLES_EXTENSION_NAME = "VK_AMD_mixed_attachment_samples";
pub const VK_AMD_shader_fragment_mask = @as(c_int, 1);
pub const VK_AMD_SHADER_FRAGMENT_MASK_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_SHADER_FRAGMENT_MASK_EXTENSION_NAME = "VK_AMD_shader_fragment_mask";
pub const VK_EXT_inline_uniform_block = @as(c_int, 1);
pub const VK_EXT_INLINE_UNIFORM_BLOCK_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_INLINE_UNIFORM_BLOCK_EXTENSION_NAME = "VK_EXT_inline_uniform_block";
pub const VK_EXT_shader_stencil_export = @as(c_int, 1);
pub const VK_EXT_SHADER_STENCIL_EXPORT_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SHADER_STENCIL_EXPORT_EXTENSION_NAME = "VK_EXT_shader_stencil_export";
pub const VK_EXT_sample_locations = @as(c_int, 1);
pub const VK_EXT_SAMPLE_LOCATIONS_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SAMPLE_LOCATIONS_EXTENSION_NAME = "VK_EXT_sample_locations";
pub const VK_EXT_blend_operation_advanced = @as(c_int, 1);
pub const VK_EXT_BLEND_OPERATION_ADVANCED_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_BLEND_OPERATION_ADVANCED_EXTENSION_NAME = "VK_EXT_blend_operation_advanced";
pub const VK_NV_fragment_coverage_to_color = @as(c_int, 1);
pub const VK_NV_FRAGMENT_COVERAGE_TO_COLOR_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_FRAGMENT_COVERAGE_TO_COLOR_EXTENSION_NAME = "VK_NV_fragment_coverage_to_color";
pub const VK_NV_framebuffer_mixed_samples = @as(c_int, 1);
pub const VK_NV_FRAMEBUFFER_MIXED_SAMPLES_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_FRAMEBUFFER_MIXED_SAMPLES_EXTENSION_NAME = "VK_NV_framebuffer_mixed_samples";
pub const VK_NV_fill_rectangle = @as(c_int, 1);
pub const VK_NV_FILL_RECTANGLE_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_FILL_RECTANGLE_EXTENSION_NAME = "VK_NV_fill_rectangle";
pub const VK_NV_shader_sm_builtins = @as(c_int, 1);
pub const VK_NV_SHADER_SM_BUILTINS_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_SHADER_SM_BUILTINS_EXTENSION_NAME = "VK_NV_shader_sm_builtins";
pub const VK_EXT_post_depth_coverage = @as(c_int, 1);
pub const VK_EXT_POST_DEPTH_COVERAGE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_POST_DEPTH_COVERAGE_EXTENSION_NAME = "VK_EXT_post_depth_coverage";
pub const VK_EXT_image_drm_format_modifier = @as(c_int, 1);
pub const VK_EXT_IMAGE_DRM_FORMAT_MODIFIER_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_IMAGE_DRM_FORMAT_MODIFIER_EXTENSION_NAME = "VK_EXT_image_drm_format_modifier";
pub const VK_EXT_validation_cache = @as(c_int, 1);
pub const VK_EXT_VALIDATION_CACHE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_VALIDATION_CACHE_EXTENSION_NAME = "VK_EXT_validation_cache";
pub const VK_EXT_descriptor_indexing = @as(c_int, 1);
pub const VK_EXT_DESCRIPTOR_INDEXING_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_DESCRIPTOR_INDEXING_EXTENSION_NAME = "VK_EXT_descriptor_indexing";
pub const VK_EXT_shader_viewport_index_layer = @as(c_int, 1);
pub const VK_EXT_SHADER_VIEWPORT_INDEX_LAYER_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SHADER_VIEWPORT_INDEX_LAYER_EXTENSION_NAME = "VK_EXT_shader_viewport_index_layer";
pub const VK_NV_shading_rate_image = @as(c_int, 1);
pub const VK_NV_SHADING_RATE_IMAGE_SPEC_VERSION = @as(c_int, 3);
pub const VK_NV_SHADING_RATE_IMAGE_EXTENSION_NAME = "VK_NV_shading_rate_image";
pub const VK_NV_ray_tracing = @as(c_int, 1);
pub const VK_NV_RAY_TRACING_SPEC_VERSION = @as(c_int, 3);
pub const VK_NV_RAY_TRACING_EXTENSION_NAME = "VK_NV_ray_tracing";
pub const VK_SHADER_UNUSED_KHR = ~@as(c_uint, 0);
pub const VK_SHADER_UNUSED_NV = VK_SHADER_UNUSED_KHR;
pub const VK_NV_representative_fragment_test = @as(c_int, 1);
pub const VK_NV_REPRESENTATIVE_FRAGMENT_TEST_SPEC_VERSION = @as(c_int, 2);
pub const VK_NV_REPRESENTATIVE_FRAGMENT_TEST_EXTENSION_NAME = "VK_NV_representative_fragment_test";
pub const VK_EXT_filter_cubic = @as(c_int, 1);
pub const VK_EXT_FILTER_CUBIC_SPEC_VERSION = @as(c_int, 3);
pub const VK_EXT_FILTER_CUBIC_EXTENSION_NAME = "VK_EXT_filter_cubic";
pub const VK_QCOM_render_pass_shader_resolve = @as(c_int, 1);
pub const VK_QCOM_RENDER_PASS_SHADER_RESOLVE_SPEC_VERSION = @as(c_int, 4);
pub const VK_QCOM_RENDER_PASS_SHADER_RESOLVE_EXTENSION_NAME = "VK_QCOM_render_pass_shader_resolve";
pub const VK_EXT_global_priority = @as(c_int, 1);
pub const VK_EXT_GLOBAL_PRIORITY_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_GLOBAL_PRIORITY_EXTENSION_NAME = "VK_EXT_global_priority";
pub const VK_EXT_external_memory_host = @as(c_int, 1);
pub const VK_EXT_EXTERNAL_MEMORY_HOST_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_EXTERNAL_MEMORY_HOST_EXTENSION_NAME = "VK_EXT_external_memory_host";
pub const VK_AMD_buffer_marker = @as(c_int, 1);
pub const VK_AMD_BUFFER_MARKER_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_BUFFER_MARKER_EXTENSION_NAME = "VK_AMD_buffer_marker";
pub const VK_AMD_pipeline_compiler_control = @as(c_int, 1);
pub const VK_AMD_PIPELINE_COMPILER_CONTROL_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_PIPELINE_COMPILER_CONTROL_EXTENSION_NAME = "VK_AMD_pipeline_compiler_control";
pub const VK_EXT_calibrated_timestamps = @as(c_int, 1);
pub const VK_EXT_CALIBRATED_TIMESTAMPS_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_CALIBRATED_TIMESTAMPS_EXTENSION_NAME = "VK_EXT_calibrated_timestamps";
pub const VK_AMD_shader_core_properties = @as(c_int, 1);
pub const VK_AMD_SHADER_CORE_PROPERTIES_SPEC_VERSION = @as(c_int, 2);
pub const VK_AMD_SHADER_CORE_PROPERTIES_EXTENSION_NAME = "VK_AMD_shader_core_properties";
pub const VK_AMD_memory_overallocation_behavior = @as(c_int, 1);
pub const VK_AMD_MEMORY_OVERALLOCATION_BEHAVIOR_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_MEMORY_OVERALLOCATION_BEHAVIOR_EXTENSION_NAME = "VK_AMD_memory_overallocation_behavior";
pub const VK_EXT_vertex_attribute_divisor = @as(c_int, 1);
pub const VK_EXT_VERTEX_ATTRIBUTE_DIVISOR_SPEC_VERSION = @as(c_int, 3);
pub const VK_EXT_VERTEX_ATTRIBUTE_DIVISOR_EXTENSION_NAME = "VK_EXT_vertex_attribute_divisor";
pub const VK_EXT_pipeline_creation_feedback = @as(c_int, 1);
pub const VK_EXT_PIPELINE_CREATION_FEEDBACK_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_PIPELINE_CREATION_FEEDBACK_EXTENSION_NAME = "VK_EXT_pipeline_creation_feedback";
pub const VK_NV_shader_subgroup_partitioned = @as(c_int, 1);
pub const VK_NV_SHADER_SUBGROUP_PARTITIONED_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_SHADER_SUBGROUP_PARTITIONED_EXTENSION_NAME = "VK_NV_shader_subgroup_partitioned";
pub const VK_NV_compute_shader_derivatives = @as(c_int, 1);
pub const VK_NV_COMPUTE_SHADER_DERIVATIVES_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_COMPUTE_SHADER_DERIVATIVES_EXTENSION_NAME = "VK_NV_compute_shader_derivatives";
pub const VK_NV_mesh_shader = @as(c_int, 1);
pub const VK_NV_MESH_SHADER_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_MESH_SHADER_EXTENSION_NAME = "VK_NV_mesh_shader";
pub const VK_NV_fragment_shader_barycentric = @as(c_int, 1);
pub const VK_NV_FRAGMENT_SHADER_BARYCENTRIC_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_FRAGMENT_SHADER_BARYCENTRIC_EXTENSION_NAME = "VK_NV_fragment_shader_barycentric";
pub const VK_NV_shader_image_footprint = @as(c_int, 1);
pub const VK_NV_SHADER_IMAGE_FOOTPRINT_SPEC_VERSION = @as(c_int, 2);
pub const VK_NV_SHADER_IMAGE_FOOTPRINT_EXTENSION_NAME = "VK_NV_shader_image_footprint";
pub const VK_NV_scissor_exclusive = @as(c_int, 1);
pub const VK_NV_SCISSOR_EXCLUSIVE_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_SCISSOR_EXCLUSIVE_EXTENSION_NAME = "VK_NV_scissor_exclusive";
pub const VK_NV_device_diagnostic_checkpoints = @as(c_int, 1);
pub const VK_NV_DEVICE_DIAGNOSTIC_CHECKPOINTS_SPEC_VERSION = @as(c_int, 2);
pub const VK_NV_DEVICE_DIAGNOSTIC_CHECKPOINTS_EXTENSION_NAME = "VK_NV_device_diagnostic_checkpoints";
pub const VK_INTEL_shader_integer_functions2 = @as(c_int, 1);
pub const VK_INTEL_SHADER_INTEGER_FUNCTIONS_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_INTEL_SHADER_INTEGER_FUNCTIONS_2_EXTENSION_NAME = "VK_INTEL_shader_integer_functions2";
pub const VK_INTEL_performance_query = @as(c_int, 1);
pub const VK_INTEL_PERFORMANCE_QUERY_SPEC_VERSION = @as(c_int, 2);
pub const VK_INTEL_PERFORMANCE_QUERY_EXTENSION_NAME = "VK_INTEL_performance_query";
pub const VK_EXT_pci_bus_info = @as(c_int, 1);
pub const VK_EXT_PCI_BUS_INFO_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_PCI_BUS_INFO_EXTENSION_NAME = "VK_EXT_pci_bus_info";
pub const VK_AMD_display_native_hdr = @as(c_int, 1);
pub const VK_AMD_DISPLAY_NATIVE_HDR_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_DISPLAY_NATIVE_HDR_EXTENSION_NAME = "VK_AMD_display_native_hdr";
pub const VK_EXT_fragment_density_map = @as(c_int, 1);
pub const VK_EXT_FRAGMENT_DENSITY_MAP_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_FRAGMENT_DENSITY_MAP_EXTENSION_NAME = "VK_EXT_fragment_density_map";
pub const VK_EXT_scalar_block_layout = @as(c_int, 1);
pub const VK_EXT_SCALAR_BLOCK_LAYOUT_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SCALAR_BLOCK_LAYOUT_EXTENSION_NAME = "VK_EXT_scalar_block_layout";
pub const VK_GOOGLE_hlsl_functionality1 = @as(c_int, 1);
pub const VK_GOOGLE_HLSL_FUNCTIONALITY_1_SPEC_VERSION = @as(c_int, 1);
pub const VK_GOOGLE_HLSL_FUNCTIONALITY_1_EXTENSION_NAME = "VK_GOOGLE_hlsl_functionality1";
pub const VK_GOOGLE_HLSL_FUNCTIONALITY1_SPEC_VERSION = VK_GOOGLE_HLSL_FUNCTIONALITY_1_SPEC_VERSION;
pub const VK_GOOGLE_HLSL_FUNCTIONALITY1_EXTENSION_NAME = VK_GOOGLE_HLSL_FUNCTIONALITY_1_EXTENSION_NAME;
pub const VK_GOOGLE_decorate_string = @as(c_int, 1);
pub const VK_GOOGLE_DECORATE_STRING_SPEC_VERSION = @as(c_int, 1);
pub const VK_GOOGLE_DECORATE_STRING_EXTENSION_NAME = "VK_GOOGLE_decorate_string";
pub const VK_EXT_subgroup_size_control = @as(c_int, 1);
pub const VK_EXT_SUBGROUP_SIZE_CONTROL_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_SUBGROUP_SIZE_CONTROL_EXTENSION_NAME = "VK_EXT_subgroup_size_control";
pub const VK_AMD_shader_core_properties2 = @as(c_int, 1);
pub const VK_AMD_SHADER_CORE_PROPERTIES_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_SHADER_CORE_PROPERTIES_2_EXTENSION_NAME = "VK_AMD_shader_core_properties2";
pub const VK_AMD_device_coherent_memory = @as(c_int, 1);
pub const VK_AMD_DEVICE_COHERENT_MEMORY_SPEC_VERSION = @as(c_int, 1);
pub const VK_AMD_DEVICE_COHERENT_MEMORY_EXTENSION_NAME = "VK_AMD_device_coherent_memory";
pub const VK_EXT_shader_image_atomic_int64 = @as(c_int, 1);
pub const VK_EXT_SHADER_IMAGE_ATOMIC_INT64_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SHADER_IMAGE_ATOMIC_INT64_EXTENSION_NAME = "VK_EXT_shader_image_atomic_int64";
pub const VK_EXT_memory_budget = @as(c_int, 1);
pub const VK_EXT_MEMORY_BUDGET_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_MEMORY_BUDGET_EXTENSION_NAME = "VK_EXT_memory_budget";
pub const VK_EXT_memory_priority = @as(c_int, 1);
pub const VK_EXT_MEMORY_PRIORITY_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_MEMORY_PRIORITY_EXTENSION_NAME = "VK_EXT_memory_priority";
pub const VK_NV_dedicated_allocation_image_aliasing = @as(c_int, 1);
pub const VK_NV_DEDICATED_ALLOCATION_IMAGE_ALIASING_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_DEDICATED_ALLOCATION_IMAGE_ALIASING_EXTENSION_NAME = "VK_NV_dedicated_allocation_image_aliasing";
pub const VK_EXT_buffer_device_address = @as(c_int, 1);
pub const VK_EXT_BUFFER_DEVICE_ADDRESS_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME = "VK_EXT_buffer_device_address";
pub const VK_EXT_tooling_info = @as(c_int, 1);
pub const VK_EXT_TOOLING_INFO_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_TOOLING_INFO_EXTENSION_NAME = "VK_EXT_tooling_info";
pub const VK_EXT_separate_stencil_usage = @as(c_int, 1);
pub const VK_EXT_SEPARATE_STENCIL_USAGE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SEPARATE_STENCIL_USAGE_EXTENSION_NAME = "VK_EXT_separate_stencil_usage";
pub const VK_EXT_validation_features = @as(c_int, 1);
pub const VK_EXT_VALIDATION_FEATURES_SPEC_VERSION = @as(c_int, 5);
pub const VK_EXT_VALIDATION_FEATURES_EXTENSION_NAME = "VK_EXT_validation_features";
pub const VK_NV_cooperative_matrix = @as(c_int, 1);
pub const VK_NV_COOPERATIVE_MATRIX_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_COOPERATIVE_MATRIX_EXTENSION_NAME = "VK_NV_cooperative_matrix";
pub const VK_NV_coverage_reduction_mode = @as(c_int, 1);
pub const VK_NV_COVERAGE_REDUCTION_MODE_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_COVERAGE_REDUCTION_MODE_EXTENSION_NAME = "VK_NV_coverage_reduction_mode";
pub const VK_EXT_fragment_shader_interlock = @as(c_int, 1);
pub const VK_EXT_FRAGMENT_SHADER_INTERLOCK_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_FRAGMENT_SHADER_INTERLOCK_EXTENSION_NAME = "VK_EXT_fragment_shader_interlock";
pub const VK_EXT_ycbcr_image_arrays = @as(c_int, 1);
pub const VK_EXT_YCBCR_IMAGE_ARRAYS_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_YCBCR_IMAGE_ARRAYS_EXTENSION_NAME = "VK_EXT_ycbcr_image_arrays";
pub const VK_EXT_provoking_vertex = @as(c_int, 1);
pub const VK_EXT_PROVOKING_VERTEX_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_PROVOKING_VERTEX_EXTENSION_NAME = "VK_EXT_provoking_vertex";
pub const VK_EXT_headless_surface = @as(c_int, 1);
pub const VK_EXT_HEADLESS_SURFACE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_HEADLESS_SURFACE_EXTENSION_NAME = "VK_EXT_headless_surface";
pub const VK_EXT_line_rasterization = @as(c_int, 1);
pub const VK_EXT_LINE_RASTERIZATION_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_LINE_RASTERIZATION_EXTENSION_NAME = "VK_EXT_line_rasterization";
pub const VK_EXT_shader_atomic_float = @as(c_int, 1);
pub const VK_EXT_SHADER_ATOMIC_FLOAT_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SHADER_ATOMIC_FLOAT_EXTENSION_NAME = "VK_EXT_shader_atomic_float";
pub const VK_EXT_host_query_reset = @as(c_int, 1);
pub const VK_EXT_HOST_QUERY_RESET_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_HOST_QUERY_RESET_EXTENSION_NAME = "VK_EXT_host_query_reset";
pub const VK_EXT_index_type_uint8 = @as(c_int, 1);
pub const VK_EXT_INDEX_TYPE_UINT8_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_INDEX_TYPE_UINT8_EXTENSION_NAME = "VK_EXT_index_type_uint8";
pub const VK_EXT_extended_dynamic_state = @as(c_int, 1);
pub const VK_EXT_EXTENDED_DYNAMIC_STATE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_EXTENDED_DYNAMIC_STATE_EXTENSION_NAME = "VK_EXT_extended_dynamic_state";
pub const VK_EXT_shader_atomic_float2 = @as(c_int, 1);
pub const VK_EXT_SHADER_ATOMIC_FLOAT_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SHADER_ATOMIC_FLOAT_2_EXTENSION_NAME = "VK_EXT_shader_atomic_float2";
pub const VK_EXT_shader_demote_to_helper_invocation = @as(c_int, 1);
pub const VK_EXT_SHADER_DEMOTE_TO_HELPER_INVOCATION_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_SHADER_DEMOTE_TO_HELPER_INVOCATION_EXTENSION_NAME = "VK_EXT_shader_demote_to_helper_invocation";
pub const VK_NV_device_generated_commands = @as(c_int, 1);
pub const VK_NV_DEVICE_GENERATED_COMMANDS_SPEC_VERSION = @as(c_int, 3);
pub const VK_NV_DEVICE_GENERATED_COMMANDS_EXTENSION_NAME = "VK_NV_device_generated_commands";
pub const VK_NV_inherited_viewport_scissor = @as(c_int, 1);
pub const VK_NV_INHERITED_VIEWPORT_SCISSOR_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_INHERITED_VIEWPORT_SCISSOR_EXTENSION_NAME = "VK_NV_inherited_viewport_scissor";
pub const VK_EXT_texel_buffer_alignment = @as(c_int, 1);
pub const VK_EXT_TEXEL_BUFFER_ALIGNMENT_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_TEXEL_BUFFER_ALIGNMENT_EXTENSION_NAME = "VK_EXT_texel_buffer_alignment";
pub const VK_QCOM_render_pass_transform = @as(c_int, 1);
pub const VK_QCOM_RENDER_PASS_TRANSFORM_SPEC_VERSION = @as(c_int, 2);
pub const VK_QCOM_RENDER_PASS_TRANSFORM_EXTENSION_NAME = "VK_QCOM_render_pass_transform";
pub const VK_EXT_device_memory_report = @as(c_int, 1);
pub const VK_EXT_DEVICE_MEMORY_REPORT_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_DEVICE_MEMORY_REPORT_EXTENSION_NAME = "VK_EXT_device_memory_report";
pub const VK_EXT_acquire_drm_display = @as(c_int, 1);
pub const VK_EXT_ACQUIRE_DRM_DISPLAY_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_ACQUIRE_DRM_DISPLAY_EXTENSION_NAME = "VK_EXT_acquire_drm_display";
pub const VK_EXT_robustness2 = @as(c_int, 1);
pub const VK_EXT_ROBUSTNESS_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_ROBUSTNESS_2_EXTENSION_NAME = "VK_EXT_robustness2";
pub const VK_EXT_custom_border_color = @as(c_int, 1);
pub const VK_EXT_CUSTOM_BORDER_COLOR_SPEC_VERSION = @as(c_int, 12);
pub const VK_EXT_CUSTOM_BORDER_COLOR_EXTENSION_NAME = "VK_EXT_custom_border_color";
pub const VK_GOOGLE_user_type = @as(c_int, 1);
pub const VK_GOOGLE_USER_TYPE_SPEC_VERSION = @as(c_int, 1);
pub const VK_GOOGLE_USER_TYPE_EXTENSION_NAME = "VK_GOOGLE_user_type";
pub const VK_EXT_private_data = @as(c_int, 1);
pub const VK_EXT_PRIVATE_DATA_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_PRIVATE_DATA_EXTENSION_NAME = "VK_EXT_private_data";
pub const VK_EXT_pipeline_creation_cache_control = @as(c_int, 1);
pub const VK_EXT_PIPELINE_CREATION_CACHE_CONTROL_SPEC_VERSION = @as(c_int, 3);
pub const VK_EXT_PIPELINE_CREATION_CACHE_CONTROL_EXTENSION_NAME = "VK_EXT_pipeline_creation_cache_control";
pub const VK_NV_device_diagnostics_config = @as(c_int, 1);
pub const VK_NV_DEVICE_DIAGNOSTICS_CONFIG_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_DEVICE_DIAGNOSTICS_CONFIG_EXTENSION_NAME = "VK_NV_device_diagnostics_config";
pub const VK_QCOM_render_pass_store_ops = @as(c_int, 1);
pub const VK_QCOM_RENDER_PASS_STORE_OPS_SPEC_VERSION = @as(c_int, 2);
pub const VK_QCOM_RENDER_PASS_STORE_OPS_EXTENSION_NAME = "VK_QCOM_render_pass_store_ops";
pub const VK_NV_fragment_shading_rate_enums = @as(c_int, 1);
pub const VK_NV_FRAGMENT_SHADING_RATE_ENUMS_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_FRAGMENT_SHADING_RATE_ENUMS_EXTENSION_NAME = "VK_NV_fragment_shading_rate_enums";
pub const VK_NV_ray_tracing_motion_blur = @as(c_int, 1);
pub const VK_NV_RAY_TRACING_MOTION_BLUR_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_RAY_TRACING_MOTION_BLUR_EXTENSION_NAME = "VK_NV_ray_tracing_motion_blur";
pub const VK_EXT_ycbcr_2plane_444_formats = @as(c_int, 1);
pub const VK_EXT_YCBCR_2PLANE_444_FORMATS_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_YCBCR_2PLANE_444_FORMATS_EXTENSION_NAME = "VK_EXT_ycbcr_2plane_444_formats";
pub const VK_EXT_fragment_density_map2 = @as(c_int, 1);
pub const VK_EXT_FRAGMENT_DENSITY_MAP_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_FRAGMENT_DENSITY_MAP_2_EXTENSION_NAME = "VK_EXT_fragment_density_map2";
pub const VK_QCOM_rotated_copy_commands = @as(c_int, 1);
pub const VK_QCOM_ROTATED_COPY_COMMANDS_SPEC_VERSION = @as(c_int, 1);
pub const VK_QCOM_ROTATED_COPY_COMMANDS_EXTENSION_NAME = "VK_QCOM_rotated_copy_commands";
pub const VK_EXT_image_robustness = @as(c_int, 1);
pub const VK_EXT_IMAGE_ROBUSTNESS_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_IMAGE_ROBUSTNESS_EXTENSION_NAME = "VK_EXT_image_robustness";
pub const VK_EXT_4444_formats = @as(c_int, 1);
pub const VK_EXT_4444_FORMATS_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_4444_FORMATS_EXTENSION_NAME = "VK_EXT_4444_formats";
pub const VK_ARM_rasterization_order_attachment_access = @as(c_int, 1);
pub const VK_ARM_RASTERIZATION_ORDER_ATTACHMENT_ACCESS_SPEC_VERSION = @as(c_int, 1);
pub const VK_ARM_RASTERIZATION_ORDER_ATTACHMENT_ACCESS_EXTENSION_NAME = "VK_ARM_rasterization_order_attachment_access";
pub const VK_EXT_rgba10x6_formats = @as(c_int, 1);
pub const VK_EXT_RGBA10X6_FORMATS_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_RGBA10X6_FORMATS_EXTENSION_NAME = "VK_EXT_rgba10x6_formats";
pub const VK_NV_acquire_winrt_display = @as(c_int, 1);
pub const VK_NV_ACQUIRE_WINRT_DISPLAY_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_ACQUIRE_WINRT_DISPLAY_EXTENSION_NAME = "VK_NV_acquire_winrt_display";
pub const VK_VALVE_mutable_descriptor_type = @as(c_int, 1);
pub const VK_VALVE_MUTABLE_DESCRIPTOR_TYPE_SPEC_VERSION = @as(c_int, 1);
pub const VK_VALVE_MUTABLE_DESCRIPTOR_TYPE_EXTENSION_NAME = "VK_VALVE_mutable_descriptor_type";
pub const VK_EXT_vertex_input_dynamic_state = @as(c_int, 1);
pub const VK_EXT_VERTEX_INPUT_DYNAMIC_STATE_SPEC_VERSION = @as(c_int, 2);
pub const VK_EXT_VERTEX_INPUT_DYNAMIC_STATE_EXTENSION_NAME = "VK_EXT_vertex_input_dynamic_state";
pub const VK_EXT_physical_device_drm = @as(c_int, 1);
pub const VK_EXT_PHYSICAL_DEVICE_DRM_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_PHYSICAL_DEVICE_DRM_EXTENSION_NAME = "VK_EXT_physical_device_drm";
pub const VK_EXT_depth_clip_control = @as(c_int, 1);
pub const VK_EXT_DEPTH_CLIP_CONTROL_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_DEPTH_CLIP_CONTROL_EXTENSION_NAME = "VK_EXT_depth_clip_control";
pub const VK_EXT_primitive_topology_list_restart = @as(c_int, 1);
pub const VK_EXT_PRIMITIVE_TOPOLOGY_LIST_RESTART_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_PRIMITIVE_TOPOLOGY_LIST_RESTART_EXTENSION_NAME = "VK_EXT_primitive_topology_list_restart";
pub const VK_HUAWEI_subpass_shading = @as(c_int, 1);
pub const VK_HUAWEI_SUBPASS_SHADING_SPEC_VERSION = @as(c_int, 2);
pub const VK_HUAWEI_SUBPASS_SHADING_EXTENSION_NAME = "VK_HUAWEI_subpass_shading";
pub const VK_HUAWEI_invocation_mask = @as(c_int, 1);
pub const VK_HUAWEI_INVOCATION_MASK_SPEC_VERSION = @as(c_int, 1);
pub const VK_HUAWEI_INVOCATION_MASK_EXTENSION_NAME = "VK_HUAWEI_invocation_mask";
pub const VK_NV_external_memory_rdma = @as(c_int, 1);
pub const VK_NV_EXTERNAL_MEMORY_RDMA_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_EXTERNAL_MEMORY_RDMA_EXTENSION_NAME = "VK_NV_external_memory_rdma";
pub const VK_EXT_extended_dynamic_state2 = @as(c_int, 1);
pub const VK_EXT_EXTENDED_DYNAMIC_STATE_2_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_EXTENDED_DYNAMIC_STATE_2_EXTENSION_NAME = "VK_EXT_extended_dynamic_state2";
pub const VK_EXT_color_write_enable = @as(c_int, 1);
pub const VK_EXT_COLOR_WRITE_ENABLE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_COLOR_WRITE_ENABLE_EXTENSION_NAME = "VK_EXT_color_write_enable";
pub const VK_EXT_global_priority_query = @as(c_int, 1);
pub const VK_MAX_GLOBAL_PRIORITY_SIZE_EXT = @as(c_uint, 16);
pub const VK_EXT_GLOBAL_PRIORITY_QUERY_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_GLOBAL_PRIORITY_QUERY_EXTENSION_NAME = "VK_EXT_global_priority_query";
pub const VK_EXT_image_view_min_lod = @as(c_int, 1);
pub const VK_EXT_IMAGE_VIEW_MIN_LOD_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_IMAGE_VIEW_MIN_LOD_EXTENSION_NAME = "VK_EXT_image_view_min_lod";
pub const VK_EXT_multi_draw = @as(c_int, 1);
pub const VK_EXT_MULTI_DRAW_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_MULTI_DRAW_EXTENSION_NAME = "VK_EXT_multi_draw";
pub const VK_EXT_load_store_op_none = @as(c_int, 1);
pub const VK_EXT_LOAD_STORE_OP_NONE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_LOAD_STORE_OP_NONE_EXTENSION_NAME = "VK_EXT_load_store_op_none";
pub const VK_EXT_border_color_swizzle = @as(c_int, 1);
pub const VK_EXT_BORDER_COLOR_SWIZZLE_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_BORDER_COLOR_SWIZZLE_EXTENSION_NAME = "VK_EXT_border_color_swizzle";
pub const VK_EXT_pageable_device_local_memory = @as(c_int, 1);
pub const VK_EXT_PAGEABLE_DEVICE_LOCAL_MEMORY_SPEC_VERSION = @as(c_int, 1);
pub const VK_EXT_PAGEABLE_DEVICE_LOCAL_MEMORY_EXTENSION_NAME = "VK_EXT_pageable_device_local_memory";
pub const VK_QCOM_fragment_density_map_offset = @as(c_int, 1);
pub const VK_QCOM_FRAGMENT_DENSITY_MAP_OFFSET_SPEC_VERSION = @as(c_int, 1);
pub const VK_QCOM_FRAGMENT_DENSITY_MAP_OFFSET_EXTENSION_NAME = "VK_QCOM_fragment_density_map_offset";
pub const VK_NV_linear_color_attachment = @as(c_int, 1);
pub const VK_NV_LINEAR_COLOR_ATTACHMENT_SPEC_VERSION = @as(c_int, 1);
pub const VK_NV_LINEAR_COLOR_ATTACHMENT_EXTENSION_NAME = "VK_NV_linear_color_attachment";
pub const VK_GOOGLE_surfaceless_query = @as(c_int, 1);
pub const VK_GOOGLE_SURFACELESS_QUERY_SPEC_VERSION = @as(c_int, 1);
pub const VK_GOOGLE_SURFACELESS_QUERY_EXTENSION_NAME = "VK_GOOGLE_surfaceless_query";
pub const VK_KHR_acceleration_structure = @as(c_int, 1);
pub const VK_KHR_ACCELERATION_STRUCTURE_SPEC_VERSION = @as(c_int, 13);
pub const VK_KHR_ACCELERATION_STRUCTURE_EXTENSION_NAME = "VK_KHR_acceleration_structure";
pub const VK_KHR_ray_tracing_pipeline = @as(c_int, 1);
pub const VK_KHR_RAY_TRACING_PIPELINE_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_RAY_TRACING_PIPELINE_EXTENSION_NAME = "VK_KHR_ray_tracing_pipeline";
pub const VK_KHR_ray_query = @as(c_int, 1);
pub const VK_KHR_RAY_QUERY_SPEC_VERSION = @as(c_int, 1);
pub const VK_KHR_RAY_QUERY_EXTENSION_NAME = "VK_KHR_ray_query";

pub const __darwin_pthread_handler_rec = struct___darwin_pthread_handler_rec;
pub const _opaque_pthread_attr_t = struct__opaque_pthread_attr_t;
pub const _opaque_pthread_cond_t = struct__opaque_pthread_cond_t;
pub const _opaque_pthread_condattr_t = struct__opaque_pthread_condattr_t;
pub const _opaque_pthread_mutex_t = struct__opaque_pthread_mutex_t;
pub const _opaque_pthread_mutexattr_t = struct__opaque_pthread_mutexattr_t;
pub const _opaque_pthread_once_t = struct__opaque_pthread_once_t;
pub const _opaque_pthread_rwlock_t = struct__opaque_pthread_rwlock_t;
pub const _opaque_pthread_rwlockattr_t = struct__opaque_pthread_rwlockattr_t;
pub const _opaque_pthread_t = struct__opaque_pthread_t;
pub const VkBuffer_T = struct_VkBuffer_T;
pub const VkImage_T = struct_VkImage_T;
pub const VkQueue_T = struct_VkQueue_T;
pub const VkSemaphore_T = struct_VkSemaphore_T;
pub const VkCommandBuffer_T = struct_VkCommandBuffer_T;
pub const VkFence_T = struct_VkFence_T;
pub const VkEvent_T = struct_VkEvent_T;
pub const VkQueryPool_T = struct_VkQueryPool_T;
pub const VkBufferView_T = struct_VkBufferView_T;
pub const VkImageView_T = struct_VkImageView_T;
pub const VkShaderModule_T = struct_VkShaderModule_T;
pub const VkPipelineCache_T = struct_VkPipelineCache_T;
pub const VkPipelineLayout_T = struct_VkPipelineLayout_T;
pub const VkPipeline_T = struct_VkPipeline_T;
pub const VkRenderPass_T = struct_VkRenderPass_T;
pub const VkDescriptorSetLayout_T = struct_VkDescriptorSetLayout_T;
pub const VkSampler_T = struct_VkSampler_T;
pub const VkDescriptorSet_T = struct_VkDescriptorSet_T;
pub const VkDescriptorPool_T = struct_VkDescriptorPool_T;
pub const VkFramebuffer_T = struct_VkFramebuffer_T;
pub const VkCommandPool_T = struct_VkCommandPool_T;
pub const VkSamplerYcbcrConversion_T = struct_VkSamplerYcbcrConversion_T;
pub const VkDescriptorUpdateTemplate_T = struct_VkDescriptorUpdateTemplate_T;
pub const VkSurfaceKHR_T = struct_VkSurfaceKHR_T;
pub const VkSwapchainKHR_T = struct_VkSwapchainKHR_T;
pub const VkDisplayKHR_T = struct_VkDisplayKHR_T;
pub const VkDisplayModeKHR_T = struct_VkDisplayModeKHR_T;
pub const VkDeferredOperationKHR_T = struct_VkDeferredOperationKHR_T;
pub const VkDebugReportCallbackEXT_T = struct_VkDebugReportCallbackEXT_T;
pub const VkCuModuleNVX_T = struct_VkCuModuleNVX_T;
pub const VkCuFunctionNVX_T = struct_VkCuFunctionNVX_T;
pub const VkDebugUtilsMessengerEXT_T = struct_VkDebugUtilsMessengerEXT_T;
pub const VkValidationCacheEXT_T = struct_VkValidationCacheEXT_T;
pub const VkAccelerationStructureNV_T = struct_VkAccelerationStructureNV_T;
pub const VkPerformanceConfigurationINTEL_T = struct_VkPerformanceConfigurationINTEL_T;
pub const VkIndirectCommandsLayoutNV_T = struct_VkIndirectCommandsLayoutNV_T;
pub const VkPrivateDataSlotEXT_T = struct_VkPrivateDataSlotEXT_T;
pub const VkAccelerationStructureKHR_T = struct_VkAccelerationStructureKHR_T;





























pub const __builtin_bswap16 = @import("std").zig.c_builtins.__builtin_bswap16;
pub const __builtin_bswap32 = @import("std").zig.c_builtins.__builtin_bswap32;
pub const __builtin_bswap64 = @import("std").zig.c_builtins.__builtin_bswap64;
pub const __builtin_signbit = @import("std").zig.c_builtins.__builtin_signbit;
pub const __builtin_signbitf = @import("std").zig.c_builtins.__builtin_signbitf;
pub const __builtin_popcount = @import("std").zig.c_builtins.__builtin_popcount;
pub const __builtin_ctz = @import("std").zig.c_builtins.__builtin_ctz;
pub const __builtin_clz = @import("std").zig.c_builtins.__builtin_clz;
pub const __builtin_sqrt = @import("std").zig.c_builtins.__builtin_sqrt;
pub const __builtin_sqrtf = @import("std").zig.c_builtins.__builtin_sqrtf;
pub const __builtin_sin = @import("std").zig.c_builtins.__builtin_sin;
pub const __builtin_sinf = @import("std").zig.c_builtins.__builtin_sinf;
pub const __builtin_cos = @import("std").zig.c_builtins.__builtin_cos;
pub const __builtin_cosf = @import("std").zig.c_builtins.__builtin_cosf;
pub const __builtin_exp = @import("std").zig.c_builtins.__builtin_exp;
pub const __builtin_expf = @import("std").zig.c_builtins.__builtin_expf;
pub const __builtin_exp2 = @import("std").zig.c_builtins.__builtin_exp2;
pub const __builtin_exp2f = @import("std").zig.c_builtins.__builtin_exp2f;
pub const __builtin_log = @import("std").zig.c_builtins.__builtin_log;
pub const __builtin_logf = @import("std").zig.c_builtins.__builtin_logf;
pub const __builtin_log2 = @import("std").zig.c_builtins.__builtin_log2;
pub const __builtin_log2f = @import("std").zig.c_builtins.__builtin_log2f;
pub const __builtin_log10 = @import("std").zig.c_builtins.__builtin_log10;
pub const __builtin_log10f = @import("std").zig.c_builtins.__builtin_log10f;
pub const __builtin_abs = @import("std").zig.c_builtins.__builtin_abs;
pub const __builtin_fabs = @import("std").zig.c_builtins.__builtin_fabs;
pub const __builtin_fabsf = @import("std").zig.c_builtins.__builtin_fabsf;
pub const __builtin_floor = @import("std").zig.c_builtins.__builtin_floor;
pub const __builtin_floorf = @import("std").zig.c_builtins.__builtin_floorf;
pub const __builtin_ceil = @import("std").zig.c_builtins.__builtin_ceil;
pub const __builtin_ceilf = @import("std").zig.c_builtins.__builtin_ceilf;
pub const __builtin_trunc = @import("std").zig.c_builtins.__builtin_trunc;
pub const __builtin_truncf = @import("std").zig.c_builtins.__builtin_truncf;
pub const __builtin_round = @import("std").zig.c_builtins.__builtin_round;
pub const __builtin_roundf = @import("std").zig.c_builtins.__builtin_roundf;
pub const __builtin_strlen = @import("std").zig.c_builtins.__builtin_strlen;
pub const __builtin_strcmp = @import("std").zig.c_builtins.__builtin_strcmp;
pub const __builtin_object_size = @import("std").zig.c_builtins.__builtin_object_size;
pub const __builtin___memset_chk = @import("std").zig.c_builtins.__builtin___memset_chk;
pub const __builtin_memset = @import("std").zig.c_builtins.__builtin_memset;
pub const __builtin___memcpy_chk = @import("std").zig.c_builtins.__builtin___memcpy_chk;
pub const __builtin_memcpy = @import("std").zig.c_builtins.__builtin_memcpy;
pub const __builtin_expect = @import("std").zig.c_builtins.__builtin_expect;
pub const __builtin_nanf = @import("std").zig.c_builtins.__builtin_nanf;
pub const __builtin_huge_valf = @import("std").zig.c_builtins.__builtin_huge_valf;
pub const __builtin_inff = @import("std").zig.c_builtins.__builtin_inff;
pub const __builtin_isnan = @import("std").zig.c_builtins.__builtin_isnan;
pub const __builtin_isinf = @import("std").zig.c_builtins.__builtin_isinf;
pub const __builtin_isinf_sign = @import("std").zig.c_builtins.__builtin_isinf_sign;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = c_longdouble;
pub const int_least8_t = i8;
pub const int_least16_t = i16;
pub const int_least32_t = i32;
pub const int_least64_t = i64;
pub const uint_least8_t = u8;
pub const uint_least16_t = u16;
pub const uint_least32_t = u32;
pub const uint_least64_t = u64;
pub const int_fast8_t = i8;
pub const int_fast16_t = i16;
pub const int_fast32_t = i32;
pub const int_fast64_t = i64;
pub const uint_fast8_t = u8;
pub const uint_fast16_t = u16;
pub const uint_fast32_t = u32;
pub const uint_fast64_t = u64;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_longlong;
pub const __uint64_t = c_ulonglong;
pub const __darwin_intptr_t = c_long;
pub const __darwin_natural_t = c_uint;
pub const __darwin_ct_rune_t = c_int;
pub const __mbstate_t = extern union {
    __mbstate8: [128]u8,
    _mbstateL: c_longlong,
};
pub const __darwin_mbstate_t = __mbstate_t;
pub const __darwin_ptrdiff_t = c_long;
pub const __darwin_size_t = c_ulong;
pub const __builtin_va_list = [*c]u8;
pub const __darwin_va_list = __builtin_va_list;
pub const __darwin_wchar_t = c_int;
pub const __darwin_rune_t = __darwin_wchar_t;
pub const __darwin_wint_t = c_int;
pub const __darwin_clock_t = c_ulong;
pub const __darwin_socklen_t = __uint32_t;
pub const __darwin_ssize_t = c_long;
pub const __darwin_time_t = c_long;
pub const __darwin_blkcnt_t = __int64_t;
pub const __darwin_blksize_t = __int32_t;
pub const __darwin_dev_t = __int32_t;
pub const __darwin_fsblkcnt_t = c_uint;
pub const __darwin_fsfilcnt_t = c_uint;
pub const __darwin_gid_t = __uint32_t;
pub const __darwin_id_t = __uint32_t;
pub const __darwin_ino64_t = __uint64_t;
pub const __darwin_ino_t = __darwin_ino64_t;
pub const __darwin_mach_port_name_t = __darwin_natural_t;
pub const __darwin_mach_port_t = __darwin_mach_port_name_t;
pub const __darwin_mode_t = __uint16_t;
pub const __darwin_off_t = __int64_t;
pub const __darwin_pid_t = __int32_t;
pub const __darwin_sigset_t = __uint32_t;
pub const __darwin_suseconds_t = __int32_t;
pub const __darwin_uid_t = __uint32_t;
pub const __darwin_useconds_t = __uint32_t;
pub const __darwin_uuid_t = [16]u8;
pub const __darwin_uuid_string_t = [37]u8;
pub const struct___darwin_pthread_handler_rec = extern struct {
    __routine: ?fn (?*anyopaque) callconv(.C) void,
    __arg: ?*anyopaque,
    __next: [*c]struct___darwin_pthread_handler_rec,
};
pub const struct__opaque_pthread_attr_t = extern struct {
    __sig: c_long,
    __opaque: [56]u8,
};
pub const struct__opaque_pthread_cond_t = extern struct {
    __sig: c_long,
    __opaque: [40]u8,
};
pub const struct__opaque_pthread_condattr_t = extern struct {
    __sig: c_long,
    __opaque: [8]u8,
};
pub const struct__opaque_pthread_mutex_t = extern struct {
    __sig: c_long,
    __opaque: [56]u8,
};
pub const struct__opaque_pthread_mutexattr_t = extern struct {
    __sig: c_long,
    __opaque: [8]u8,
};
pub const struct__opaque_pthread_once_t = extern struct {
    __sig: c_long,
    __opaque: [8]u8,
};
pub const struct__opaque_pthread_rwlock_t = extern struct {
    __sig: c_long,
    __opaque: [192]u8,
};
pub const struct__opaque_pthread_rwlockattr_t = extern struct {
    __sig: c_long,
    __opaque: [16]u8,
};
pub const struct__opaque_pthread_t = extern struct {
    __sig: c_long,
    __cleanup_stack: [*c]struct___darwin_pthread_handler_rec,
    __opaque: [8176]u8,
};
pub const __darwin_pthread_attr_t = struct__opaque_pthread_attr_t;
pub const __darwin_pthread_cond_t = struct__opaque_pthread_cond_t;
pub const __darwin_pthread_condattr_t = struct__opaque_pthread_condattr_t;
pub const __darwin_pthread_key_t = c_ulong;
pub const __darwin_pthread_mutex_t = struct__opaque_pthread_mutex_t;
pub const __darwin_pthread_mutexattr_t = struct__opaque_pthread_mutexattr_t;
pub const __darwin_pthread_once_t = struct__opaque_pthread_once_t;
pub const __darwin_pthread_rwlock_t = struct__opaque_pthread_rwlock_t;
pub const __darwin_pthread_rwlockattr_t = struct__opaque_pthread_rwlockattr_t;
pub const __darwin_pthread_t = [*c]struct__opaque_pthread_t;
pub const u_int8_t = u8;
pub const u_int16_t = c_ushort;
pub const u_int32_t = c_uint;
pub const u_int64_t = c_ulonglong;
pub const register_t = i64;
pub const user_addr_t = u_int64_t;
pub const user_size_t = u_int64_t;
pub const user_ssize_t = i64;
pub const user_long_t = i64;
pub const user_ulong_t = u_int64_t;
pub const user_time_t = i64;
pub const user_off_t = i64;
pub const syscall_arg_t = u_int64_t;
pub const intmax_t = c_long;
pub const uintmax_t = c_ulong;
pub const VkBool32 = u32;
pub const vk.DeviceAddress = u64;
pub const vk.DeviceSize = u64;
pub const VkFlags = u32;
pub const VkSampleMask = u32;
pub const struct_VkBuffer_T = opaque {};
pub const VkBuffer = ?*struct_VkBuffer_T;
pub const struct_VkImage_T = opaque {};
pub const VkImage = ?*struct_VkImage_T;
pub const struct_vk.Instance_T = opaque {};
pub const vk.Instance = ?*struct_vk.Instance_T;
pub const struct_vk.PhysicalDevice_T = opaque {};
pub const vk.PhysicalDevice = ?*struct_vk.PhysicalDevice_T;
pub const struct_vk.Device_T = opaque {};
pub const vk.Device = ?*struct_vk.Device_T;
pub const struct_VkQueue_T = opaque {};
pub const VkQueue = ?*struct_VkQueue_T;
pub const struct_VkSemaphore_T = opaque {};
pub const VkSemaphore = ?*struct_VkSemaphore_T;
pub const struct_VkCommandBuffer_T = opaque {};
pub const VkCommandBuffer = ?*struct_VkCommandBuffer_T;
pub const struct_VkFence_T = opaque {};
pub const VkFence = ?*struct_VkFence_T;
pub const struct_vk.DeviceMemory_T = opaque {};
pub const vk.DeviceMemory = ?*struct_vk.DeviceMemory_T;
pub const struct_VkEvent_T = opaque {};
pub const VkEvent = ?*struct_VkEvent_T;
pub const struct_VkQueryPool_T = opaque {};
pub const VkQueryPool = ?*struct_VkQueryPool_T;
pub const struct_VkBufferView_T = opaque {};
pub const VkBufferView = ?*struct_VkBufferView_T;
pub const struct_VkImageView_T = opaque {};
pub const VkImageView = ?*struct_VkImageView_T;
pub const struct_VkShaderModule_T = opaque {};
pub const VkShaderModule = ?*struct_VkShaderModule_T;
pub const struct_VkPipelineCache_T = opaque {};
pub const VkPipelineCache = ?*struct_VkPipelineCache_T;
pub const struct_VkPipelineLayout_T = opaque {};
pub const VkPipelineLayout = ?*struct_VkPipelineLayout_T;
pub const struct_VkPipeline_T = opaque {};
pub const VkPipeline = ?*struct_VkPipeline_T;
pub const struct_VkRenderPass_T = opaque {};
pub const VkRenderPass = ?*struct_VkRenderPass_T;
pub const struct_VkDescriptorSetLayout_T = opaque {};
pub const VkDescriptorSetLayout = ?*struct_VkDescriptorSetLayout_T;
pub const struct_VkSampler_T = opaque {};
pub const VkSampler = ?*struct_VkSampler_T;
pub const struct_VkDescriptorSet_T = opaque {};
pub const VkDescriptorSet = ?*struct_VkDescriptorSet_T;
pub const struct_VkDescriptorPool_T = opaque {};
pub const VkDescriptorPool = ?*struct_VkDescriptorPool_T;
pub const struct_VkFramebuffer_T = opaque {};
pub const VkFramebuffer = ?*struct_VkFramebuffer_T;
pub const struct_VkCommandPool_T = opaque {};
pub const VkCommandPool = ?*struct_VkCommandPool_T;
pub const VK_SUCCESS: c_int = 0;
pub const VK_NOT_READY: c_int = 1;
pub const VK_TIMEOUT: c_int = 2;
pub const VK_EVENT_SET: c_int = 3;
pub const VK_EVENT_RESET: c_int = 4;
pub const VK_INCOMPLETE: c_int = 5;
pub const VK_ERROR_OUT_OF_HOST_MEMORY: c_int = -1;
pub const VK_ERROR_OUT_OF_DEVICE_MEMORY: c_int = -2;
pub const VK_ERROR_INITIALIZATION_FAILED: c_int = -3;
pub const VK_ERROR_DEVICE_LOST: c_int = -4;
pub const VK_ERROR_MEMORY_MAP_FAILED: c_int = -5;
pub const VK_ERROR_LAYER_NOT_PRESENT: c_int = -6;
pub const VK_ERROR_EXTENSION_NOT_PRESENT: c_int = -7;
pub const VK_ERROR_FEATURE_NOT_PRESENT: c_int = -8;
pub const VK_ERROR_INCOMPATIBLE_DRIVER: c_int = -9;
pub const VK_ERROR_TOO_MANY_OBJECTS: c_int = -10;
pub const VK_ERROR_FORMAT_NOT_SUPPORTED: c_int = -11;
pub const VK_ERROR_FRAGMENTED_POOL: c_int = -12;
pub const VK_ERROR_UNKNOWN: c_int = -13;
pub const VK_ERROR_OUT_OF_POOL_MEMORY: c_int = -1000069000;
pub const VK_ERROR_INVALID_EXTERNAL_HANDLE: c_int = -1000072003;
pub const VK_ERROR_FRAGMENTATION: c_int = -1000161000;
pub const VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS: c_int = -1000257000;
pub const VK_ERROR_SURFACE_LOST_KHR: c_int = -1000000000;
pub const VK_ERROR_NATIVE_WINDOW_IN_USE_KHR: c_int = -1000000001;
pub const VK_SUBOPTIMAL_KHR: c_int = 1000001003;
pub const VK_ERROR_OUT_OF_DATE_KHR: c_int = -1000001004;
pub const VK_ERROR_INCOMPATIBLE_DISPLAY_KHR: c_int = -1000003001;
pub const VK_ERROR_VALIDATION_FAILED_EXT: c_int = -1000011001;
pub const VK_ERROR_INVALID_SHADER_NV: c_int = -1000012000;
pub const VK_ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT: c_int = -1000158000;
pub const VK_ERROR_NOT_PERMITTED_EXT: c_int = -1000174001;
pub const VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT: c_int = -1000255000;
pub const VK_THREAD_IDLE_KHR: c_int = 1000268000;
pub const VK_THREAD_DONE_KHR: c_int = 1000268001;
pub const VK_OPERATION_DEFERRED_KHR: c_int = 1000268002;
pub const VK_OPERATION_NOT_DEFERRED_KHR: c_int = 1000268003;
pub const VK_PIPELINE_COMPILE_REQUIRED_EXT: c_int = 1000297000;
pub const VK_ERROR_OUT_OF_POOL_MEMORY_KHR: c_int = -1000069000;
pub const VK_ERROR_INVALID_EXTERNAL_HANDLE_KHR: c_int = -1000072003;
pub const VK_ERROR_FRAGMENTATION_EXT: c_int = -1000161000;
pub const VK_ERROR_INVALID_DEVICE_ADDRESS_EXT: c_int = -1000257000;
pub const VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS_KHR: c_int = -1000257000;
pub const VK_ERROR_PIPELINE_COMPILE_REQUIRED_EXT: c_int = 1000297000;
pub const VK_RESULT_MAX_ENUM: c_int = 2147483647;
pub const enum_VkResult = c_int;
pub const VkResult = enum_VkResult;
pub const VK_STRUCTURE_TYPE_APPLICATION_INFO: c_int = 0;
pub const VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO: c_int = 1;
pub const VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO: c_int = 2;
pub const VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO: c_int = 3;
pub const VK_STRUCTURE_TYPE_SUBMIT_INFO: c_int = 4;
pub const VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO: c_int = 5;
pub const VK_STRUCTURE_TYPE_MAPPED_MEMORY_RANGE: c_int = 6;
pub const VK_STRUCTURE_TYPE_BIND_SPARSE_INFO: c_int = 7;
pub const VK_STRUCTURE_TYPE_FENCE_CREATE_INFO: c_int = 8;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO: c_int = 9;
pub const VK_STRUCTURE_TYPE_EVENT_CREATE_INFO: c_int = 10;
pub const VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO: c_int = 11;
pub const VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO: c_int = 12;
pub const VK_STRUCTURE_TYPE_BUFFER_VIEW_CREATE_INFO: c_int = 13;
pub const VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO: c_int = 14;
pub const VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO: c_int = 15;
pub const VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO: c_int = 16;
pub const VK_STRUCTURE_TYPE_PIPELINE_CACHE_CREATE_INFO: c_int = 17;
pub const VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO: c_int = 18;
pub const VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO: c_int = 19;
pub const VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO: c_int = 20;
pub const VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_STATE_CREATE_INFO: c_int = 21;
pub const VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO: c_int = 22;
pub const VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO: c_int = 23;
pub const VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO: c_int = 24;
pub const VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO: c_int = 25;
pub const VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO: c_int = 26;
pub const VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO: c_int = 27;
pub const VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO: c_int = 28;
pub const VK_STRUCTURE_TYPE_COMPUTE_PIPELINE_CREATE_INFO: c_int = 29;
pub const VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO: c_int = 30;
pub const VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO: c_int = 31;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO: c_int = 32;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO: c_int = 33;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO: c_int = 34;
pub const VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET: c_int = 35;
pub const VK_STRUCTURE_TYPE_COPY_DESCRIPTOR_SET: c_int = 36;
pub const VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO: c_int = 37;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO: c_int = 38;
pub const VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO: c_int = 39;
pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO: c_int = 40;
pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_INFO: c_int = 41;
pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO: c_int = 42;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO: c_int = 43;
pub const VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER: c_int = 44;
pub const VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER: c_int = 45;
pub const VK_STRUCTURE_TYPE_MEMORY_BARRIER: c_int = 46;
pub const VK_STRUCTURE_TYPE_LOADER_INSTANCE_CREATE_INFO: c_int = 47;
pub const VK_STRUCTURE_TYPE_LOADER_DEVICE_CREATE_INFO: c_int = 48;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_PROPERTIES: c_int = 1000094000;
pub const VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_INFO: c_int = 1000157000;
pub const VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_INFO: c_int = 1000157001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_16BIT_STORAGE_FEATURES: c_int = 1000083000;
pub const VK_STRUCTURE_TYPE_MEMORY_DEDICATED_REQUIREMENTS: c_int = 1000127000;
pub const VK_STRUCTURE_TYPE_MEMORY_DEDICATED_ALLOCATE_INFO: c_int = 1000127001;
pub const VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO: c_int = 1000060000;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_RENDER_PASS_BEGIN_INFO: c_int = 1000060003;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_COMMAND_BUFFER_BEGIN_INFO: c_int = 1000060004;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_SUBMIT_INFO: c_int = 1000060005;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_BIND_SPARSE_INFO: c_int = 1000060006;
pub const VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_DEVICE_GROUP_INFO: c_int = 1000060013;
pub const VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_DEVICE_GROUP_INFO: c_int = 1000060014;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_GROUP_PROPERTIES: c_int = 1000070000;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_DEVICE_CREATE_INFO: c_int = 1000070001;
pub const VK_STRUCTURE_TYPE_BUFFER_MEMORY_REQUIREMENTS_INFO_2: c_int = 1000146000;
pub const VK_STRUCTURE_TYPE_IMAGE_MEMORY_REQUIREMENTS_INFO_2: c_int = 1000146001;
pub const VK_STRUCTURE_TYPE_IMAGE_SPARSE_MEMORY_REQUIREMENTS_INFO_2: c_int = 1000146002;
pub const VK_STRUCTURE_TYPE_MEMORY_REQUIREMENTS_2: c_int = 1000146003;
pub const VK_STRUCTURE_TYPE_SPARSE_IMAGE_MEMORY_REQUIREMENTS_2: c_int = 1000146004;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2: c_int = 1000059000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2: c_int = 1000059001;
pub const VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_2: c_int = 1000059002;
pub const VK_STRUCTURE_TYPE_IMAGE_FORMAT_PROPERTIES_2: c_int = 1000059003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_FORMAT_INFO_2: c_int = 1000059004;
pub const VK_STRUCTURE_TYPE_QUEUE_FAMILY_PROPERTIES_2: c_int = 1000059005;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_PROPERTIES_2: c_int = 1000059006;
pub const VK_STRUCTURE_TYPE_SPARSE_IMAGE_FORMAT_PROPERTIES_2: c_int = 1000059007;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SPARSE_IMAGE_FORMAT_INFO_2: c_int = 1000059008;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_POINT_CLIPPING_PROPERTIES: c_int = 1000117000;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_INPUT_ATTACHMENT_ASPECT_CREATE_INFO: c_int = 1000117001;
pub const VK_STRUCTURE_TYPE_IMAGE_VIEW_USAGE_CREATE_INFO: c_int = 1000117002;
pub const VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_DOMAIN_ORIGIN_STATE_CREATE_INFO: c_int = 1000117003;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_MULTIVIEW_CREATE_INFO: c_int = 1000053000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_FEATURES: c_int = 1000053001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_PROPERTIES: c_int = 1000053002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VARIABLE_POINTERS_FEATURES: c_int = 1000120000;
pub const VK_STRUCTURE_TYPE_PROTECTED_SUBMIT_INFO: c_int = 1000145000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROTECTED_MEMORY_FEATURES: c_int = 1000145001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROTECTED_MEMORY_PROPERTIES: c_int = 1000145002;
pub const VK_STRUCTURE_TYPE_DEVICE_QUEUE_INFO_2: c_int = 1000145003;
pub const VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_CREATE_INFO: c_int = 1000156000;
pub const VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_INFO: c_int = 1000156001;
pub const VK_STRUCTURE_TYPE_BIND_IMAGE_PLANE_MEMORY_INFO: c_int = 1000156002;
pub const VK_STRUCTURE_TYPE_IMAGE_PLANE_MEMORY_REQUIREMENTS_INFO: c_int = 1000156003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLER_YCBCR_CONVERSION_FEATURES: c_int = 1000156004;
pub const VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_IMAGE_FORMAT_PROPERTIES: c_int = 1000156005;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_CREATE_INFO: c_int = 1000085000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_IMAGE_FORMAT_INFO: c_int = 1000071000;
pub const VK_STRUCTURE_TYPE_EXTERNAL_IMAGE_FORMAT_PROPERTIES: c_int = 1000071001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_BUFFER_INFO: c_int = 1000071002;
pub const VK_STRUCTURE_TYPE_EXTERNAL_BUFFER_PROPERTIES: c_int = 1000071003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ID_PROPERTIES: c_int = 1000071004;
pub const VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_BUFFER_CREATE_INFO: c_int = 1000072000;
pub const VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO: c_int = 1000072001;
pub const VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO: c_int = 1000072002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_FENCE_INFO: c_int = 1000112000;
pub const VK_STRUCTURE_TYPE_EXTERNAL_FENCE_PROPERTIES: c_int = 1000112001;
pub const VK_STRUCTURE_TYPE_EXPORT_FENCE_CREATE_INFO: c_int = 1000113000;
pub const VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_CREATE_INFO: c_int = 1000077000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_SEMAPHORE_INFO: c_int = 1000076000;
pub const VK_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_PROPERTIES: c_int = 1000076001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MAINTENANCE_3_PROPERTIES: c_int = 1000168000;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_SUPPORT: c_int = 1000168001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DRAW_PARAMETERS_FEATURES: c_int = 1000063000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_FEATURES: c_int = 49;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_1_PROPERTIES: c_int = 50;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_FEATURES: c_int = 51;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_1_2_PROPERTIES: c_int = 52;
pub const VK_STRUCTURE_TYPE_IMAGE_FORMAT_LIST_CREATE_INFO: c_int = 1000147000;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2: c_int = 1000109000;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2: c_int = 1000109001;
pub const VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_2: c_int = 1000109002;
pub const VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2: c_int = 1000109003;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2: c_int = 1000109004;
pub const VK_STRUCTURE_TYPE_SUBPASS_BEGIN_INFO: c_int = 1000109005;
pub const VK_STRUCTURE_TYPE_SUBPASS_END_INFO: c_int = 1000109006;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_8BIT_STORAGE_FEATURES: c_int = 1000177000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES: c_int = 1000196000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_INT64_FEATURES: c_int = 1000180000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_FLOAT16_INT8_FEATURES: c_int = 1000082000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FLOAT_CONTROLS_PROPERTIES: c_int = 1000197000;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_BINDING_FLAGS_CREATE_INFO: c_int = 1000161000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES: c_int = 1000161001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_PROPERTIES: c_int = 1000161002;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_ALLOCATE_INFO: c_int = 1000161003;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_LAYOUT_SUPPORT: c_int = 1000161004;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_STENCIL_RESOLVE_PROPERTIES: c_int = 1000199000;
pub const VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_DEPTH_STENCIL_RESOLVE: c_int = 1000199001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SCALAR_BLOCK_LAYOUT_FEATURES: c_int = 1000221000;
pub const VK_STRUCTURE_TYPE_IMAGE_STENCIL_USAGE_CREATE_INFO: c_int = 1000246000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLER_FILTER_MINMAX_PROPERTIES: c_int = 1000130000;
pub const VK_STRUCTURE_TYPE_SAMPLER_REDUCTION_MODE_CREATE_INFO: c_int = 1000130001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_MEMORY_MODEL_FEATURES: c_int = 1000211000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGELESS_FRAMEBUFFER_FEATURES: c_int = 1000108000;
pub const VK_STRUCTURE_TYPE_FRAMEBUFFER_ATTACHMENTS_CREATE_INFO: c_int = 1000108001;
pub const VK_STRUCTURE_TYPE_FRAMEBUFFER_ATTACHMENT_IMAGE_INFO: c_int = 1000108002;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_ATTACHMENT_BEGIN_INFO: c_int = 1000108003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_UNIFORM_BUFFER_STANDARD_LAYOUT_FEATURES: c_int = 1000253000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SUBGROUP_EXTENDED_TYPES_FEATURES: c_int = 1000175000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SEPARATE_DEPTH_STENCIL_LAYOUTS_FEATURES: c_int = 1000241000;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_STENCIL_LAYOUT: c_int = 1000241001;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_STENCIL_LAYOUT: c_int = 1000241002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_HOST_QUERY_RESET_FEATURES: c_int = 1000261000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_FEATURES: c_int = 1000207000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_PROPERTIES: c_int = 1000207001;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO: c_int = 1000207002;
pub const VK_STRUCTURE_TYPE_TIMELINE_SEMAPHORE_SUBMIT_INFO: c_int = 1000207003;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_WAIT_INFO: c_int = 1000207004;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_SIGNAL_INFO: c_int = 1000207005;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES: c_int = 1000257000;
pub const VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO: c_int = 1000244001;
pub const VK_STRUCTURE_TYPE_BUFFER_OPAQUE_CAPTURE_ADDRESS_CREATE_INFO: c_int = 1000257002;
pub const VK_STRUCTURE_TYPE_MEMORY_OPAQUE_CAPTURE_ADDRESS_ALLOCATE_INFO: c_int = 1000257003;
pub const VK_STRUCTURE_TYPE_DEVICE_MEMORY_OPAQUE_CAPTURE_ADDRESS_INFO: c_int = 1000257004;
pub const VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR: c_int = 1000001000;
pub const VK_STRUCTURE_TYPE_PRESENT_INFO_KHR: c_int = 1000001001;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_PRESENT_CAPABILITIES_KHR: c_int = 1000060007;
pub const VK_STRUCTURE_TYPE_IMAGE_SWAPCHAIN_CREATE_INFO_KHR: c_int = 1000060008;
pub const VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_SWAPCHAIN_INFO_KHR: c_int = 1000060009;
pub const VK_STRUCTURE_TYPE_ACQUIRE_NEXT_IMAGE_INFO_KHR: c_int = 1000060010;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_PRESENT_INFO_KHR: c_int = 1000060011;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_SWAPCHAIN_CREATE_INFO_KHR: c_int = 1000060012;
pub const VK_STRUCTURE_TYPE_DISPLAY_MODE_CREATE_INFO_KHR: c_int = 1000002000;
pub const VK_STRUCTURE_TYPE_DISPLAY_SURFACE_CREATE_INFO_KHR: c_int = 1000002001;
pub const VK_STRUCTURE_TYPE_DISPLAY_PRESENT_INFO_KHR: c_int = 1000003000;
pub const VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR: c_int = 1000004000;
pub const VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR: c_int = 1000005000;
pub const VK_STRUCTURE_TYPE_WAYLAND_SURFACE_CREATE_INFO_KHR: c_int = 1000006000;
pub const VK_STRUCTURE_TYPE_ANDROID_SURFACE_CREATE_INFO_KHR: c_int = 1000008000;
pub const VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR: c_int = 1000009000;
pub const VK_STRUCTURE_TYPE_DEBUG_REPORT_CALLBACK_CREATE_INFO_EXT: c_int = 1000011000;
pub const VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_RASTERIZATION_ORDER_AMD: c_int = 1000018000;
pub const VK_STRUCTURE_TYPE_DEBUG_MARKER_OBJECT_NAME_INFO_EXT: c_int = 1000022000;
pub const VK_STRUCTURE_TYPE_DEBUG_MARKER_OBJECT_TAG_INFO_EXT: c_int = 1000022001;
pub const VK_STRUCTURE_TYPE_DEBUG_MARKER_MARKER_INFO_EXT: c_int = 1000022002;
pub const VK_STRUCTURE_TYPE_DEDICATED_ALLOCATION_IMAGE_CREATE_INFO_NV: c_int = 1000026000;
pub const VK_STRUCTURE_TYPE_DEDICATED_ALLOCATION_BUFFER_CREATE_INFO_NV: c_int = 1000026001;
pub const VK_STRUCTURE_TYPE_DEDICATED_ALLOCATION_MEMORY_ALLOCATE_INFO_NV: c_int = 1000026002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TRANSFORM_FEEDBACK_FEATURES_EXT: c_int = 1000028000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TRANSFORM_FEEDBACK_PROPERTIES_EXT: c_int = 1000028001;
pub const VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_STREAM_CREATE_INFO_EXT: c_int = 1000028002;
pub const VK_STRUCTURE_TYPE_CU_MODULE_CREATE_INFO_NVX: c_int = 1000029000;
pub const VK_STRUCTURE_TYPE_CU_FUNCTION_CREATE_INFO_NVX: c_int = 1000029001;
pub const VK_STRUCTURE_TYPE_CU_LAUNCH_INFO_NVX: c_int = 1000029002;
pub const VK_STRUCTURE_TYPE_IMAGE_VIEW_HANDLE_INFO_NVX: c_int = 1000030000;
pub const VK_STRUCTURE_TYPE_IMAGE_VIEW_ADDRESS_PROPERTIES_NVX: c_int = 1000030001;
pub const VK_STRUCTURE_TYPE_TEXTURE_LOD_GATHER_FORMAT_PROPERTIES_AMD: c_int = 1000041000;
pub const VK_STRUCTURE_TYPE_RENDERING_INFO_KHR: c_int = 1000044000;
pub const VK_STRUCTURE_TYPE_RENDERING_ATTACHMENT_INFO_KHR: c_int = 1000044001;
pub const VK_STRUCTURE_TYPE_PIPELINE_RENDERING_CREATE_INFO_KHR: c_int = 1000044002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DYNAMIC_RENDERING_FEATURES_KHR: c_int = 1000044003;
pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_RENDERING_INFO_KHR: c_int = 1000044004;
pub const VK_STRUCTURE_TYPE_RENDERING_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR: c_int = 1000044006;
pub const VK_STRUCTURE_TYPE_RENDERING_FRAGMENT_DENSITY_MAP_ATTACHMENT_INFO_EXT: c_int = 1000044007;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_SAMPLE_COUNT_INFO_AMD: c_int = 1000044008;
pub const VK_STRUCTURE_TYPE_MULTIVIEW_PER_VIEW_ATTRIBUTES_INFO_NVX: c_int = 1000044009;
pub const VK_STRUCTURE_TYPE_STREAM_DESCRIPTOR_SURFACE_CREATE_INFO_GGP: c_int = 1000049000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CORNER_SAMPLED_IMAGE_FEATURES_NV: c_int = 1000050000;
pub const VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO_NV: c_int = 1000056000;
pub const VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO_NV: c_int = 1000056001;
pub const VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_NV: c_int = 1000057000;
pub const VK_STRUCTURE_TYPE_EXPORT_MEMORY_WIN32_HANDLE_INFO_NV: c_int = 1000057001;
pub const VK_STRUCTURE_TYPE_WIN32_KEYED_MUTEX_ACQUIRE_RELEASE_INFO_NV: c_int = 1000058000;
pub const VK_STRUCTURE_TYPE_VALIDATION_FLAGS_EXT: c_int = 1000061000;
pub const VK_STRUCTURE_TYPE_VI_SURFACE_CREATE_INFO_NN: c_int = 1000062000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TEXTURE_COMPRESSION_ASTC_HDR_FEATURES_EXT: c_int = 1000066000;
pub const VK_STRUCTURE_TYPE_IMAGE_VIEW_ASTC_DECODE_MODE_EXT: c_int = 1000067000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ASTC_DECODE_FEATURES_EXT: c_int = 1000067001;
pub const VK_STRUCTURE_TYPE_IMPORT_MEMORY_WIN32_HANDLE_INFO_KHR: c_int = 1000073000;
pub const VK_STRUCTURE_TYPE_EXPORT_MEMORY_WIN32_HANDLE_INFO_KHR: c_int = 1000073001;
pub const VK_STRUCTURE_TYPE_MEMORY_WIN32_HANDLE_PROPERTIES_KHR: c_int = 1000073002;
pub const VK_STRUCTURE_TYPE_MEMORY_GET_WIN32_HANDLE_INFO_KHR: c_int = 1000073003;
pub const VK_STRUCTURE_TYPE_IMPORT_MEMORY_FD_INFO_KHR: c_int = 1000074000;
pub const VK_STRUCTURE_TYPE_MEMORY_FD_PROPERTIES_KHR: c_int = 1000074001;
pub const VK_STRUCTURE_TYPE_MEMORY_GET_FD_INFO_KHR: c_int = 1000074002;
pub const VK_STRUCTURE_TYPE_WIN32_KEYED_MUTEX_ACQUIRE_RELEASE_INFO_KHR: c_int = 1000075000;
pub const VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR: c_int = 1000078000;
pub const VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_WIN32_HANDLE_INFO_KHR: c_int = 1000078001;
pub const VK_STRUCTURE_TYPE_D3D12_FENCE_SUBMIT_INFO_KHR: c_int = 1000078002;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_GET_WIN32_HANDLE_INFO_KHR: c_int = 1000078003;
pub const VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_FD_INFO_KHR: c_int = 1000079000;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_GET_FD_INFO_KHR: c_int = 1000079001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PUSH_DESCRIPTOR_PROPERTIES_KHR: c_int = 1000080000;
pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_CONDITIONAL_RENDERING_INFO_EXT: c_int = 1000081000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CONDITIONAL_RENDERING_FEATURES_EXT: c_int = 1000081001;
pub const VK_STRUCTURE_TYPE_CONDITIONAL_RENDERING_BEGIN_INFO_EXT: c_int = 1000081002;
pub const VK_STRUCTURE_TYPE_PRESENT_REGIONS_KHR: c_int = 1000084000;
pub const VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_W_SCALING_STATE_CREATE_INFO_NV: c_int = 1000087000;
pub const VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_2_EXT: c_int = 1000090000;
pub const VK_STRUCTURE_TYPE_DISPLAY_POWER_INFO_EXT: c_int = 1000091000;
pub const VK_STRUCTURE_TYPE_DEVICE_EVENT_INFO_EXT: c_int = 1000091001;
pub const VK_STRUCTURE_TYPE_DISPLAY_EVENT_INFO_EXT: c_int = 1000091002;
pub const VK_STRUCTURE_TYPE_SWAPCHAIN_COUNTER_CREATE_INFO_EXT: c_int = 1000091003;
pub const VK_STRUCTURE_TYPE_PRESENT_TIMES_INFO_GOOGLE: c_int = 1000092000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_PER_VIEW_ATTRIBUTES_PROPERTIES_NVX: c_int = 1000097000;
pub const VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_SWIZZLE_STATE_CREATE_INFO_NV: c_int = 1000098000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DISCARD_RECTANGLE_PROPERTIES_EXT: c_int = 1000099000;
pub const VK_STRUCTURE_TYPE_PIPELINE_DISCARD_RECTANGLE_STATE_CREATE_INFO_EXT: c_int = 1000099001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CONSERVATIVE_RASTERIZATION_PROPERTIES_EXT: c_int = 1000101000;
pub const VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_CONSERVATIVE_STATE_CREATE_INFO_EXT: c_int = 1000101001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_CLIP_ENABLE_FEATURES_EXT: c_int = 1000102000;
pub const VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_DEPTH_CLIP_STATE_CREATE_INFO_EXT: c_int = 1000102001;
pub const VK_STRUCTURE_TYPE_HDR_METADATA_EXT: c_int = 1000105000;
pub const VK_STRUCTURE_TYPE_SHARED_PRESENT_SURFACE_CAPABILITIES_KHR: c_int = 1000111000;
pub const VK_STRUCTURE_TYPE_IMPORT_FENCE_WIN32_HANDLE_INFO_KHR: c_int = 1000114000;
pub const VK_STRUCTURE_TYPE_EXPORT_FENCE_WIN32_HANDLE_INFO_KHR: c_int = 1000114001;
pub const VK_STRUCTURE_TYPE_FENCE_GET_WIN32_HANDLE_INFO_KHR: c_int = 1000114002;
pub const VK_STRUCTURE_TYPE_IMPORT_FENCE_FD_INFO_KHR: c_int = 1000115000;
pub const VK_STRUCTURE_TYPE_FENCE_GET_FD_INFO_KHR: c_int = 1000115001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PERFORMANCE_QUERY_FEATURES_KHR: c_int = 1000116000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PERFORMANCE_QUERY_PROPERTIES_KHR: c_int = 1000116001;
pub const VK_STRUCTURE_TYPE_QUERY_POOL_PERFORMANCE_CREATE_INFO_KHR: c_int = 1000116002;
pub const VK_STRUCTURE_TYPE_PERFORMANCE_QUERY_SUBMIT_INFO_KHR: c_int = 1000116003;
pub const VK_STRUCTURE_TYPE_ACQUIRE_PROFILING_LOCK_INFO_KHR: c_int = 1000116004;
pub const VK_STRUCTURE_TYPE_PERFORMANCE_COUNTER_KHR: c_int = 1000116005;
pub const VK_STRUCTURE_TYPE_PERFORMANCE_COUNTER_DESCRIPTION_KHR: c_int = 1000116006;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SURFACE_INFO_2_KHR: c_int = 1000119000;
pub const VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_2_KHR: c_int = 1000119001;
pub const VK_STRUCTURE_TYPE_SURFACE_FORMAT_2_KHR: c_int = 1000119002;
pub const VK_STRUCTURE_TYPE_DISPLAY_PROPERTIES_2_KHR: c_int = 1000121000;
pub const VK_STRUCTURE_TYPE_DISPLAY_PLANE_PROPERTIES_2_KHR: c_int = 1000121001;
pub const VK_STRUCTURE_TYPE_DISPLAY_MODE_PROPERTIES_2_KHR: c_int = 1000121002;
pub const VK_STRUCTURE_TYPE_DISPLAY_PLANE_INFO_2_KHR: c_int = 1000121003;
pub const VK_STRUCTURE_TYPE_DISPLAY_PLANE_CAPABILITIES_2_KHR: c_int = 1000121004;
pub const VK_STRUCTURE_TYPE_IOS_SURFACE_CREATE_INFO_MVK: c_int = 1000122000;
pub const VK_STRUCTURE_TYPE_MACOS_SURFACE_CREATE_INFO_MVK: c_int = 1000123000;
pub const VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_NAME_INFO_EXT: c_int = 1000128000;
pub const VK_STRUCTURE_TYPE_DEBUG_UTILS_OBJECT_TAG_INFO_EXT: c_int = 1000128001;
pub const VK_STRUCTURE_TYPE_DEBUG_UTILS_LABEL_EXT: c_int = 1000128002;
pub const VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CALLBACK_DATA_EXT: c_int = 1000128003;
pub const VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT: c_int = 1000128004;
pub const VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_USAGE_ANDROID: c_int = 1000129000;
pub const VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_PROPERTIES_ANDROID: c_int = 1000129001;
pub const VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_FORMAT_PROPERTIES_ANDROID: c_int = 1000129002;
pub const VK_STRUCTURE_TYPE_IMPORT_ANDROID_HARDWARE_BUFFER_INFO_ANDROID: c_int = 1000129003;
pub const VK_STRUCTURE_TYPE_MEMORY_GET_ANDROID_HARDWARE_BUFFER_INFO_ANDROID: c_int = 1000129004;
pub const VK_STRUCTURE_TYPE_EXTERNAL_FORMAT_ANDROID: c_int = 1000129005;
pub const VK_STRUCTURE_TYPE_ANDROID_HARDWARE_BUFFER_FORMAT_PROPERTIES_2_ANDROID: c_int = 1000129006;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INLINE_UNIFORM_BLOCK_FEATURES_EXT: c_int = 1000138000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INLINE_UNIFORM_BLOCK_PROPERTIES_EXT: c_int = 1000138001;
pub const VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_INLINE_UNIFORM_BLOCK_EXT: c_int = 1000138002;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_INLINE_UNIFORM_BLOCK_CREATE_INFO_EXT: c_int = 1000138003;
pub const VK_STRUCTURE_TYPE_SAMPLE_LOCATIONS_INFO_EXT: c_int = 1000143000;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_SAMPLE_LOCATIONS_BEGIN_INFO_EXT: c_int = 1000143001;
pub const VK_STRUCTURE_TYPE_PIPELINE_SAMPLE_LOCATIONS_STATE_CREATE_INFO_EXT: c_int = 1000143002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLE_LOCATIONS_PROPERTIES_EXT: c_int = 1000143003;
pub const VK_STRUCTURE_TYPE_MULTISAMPLE_PROPERTIES_EXT: c_int = 1000143004;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BLEND_OPERATION_ADVANCED_FEATURES_EXT: c_int = 1000148000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BLEND_OPERATION_ADVANCED_PROPERTIES_EXT: c_int = 1000148001;
pub const VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_ADVANCED_STATE_CREATE_INFO_EXT: c_int = 1000148002;
pub const VK_STRUCTURE_TYPE_PIPELINE_COVERAGE_TO_COLOR_STATE_CREATE_INFO_NV: c_int = 1000149000;
pub const VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_KHR: c_int = 1000150007;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_GEOMETRY_INFO_KHR: c_int = 1000150000;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_DEVICE_ADDRESS_INFO_KHR: c_int = 1000150002;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_AABBS_DATA_KHR: c_int = 1000150003;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_INSTANCES_DATA_KHR: c_int = 1000150004;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_TRIANGLES_DATA_KHR: c_int = 1000150005;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_KHR: c_int = 1000150006;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_VERSION_INFO_KHR: c_int = 1000150009;
pub const VK_STRUCTURE_TYPE_COPY_ACCELERATION_STRUCTURE_INFO_KHR: c_int = 1000150010;
pub const VK_STRUCTURE_TYPE_COPY_ACCELERATION_STRUCTURE_TO_MEMORY_INFO_KHR: c_int = 1000150011;
pub const VK_STRUCTURE_TYPE_COPY_MEMORY_TO_ACCELERATION_STRUCTURE_INFO_KHR: c_int = 1000150012;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_FEATURES_KHR: c_int = 1000150013;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ACCELERATION_STRUCTURE_PROPERTIES_KHR: c_int = 1000150014;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_KHR: c_int = 1000150017;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_BUILD_SIZES_INFO_KHR: c_int = 1000150020;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_FEATURES_KHR: c_int = 1000347000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PIPELINE_PROPERTIES_KHR: c_int = 1000347001;
pub const VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_KHR: c_int = 1000150015;
pub const VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR: c_int = 1000150016;
pub const VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_INTERFACE_CREATE_INFO_KHR: c_int = 1000150018;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_QUERY_FEATURES_KHR: c_int = 1000348013;
pub const VK_STRUCTURE_TYPE_PIPELINE_COVERAGE_MODULATION_STATE_CREATE_INFO_NV: c_int = 1000152000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SM_BUILTINS_FEATURES_NV: c_int = 1000154000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SM_BUILTINS_PROPERTIES_NV: c_int = 1000154001;
pub const VK_STRUCTURE_TYPE_DRM_FORMAT_MODIFIER_PROPERTIES_LIST_EXT: c_int = 1000158000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_DRM_FORMAT_MODIFIER_INFO_EXT: c_int = 1000158002;
pub const VK_STRUCTURE_TYPE_IMAGE_DRM_FORMAT_MODIFIER_LIST_CREATE_INFO_EXT: c_int = 1000158003;
pub const VK_STRUCTURE_TYPE_IMAGE_DRM_FORMAT_MODIFIER_EXPLICIT_CREATE_INFO_EXT: c_int = 1000158004;
pub const VK_STRUCTURE_TYPE_IMAGE_DRM_FORMAT_MODIFIER_PROPERTIES_EXT: c_int = 1000158005;
pub const VK_STRUCTURE_TYPE_DRM_FORMAT_MODIFIER_PROPERTIES_LIST_2_EXT: c_int = 1000158006;
pub const VK_STRUCTURE_TYPE_VALIDATION_CACHE_CREATE_INFO_EXT: c_int = 1000160000;
pub const VK_STRUCTURE_TYPE_SHADER_MODULE_VALIDATION_CACHE_CREATE_INFO_EXT: c_int = 1000160001;
pub const VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_SHADING_RATE_IMAGE_STATE_CREATE_INFO_NV: c_int = 1000164000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADING_RATE_IMAGE_FEATURES_NV: c_int = 1000164001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADING_RATE_IMAGE_PROPERTIES_NV: c_int = 1000164002;
pub const VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_COARSE_SAMPLE_ORDER_STATE_CREATE_INFO_NV: c_int = 1000164005;
pub const VK_STRUCTURE_TYPE_RAY_TRACING_PIPELINE_CREATE_INFO_NV: c_int = 1000165000;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_CREATE_INFO_NV: c_int = 1000165001;
pub const VK_STRUCTURE_TYPE_GEOMETRY_NV: c_int = 1000165003;
pub const VK_STRUCTURE_TYPE_GEOMETRY_TRIANGLES_NV: c_int = 1000165004;
pub const VK_STRUCTURE_TYPE_GEOMETRY_AABB_NV: c_int = 1000165005;
pub const VK_STRUCTURE_TYPE_BIND_ACCELERATION_STRUCTURE_MEMORY_INFO_NV: c_int = 1000165006;
pub const VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_NV: c_int = 1000165007;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_INFO_NV: c_int = 1000165008;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_PROPERTIES_NV: c_int = 1000165009;
pub const VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_NV: c_int = 1000165011;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_INFO_NV: c_int = 1000165012;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_REPRESENTATIVE_FRAGMENT_TEST_FEATURES_NV: c_int = 1000166000;
pub const VK_STRUCTURE_TYPE_PIPELINE_REPRESENTATIVE_FRAGMENT_TEST_STATE_CREATE_INFO_NV: c_int = 1000166001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_VIEW_IMAGE_FORMAT_INFO_EXT: c_int = 1000170000;
pub const VK_STRUCTURE_TYPE_FILTER_CUBIC_IMAGE_VIEW_IMAGE_FORMAT_PROPERTIES_EXT: c_int = 1000170001;
pub const VK_STRUCTURE_TYPE_DEVICE_QUEUE_GLOBAL_PRIORITY_CREATE_INFO_EXT: c_int = 1000174000;
pub const VK_STRUCTURE_TYPE_IMPORT_MEMORY_HOST_POINTER_INFO_EXT: c_int = 1000178000;
pub const VK_STRUCTURE_TYPE_MEMORY_HOST_POINTER_PROPERTIES_EXT: c_int = 1000178001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_MEMORY_HOST_PROPERTIES_EXT: c_int = 1000178002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_CLOCK_FEATURES_KHR: c_int = 1000181000;
pub const VK_STRUCTURE_TYPE_PIPELINE_COMPILER_CONTROL_CREATE_INFO_AMD: c_int = 1000183000;
pub const VK_STRUCTURE_TYPE_CALIBRATED_TIMESTAMP_INFO_EXT: c_int = 1000184000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_CORE_PROPERTIES_AMD: c_int = 1000185000;
pub const VK_STRUCTURE_TYPE_DEVICE_MEMORY_OVERALLOCATION_CREATE_INFO_AMD: c_int = 1000189000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VERTEX_ATTRIBUTE_DIVISOR_PROPERTIES_EXT: c_int = 1000190000;
pub const VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_DIVISOR_STATE_CREATE_INFO_EXT: c_int = 1000190001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VERTEX_ATTRIBUTE_DIVISOR_FEATURES_EXT: c_int = 1000190002;
pub const VK_STRUCTURE_TYPE_PRESENT_FRAME_TOKEN_GGP: c_int = 1000191000;
pub const VK_STRUCTURE_TYPE_PIPELINE_CREATION_FEEDBACK_CREATE_INFO_EXT: c_int = 1000192000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COMPUTE_SHADER_DERIVATIVES_FEATURES_NV: c_int = 1000201000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MESH_SHADER_FEATURES_NV: c_int = 1000202000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MESH_SHADER_PROPERTIES_NV: c_int = 1000202001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADER_BARYCENTRIC_FEATURES_NV: c_int = 1000203000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_IMAGE_FOOTPRINT_FEATURES_NV: c_int = 1000204000;
pub const VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_EXCLUSIVE_SCISSOR_STATE_CREATE_INFO_NV: c_int = 1000205000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXCLUSIVE_SCISSOR_FEATURES_NV: c_int = 1000205002;
pub const VK_STRUCTURE_TYPE_CHECKPOINT_DATA_NV: c_int = 1000206000;
pub const VK_STRUCTURE_TYPE_QUEUE_FAMILY_CHECKPOINT_PROPERTIES_NV: c_int = 1000206001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_INTEGER_FUNCTIONS_2_FEATURES_INTEL: c_int = 1000209000;
pub const VK_STRUCTURE_TYPE_QUERY_POOL_PERFORMANCE_QUERY_CREATE_INFO_INTEL: c_int = 1000210000;
pub const VK_STRUCTURE_TYPE_INITIALIZE_PERFORMANCE_API_INFO_INTEL: c_int = 1000210001;
pub const VK_STRUCTURE_TYPE_PERFORMANCE_MARKER_INFO_INTEL: c_int = 1000210002;
pub const VK_STRUCTURE_TYPE_PERFORMANCE_STREAM_MARKER_INFO_INTEL: c_int = 1000210003;
pub const VK_STRUCTURE_TYPE_PERFORMANCE_OVERRIDE_INFO_INTEL: c_int = 1000210004;
pub const VK_STRUCTURE_TYPE_PERFORMANCE_CONFIGURATION_ACQUIRE_INFO_INTEL: c_int = 1000210005;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PCI_BUS_INFO_PROPERTIES_EXT: c_int = 1000212000;
pub const VK_STRUCTURE_TYPE_DISPLAY_NATIVE_HDR_SURFACE_CAPABILITIES_AMD: c_int = 1000213000;
pub const VK_STRUCTURE_TYPE_SWAPCHAIN_DISPLAY_NATIVE_HDR_CREATE_INFO_AMD: c_int = 1000213001;
pub const VK_STRUCTURE_TYPE_IMAGEPIPE_SURFACE_CREATE_INFO_FUCHSIA: c_int = 1000214000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_TERMINATE_INVOCATION_FEATURES_KHR: c_int = 1000215000;
pub const VK_STRUCTURE_TYPE_METAL_SURFACE_CREATE_INFO_EXT: c_int = 1000217000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_FEATURES_EXT: c_int = 1000218000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_PROPERTIES_EXT: c_int = 1000218001;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_FRAGMENT_DENSITY_MAP_CREATE_INFO_EXT: c_int = 1000218002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_SIZE_CONTROL_PROPERTIES_EXT: c_int = 1000225000;
pub const VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_REQUIRED_SUBGROUP_SIZE_CREATE_INFO_EXT: c_int = 1000225001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBGROUP_SIZE_CONTROL_FEATURES_EXT: c_int = 1000225002;
pub const VK_STRUCTURE_TYPE_FRAGMENT_SHADING_RATE_ATTACHMENT_INFO_KHR: c_int = 1000226000;
pub const VK_STRUCTURE_TYPE_PIPELINE_FRAGMENT_SHADING_RATE_STATE_CREATE_INFO_KHR: c_int = 1000226001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_PROPERTIES_KHR: c_int = 1000226002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_FEATURES_KHR: c_int = 1000226003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_KHR: c_int = 1000226004;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_CORE_PROPERTIES_2_AMD: c_int = 1000227000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COHERENT_MEMORY_FEATURES_AMD: c_int = 1000229000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_IMAGE_ATOMIC_INT64_FEATURES_EXT: c_int = 1000234000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_BUDGET_PROPERTIES_EXT: c_int = 1000237000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_PRIORITY_FEATURES_EXT: c_int = 1000238000;
pub const VK_STRUCTURE_TYPE_MEMORY_PRIORITY_ALLOCATE_INFO_EXT: c_int = 1000238001;
pub const VK_STRUCTURE_TYPE_SURFACE_PROTECTED_CAPABILITIES_KHR: c_int = 1000239000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEDICATED_ALLOCATION_IMAGE_ALIASING_FEATURES_NV: c_int = 1000240000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES_EXT: c_int = 1000244000;
pub const VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_CREATE_INFO_EXT: c_int = 1000244002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TOOL_PROPERTIES_EXT: c_int = 1000245000;
pub const VK_STRUCTURE_TYPE_VALIDATION_FEATURES_EXT: c_int = 1000247000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRESENT_WAIT_FEATURES_KHR: c_int = 1000248000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COOPERATIVE_MATRIX_FEATURES_NV: c_int = 1000249000;
pub const VK_STRUCTURE_TYPE_COOPERATIVE_MATRIX_PROPERTIES_NV: c_int = 1000249001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COOPERATIVE_MATRIX_PROPERTIES_NV: c_int = 1000249002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COVERAGE_REDUCTION_MODE_FEATURES_NV: c_int = 1000250000;
pub const VK_STRUCTURE_TYPE_PIPELINE_COVERAGE_REDUCTION_STATE_CREATE_INFO_NV: c_int = 1000250001;
pub const VK_STRUCTURE_TYPE_FRAMEBUFFER_MIXED_SAMPLES_COMBINATION_NV: c_int = 1000250002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADER_INTERLOCK_FEATURES_EXT: c_int = 1000251000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_YCBCR_IMAGE_ARRAYS_FEATURES_EXT: c_int = 1000252000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROVOKING_VERTEX_FEATURES_EXT: c_int = 1000254000;
pub const VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_PROVOKING_VERTEX_STATE_CREATE_INFO_EXT: c_int = 1000254001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROVOKING_VERTEX_PROPERTIES_EXT: c_int = 1000254002;
pub const VK_STRUCTURE_TYPE_SURFACE_FULL_SCREEN_EXCLUSIVE_INFO_EXT: c_int = 1000255000;
pub const VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES_FULL_SCREEN_EXCLUSIVE_EXT: c_int = 1000255002;
pub const VK_STRUCTURE_TYPE_SURFACE_FULL_SCREEN_EXCLUSIVE_WIN32_INFO_EXT: c_int = 1000255001;
pub const VK_STRUCTURE_TYPE_HEADLESS_SURFACE_CREATE_INFO_EXT: c_int = 1000256000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_LINE_RASTERIZATION_FEATURES_EXT: c_int = 1000259000;
pub const VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_LINE_STATE_CREATE_INFO_EXT: c_int = 1000259001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_LINE_RASTERIZATION_PROPERTIES_EXT: c_int = 1000259002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_FLOAT_FEATURES_EXT: c_int = 1000260000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INDEX_TYPE_UINT8_FEATURES_EXT: c_int = 1000265000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_FEATURES_EXT: c_int = 1000267000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PIPELINE_EXECUTABLE_PROPERTIES_FEATURES_KHR: c_int = 1000269000;
pub const VK_STRUCTURE_TYPE_PIPELINE_INFO_KHR: c_int = 1000269001;
pub const VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_PROPERTIES_KHR: c_int = 1000269002;
pub const VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_INFO_KHR: c_int = 1000269003;
pub const VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_STATISTIC_KHR: c_int = 1000269004;
pub const VK_STRUCTURE_TYPE_PIPELINE_EXECUTABLE_INTERNAL_REPRESENTATION_KHR: c_int = 1000269005;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_FLOAT_2_FEATURES_EXT: c_int = 1000273000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DEMOTE_TO_HELPER_INVOCATION_FEATURES_EXT: c_int = 1000276000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEVICE_GENERATED_COMMANDS_PROPERTIES_NV: c_int = 1000277000;
pub const VK_STRUCTURE_TYPE_GRAPHICS_SHADER_GROUP_CREATE_INFO_NV: c_int = 1000277001;
pub const VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_SHADER_GROUPS_CREATE_INFO_NV: c_int = 1000277002;
pub const VK_STRUCTURE_TYPE_INDIRECT_COMMANDS_LAYOUT_TOKEN_NV: c_int = 1000277003;
pub const VK_STRUCTURE_TYPE_INDIRECT_COMMANDS_LAYOUT_CREATE_INFO_NV: c_int = 1000277004;
pub const VK_STRUCTURE_TYPE_GENERATED_COMMANDS_INFO_NV: c_int = 1000277005;
pub const VK_STRUCTURE_TYPE_GENERATED_COMMANDS_MEMORY_REQUIREMENTS_INFO_NV: c_int = 1000277006;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEVICE_GENERATED_COMMANDS_FEATURES_NV: c_int = 1000277007;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INHERITED_VIEWPORT_SCISSOR_FEATURES_NV: c_int = 1000278000;
pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_VIEWPORT_SCISSOR_INFO_NV: c_int = 1000278001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_INTEGER_DOT_PRODUCT_FEATURES_KHR: c_int = 1000280000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_INTEGER_DOT_PRODUCT_PROPERTIES_KHR: c_int = 1000280001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TEXEL_BUFFER_ALIGNMENT_FEATURES_EXT: c_int = 1000281000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TEXEL_BUFFER_ALIGNMENT_PROPERTIES_EXT: c_int = 1000281001;
pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_INHERITANCE_RENDER_PASS_TRANSFORM_INFO_QCOM: c_int = 1000282000;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_TRANSFORM_BEGIN_INFO_QCOM: c_int = 1000282001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEVICE_MEMORY_REPORT_FEATURES_EXT: c_int = 1000284000;
pub const VK_STRUCTURE_TYPE_DEVICE_DEVICE_MEMORY_REPORT_CREATE_INFO_EXT: c_int = 1000284001;
pub const VK_STRUCTURE_TYPE_DEVICE_MEMORY_REPORT_CALLBACK_DATA_EXT: c_int = 1000284002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ROBUSTNESS_2_FEATURES_EXT: c_int = 1000286000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ROBUSTNESS_2_PROPERTIES_EXT: c_int = 1000286001;
pub const VK_STRUCTURE_TYPE_SAMPLER_CUSTOM_BORDER_COLOR_CREATE_INFO_EXT: c_int = 1000287000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CUSTOM_BORDER_COLOR_PROPERTIES_EXT: c_int = 1000287001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_CUSTOM_BORDER_COLOR_FEATURES_EXT: c_int = 1000287002;
pub const VK_STRUCTURE_TYPE_PIPELINE_LIBRARY_CREATE_INFO_KHR: c_int = 1000290000;
pub const VK_STRUCTURE_TYPE_PRESENT_ID_KHR: c_int = 1000294000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRESENT_ID_FEATURES_KHR: c_int = 1000294001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRIVATE_DATA_FEATURES_EXT: c_int = 1000295000;
pub const VK_STRUCTURE_TYPE_DEVICE_PRIVATE_DATA_CREATE_INFO_EXT: c_int = 1000295001;
pub const VK_STRUCTURE_TYPE_PRIVATE_DATA_SLOT_CREATE_INFO_EXT: c_int = 1000295002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PIPELINE_CREATION_CACHE_CONTROL_FEATURES_EXT: c_int = 1000297000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DIAGNOSTICS_CONFIG_FEATURES_NV: c_int = 1000300000;
pub const VK_STRUCTURE_TYPE_DEVICE_DIAGNOSTICS_CONFIG_CREATE_INFO_NV: c_int = 1000300001;
pub const VK_STRUCTURE_TYPE_MEMORY_BARRIER_2_KHR: c_int = 1000314000;
pub const VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER_2_KHR: c_int = 1000314001;
pub const VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER_2_KHR: c_int = 1000314002;
pub const VK_STRUCTURE_TYPE_DEPENDENCY_INFO_KHR: c_int = 1000314003;
pub const VK_STRUCTURE_TYPE_SUBMIT_INFO_2_KHR: c_int = 1000314004;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_SUBMIT_INFO_KHR: c_int = 1000314005;
pub const VK_STRUCTURE_TYPE_COMMAND_BUFFER_SUBMIT_INFO_KHR: c_int = 1000314006;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SYNCHRONIZATION_2_FEATURES_KHR: c_int = 1000314007;
pub const VK_STRUCTURE_TYPE_QUEUE_FAMILY_CHECKPOINT_PROPERTIES_2_NV: c_int = 1000314008;
pub const VK_STRUCTURE_TYPE_CHECKPOINT_DATA_2_NV: c_int = 1000314009;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SUBGROUP_UNIFORM_CONTROL_FLOW_FEATURES_KHR: c_int = 1000323000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ZERO_INITIALIZE_WORKGROUP_MEMORY_FEATURES_KHR: c_int = 1000325000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_ENUMS_PROPERTIES_NV: c_int = 1000326000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_SHADING_RATE_ENUMS_FEATURES_NV: c_int = 1000326001;
pub const VK_STRUCTURE_TYPE_PIPELINE_FRAGMENT_SHADING_RATE_ENUM_STATE_CREATE_INFO_NV: c_int = 1000326002;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_GEOMETRY_MOTION_TRIANGLES_DATA_NV: c_int = 1000327000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RAY_TRACING_MOTION_BLUR_FEATURES_NV: c_int = 1000327001;
pub const VK_STRUCTURE_TYPE_ACCELERATION_STRUCTURE_MOTION_INFO_NV: c_int = 1000327002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_YCBCR_2_PLANE_444_FORMATS_FEATURES_EXT: c_int = 1000330000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_2_FEATURES_EXT: c_int = 1000332000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_2_PROPERTIES_EXT: c_int = 1000332001;
pub const VK_STRUCTURE_TYPE_COPY_COMMAND_TRANSFORM_INFO_QCOM: c_int = 1000333000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_ROBUSTNESS_FEATURES_EXT: c_int = 1000335000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_WORKGROUP_MEMORY_EXPLICIT_LAYOUT_FEATURES_KHR: c_int = 1000336000;
pub const VK_STRUCTURE_TYPE_COPY_BUFFER_INFO_2_KHR: c_int = 1000337000;
pub const VK_STRUCTURE_TYPE_COPY_IMAGE_INFO_2_KHR: c_int = 1000337001;
pub const VK_STRUCTURE_TYPE_COPY_BUFFER_TO_IMAGE_INFO_2_KHR: c_int = 1000337002;
pub const VK_STRUCTURE_TYPE_COPY_IMAGE_TO_BUFFER_INFO_2_KHR: c_int = 1000337003;
pub const VK_STRUCTURE_TYPE_BLIT_IMAGE_INFO_2_KHR: c_int = 1000337004;
pub const VK_STRUCTURE_TYPE_RESOLVE_IMAGE_INFO_2_KHR: c_int = 1000337005;
pub const VK_STRUCTURE_TYPE_BUFFER_COPY_2_KHR: c_int = 1000337006;
pub const VK_STRUCTURE_TYPE_IMAGE_COPY_2_KHR: c_int = 1000337007;
pub const VK_STRUCTURE_TYPE_IMAGE_BLIT_2_KHR: c_int = 1000337008;
pub const VK_STRUCTURE_TYPE_BUFFER_IMAGE_COPY_2_KHR: c_int = 1000337009;
pub const VK_STRUCTURE_TYPE_IMAGE_RESOLVE_2_KHR: c_int = 1000337010;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_4444_FORMATS_FEATURES_EXT: c_int = 1000340000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RASTERIZATION_ORDER_ATTACHMENT_ACCESS_FEATURES_ARM: c_int = 1000342000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_RGBA10X6_FORMATS_FEATURES_EXT: c_int = 1000344000;
pub const VK_STRUCTURE_TYPE_DIRECTFB_SURFACE_CREATE_INFO_EXT: c_int = 1000346000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MUTABLE_DESCRIPTOR_TYPE_FEATURES_VALVE: c_int = 1000351000;
pub const VK_STRUCTURE_TYPE_MUTABLE_DESCRIPTOR_TYPE_CREATE_INFO_VALVE: c_int = 1000351002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VERTEX_INPUT_DYNAMIC_STATE_FEATURES_EXT: c_int = 1000352000;
pub const VK_STRUCTURE_TYPE_VERTEX_INPUT_BINDING_DESCRIPTION_2_EXT: c_int = 1000352001;
pub const VK_STRUCTURE_TYPE_VERTEX_INPUT_ATTRIBUTE_DESCRIPTION_2_EXT: c_int = 1000352002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRM_PROPERTIES_EXT: c_int = 1000353000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_CLIP_CONTROL_FEATURES_EXT: c_int = 1000355000;
pub const VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_DEPTH_CLIP_CONTROL_CREATE_INFO_EXT: c_int = 1000355001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PRIMITIVE_TOPOLOGY_LIST_RESTART_FEATURES_EXT: c_int = 1000356000;
pub const VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_3_KHR: c_int = 1000360000;
pub const VK_STRUCTURE_TYPE_IMPORT_MEMORY_ZIRCON_HANDLE_INFO_FUCHSIA: c_int = 1000364000;
pub const VK_STRUCTURE_TYPE_MEMORY_ZIRCON_HANDLE_PROPERTIES_FUCHSIA: c_int = 1000364001;
pub const VK_STRUCTURE_TYPE_MEMORY_GET_ZIRCON_HANDLE_INFO_FUCHSIA: c_int = 1000364002;
pub const VK_STRUCTURE_TYPE_IMPORT_SEMAPHORE_ZIRCON_HANDLE_INFO_FUCHSIA: c_int = 1000365000;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_GET_ZIRCON_HANDLE_INFO_FUCHSIA: c_int = 1000365001;
pub const VK_STRUCTURE_TYPE_BUFFER_COLLECTION_CREATE_INFO_FUCHSIA: c_int = 1000366000;
pub const VK_STRUCTURE_TYPE_IMPORT_MEMORY_BUFFER_COLLECTION_FUCHSIA: c_int = 1000366001;
pub const VK_STRUCTURE_TYPE_BUFFER_COLLECTION_IMAGE_CREATE_INFO_FUCHSIA: c_int = 1000366002;
pub const VK_STRUCTURE_TYPE_BUFFER_COLLECTION_PROPERTIES_FUCHSIA: c_int = 1000366003;
pub const VK_STRUCTURE_TYPE_BUFFER_CONSTRAINTS_INFO_FUCHSIA: c_int = 1000366004;
pub const VK_STRUCTURE_TYPE_BUFFER_COLLECTION_BUFFER_CREATE_INFO_FUCHSIA: c_int = 1000366005;
pub const VK_STRUCTURE_TYPE_IMAGE_CONSTRAINTS_INFO_FUCHSIA: c_int = 1000366006;
pub const VK_STRUCTURE_TYPE_IMAGE_FORMAT_CONSTRAINTS_INFO_FUCHSIA: c_int = 1000366007;
pub const VK_STRUCTURE_TYPE_SYSMEM_COLOR_SPACE_FUCHSIA: c_int = 1000366008;
pub const VK_STRUCTURE_TYPE_BUFFER_COLLECTION_CONSTRAINTS_INFO_FUCHSIA: c_int = 1000366009;
pub const VK_STRUCTURE_TYPE_SUBPASS_SHADING_PIPELINE_CREATE_INFO_HUAWEI: c_int = 1000369000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBPASS_SHADING_FEATURES_HUAWEI: c_int = 1000369001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SUBPASS_SHADING_PROPERTIES_HUAWEI: c_int = 1000369002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_INVOCATION_MASK_FEATURES_HUAWEI: c_int = 1000370000;
pub const VK_STRUCTURE_TYPE_MEMORY_GET_REMOTE_ADDRESS_INFO_NV: c_int = 1000371000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_MEMORY_RDMA_FEATURES_NV: c_int = 1000371001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTENDED_DYNAMIC_STATE_2_FEATURES_EXT: c_int = 1000377000;
pub const VK_STRUCTURE_TYPE_SCREEN_SURFACE_CREATE_INFO_QNX: c_int = 1000378000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_COLOR_WRITE_ENABLE_FEATURES_EXT: c_int = 1000381000;
pub const VK_STRUCTURE_TYPE_PIPELINE_COLOR_WRITE_CREATE_INFO_EXT: c_int = 1000381001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_GLOBAL_PRIORITY_QUERY_FEATURES_EXT: c_int = 1000388000;
pub const VK_STRUCTURE_TYPE_QUEUE_FAMILY_GLOBAL_PRIORITY_PROPERTIES_EXT: c_int = 1000388001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_VIEW_MIN_LOD_FEATURES_EXT: c_int = 1000391000;
pub const VK_STRUCTURE_TYPE_IMAGE_VIEW_MIN_LOD_CREATE_INFO_EXT: c_int = 1000391001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTI_DRAW_FEATURES_EXT: c_int = 1000392000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTI_DRAW_PROPERTIES_EXT: c_int = 1000392001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BORDER_COLOR_SWIZZLE_FEATURES_EXT: c_int = 1000411000;
pub const VK_STRUCTURE_TYPE_SAMPLER_BORDER_COLOR_COMPONENT_MAPPING_CREATE_INFO_EXT: c_int = 1000411001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PAGEABLE_DEVICE_LOCAL_MEMORY_FEATURES_EXT: c_int = 1000412000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MAINTENANCE_4_FEATURES_KHR: c_int = 1000413000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MAINTENANCE_4_PROPERTIES_KHR: c_int = 1000413001;
pub const VK_STRUCTURE_TYPE_DEVICE_BUFFER_MEMORY_REQUIREMENTS_KHR: c_int = 1000413002;
pub const VK_STRUCTURE_TYPE_DEVICE_IMAGE_MEMORY_REQUIREMENTS_KHR: c_int = 1000413003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_OFFSET_FEATURES_QCOM: c_int = 1000425000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FRAGMENT_DENSITY_MAP_OFFSET_PROPERTIES_QCOM: c_int = 1000425001;
pub const VK_STRUCTURE_TYPE_SUBPASS_FRAGMENT_DENSITY_MAP_OFFSET_END_INFO_QCOM: c_int = 1000425002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_LINEAR_COLOR_ATTACHMENT_FEATURES_NV: c_int = 1000430000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VARIABLE_POINTER_FEATURES: c_int = 1000120000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_DRAW_PARAMETER_FEATURES: c_int = 1000063000;
pub const VK_STRUCTURE_TYPE_DEBUG_REPORT_CREATE_INFO_EXT: c_int = 1000011000;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_SAMPLE_COUNT_INFO_NV: c_int = 1000044008;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_MULTIVIEW_CREATE_INFO_KHR: c_int = 1000053000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_FEATURES_KHR: c_int = 1000053001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MULTIVIEW_PROPERTIES_KHR: c_int = 1000053002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FEATURES_2_KHR: c_int = 1000059000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_PROPERTIES_2_KHR: c_int = 1000059001;
pub const VK_STRUCTURE_TYPE_FORMAT_PROPERTIES_2_KHR: c_int = 1000059002;
pub const VK_STRUCTURE_TYPE_IMAGE_FORMAT_PROPERTIES_2_KHR: c_int = 1000059003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGE_FORMAT_INFO_2_KHR: c_int = 1000059004;
pub const VK_STRUCTURE_TYPE_QUEUE_FAMILY_PROPERTIES_2_KHR: c_int = 1000059005;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MEMORY_PROPERTIES_2_KHR: c_int = 1000059006;
pub const VK_STRUCTURE_TYPE_SPARSE_IMAGE_FORMAT_PROPERTIES_2_KHR: c_int = 1000059007;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SPARSE_IMAGE_FORMAT_INFO_2_KHR: c_int = 1000059008;
pub const VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_FLAGS_INFO_KHR: c_int = 1000060000;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_RENDER_PASS_BEGIN_INFO_KHR: c_int = 1000060003;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_COMMAND_BUFFER_BEGIN_INFO_KHR: c_int = 1000060004;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_SUBMIT_INFO_KHR: c_int = 1000060005;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_BIND_SPARSE_INFO_KHR: c_int = 1000060006;
pub const VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_DEVICE_GROUP_INFO_KHR: c_int = 1000060013;
pub const VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_DEVICE_GROUP_INFO_KHR: c_int = 1000060014;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_GROUP_PROPERTIES_KHR: c_int = 1000070000;
pub const VK_STRUCTURE_TYPE_DEVICE_GROUP_DEVICE_CREATE_INFO_KHR: c_int = 1000070001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_IMAGE_FORMAT_INFO_KHR: c_int = 1000071000;
pub const VK_STRUCTURE_TYPE_EXTERNAL_IMAGE_FORMAT_PROPERTIES_KHR: c_int = 1000071001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_BUFFER_INFO_KHR: c_int = 1000071002;
pub const VK_STRUCTURE_TYPE_EXTERNAL_BUFFER_PROPERTIES_KHR: c_int = 1000071003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_ID_PROPERTIES_KHR: c_int = 1000071004;
pub const VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_BUFFER_CREATE_INFO_KHR: c_int = 1000072000;
pub const VK_STRUCTURE_TYPE_EXTERNAL_MEMORY_IMAGE_CREATE_INFO_KHR: c_int = 1000072001;
pub const VK_STRUCTURE_TYPE_EXPORT_MEMORY_ALLOCATE_INFO_KHR: c_int = 1000072002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_SEMAPHORE_INFO_KHR: c_int = 1000076000;
pub const VK_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_PROPERTIES_KHR: c_int = 1000076001;
pub const VK_STRUCTURE_TYPE_EXPORT_SEMAPHORE_CREATE_INFO_KHR: c_int = 1000077000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_FLOAT16_INT8_FEATURES_KHR: c_int = 1000082000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FLOAT16_INT8_FEATURES_KHR: c_int = 1000082000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_16BIT_STORAGE_FEATURES_KHR: c_int = 1000083000;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_CREATE_INFO_KHR: c_int = 1000085000;
pub const VK_STRUCTURE_TYPE_SURFACE_CAPABILITIES2_EXT: c_int = 1000090000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_IMAGELESS_FRAMEBUFFER_FEATURES_KHR: c_int = 1000108000;
pub const VK_STRUCTURE_TYPE_FRAMEBUFFER_ATTACHMENTS_CREATE_INFO_KHR: c_int = 1000108001;
pub const VK_STRUCTURE_TYPE_FRAMEBUFFER_ATTACHMENT_IMAGE_INFO_KHR: c_int = 1000108002;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_ATTACHMENT_BEGIN_INFO_KHR: c_int = 1000108003;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_2_KHR: c_int = 1000109000;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_2_KHR: c_int = 1000109001;
pub const VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_2_KHR: c_int = 1000109002;
pub const VK_STRUCTURE_TYPE_SUBPASS_DEPENDENCY_2_KHR: c_int = 1000109003;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO_2_KHR: c_int = 1000109004;
pub const VK_STRUCTURE_TYPE_SUBPASS_BEGIN_INFO_KHR: c_int = 1000109005;
pub const VK_STRUCTURE_TYPE_SUBPASS_END_INFO_KHR: c_int = 1000109006;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_EXTERNAL_FENCE_INFO_KHR: c_int = 1000112000;
pub const VK_STRUCTURE_TYPE_EXTERNAL_FENCE_PROPERTIES_KHR: c_int = 1000112001;
pub const VK_STRUCTURE_TYPE_EXPORT_FENCE_CREATE_INFO_KHR: c_int = 1000113000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_POINT_CLIPPING_PROPERTIES_KHR: c_int = 1000117000;
pub const VK_STRUCTURE_TYPE_RENDER_PASS_INPUT_ATTACHMENT_ASPECT_CREATE_INFO_KHR: c_int = 1000117001;
pub const VK_STRUCTURE_TYPE_IMAGE_VIEW_USAGE_CREATE_INFO_KHR: c_int = 1000117002;
pub const VK_STRUCTURE_TYPE_PIPELINE_TESSELLATION_DOMAIN_ORIGIN_STATE_CREATE_INFO_KHR: c_int = 1000117003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VARIABLE_POINTERS_FEATURES_KHR: c_int = 1000120000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VARIABLE_POINTER_FEATURES_KHR: c_int = 1000120000;
pub const VK_STRUCTURE_TYPE_MEMORY_DEDICATED_REQUIREMENTS_KHR: c_int = 1000127000;
pub const VK_STRUCTURE_TYPE_MEMORY_DEDICATED_ALLOCATE_INFO_KHR: c_int = 1000127001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLER_FILTER_MINMAX_PROPERTIES_EXT: c_int = 1000130000;
pub const VK_STRUCTURE_TYPE_SAMPLER_REDUCTION_MODE_CREATE_INFO_EXT: c_int = 1000130001;
pub const VK_STRUCTURE_TYPE_BUFFER_MEMORY_REQUIREMENTS_INFO_2_KHR: c_int = 1000146000;
pub const VK_STRUCTURE_TYPE_IMAGE_MEMORY_REQUIREMENTS_INFO_2_KHR: c_int = 1000146001;
pub const VK_STRUCTURE_TYPE_IMAGE_SPARSE_MEMORY_REQUIREMENTS_INFO_2_KHR: c_int = 1000146002;
pub const VK_STRUCTURE_TYPE_MEMORY_REQUIREMENTS_2_KHR: c_int = 1000146003;
pub const VK_STRUCTURE_TYPE_SPARSE_IMAGE_MEMORY_REQUIREMENTS_2_KHR: c_int = 1000146004;
pub const VK_STRUCTURE_TYPE_IMAGE_FORMAT_LIST_CREATE_INFO_KHR: c_int = 1000147000;
pub const VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_CREATE_INFO_KHR: c_int = 1000156000;
pub const VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_INFO_KHR: c_int = 1000156001;
pub const VK_STRUCTURE_TYPE_BIND_IMAGE_PLANE_MEMORY_INFO_KHR: c_int = 1000156002;
pub const VK_STRUCTURE_TYPE_IMAGE_PLANE_MEMORY_REQUIREMENTS_INFO_KHR: c_int = 1000156003;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SAMPLER_YCBCR_CONVERSION_FEATURES_KHR: c_int = 1000156004;
pub const VK_STRUCTURE_TYPE_SAMPLER_YCBCR_CONVERSION_IMAGE_FORMAT_PROPERTIES_KHR: c_int = 1000156005;
pub const VK_STRUCTURE_TYPE_BIND_BUFFER_MEMORY_INFO_KHR: c_int = 1000157000;
pub const VK_STRUCTURE_TYPE_BIND_IMAGE_MEMORY_INFO_KHR: c_int = 1000157001;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_BINDING_FLAGS_CREATE_INFO_EXT: c_int = 1000161000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_FEATURES_EXT: c_int = 1000161001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DESCRIPTOR_INDEXING_PROPERTIES_EXT: c_int = 1000161002;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_ALLOCATE_INFO_EXT: c_int = 1000161003;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_VARIABLE_DESCRIPTOR_COUNT_LAYOUT_SUPPORT_EXT: c_int = 1000161004;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_MAINTENANCE_3_PROPERTIES_KHR: c_int = 1000168000;
pub const VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_SUPPORT_KHR: c_int = 1000168001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_SUBGROUP_EXTENDED_TYPES_FEATURES_KHR: c_int = 1000175000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_8BIT_STORAGE_FEATURES_KHR: c_int = 1000177000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SHADER_ATOMIC_INT64_FEATURES_KHR: c_int = 1000180000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DRIVER_PROPERTIES_KHR: c_int = 1000196000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_FLOAT_CONTROLS_PROPERTIES_KHR: c_int = 1000197000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_DEPTH_STENCIL_RESOLVE_PROPERTIES_KHR: c_int = 1000199000;
pub const VK_STRUCTURE_TYPE_SUBPASS_DESCRIPTION_DEPTH_STENCIL_RESOLVE_KHR: c_int = 1000199001;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_FEATURES_KHR: c_int = 1000207000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_TIMELINE_SEMAPHORE_PROPERTIES_KHR: c_int = 1000207001;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_TYPE_CREATE_INFO_KHR: c_int = 1000207002;
pub const VK_STRUCTURE_TYPE_TIMELINE_SEMAPHORE_SUBMIT_INFO_KHR: c_int = 1000207003;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_WAIT_INFO_KHR: c_int = 1000207004;
pub const VK_STRUCTURE_TYPE_SEMAPHORE_SIGNAL_INFO_KHR: c_int = 1000207005;
pub const VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO_INTEL: c_int = 1000210000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_VULKAN_MEMORY_MODEL_FEATURES_KHR: c_int = 1000211000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SCALAR_BLOCK_LAYOUT_FEATURES_EXT: c_int = 1000221000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_SEPARATE_DEPTH_STENCIL_LAYOUTS_FEATURES_KHR: c_int = 1000241000;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_REFERENCE_STENCIL_LAYOUT_KHR: c_int = 1000241001;
pub const VK_STRUCTURE_TYPE_ATTACHMENT_DESCRIPTION_STENCIL_LAYOUT_KHR: c_int = 1000241002;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_ADDRESS_FEATURES_EXT: c_int = 1000244000;
pub const VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO_EXT: c_int = 1000244001;
pub const VK_STRUCTURE_TYPE_IMAGE_STENCIL_USAGE_CREATE_INFO_EXT: c_int = 1000246000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_UNIFORM_BUFFER_STANDARD_LAYOUT_FEATURES_KHR: c_int = 1000253000;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_BUFFER_DEVICE_ADDRESS_FEATURES_KHR: c_int = 1000257000;
pub const VK_STRUCTURE_TYPE_BUFFER_DEVICE_ADDRESS_INFO_KHR: c_int = 1000244001;
pub const VK_STRUCTURE_TYPE_BUFFER_OPAQUE_CAPTURE_ADDRESS_CREATE_INFO_KHR: c_int = 1000257002;
pub const VK_STRUCTURE_TYPE_MEMORY_OPAQUE_CAPTURE_ADDRESS_ALLOCATE_INFO_KHR: c_int = 1000257003;
pub const VK_STRUCTURE_TYPE_DEVICE_MEMORY_OPAQUE_CAPTURE_ADDRESS_INFO_KHR: c_int = 1000257004;
pub const VK_STRUCTURE_TYPE_PHYSICAL_DEVICE_HOST_QUERY_RESET_FEATURES_EXT: c_int = 1000261000;
pub const VK_STRUCTURE_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkStructureType = c_uint;
pub const VkStructureType = enum_VkStructureType;
pub const VK_IMAGE_LAYOUT_UNDEFINED: c_int = 0;
pub const VK_IMAGE_LAYOUT_GENERAL: c_int = 1;
pub const VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL: c_int = 2;
pub const VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL: c_int = 3;
pub const VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL: c_int = 4;
pub const VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL: c_int = 5;
pub const VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL: c_int = 6;
pub const VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL: c_int = 7;
pub const VK_IMAGE_LAYOUT_PREINITIALIZED: c_int = 8;
pub const VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL: c_int = 1000117000;
pub const VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL: c_int = 1000117001;
pub const VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL: c_int = 1000241000;
pub const VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL: c_int = 1000241001;
pub const VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL: c_int = 1000241002;
pub const VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL: c_int = 1000241003;
pub const VK_IMAGE_LAYOUT_PRESENT_SRC_KHR: c_int = 1000001002;
pub const VK_IMAGE_LAYOUT_SHARED_PRESENT_KHR: c_int = 1000111000;
pub const VK_IMAGE_LAYOUT_FRAGMENT_DENSITY_MAP_OPTIMAL_EXT: c_int = 1000218000;
pub const VK_IMAGE_LAYOUT_FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL_KHR: c_int = 1000164003;
pub const VK_IMAGE_LAYOUT_READ_ONLY_OPTIMAL_KHR: c_int = 1000314000;
pub const VK_IMAGE_LAYOUT_ATTACHMENT_OPTIMAL_KHR: c_int = 1000314001;
pub const VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL_KHR: c_int = 1000117000;
pub const VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL_KHR: c_int = 1000117001;
pub const VK_IMAGE_LAYOUT_SHADING_RATE_OPTIMAL_NV: c_int = 1000164003;
pub const VK_IMAGE_LAYOUT_DEPTH_ATTACHMENT_OPTIMAL_KHR: c_int = 1000241000;
pub const VK_IMAGE_LAYOUT_DEPTH_READ_ONLY_OPTIMAL_KHR: c_int = 1000241001;
pub const VK_IMAGE_LAYOUT_STENCIL_ATTACHMENT_OPTIMAL_KHR: c_int = 1000241002;
pub const VK_IMAGE_LAYOUT_STENCIL_READ_ONLY_OPTIMAL_KHR: c_int = 1000241003;
pub const VK_IMAGE_LAYOUT_MAX_ENUM: c_int = 2147483647;
pub const enum_VkImageLayout = c_uint;
pub const VkImageLayout = enum_VkImageLayout;
pub const VK_OBJECT_TYPE_UNKNOWN: c_int = 0;
pub const VK_OBJECT_TYPE_INSTANCE: c_int = 1;
pub const VK_OBJECT_TYPE_PHYSICAL_DEVICE: c_int = 2;
pub const VK_OBJECT_TYPE_DEVICE: c_int = 3;
pub const VK_OBJECT_TYPE_QUEUE: c_int = 4;
pub const VK_OBJECT_TYPE_SEMAPHORE: c_int = 5;
pub const VK_OBJECT_TYPE_COMMAND_BUFFER: c_int = 6;
pub const VK_OBJECT_TYPE_FENCE: c_int = 7;
pub const VK_OBJECT_TYPE_DEVICE_MEMORY: c_int = 8;
pub const VK_OBJECT_TYPE_BUFFER: c_int = 9;
pub const VK_OBJECT_TYPE_IMAGE: c_int = 10;
pub const VK_OBJECT_TYPE_EVENT: c_int = 11;
pub const VK_OBJECT_TYPE_QUERY_POOL: c_int = 12;
pub const VK_OBJECT_TYPE_BUFFER_VIEW: c_int = 13;
pub const VK_OBJECT_TYPE_IMAGE_VIEW: c_int = 14;
pub const VK_OBJECT_TYPE_SHADER_MODULE: c_int = 15;
pub const VK_OBJECT_TYPE_PIPELINE_CACHE: c_int = 16;
pub const VK_OBJECT_TYPE_PIPELINE_LAYOUT: c_int = 17;
pub const VK_OBJECT_TYPE_RENDER_PASS: c_int = 18;
pub const VK_OBJECT_TYPE_PIPELINE: c_int = 19;
pub const VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT: c_int = 20;
pub const VK_OBJECT_TYPE_SAMPLER: c_int = 21;
pub const VK_OBJECT_TYPE_DESCRIPTOR_POOL: c_int = 22;
pub const VK_OBJECT_TYPE_DESCRIPTOR_SET: c_int = 23;
pub const VK_OBJECT_TYPE_FRAMEBUFFER: c_int = 24;
pub const VK_OBJECT_TYPE_COMMAND_POOL: c_int = 25;
pub const VK_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION: c_int = 1000156000;
pub const VK_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE: c_int = 1000085000;
pub const VK_OBJECT_TYPE_SURFACE_KHR: c_int = 1000000000;
pub const VK_OBJECT_TYPE_SWAPCHAIN_KHR: c_int = 1000001000;
pub const VK_OBJECT_TYPE_DISPLAY_KHR: c_int = 1000002000;
pub const VK_OBJECT_TYPE_DISPLAY_MODE_KHR: c_int = 1000002001;
pub const VK_OBJECT_TYPE_DEBUG_REPORT_CALLBACK_EXT: c_int = 1000011000;
pub const VK_OBJECT_TYPE_CU_MODULE_NVX: c_int = 1000029000;
pub const VK_OBJECT_TYPE_CU_FUNCTION_NVX: c_int = 1000029001;
pub const VK_OBJECT_TYPE_DEBUG_UTILS_MESSENGER_EXT: c_int = 1000128000;
pub const VK_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR: c_int = 1000150000;
pub const VK_OBJECT_TYPE_VALIDATION_CACHE_EXT: c_int = 1000160000;
pub const VK_OBJECT_TYPE_ACCELERATION_STRUCTURE_NV: c_int = 1000165000;
pub const VK_OBJECT_TYPE_PERFORMANCE_CONFIGURATION_INTEL: c_int = 1000210000;
pub const VK_OBJECT_TYPE_DEFERRED_OPERATION_KHR: c_int = 1000268000;
pub const VK_OBJECT_TYPE_INDIRECT_COMMANDS_LAYOUT_NV: c_int = 1000277000;
pub const VK_OBJECT_TYPE_PRIVATE_DATA_SLOT_EXT: c_int = 1000295000;
pub const VK_OBJECT_TYPE_BUFFER_COLLECTION_FUCHSIA: c_int = 1000366000;
pub const VK_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_KHR: c_int = 1000085000;
pub const VK_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION_KHR: c_int = 1000156000;
pub const VK_OBJECT_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkObjectType = c_uint;
pub const VkObjectType = enum_VkObjectType;
pub const VK_PIPELINE_CACHE_HEADER_VERSION_ONE: c_int = 1;
pub const VK_PIPELINE_CACHE_HEADER_VERSION_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPipelineCacheHeaderVersion = c_uint;
pub const VkPipelineCacheHeaderVersion = enum_VkPipelineCacheHeaderVersion;
pub const VK_VENDOR_ID_VIV: c_int = 65537;
pub const VK_VENDOR_ID_VSI: c_int = 65538;
pub const VK_VENDOR_ID_KAZAN: c_int = 65539;
pub const VK_VENDOR_ID_CODEPLAY: c_int = 65540;
pub const VK_VENDOR_ID_MESA: c_int = 65541;
pub const VK_VENDOR_ID_POCL: c_int = 65542;
pub const VK_VENDOR_ID_MAX_ENUM: c_int = 2147483647;
pub const enum_VkVendorId = c_uint;
pub const VkVendorId = enum_VkVendorId;
pub const VK_SYSTEM_ALLOCATION_SCOPE_COMMAND: c_int = 0;
pub const VK_SYSTEM_ALLOCATION_SCOPE_OBJECT: c_int = 1;
pub const VK_SYSTEM_ALLOCATION_SCOPE_CACHE: c_int = 2;
pub const VK_SYSTEM_ALLOCATION_SCOPE_DEVICE: c_int = 3;
pub const VK_SYSTEM_ALLOCATION_SCOPE_INSTANCE: c_int = 4;
pub const VK_SYSTEM_ALLOCATION_SCOPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSystemAllocationScope = c_uint;
pub const VkSystemAllocationScope = enum_VkSystemAllocationScope;
pub const VK_INTERNAL_ALLOCATION_TYPE_EXECUTABLE: c_int = 0;
pub const VK_INTERNAL_ALLOCATION_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkInternalAllocationType = c_uint;
pub const VkInternalAllocationType = enum_VkInternalAllocationType;
pub const VK_FORMAT_UNDEFINED: c_int = 0;
pub const VK_FORMAT_R4G4_UNORM_PACK8: c_int = 1;
pub const VK_FORMAT_R4G4B4A4_UNORM_PACK16: c_int = 2;
pub const VK_FORMAT_B4G4R4A4_UNORM_PACK16: c_int = 3;
pub const VK_FORMAT_R5G6B5_UNORM_PACK16: c_int = 4;
pub const VK_FORMAT_B5G6R5_UNORM_PACK16: c_int = 5;
pub const VK_FORMAT_R5G5B5A1_UNORM_PACK16: c_int = 6;
pub const VK_FORMAT_B5G5R5A1_UNORM_PACK16: c_int = 7;
pub const VK_FORMAT_A1R5G5B5_UNORM_PACK16: c_int = 8;
pub const VK_FORMAT_R8_UNORM: c_int = 9;
pub const VK_FORMAT_R8_SNORM: c_int = 10;
pub const VK_FORMAT_R8_USCALED: c_int = 11;
pub const VK_FORMAT_R8_SSCALED: c_int = 12;
pub const VK_FORMAT_R8_UINT: c_int = 13;
pub const VK_FORMAT_R8_SINT: c_int = 14;
pub const VK_FORMAT_R8_SRGB: c_int = 15;
pub const VK_FORMAT_R8G8_UNORM: c_int = 16;
pub const VK_FORMAT_R8G8_SNORM: c_int = 17;
pub const VK_FORMAT_R8G8_USCALED: c_int = 18;
pub const VK_FORMAT_R8G8_SSCALED: c_int = 19;
pub const VK_FORMAT_R8G8_UINT: c_int = 20;
pub const VK_FORMAT_R8G8_SINT: c_int = 21;
pub const VK_FORMAT_R8G8_SRGB: c_int = 22;
pub const VK_FORMAT_R8G8B8_UNORM: c_int = 23;
pub const VK_FORMAT_R8G8B8_SNORM: c_int = 24;
pub const VK_FORMAT_R8G8B8_USCALED: c_int = 25;
pub const VK_FORMAT_R8G8B8_SSCALED: c_int = 26;
pub const VK_FORMAT_R8G8B8_UINT: c_int = 27;
pub const VK_FORMAT_R8G8B8_SINT: c_int = 28;
pub const VK_FORMAT_R8G8B8_SRGB: c_int = 29;
pub const VK_FORMAT_B8G8R8_UNORM: c_int = 30;
pub const VK_FORMAT_B8G8R8_SNORM: c_int = 31;
pub const VK_FORMAT_B8G8R8_USCALED: c_int = 32;
pub const VK_FORMAT_B8G8R8_SSCALED: c_int = 33;
pub const VK_FORMAT_B8G8R8_UINT: c_int = 34;
pub const VK_FORMAT_B8G8R8_SINT: c_int = 35;
pub const VK_FORMAT_B8G8R8_SRGB: c_int = 36;
pub const VK_FORMAT_R8G8B8A8_UNORM: c_int = 37;
pub const VK_FORMAT_R8G8B8A8_SNORM: c_int = 38;
pub const VK_FORMAT_R8G8B8A8_USCALED: c_int = 39;
pub const VK_FORMAT_R8G8B8A8_SSCALED: c_int = 40;
pub const VK_FORMAT_R8G8B8A8_UINT: c_int = 41;
pub const VK_FORMAT_R8G8B8A8_SINT: c_int = 42;
pub const VK_FORMAT_R8G8B8A8_SRGB: c_int = 43;
pub const VK_FORMAT_B8G8R8A8_UNORM: c_int = 44;
pub const VK_FORMAT_B8G8R8A8_SNORM: c_int = 45;
pub const VK_FORMAT_B8G8R8A8_USCALED: c_int = 46;
pub const VK_FORMAT_B8G8R8A8_SSCALED: c_int = 47;
pub const VK_FORMAT_B8G8R8A8_UINT: c_int = 48;
pub const VK_FORMAT_B8G8R8A8_SINT: c_int = 49;
pub const VK_FORMAT_B8G8R8A8_SRGB: c_int = 50;
pub const VK_FORMAT_A8B8G8R8_UNORM_PACK32: c_int = 51;
pub const VK_FORMAT_A8B8G8R8_SNORM_PACK32: c_int = 52;
pub const VK_FORMAT_A8B8G8R8_USCALED_PACK32: c_int = 53;
pub const VK_FORMAT_A8B8G8R8_SSCALED_PACK32: c_int = 54;
pub const VK_FORMAT_A8B8G8R8_UINT_PACK32: c_int = 55;
pub const VK_FORMAT_A8B8G8R8_SINT_PACK32: c_int = 56;
pub const VK_FORMAT_A8B8G8R8_SRGB_PACK32: c_int = 57;
pub const VK_FORMAT_A2R10G10B10_UNORM_PACK32: c_int = 58;
pub const VK_FORMAT_A2R10G10B10_SNORM_PACK32: c_int = 59;
pub const VK_FORMAT_A2R10G10B10_USCALED_PACK32: c_int = 60;
pub const VK_FORMAT_A2R10G10B10_SSCALED_PACK32: c_int = 61;
pub const VK_FORMAT_A2R10G10B10_UINT_PACK32: c_int = 62;
pub const VK_FORMAT_A2R10G10B10_SINT_PACK32: c_int = 63;
pub const VK_FORMAT_A2B10G10R10_UNORM_PACK32: c_int = 64;
pub const VK_FORMAT_A2B10G10R10_SNORM_PACK32: c_int = 65;
pub const VK_FORMAT_A2B10G10R10_USCALED_PACK32: c_int = 66;
pub const VK_FORMAT_A2B10G10R10_SSCALED_PACK32: c_int = 67;
pub const VK_FORMAT_A2B10G10R10_UINT_PACK32: c_int = 68;
pub const VK_FORMAT_A2B10G10R10_SINT_PACK32: c_int = 69;
pub const VK_FORMAT_R16_UNORM: c_int = 70;
pub const VK_FORMAT_R16_SNORM: c_int = 71;
pub const VK_FORMAT_R16_USCALED: c_int = 72;
pub const VK_FORMAT_R16_SSCALED: c_int = 73;
pub const VK_FORMAT_R16_UINT: c_int = 74;
pub const VK_FORMAT_R16_SINT: c_int = 75;
pub const VK_FORMAT_R16_SFLOAT: c_int = 76;
pub const VK_FORMAT_R16G16_UNORM: c_int = 77;
pub const VK_FORMAT_R16G16_SNORM: c_int = 78;
pub const VK_FORMAT_R16G16_USCALED: c_int = 79;
pub const VK_FORMAT_R16G16_SSCALED: c_int = 80;
pub const VK_FORMAT_R16G16_UINT: c_int = 81;
pub const VK_FORMAT_R16G16_SINT: c_int = 82;
pub const VK_FORMAT_R16G16_SFLOAT: c_int = 83;
pub const VK_FORMAT_R16G16B16_UNORM: c_int = 84;
pub const VK_FORMAT_R16G16B16_SNORM: c_int = 85;
pub const VK_FORMAT_R16G16B16_USCALED: c_int = 86;
pub const VK_FORMAT_R16G16B16_SSCALED: c_int = 87;
pub const VK_FORMAT_R16G16B16_UINT: c_int = 88;
pub const VK_FORMAT_R16G16B16_SINT: c_int = 89;
pub const VK_FORMAT_R16G16B16_SFLOAT: c_int = 90;
pub const VK_FORMAT_R16G16B16A16_UNORM: c_int = 91;
pub const VK_FORMAT_R16G16B16A16_SNORM: c_int = 92;
pub const VK_FORMAT_R16G16B16A16_USCALED: c_int = 93;
pub const VK_FORMAT_R16G16B16A16_SSCALED: c_int = 94;
pub const VK_FORMAT_R16G16B16A16_UINT: c_int = 95;
pub const VK_FORMAT_R16G16B16A16_SINT: c_int = 96;
pub const VK_FORMAT_R16G16B16A16_SFLOAT: c_int = 97;
pub const VK_FORMAT_R32_UINT: c_int = 98;
pub const VK_FORMAT_R32_SINT: c_int = 99;
pub const VK_FORMAT_R32_SFLOAT: c_int = 100;
pub const VK_FORMAT_R32G32_UINT: c_int = 101;
pub const VK_FORMAT_R32G32_SINT: c_int = 102;
pub const VK_FORMAT_R32G32_SFLOAT: c_int = 103;
pub const VK_FORMAT_R32G32B32_UINT: c_int = 104;
pub const VK_FORMAT_R32G32B32_SINT: c_int = 105;
pub const VK_FORMAT_R32G32B32_SFLOAT: c_int = 106;
pub const VK_FORMAT_R32G32B32A32_UINT: c_int = 107;
pub const VK_FORMAT_R32G32B32A32_SINT: c_int = 108;
pub const VK_FORMAT_R32G32B32A32_SFLOAT: c_int = 109;
pub const VK_FORMAT_R64_UINT: c_int = 110;
pub const VK_FORMAT_R64_SINT: c_int = 111;
pub const VK_FORMAT_R64_SFLOAT: c_int = 112;
pub const VK_FORMAT_R64G64_UINT: c_int = 113;
pub const VK_FORMAT_R64G64_SINT: c_int = 114;
pub const VK_FORMAT_R64G64_SFLOAT: c_int = 115;
pub const VK_FORMAT_R64G64B64_UINT: c_int = 116;
pub const VK_FORMAT_R64G64B64_SINT: c_int = 117;
pub const VK_FORMAT_R64G64B64_SFLOAT: c_int = 118;
pub const VK_FORMAT_R64G64B64A64_UINT: c_int = 119;
pub const VK_FORMAT_R64G64B64A64_SINT: c_int = 120;
pub const VK_FORMAT_R64G64B64A64_SFLOAT: c_int = 121;
pub const VK_FORMAT_B10G11R11_UFLOAT_PACK32: c_int = 122;
pub const VK_FORMAT_E5B9G9R9_UFLOAT_PACK32: c_int = 123;
pub const VK_FORMAT_D16_UNORM: c_int = 124;
pub const VK_FORMAT_X8_D24_UNORM_PACK32: c_int = 125;
pub const VK_FORMAT_D32_SFLOAT: c_int = 126;
pub const VK_FORMAT_S8_UINT: c_int = 127;
pub const VK_FORMAT_D16_UNORM_S8_UINT: c_int = 128;
pub const VK_FORMAT_D24_UNORM_S8_UINT: c_int = 129;
pub const VK_FORMAT_D32_SFLOAT_S8_UINT: c_int = 130;
pub const VK_FORMAT_BC1_RGB_UNORM_BLOCK: c_int = 131;
pub const VK_FORMAT_BC1_RGB_SRGB_BLOCK: c_int = 132;
pub const VK_FORMAT_BC1_RGBA_UNORM_BLOCK: c_int = 133;
pub const VK_FORMAT_BC1_RGBA_SRGB_BLOCK: c_int = 134;
pub const VK_FORMAT_BC2_UNORM_BLOCK: c_int = 135;
pub const VK_FORMAT_BC2_SRGB_BLOCK: c_int = 136;
pub const VK_FORMAT_BC3_UNORM_BLOCK: c_int = 137;
pub const VK_FORMAT_BC3_SRGB_BLOCK: c_int = 138;
pub const VK_FORMAT_BC4_UNORM_BLOCK: c_int = 139;
pub const VK_FORMAT_BC4_SNORM_BLOCK: c_int = 140;
pub const VK_FORMAT_BC5_UNORM_BLOCK: c_int = 141;
pub const VK_FORMAT_BC5_SNORM_BLOCK: c_int = 142;
pub const VK_FORMAT_BC6H_UFLOAT_BLOCK: c_int = 143;
pub const VK_FORMAT_BC6H_SFLOAT_BLOCK: c_int = 144;
pub const VK_FORMAT_BC7_UNORM_BLOCK: c_int = 145;
pub const VK_FORMAT_BC7_SRGB_BLOCK: c_int = 146;
pub const VK_FORMAT_ETC2_R8G8B8_UNORM_BLOCK: c_int = 147;
pub const VK_FORMAT_ETC2_R8G8B8_SRGB_BLOCK: c_int = 148;
pub const VK_FORMAT_ETC2_R8G8B8A1_UNORM_BLOCK: c_int = 149;
pub const VK_FORMAT_ETC2_R8G8B8A1_SRGB_BLOCK: c_int = 150;
pub const VK_FORMAT_ETC2_R8G8B8A8_UNORM_BLOCK: c_int = 151;
pub const VK_FORMAT_ETC2_R8G8B8A8_SRGB_BLOCK: c_int = 152;
pub const VK_FORMAT_EAC_R11_UNORM_BLOCK: c_int = 153;
pub const VK_FORMAT_EAC_R11_SNORM_BLOCK: c_int = 154;
pub const VK_FORMAT_EAC_R11G11_UNORM_BLOCK: c_int = 155;
pub const VK_FORMAT_EAC_R11G11_SNORM_BLOCK: c_int = 156;
pub const VK_FORMAT_ASTC_4x4_UNORM_BLOCK: c_int = 157;
pub const VK_FORMAT_ASTC_4x4_SRGB_BLOCK: c_int = 158;
pub const VK_FORMAT_ASTC_5x4_UNORM_BLOCK: c_int = 159;
pub const VK_FORMAT_ASTC_5x4_SRGB_BLOCK: c_int = 160;
pub const VK_FORMAT_ASTC_5x5_UNORM_BLOCK: c_int = 161;
pub const VK_FORMAT_ASTC_5x5_SRGB_BLOCK: c_int = 162;
pub const VK_FORMAT_ASTC_6x5_UNORM_BLOCK: c_int = 163;
pub const VK_FORMAT_ASTC_6x5_SRGB_BLOCK: c_int = 164;
pub const VK_FORMAT_ASTC_6x6_UNORM_BLOCK: c_int = 165;
pub const VK_FORMAT_ASTC_6x6_SRGB_BLOCK: c_int = 166;
pub const VK_FORMAT_ASTC_8x5_UNORM_BLOCK: c_int = 167;
pub const VK_FORMAT_ASTC_8x5_SRGB_BLOCK: c_int = 168;
pub const VK_FORMAT_ASTC_8x6_UNORM_BLOCK: c_int = 169;
pub const VK_FORMAT_ASTC_8x6_SRGB_BLOCK: c_int = 170;
pub const VK_FORMAT_ASTC_8x8_UNORM_BLOCK: c_int = 171;
pub const VK_FORMAT_ASTC_8x8_SRGB_BLOCK: c_int = 172;
pub const VK_FORMAT_ASTC_10x5_UNORM_BLOCK: c_int = 173;
pub const VK_FORMAT_ASTC_10x5_SRGB_BLOCK: c_int = 174;
pub const VK_FORMAT_ASTC_10x6_UNORM_BLOCK: c_int = 175;
pub const VK_FORMAT_ASTC_10x6_SRGB_BLOCK: c_int = 176;
pub const VK_FORMAT_ASTC_10x8_UNORM_BLOCK: c_int = 177;
pub const VK_FORMAT_ASTC_10x8_SRGB_BLOCK: c_int = 178;
pub const VK_FORMAT_ASTC_10x10_UNORM_BLOCK: c_int = 179;
pub const VK_FORMAT_ASTC_10x10_SRGB_BLOCK: c_int = 180;
pub const VK_FORMAT_ASTC_12x10_UNORM_BLOCK: c_int = 181;
pub const VK_FORMAT_ASTC_12x10_SRGB_BLOCK: c_int = 182;
pub const VK_FORMAT_ASTC_12x12_UNORM_BLOCK: c_int = 183;
pub const VK_FORMAT_ASTC_12x12_SRGB_BLOCK: c_int = 184;
pub const VK_FORMAT_G8B8G8R8_422_UNORM: c_int = 1000156000;
pub const VK_FORMAT_B8G8R8G8_422_UNORM: c_int = 1000156001;
pub const VK_FORMAT_G8_B8_R8_3PLANE_420_UNORM: c_int = 1000156002;
pub const VK_FORMAT_G8_B8R8_2PLANE_420_UNORM: c_int = 1000156003;
pub const VK_FORMAT_G8_B8_R8_3PLANE_422_UNORM: c_int = 1000156004;
pub const VK_FORMAT_G8_B8R8_2PLANE_422_UNORM: c_int = 1000156005;
pub const VK_FORMAT_G8_B8_R8_3PLANE_444_UNORM: c_int = 1000156006;
pub const VK_FORMAT_R10X6_UNORM_PACK16: c_int = 1000156007;
pub const VK_FORMAT_R10X6G10X6_UNORM_2PACK16: c_int = 1000156008;
pub const VK_FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16: c_int = 1000156009;
pub const VK_FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16: c_int = 1000156010;
pub const VK_FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16: c_int = 1000156011;
pub const VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16: c_int = 1000156012;
pub const VK_FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16: c_int = 1000156013;
pub const VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16: c_int = 1000156014;
pub const VK_FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16: c_int = 1000156015;
pub const VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16: c_int = 1000156016;
pub const VK_FORMAT_R12X4_UNORM_PACK16: c_int = 1000156017;
pub const VK_FORMAT_R12X4G12X4_UNORM_2PACK16: c_int = 1000156018;
pub const VK_FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16: c_int = 1000156019;
pub const VK_FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16: c_int = 1000156020;
pub const VK_FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16: c_int = 1000156021;
pub const VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16: c_int = 1000156022;
pub const VK_FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16: c_int = 1000156023;
pub const VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16: c_int = 1000156024;
pub const VK_FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16: c_int = 1000156025;
pub const VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16: c_int = 1000156026;
pub const VK_FORMAT_G16B16G16R16_422_UNORM: c_int = 1000156027;
pub const VK_FORMAT_B16G16R16G16_422_UNORM: c_int = 1000156028;
pub const VK_FORMAT_G16_B16_R16_3PLANE_420_UNORM: c_int = 1000156029;
pub const VK_FORMAT_G16_B16R16_2PLANE_420_UNORM: c_int = 1000156030;
pub const VK_FORMAT_G16_B16_R16_3PLANE_422_UNORM: c_int = 1000156031;
pub const VK_FORMAT_G16_B16R16_2PLANE_422_UNORM: c_int = 1000156032;
pub const VK_FORMAT_G16_B16_R16_3PLANE_444_UNORM: c_int = 1000156033;
pub const VK_FORMAT_PVRTC1_2BPP_UNORM_BLOCK_IMG: c_int = 1000054000;
pub const VK_FORMAT_PVRTC1_4BPP_UNORM_BLOCK_IMG: c_int = 1000054001;
pub const VK_FORMAT_PVRTC2_2BPP_UNORM_BLOCK_IMG: c_int = 1000054002;
pub const VK_FORMAT_PVRTC2_4BPP_UNORM_BLOCK_IMG: c_int = 1000054003;
pub const VK_FORMAT_PVRTC1_2BPP_SRGB_BLOCK_IMG: c_int = 1000054004;
pub const VK_FORMAT_PVRTC1_4BPP_SRGB_BLOCK_IMG: c_int = 1000054005;
pub const VK_FORMAT_PVRTC2_2BPP_SRGB_BLOCK_IMG: c_int = 1000054006;
pub const VK_FORMAT_PVRTC2_4BPP_SRGB_BLOCK_IMG: c_int = 1000054007;
pub const VK_FORMAT_ASTC_4x4_SFLOAT_BLOCK_EXT: c_int = 1000066000;
pub const VK_FORMAT_ASTC_5x4_SFLOAT_BLOCK_EXT: c_int = 1000066001;
pub const VK_FORMAT_ASTC_5x5_SFLOAT_BLOCK_EXT: c_int = 1000066002;
pub const VK_FORMAT_ASTC_6x5_SFLOAT_BLOCK_EXT: c_int = 1000066003;
pub const VK_FORMAT_ASTC_6x6_SFLOAT_BLOCK_EXT: c_int = 1000066004;
pub const VK_FORMAT_ASTC_8x5_SFLOAT_BLOCK_EXT: c_int = 1000066005;
pub const VK_FORMAT_ASTC_8x6_SFLOAT_BLOCK_EXT: c_int = 1000066006;
pub const VK_FORMAT_ASTC_8x8_SFLOAT_BLOCK_EXT: c_int = 1000066007;
pub const VK_FORMAT_ASTC_10x5_SFLOAT_BLOCK_EXT: c_int = 1000066008;
pub const VK_FORMAT_ASTC_10x6_SFLOAT_BLOCK_EXT: c_int = 1000066009;
pub const VK_FORMAT_ASTC_10x8_SFLOAT_BLOCK_EXT: c_int = 1000066010;
pub const VK_FORMAT_ASTC_10x10_SFLOAT_BLOCK_EXT: c_int = 1000066011;
pub const VK_FORMAT_ASTC_12x10_SFLOAT_BLOCK_EXT: c_int = 1000066012;
pub const VK_FORMAT_ASTC_12x12_SFLOAT_BLOCK_EXT: c_int = 1000066013;
pub const VK_FORMAT_G8_B8R8_2PLANE_444_UNORM_EXT: c_int = 1000330000;
pub const VK_FORMAT_G10X6_B10X6R10X6_2PLANE_444_UNORM_3PACK16_EXT: c_int = 1000330001;
pub const VK_FORMAT_G12X4_B12X4R12X4_2PLANE_444_UNORM_3PACK16_EXT: c_int = 1000330002;
pub const VK_FORMAT_G16_B16R16_2PLANE_444_UNORM_EXT: c_int = 1000330003;
pub const VK_FORMAT_A4R4G4B4_UNORM_PACK16_EXT: c_int = 1000340000;
pub const VK_FORMAT_A4B4G4R4_UNORM_PACK16_EXT: c_int = 1000340001;
pub const VK_FORMAT_G8B8G8R8_422_UNORM_KHR: c_int = 1000156000;
pub const VK_FORMAT_B8G8R8G8_422_UNORM_KHR: c_int = 1000156001;
pub const VK_FORMAT_G8_B8_R8_3PLANE_420_UNORM_KHR: c_int = 1000156002;
pub const VK_FORMAT_G8_B8R8_2PLANE_420_UNORM_KHR: c_int = 1000156003;
pub const VK_FORMAT_G8_B8_R8_3PLANE_422_UNORM_KHR: c_int = 1000156004;
pub const VK_FORMAT_G8_B8R8_2PLANE_422_UNORM_KHR: c_int = 1000156005;
pub const VK_FORMAT_G8_B8_R8_3PLANE_444_UNORM_KHR: c_int = 1000156006;
pub const VK_FORMAT_R10X6_UNORM_PACK16_KHR: c_int = 1000156007;
pub const VK_FORMAT_R10X6G10X6_UNORM_2PACK16_KHR: c_int = 1000156008;
pub const VK_FORMAT_R10X6G10X6B10X6A10X6_UNORM_4PACK16_KHR: c_int = 1000156009;
pub const VK_FORMAT_G10X6B10X6G10X6R10X6_422_UNORM_4PACK16_KHR: c_int = 1000156010;
pub const VK_FORMAT_B10X6G10X6R10X6G10X6_422_UNORM_4PACK16_KHR: c_int = 1000156011;
pub const VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16_KHR: c_int = 1000156012;
pub const VK_FORMAT_G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16_KHR: c_int = 1000156013;
pub const VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16_KHR: c_int = 1000156014;
pub const VK_FORMAT_G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16_KHR: c_int = 1000156015;
pub const VK_FORMAT_G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16_KHR: c_int = 1000156016;
pub const VK_FORMAT_R12X4_UNORM_PACK16_KHR: c_int = 1000156017;
pub const VK_FORMAT_R12X4G12X4_UNORM_2PACK16_KHR: c_int = 1000156018;
pub const VK_FORMAT_R12X4G12X4B12X4A12X4_UNORM_4PACK16_KHR: c_int = 1000156019;
pub const VK_FORMAT_G12X4B12X4G12X4R12X4_422_UNORM_4PACK16_KHR: c_int = 1000156020;
pub const VK_FORMAT_B12X4G12X4R12X4G12X4_422_UNORM_4PACK16_KHR: c_int = 1000156021;
pub const VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16_KHR: c_int = 1000156022;
pub const VK_FORMAT_G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16_KHR: c_int = 1000156023;
pub const VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16_KHR: c_int = 1000156024;
pub const VK_FORMAT_G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16_KHR: c_int = 1000156025;
pub const VK_FORMAT_G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16_KHR: c_int = 1000156026;
pub const VK_FORMAT_G16B16G16R16_422_UNORM_KHR: c_int = 1000156027;
pub const VK_FORMAT_B16G16R16G16_422_UNORM_KHR: c_int = 1000156028;
pub const VK_FORMAT_G16_B16_R16_3PLANE_420_UNORM_KHR: c_int = 1000156029;
pub const VK_FORMAT_G16_B16R16_2PLANE_420_UNORM_KHR: c_int = 1000156030;
pub const VK_FORMAT_G16_B16_R16_3PLANE_422_UNORM_KHR: c_int = 1000156031;
pub const VK_FORMAT_G16_B16R16_2PLANE_422_UNORM_KHR: c_int = 1000156032;
pub const VK_FORMAT_G16_B16_R16_3PLANE_444_UNORM_KHR: c_int = 1000156033;
pub const VK_FORMAT_MAX_ENUM: c_int = 2147483647;
pub const enum_VkFormat = c_uint;
pub const VkFormat = enum_VkFormat;
pub const VK_IMAGE_TILING_OPTIMAL: c_int = 0;
pub const VK_IMAGE_TILING_LINEAR: c_int = 1;
pub const VK_IMAGE_TILING_DRM_FORMAT_MODIFIER_EXT: c_int = 1000158000;
pub const VK_IMAGE_TILING_MAX_ENUM: c_int = 2147483647;
pub const enum_VkImageTiling = c_uint;
pub const VkImageTiling = enum_VkImageTiling;
pub const VK_IMAGE_TYPE_1D: c_int = 0;
pub const VK_IMAGE_TYPE_2D: c_int = 1;
pub const VK_IMAGE_TYPE_3D: c_int = 2;
pub const VK_IMAGE_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkImageType = c_uint;
pub const VkImageType = enum_VkImageType;
pub const VK_PHYSICAL_DEVICE_TYPE_OTHER: c_int = 0;
pub const VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU: c_int = 1;
pub const VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU: c_int = 2;
pub const VK_PHYSICAL_DEVICE_TYPE_VIRTUAL_GPU: c_int = 3;
pub const VK_PHYSICAL_DEVICE_TYPE_CPU: c_int = 4;
pub const VK_PHYSICAL_DEVICE_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_vk.PhysicalDeviceType = c_uint;
pub const vk.PhysicalDeviceType = enum_vk.PhysicalDeviceType;
pub const VK_QUERY_TYPE_OCCLUSION: c_int = 0;
pub const VK_QUERY_TYPE_PIPELINE_STATISTICS: c_int = 1;
pub const VK_QUERY_TYPE_TIMESTAMP: c_int = 2;
pub const VK_QUERY_TYPE_TRANSFORM_FEEDBACK_STREAM_EXT: c_int = 1000028004;
pub const VK_QUERY_TYPE_PERFORMANCE_QUERY_KHR: c_int = 1000116000;
pub const VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_KHR: c_int = 1000150000;
pub const VK_QUERY_TYPE_ACCELERATION_STRUCTURE_SERIALIZATION_SIZE_KHR: c_int = 1000150001;
pub const VK_QUERY_TYPE_ACCELERATION_STRUCTURE_COMPACTED_SIZE_NV: c_int = 1000165000;
pub const VK_QUERY_TYPE_PERFORMANCE_QUERY_INTEL: c_int = 1000210000;
pub const VK_QUERY_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkQueryType = c_uint;
pub const VkQueryType = enum_VkQueryType;
pub const VK_SHARING_MODE_EXCLUSIVE: c_int = 0;
pub const VK_SHARING_MODE_CONCURRENT: c_int = 1;
pub const VK_SHARING_MODE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSharingMode = c_uint;
pub const VkSharingMode = enum_VkSharingMode;
pub const VK_COMPONENT_SWIZZLE_IDENTITY: c_int = 0;
pub const VK_COMPONENT_SWIZZLE_ZERO: c_int = 1;
pub const VK_COMPONENT_SWIZZLE_ONE: c_int = 2;
pub const VK_COMPONENT_SWIZZLE_R: c_int = 3;
pub const VK_COMPONENT_SWIZZLE_G: c_int = 4;
pub const VK_COMPONENT_SWIZZLE_B: c_int = 5;
pub const VK_COMPONENT_SWIZZLE_A: c_int = 6;
pub const VK_COMPONENT_SWIZZLE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkComponentSwizzle = c_uint;
pub const VkComponentSwizzle = enum_VkComponentSwizzle;
pub const VK_IMAGE_VIEW_TYPE_1D: c_int = 0;
pub const VK_IMAGE_VIEW_TYPE_2D: c_int = 1;
pub const VK_IMAGE_VIEW_TYPE_3D: c_int = 2;
pub const VK_IMAGE_VIEW_TYPE_CUBE: c_int = 3;
pub const VK_IMAGE_VIEW_TYPE_1D_ARRAY: c_int = 4;
pub const VK_IMAGE_VIEW_TYPE_2D_ARRAY: c_int = 5;
pub const VK_IMAGE_VIEW_TYPE_CUBE_ARRAY: c_int = 6;
pub const VK_IMAGE_VIEW_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkImageViewType = c_uint;
pub const VkImageViewType = enum_VkImageViewType;
pub const VK_BLEND_FACTOR_ZERO: c_int = 0;
pub const VK_BLEND_FACTOR_ONE: c_int = 1;
pub const VK_BLEND_FACTOR_SRC_COLOR: c_int = 2;
pub const VK_BLEND_FACTOR_ONE_MINUS_SRC_COLOR: c_int = 3;
pub const VK_BLEND_FACTOR_DST_COLOR: c_int = 4;
pub const VK_BLEND_FACTOR_ONE_MINUS_DST_COLOR: c_int = 5;
pub const VK_BLEND_FACTOR_SRC_ALPHA: c_int = 6;
pub const VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA: c_int = 7;
pub const VK_BLEND_FACTOR_DST_ALPHA: c_int = 8;
pub const VK_BLEND_FACTOR_ONE_MINUS_DST_ALPHA: c_int = 9;
pub const VK_BLEND_FACTOR_CONSTANT_COLOR: c_int = 10;
pub const VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_COLOR: c_int = 11;
pub const VK_BLEND_FACTOR_CONSTANT_ALPHA: c_int = 12;
pub const VK_BLEND_FACTOR_ONE_MINUS_CONSTANT_ALPHA: c_int = 13;
pub const VK_BLEND_FACTOR_SRC_ALPHA_SATURATE: c_int = 14;
pub const VK_BLEND_FACTOR_SRC1_COLOR: c_int = 15;
pub const VK_BLEND_FACTOR_ONE_MINUS_SRC1_COLOR: c_int = 16;
pub const VK_BLEND_FACTOR_SRC1_ALPHA: c_int = 17;
pub const VK_BLEND_FACTOR_ONE_MINUS_SRC1_ALPHA: c_int = 18;
pub const VK_BLEND_FACTOR_MAX_ENUM: c_int = 2147483647;
pub const enum_VkBlendFactor = c_uint;
pub const VkBlendFactor = enum_VkBlendFactor;
pub const VK_BLEND_OP_ADD: c_int = 0;
pub const VK_BLEND_OP_SUBTRACT: c_int = 1;
pub const VK_BLEND_OP_REVERSE_SUBTRACT: c_int = 2;
pub const VK_BLEND_OP_MIN: c_int = 3;
pub const VK_BLEND_OP_MAX: c_int = 4;
pub const VK_BLEND_OP_ZERO_EXT: c_int = 1000148000;
pub const VK_BLEND_OP_SRC_EXT: c_int = 1000148001;
pub const VK_BLEND_OP_DST_EXT: c_int = 1000148002;
pub const VK_BLEND_OP_SRC_OVER_EXT: c_int = 1000148003;
pub const VK_BLEND_OP_DST_OVER_EXT: c_int = 1000148004;
pub const VK_BLEND_OP_SRC_IN_EXT: c_int = 1000148005;
pub const VK_BLEND_OP_DST_IN_EXT: c_int = 1000148006;
pub const VK_BLEND_OP_SRC_OUT_EXT: c_int = 1000148007;
pub const VK_BLEND_OP_DST_OUT_EXT: c_int = 1000148008;
pub const VK_BLEND_OP_SRC_ATOP_EXT: c_int = 1000148009;
pub const VK_BLEND_OP_DST_ATOP_EXT: c_int = 1000148010;
pub const VK_BLEND_OP_XOR_EXT: c_int = 1000148011;
pub const VK_BLEND_OP_MULTIPLY_EXT: c_int = 1000148012;
pub const VK_BLEND_OP_SCREEN_EXT: c_int = 1000148013;
pub const VK_BLEND_OP_OVERLAY_EXT: c_int = 1000148014;
pub const VK_BLEND_OP_DARKEN_EXT: c_int = 1000148015;
pub const VK_BLEND_OP_LIGHTEN_EXT: c_int = 1000148016;
pub const VK_BLEND_OP_COLORDODGE_EXT: c_int = 1000148017;
pub const VK_BLEND_OP_COLORBURN_EXT: c_int = 1000148018;
pub const VK_BLEND_OP_HARDLIGHT_EXT: c_int = 1000148019;
pub const VK_BLEND_OP_SOFTLIGHT_EXT: c_int = 1000148020;
pub const VK_BLEND_OP_DIFFERENCE_EXT: c_int = 1000148021;
pub const VK_BLEND_OP_EXCLUSION_EXT: c_int = 1000148022;
pub const VK_BLEND_OP_INVERT_EXT: c_int = 1000148023;
pub const VK_BLEND_OP_INVERT_RGB_EXT: c_int = 1000148024;
pub const VK_BLEND_OP_LINEARDODGE_EXT: c_int = 1000148025;
pub const VK_BLEND_OP_LINEARBURN_EXT: c_int = 1000148026;
pub const VK_BLEND_OP_VIVIDLIGHT_EXT: c_int = 1000148027;
pub const VK_BLEND_OP_LINEARLIGHT_EXT: c_int = 1000148028;
pub const VK_BLEND_OP_PINLIGHT_EXT: c_int = 1000148029;
pub const VK_BLEND_OP_HARDMIX_EXT: c_int = 1000148030;
pub const VK_BLEND_OP_HSL_HUE_EXT: c_int = 1000148031;
pub const VK_BLEND_OP_HSL_SATURATION_EXT: c_int = 1000148032;
pub const VK_BLEND_OP_HSL_COLOR_EXT: c_int = 1000148033;
pub const VK_BLEND_OP_HSL_LUMINOSITY_EXT: c_int = 1000148034;
pub const VK_BLEND_OP_PLUS_EXT: c_int = 1000148035;
pub const VK_BLEND_OP_PLUS_CLAMPED_EXT: c_int = 1000148036;
pub const VK_BLEND_OP_PLUS_CLAMPED_ALPHA_EXT: c_int = 1000148037;
pub const VK_BLEND_OP_PLUS_DARKER_EXT: c_int = 1000148038;
pub const VK_BLEND_OP_MINUS_EXT: c_int = 1000148039;
pub const VK_BLEND_OP_MINUS_CLAMPED_EXT: c_int = 1000148040;
pub const VK_BLEND_OP_CONTRAST_EXT: c_int = 1000148041;
pub const VK_BLEND_OP_INVERT_OVG_EXT: c_int = 1000148042;
pub const VK_BLEND_OP_RED_EXT: c_int = 1000148043;
pub const VK_BLEND_OP_GREEN_EXT: c_int = 1000148044;
pub const VK_BLEND_OP_BLUE_EXT: c_int = 1000148045;
pub const VK_BLEND_OP_MAX_ENUM: c_int = 2147483647;
pub const enum_VkBlendOp = c_uint;
pub const VkBlendOp = enum_VkBlendOp;
pub const VK_COMPARE_OP_NEVER: c_int = 0;
pub const VK_COMPARE_OP_LESS: c_int = 1;
pub const VK_COMPARE_OP_EQUAL: c_int = 2;
pub const VK_COMPARE_OP_LESS_OR_EQUAL: c_int = 3;
pub const VK_COMPARE_OP_GREATER: c_int = 4;
pub const VK_COMPARE_OP_NOT_EQUAL: c_int = 5;
pub const VK_COMPARE_OP_GREATER_OR_EQUAL: c_int = 6;
pub const VK_COMPARE_OP_ALWAYS: c_int = 7;
pub const VK_COMPARE_OP_MAX_ENUM: c_int = 2147483647;
pub const enum_VkCompareOp = c_uint;
pub const VkCompareOp = enum_VkCompareOp;
pub const VK_DYNAMIC_STATE_VIEWPORT: c_int = 0;
pub const VK_DYNAMIC_STATE_SCISSOR: c_int = 1;
pub const VK_DYNAMIC_STATE_LINE_WIDTH: c_int = 2;
pub const VK_DYNAMIC_STATE_DEPTH_BIAS: c_int = 3;
pub const VK_DYNAMIC_STATE_BLEND_CONSTANTS: c_int = 4;
pub const VK_DYNAMIC_STATE_DEPTH_BOUNDS: c_int = 5;
pub const VK_DYNAMIC_STATE_STENCIL_COMPARE_MASK: c_int = 6;
pub const VK_DYNAMIC_STATE_STENCIL_WRITE_MASK: c_int = 7;
pub const VK_DYNAMIC_STATE_STENCIL_REFERENCE: c_int = 8;
pub const VK_DYNAMIC_STATE_VIEWPORT_W_SCALING_NV: c_int = 1000087000;
pub const VK_DYNAMIC_STATE_DISCARD_RECTANGLE_EXT: c_int = 1000099000;
pub const VK_DYNAMIC_STATE_SAMPLE_LOCATIONS_EXT: c_int = 1000143000;
pub const VK_DYNAMIC_STATE_RAY_TRACING_PIPELINE_STACK_SIZE_KHR: c_int = 1000347000;
pub const VK_DYNAMIC_STATE_VIEWPORT_SHADING_RATE_PALETTE_NV: c_int = 1000164004;
pub const VK_DYNAMIC_STATE_VIEWPORT_COARSE_SAMPLE_ORDER_NV: c_int = 1000164006;
pub const VK_DYNAMIC_STATE_EXCLUSIVE_SCISSOR_NV: c_int = 1000205001;
pub const VK_DYNAMIC_STATE_FRAGMENT_SHADING_RATE_KHR: c_int = 1000226000;
pub const VK_DYNAMIC_STATE_LINE_STIPPLE_EXT: c_int = 1000259000;
pub const VK_DYNAMIC_STATE_CULL_MODE_EXT: c_int = 1000267000;
pub const VK_DYNAMIC_STATE_FRONT_FACE_EXT: c_int = 1000267001;
pub const VK_DYNAMIC_STATE_PRIMITIVE_TOPOLOGY_EXT: c_int = 1000267002;
pub const VK_DYNAMIC_STATE_VIEWPORT_WITH_COUNT_EXT: c_int = 1000267003;
pub const VK_DYNAMIC_STATE_SCISSOR_WITH_COUNT_EXT: c_int = 1000267004;
pub const VK_DYNAMIC_STATE_VERTEX_INPUT_BINDING_STRIDE_EXT: c_int = 1000267005;
pub const VK_DYNAMIC_STATE_DEPTH_TEST_ENABLE_EXT: c_int = 1000267006;
pub const VK_DYNAMIC_STATE_DEPTH_WRITE_ENABLE_EXT: c_int = 1000267007;
pub const VK_DYNAMIC_STATE_DEPTH_COMPARE_OP_EXT: c_int = 1000267008;
pub const VK_DYNAMIC_STATE_DEPTH_BOUNDS_TEST_ENABLE_EXT: c_int = 1000267009;
pub const VK_DYNAMIC_STATE_STENCIL_TEST_ENABLE_EXT: c_int = 1000267010;
pub const VK_DYNAMIC_STATE_STENCIL_OP_EXT: c_int = 1000267011;
pub const VK_DYNAMIC_STATE_VERTEX_INPUT_EXT: c_int = 1000352000;
pub const VK_DYNAMIC_STATE_PATCH_CONTROL_POINTS_EXT: c_int = 1000377000;
pub const VK_DYNAMIC_STATE_RASTERIZER_DISCARD_ENABLE_EXT: c_int = 1000377001;
pub const VK_DYNAMIC_STATE_DEPTH_BIAS_ENABLE_EXT: c_int = 1000377002;
pub const VK_DYNAMIC_STATE_LOGIC_OP_EXT: c_int = 1000377003;
pub const VK_DYNAMIC_STATE_PRIMITIVE_RESTART_ENABLE_EXT: c_int = 1000377004;
pub const VK_DYNAMIC_STATE_COLOR_WRITE_ENABLE_EXT: c_int = 1000381000;
pub const VK_DYNAMIC_STATE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkDynamicState = c_uint;
pub const VkDynamicState = enum_VkDynamicState;
pub const VK_FRONT_FACE_COUNTER_CLOCKWISE: c_int = 0;
pub const VK_FRONT_FACE_CLOCKWISE: c_int = 1;
pub const VK_FRONT_FACE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkFrontFace = c_uint;
pub const VkFrontFace = enum_VkFrontFace;
pub const VK_VERTEX_INPUT_RATE_VERTEX: c_int = 0;
pub const VK_VERTEX_INPUT_RATE_INSTANCE: c_int = 1;
pub const VK_VERTEX_INPUT_RATE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkVertexInputRate = c_uint;
pub const VkVertexInputRate = enum_VkVertexInputRate;
pub const VK_PRIMITIVE_TOPOLOGY_POINT_LIST: c_int = 0;
pub const VK_PRIMITIVE_TOPOLOGY_LINE_LIST: c_int = 1;
pub const VK_PRIMITIVE_TOPOLOGY_LINE_STRIP: c_int = 2;
pub const VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST: c_int = 3;
pub const VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP: c_int = 4;
pub const VK_PRIMITIVE_TOPOLOGY_TRIANGLE_FAN: c_int = 5;
pub const VK_PRIMITIVE_TOPOLOGY_LINE_LIST_WITH_ADJACENCY: c_int = 6;
pub const VK_PRIMITIVE_TOPOLOGY_LINE_STRIP_WITH_ADJACENCY: c_int = 7;
pub const VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST_WITH_ADJACENCY: c_int = 8;
pub const VK_PRIMITIVE_TOPOLOGY_TRIANGLE_STRIP_WITH_ADJACENCY: c_int = 9;
pub const VK_PRIMITIVE_TOPOLOGY_PATCH_LIST: c_int = 10;
pub const VK_PRIMITIVE_TOPOLOGY_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPrimitiveTopology = c_uint;
pub const VkPrimitiveTopology = enum_VkPrimitiveTopology;
pub const VK_POLYGON_MODE_FILL: c_int = 0;
pub const VK_POLYGON_MODE_LINE: c_int = 1;
pub const VK_POLYGON_MODE_POINT: c_int = 2;
pub const VK_POLYGON_MODE_FILL_RECTANGLE_NV: c_int = 1000153000;
pub const VK_POLYGON_MODE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPolygonMode = c_uint;
pub const VkPolygonMode = enum_VkPolygonMode;
pub const VK_STENCIL_OP_KEEP: c_int = 0;
pub const VK_STENCIL_OP_ZERO: c_int = 1;
pub const VK_STENCIL_OP_REPLACE: c_int = 2;
pub const VK_STENCIL_OP_INCREMENT_AND_CLAMP: c_int = 3;
pub const VK_STENCIL_OP_DECREMENT_AND_CLAMP: c_int = 4;
pub const VK_STENCIL_OP_INVERT: c_int = 5;
pub const VK_STENCIL_OP_INCREMENT_AND_WRAP: c_int = 6;
pub const VK_STENCIL_OP_DECREMENT_AND_WRAP: c_int = 7;
pub const VK_STENCIL_OP_MAX_ENUM: c_int = 2147483647;
pub const enum_VkStencilOp = c_uint;
pub const VkStencilOp = enum_VkStencilOp;
pub const VK_LOGIC_OP_CLEAR: c_int = 0;
pub const VK_LOGIC_OP_AND: c_int = 1;
pub const VK_LOGIC_OP_AND_REVERSE: c_int = 2;
pub const VK_LOGIC_OP_COPY: c_int = 3;
pub const VK_LOGIC_OP_AND_INVERTED: c_int = 4;
pub const VK_LOGIC_OP_NO_OP: c_int = 5;
pub const VK_LOGIC_OP_XOR: c_int = 6;
pub const VK_LOGIC_OP_OR: c_int = 7;
pub const VK_LOGIC_OP_NOR: c_int = 8;
pub const VK_LOGIC_OP_EQUIVALENT: c_int = 9;
pub const VK_LOGIC_OP_INVERT: c_int = 10;
pub const VK_LOGIC_OP_OR_REVERSE: c_int = 11;
pub const VK_LOGIC_OP_COPY_INVERTED: c_int = 12;
pub const VK_LOGIC_OP_OR_INVERTED: c_int = 13;
pub const VK_LOGIC_OP_NAND: c_int = 14;
pub const VK_LOGIC_OP_SET: c_int = 15;
pub const VK_LOGIC_OP_MAX_ENUM: c_int = 2147483647;
pub const enum_VkLogicOp = c_uint;
pub const VkLogicOp = enum_VkLogicOp;
pub const VK_BORDER_COLOR_FLOAT_TRANSPARENT_BLACK: c_int = 0;
pub const VK_BORDER_COLOR_INT_TRANSPARENT_BLACK: c_int = 1;
pub const VK_BORDER_COLOR_FLOAT_OPAQUE_BLACK: c_int = 2;
pub const VK_BORDER_COLOR_INT_OPAQUE_BLACK: c_int = 3;
pub const VK_BORDER_COLOR_FLOAT_OPAQUE_WHITE: c_int = 4;
pub const VK_BORDER_COLOR_INT_OPAQUE_WHITE: c_int = 5;
pub const VK_BORDER_COLOR_FLOAT_CUSTOM_EXT: c_int = 1000287003;
pub const VK_BORDER_COLOR_INT_CUSTOM_EXT: c_int = 1000287004;
pub const VK_BORDER_COLOR_MAX_ENUM: c_int = 2147483647;
pub const enum_VkBorderColor = c_uint;
pub const VkBorderColor = enum_VkBorderColor;
pub const VK_FILTER_NEAREST: c_int = 0;
pub const VK_FILTER_LINEAR: c_int = 1;
pub const VK_FILTER_CUBIC_IMG: c_int = 1000015000;
pub const VK_FILTER_CUBIC_EXT: c_int = 1000015000;
pub const VK_FILTER_MAX_ENUM: c_int = 2147483647;
pub const enum_VkFilter = c_uint;
pub const VkFilter = enum_VkFilter;
pub const VK_SAMPLER_ADDRESS_MODE_REPEAT: c_int = 0;
pub const VK_SAMPLER_ADDRESS_MODE_MIRRORED_REPEAT: c_int = 1;
pub const VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE: c_int = 2;
pub const VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_BORDER: c_int = 3;
pub const VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE: c_int = 4;
pub const VK_SAMPLER_ADDRESS_MODE_MIRROR_CLAMP_TO_EDGE_KHR: c_int = 4;
pub const VK_SAMPLER_ADDRESS_MODE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSamplerAddressMode = c_uint;
pub const VkSamplerAddressMode = enum_VkSamplerAddressMode;
pub const VK_SAMPLER_MIPMAP_MODE_NEAREST: c_int = 0;
pub const VK_SAMPLER_MIPMAP_MODE_LINEAR: c_int = 1;
pub const VK_SAMPLER_MIPMAP_MODE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSamplerMipmapMode = c_uint;
pub const VkSamplerMipmapMode = enum_VkSamplerMipmapMode;
pub const VK_DESCRIPTOR_TYPE_SAMPLER: c_int = 0;
pub const VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER: c_int = 1;
pub const VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE: c_int = 2;
pub const VK_DESCRIPTOR_TYPE_STORAGE_IMAGE: c_int = 3;
pub const VK_DESCRIPTOR_TYPE_UNIFORM_TEXEL_BUFFER: c_int = 4;
pub const VK_DESCRIPTOR_TYPE_STORAGE_TEXEL_BUFFER: c_int = 5;
pub const VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER: c_int = 6;
pub const VK_DESCRIPTOR_TYPE_STORAGE_BUFFER: c_int = 7;
pub const VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER_DYNAMIC: c_int = 8;
pub const VK_DESCRIPTOR_TYPE_STORAGE_BUFFER_DYNAMIC: c_int = 9;
pub const VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT: c_int = 10;
pub const VK_DESCRIPTOR_TYPE_INLINE_UNIFORM_BLOCK_EXT: c_int = 1000138000;
pub const VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_KHR: c_int = 1000150000;
pub const VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_NV: c_int = 1000165000;
pub const VK_DESCRIPTOR_TYPE_MUTABLE_VALVE: c_int = 1000351000;
pub const VK_DESCRIPTOR_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkDescriptorType = c_uint;
pub const VkDescriptorType = enum_VkDescriptorType;
pub const VK_ATTACHMENT_LOAD_OP_LOAD: c_int = 0;
pub const VK_ATTACHMENT_LOAD_OP_CLEAR: c_int = 1;
pub const VK_ATTACHMENT_LOAD_OP_DONT_CARE: c_int = 2;
pub const VK_ATTACHMENT_LOAD_OP_NONE_EXT: c_int = 1000400000;
pub const VK_ATTACHMENT_LOAD_OP_MAX_ENUM: c_int = 2147483647;
pub const enum_VkAttachmentLoadOp = c_uint;
pub const VkAttachmentLoadOp = enum_VkAttachmentLoadOp;
pub const VK_ATTACHMENT_STORE_OP_STORE: c_int = 0;
pub const VK_ATTACHMENT_STORE_OP_DONT_CARE: c_int = 1;
pub const VK_ATTACHMENT_STORE_OP_NONE_KHR: c_int = 1000301000;
pub const VK_ATTACHMENT_STORE_OP_NONE_QCOM: c_int = 1000301000;
pub const VK_ATTACHMENT_STORE_OP_NONE_EXT: c_int = 1000301000;
pub const VK_ATTACHMENT_STORE_OP_MAX_ENUM: c_int = 2147483647;
pub const enum_VkAttachmentStoreOp = c_uint;
pub const VkAttachmentStoreOp = enum_VkAttachmentStoreOp;
pub const VK_PIPELINE_BIND_POINT_GRAPHICS: c_int = 0;
pub const VK_PIPELINE_BIND_POINT_COMPUTE: c_int = 1;
pub const VK_PIPELINE_BIND_POINT_RAY_TRACING_KHR: c_int = 1000165000;
pub const VK_PIPELINE_BIND_POINT_SUBPASS_SHADING_HUAWEI: c_int = 1000369003;
pub const VK_PIPELINE_BIND_POINT_RAY_TRACING_NV: c_int = 1000165000;
pub const VK_PIPELINE_BIND_POINT_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPipelineBindPoint = c_uint;
pub const VkPipelineBindPoint = enum_VkPipelineBindPoint;
pub const VK_COMMAND_BUFFER_LEVEL_PRIMARY: c_int = 0;
pub const VK_COMMAND_BUFFER_LEVEL_SECONDARY: c_int = 1;
pub const VK_COMMAND_BUFFER_LEVEL_MAX_ENUM: c_int = 2147483647;
pub const enum_VkCommandBufferLevel = c_uint;
pub const VkCommandBufferLevel = enum_VkCommandBufferLevel;
pub const VK_INDEX_TYPE_UINT16: c_int = 0;
pub const VK_INDEX_TYPE_UINT32: c_int = 1;
pub const VK_INDEX_TYPE_NONE_KHR: c_int = 1000165000;
pub const VK_INDEX_TYPE_UINT8_EXT: c_int = 1000265000;
pub const VK_INDEX_TYPE_NONE_NV: c_int = 1000165000;
pub const VK_INDEX_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkIndexType = c_uint;
pub const VkIndexType = enum_VkIndexType;
pub const VK_SUBPASS_CONTENTS_INLINE: c_int = 0;
pub const VK_SUBPASS_CONTENTS_SECONDARY_COMMAND_BUFFERS: c_int = 1;
pub const VK_SUBPASS_CONTENTS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSubpassContents = c_uint;
pub const VkSubpassContents = enum_VkSubpassContents;
pub const VK_ACCESS_INDIRECT_COMMAND_READ_BIT: c_int = 1;
pub const VK_ACCESS_INDEX_READ_BIT: c_int = 2;
pub const VK_ACCESS_VERTEX_ATTRIBUTE_READ_BIT: c_int = 4;
pub const VK_ACCESS_UNIFORM_READ_BIT: c_int = 8;
pub const VK_ACCESS_INPUT_ATTACHMENT_READ_BIT: c_int = 16;
pub const VK_ACCESS_SHADER_READ_BIT: c_int = 32;
pub const VK_ACCESS_SHADER_WRITE_BIT: c_int = 64;
pub const VK_ACCESS_COLOR_ATTACHMENT_READ_BIT: c_int = 128;
pub const VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT: c_int = 256;
pub const VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_READ_BIT: c_int = 512;
pub const VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT: c_int = 1024;
pub const VK_ACCESS_TRANSFER_READ_BIT: c_int = 2048;
pub const VK_ACCESS_TRANSFER_WRITE_BIT: c_int = 4096;
pub const VK_ACCESS_HOST_READ_BIT: c_int = 8192;
pub const VK_ACCESS_HOST_WRITE_BIT: c_int = 16384;
pub const VK_ACCESS_MEMORY_READ_BIT: c_int = 32768;
pub const VK_ACCESS_MEMORY_WRITE_BIT: c_int = 65536;
pub const VK_ACCESS_TRANSFORM_FEEDBACK_WRITE_BIT_EXT: c_int = 33554432;
pub const VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT: c_int = 67108864;
pub const VK_ACCESS_TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT: c_int = 134217728;
pub const VK_ACCESS_CONDITIONAL_RENDERING_READ_BIT_EXT: c_int = 1048576;
pub const VK_ACCESS_COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT: c_int = 524288;
pub const VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_KHR: c_int = 2097152;
pub const VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_KHR: c_int = 4194304;
pub const VK_ACCESS_FRAGMENT_DENSITY_MAP_READ_BIT_EXT: c_int = 16777216;
pub const VK_ACCESS_FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR: c_int = 8388608;
pub const VK_ACCESS_COMMAND_PREPROCESS_READ_BIT_NV: c_int = 131072;
pub const VK_ACCESS_COMMAND_PREPROCESS_WRITE_BIT_NV: c_int = 262144;
pub const VK_ACCESS_NONE_KHR: c_int = 0;
pub const VK_ACCESS_SHADING_RATE_IMAGE_READ_BIT_NV: c_int = 8388608;
pub const VK_ACCESS_ACCELERATION_STRUCTURE_READ_BIT_NV: c_int = 2097152;
pub const VK_ACCESS_ACCELERATION_STRUCTURE_WRITE_BIT_NV: c_int = 4194304;
pub const VK_ACCESS_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkAccessFlagBits = c_uint;
pub const VkAccessFlagBits = enum_VkAccessFlagBits;
pub const VkAccessFlags = VkFlags;
pub const VK_IMAGE_ASPECT_COLOR_BIT: c_int = 1;
pub const VK_IMAGE_ASPECT_DEPTH_BIT: c_int = 2;
pub const VK_IMAGE_ASPECT_STENCIL_BIT: c_int = 4;
pub const VK_IMAGE_ASPECT_METADATA_BIT: c_int = 8;
pub const VK_IMAGE_ASPECT_PLANE_0_BIT: c_int = 16;
pub const VK_IMAGE_ASPECT_PLANE_1_BIT: c_int = 32;
pub const VK_IMAGE_ASPECT_PLANE_2_BIT: c_int = 64;
pub const VK_IMAGE_ASPECT_MEMORY_PLANE_0_BIT_EXT: c_int = 128;
pub const VK_IMAGE_ASPECT_MEMORY_PLANE_1_BIT_EXT: c_int = 256;
pub const VK_IMAGE_ASPECT_MEMORY_PLANE_2_BIT_EXT: c_int = 512;
pub const VK_IMAGE_ASPECT_MEMORY_PLANE_3_BIT_EXT: c_int = 1024;
pub const VK_IMAGE_ASPECT_NONE_KHR: c_int = 0;
pub const VK_IMAGE_ASPECT_PLANE_0_BIT_KHR: c_int = 16;
pub const VK_IMAGE_ASPECT_PLANE_1_BIT_KHR: c_int = 32;
pub const VK_IMAGE_ASPECT_PLANE_2_BIT_KHR: c_int = 64;
pub const VK_IMAGE_ASPECT_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkImageAspectFlagBits = c_uint;
pub const VkImageAspectFlagBits = enum_VkImageAspectFlagBits;
pub const VkImageAspectFlags = VkFlags;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_BIT: c_int = 1;
pub const VK_FORMAT_FEATURE_STORAGE_IMAGE_BIT: c_int = 2;
pub const VK_FORMAT_FEATURE_STORAGE_IMAGE_ATOMIC_BIT: c_int = 4;
pub const VK_FORMAT_FEATURE_UNIFORM_TEXEL_BUFFER_BIT: c_int = 8;
pub const VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_BIT: c_int = 16;
pub const VK_FORMAT_FEATURE_STORAGE_TEXEL_BUFFER_ATOMIC_BIT: c_int = 32;
pub const VK_FORMAT_FEATURE_VERTEX_BUFFER_BIT: c_int = 64;
pub const VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT: c_int = 128;
pub const VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BLEND_BIT: c_int = 256;
pub const VK_FORMAT_FEATURE_DEPTH_STENCIL_ATTACHMENT_BIT: c_int = 512;
pub const VK_FORMAT_FEATURE_BLIT_SRC_BIT: c_int = 1024;
pub const VK_FORMAT_FEATURE_BLIT_DST_BIT: c_int = 2048;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_LINEAR_BIT: c_int = 4096;
pub const VK_FORMAT_FEATURE_TRANSFER_SRC_BIT: c_int = 16384;
pub const VK_FORMAT_FEATURE_TRANSFER_DST_BIT: c_int = 32768;
pub const VK_FORMAT_FEATURE_MIDPOINT_CHROMA_SAMPLES_BIT: c_int = 131072;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_LINEAR_FILTER_BIT: c_int = 262144;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_SEPARATE_RECONSTRUCTION_FILTER_BIT: c_int = 524288;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_BIT: c_int = 1048576;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_FORCEABLE_BIT: c_int = 2097152;
pub const VK_FORMAT_FEATURE_DISJOINT_BIT: c_int = 4194304;
pub const VK_FORMAT_FEATURE_COSITED_CHROMA_SAMPLES_BIT: c_int = 8388608;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_MINMAX_BIT: c_int = 65536;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_CUBIC_BIT_IMG: c_int = 8192;
pub const VK_FORMAT_FEATURE_ACCELERATION_STRUCTURE_VERTEX_BUFFER_BIT_KHR: c_int = 536870912;
pub const VK_FORMAT_FEATURE_FRAGMENT_DENSITY_MAP_BIT_EXT: c_int = 16777216;
pub const VK_FORMAT_FEATURE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR: c_int = 1073741824;
pub const VK_FORMAT_FEATURE_TRANSFER_SRC_BIT_KHR: c_int = 16384;
pub const VK_FORMAT_FEATURE_TRANSFER_DST_BIT_KHR: c_int = 32768;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_MINMAX_BIT_EXT: c_int = 65536;
pub const VK_FORMAT_FEATURE_MIDPOINT_CHROMA_SAMPLES_BIT_KHR: c_int = 131072;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_LINEAR_FILTER_BIT_KHR: c_int = 262144;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_SEPARATE_RECONSTRUCTION_FILTER_BIT_KHR: c_int = 524288;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_BIT_KHR: c_int = 1048576;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_FORCEABLE_BIT_KHR: c_int = 2097152;
pub const VK_FORMAT_FEATURE_DISJOINT_BIT_KHR: c_int = 4194304;
pub const VK_FORMAT_FEATURE_COSITED_CHROMA_SAMPLES_BIT_KHR: c_int = 8388608;
pub const VK_FORMAT_FEATURE_SAMPLED_IMAGE_FILTER_CUBIC_BIT_EXT: c_int = 8192;
pub const VK_FORMAT_FEATURE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkFormatFeatureFlagBits = c_uint;
pub const VkFormatFeatureFlagBits = enum_VkFormatFeatureFlagBits;
pub const VkFormatFeatureFlags = VkFlags;
pub const VK_IMAGE_CREATE_SPARSE_BINDING_BIT: c_int = 1;
pub const VK_IMAGE_CREATE_SPARSE_RESIDENCY_BIT: c_int = 2;
pub const VK_IMAGE_CREATE_SPARSE_ALIASED_BIT: c_int = 4;
pub const VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT: c_int = 8;
pub const VK_IMAGE_CREATE_CUBE_COMPATIBLE_BIT: c_int = 16;
pub const VK_IMAGE_CREATE_ALIAS_BIT: c_int = 1024;
pub const VK_IMAGE_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT: c_int = 64;
pub const VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT: c_int = 32;
pub const VK_IMAGE_CREATE_BLOCK_TEXEL_VIEW_COMPATIBLE_BIT: c_int = 128;
pub const VK_IMAGE_CREATE_EXTENDED_USAGE_BIT: c_int = 256;
pub const VK_IMAGE_CREATE_PROTECTED_BIT: c_int = 2048;
pub const VK_IMAGE_CREATE_DISJOINT_BIT: c_int = 512;
pub const VK_IMAGE_CREATE_CORNER_SAMPLED_BIT_NV: c_int = 8192;
pub const VK_IMAGE_CREATE_SAMPLE_LOCATIONS_COMPATIBLE_DEPTH_BIT_EXT: c_int = 4096;
pub const VK_IMAGE_CREATE_SUBSAMPLED_BIT_EXT: c_int = 16384;
pub const VK_IMAGE_CREATE_FRAGMENT_DENSITY_MAP_OFFSET_BIT_QCOM: c_int = 32768;
pub const VK_IMAGE_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT_KHR: c_int = 64;
pub const VK_IMAGE_CREATE_2D_ARRAY_COMPATIBLE_BIT_KHR: c_int = 32;
pub const VK_IMAGE_CREATE_BLOCK_TEXEL_VIEW_COMPATIBLE_BIT_KHR: c_int = 128;
pub const VK_IMAGE_CREATE_EXTENDED_USAGE_BIT_KHR: c_int = 256;
pub const VK_IMAGE_CREATE_DISJOINT_BIT_KHR: c_int = 512;
pub const VK_IMAGE_CREATE_ALIAS_BIT_KHR: c_int = 1024;
pub const VK_IMAGE_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkImageCreateFlagBits = c_uint;
pub const VkImageCreateFlagBits = enum_VkImageCreateFlagBits;
pub const VkImageCreateFlags = VkFlags;
pub const VK_SAMPLE_COUNT_1_BIT: c_int = 1;
pub const VK_SAMPLE_COUNT_2_BIT: c_int = 2;
pub const VK_SAMPLE_COUNT_4_BIT: c_int = 4;
pub const VK_SAMPLE_COUNT_8_BIT: c_int = 8;
pub const VK_SAMPLE_COUNT_16_BIT: c_int = 16;
pub const VK_SAMPLE_COUNT_32_BIT: c_int = 32;
pub const VK_SAMPLE_COUNT_64_BIT: c_int = 64;
pub const VK_SAMPLE_COUNT_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSampleCountFlagBits = c_uint;
pub const VkSampleCountFlagBits = enum_VkSampleCountFlagBits;
pub const VkSampleCountFlags = VkFlags;
pub const VK_IMAGE_USAGE_TRANSFER_SRC_BIT: c_int = 1;
pub const VK_IMAGE_USAGE_TRANSFER_DST_BIT: c_int = 2;
pub const VK_IMAGE_USAGE_SAMPLED_BIT: c_int = 4;
pub const VK_IMAGE_USAGE_STORAGE_BIT: c_int = 8;
pub const VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT: c_int = 16;
pub const VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT: c_int = 32;
pub const VK_IMAGE_USAGE_TRANSIENT_ATTACHMENT_BIT: c_int = 64;
pub const VK_IMAGE_USAGE_INPUT_ATTACHMENT_BIT: c_int = 128;
pub const VK_IMAGE_USAGE_FRAGMENT_DENSITY_MAP_BIT_EXT: c_int = 512;
pub const VK_IMAGE_USAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR: c_int = 256;
pub const VK_IMAGE_USAGE_INVOCATION_MASK_BIT_HUAWEI: c_int = 262144;
pub const VK_IMAGE_USAGE_SHADING_RATE_IMAGE_BIT_NV: c_int = 256;
pub const VK_IMAGE_USAGE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkImageUsageFlagBits = c_uint;
pub const VkImageUsageFlagBits = enum_VkImageUsageFlagBits;
pub const VkImageUsageFlags = VkFlags;
pub const vk.InstanceCreateFlags = VkFlags;
pub const VK_MEMORY_HEAP_DEVICE_LOCAL_BIT: c_int = 1;
pub const VK_MEMORY_HEAP_MULTI_INSTANCE_BIT: c_int = 2;
pub const VK_MEMORY_HEAP_MULTI_INSTANCE_BIT_KHR: c_int = 2;
pub const VK_MEMORY_HEAP_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkMemoryHeapFlagBits = c_uint;
pub const VkMemoryHeapFlagBits = enum_VkMemoryHeapFlagBits;
pub const VkMemoryHeapFlags = VkFlags;
pub const VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT: c_int = 1;
pub const VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT: c_int = 2;
pub const VK_MEMORY_PROPERTY_HOST_COHERENT_BIT: c_int = 4;
pub const VK_MEMORY_PROPERTY_HOST_CACHED_BIT: c_int = 8;
pub const VK_MEMORY_PROPERTY_LAZILY_ALLOCATED_BIT: c_int = 16;
pub const VK_MEMORY_PROPERTY_PROTECTED_BIT: c_int = 32;
pub const VK_MEMORY_PROPERTY_DEVICE_COHERENT_BIT_AMD: c_int = 64;
pub const VK_MEMORY_PROPERTY_DEVICE_UNCACHED_BIT_AMD: c_int = 128;
pub const VK_MEMORY_PROPERTY_RDMA_CAPABLE_BIT_NV: c_int = 256;
pub const VK_MEMORY_PROPERTY_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkMemoryPropertyFlagBits = c_uint;
pub const VkMemoryPropertyFlagBits = enum_VkMemoryPropertyFlagBits;
pub const VkMemoryPropertyFlags = VkFlags;
pub const VK_QUEUE_GRAPHICS_BIT: c_int = 1;
pub const VK_QUEUE_COMPUTE_BIT: c_int = 2;
pub const VK_QUEUE_TRANSFER_BIT: c_int = 4;
pub const VK_QUEUE_SPARSE_BINDING_BIT: c_int = 8;
pub const VK_QUEUE_PROTECTED_BIT: c_int = 16;
pub const VK_QUEUE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkQueueFlagBits = c_uint;
pub const VkQueueFlagBits = enum_VkQueueFlagBits;
pub const VkQueueFlags = VkFlags;
pub const vk.DeviceCreateFlags = VkFlags;
pub const VK_DEVICE_QUEUE_CREATE_PROTECTED_BIT: c_int = 1;
pub const VK_DEVICE_QUEUE_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_vk.DeviceQueueCreateFlagBits = c_uint;
pub const vk.DeviceQueueCreateFlagBits = enum_vk.DeviceQueueCreateFlagBits;
pub const vk.DeviceQueueCreateFlags = VkFlags;
pub const VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT: c_int = 1;
pub const VK_PIPELINE_STAGE_DRAW_INDIRECT_BIT: c_int = 2;
pub const VK_PIPELINE_STAGE_VERTEX_INPUT_BIT: c_int = 4;
pub const VK_PIPELINE_STAGE_VERTEX_SHADER_BIT: c_int = 8;
pub const VK_PIPELINE_STAGE_TESSELLATION_CONTROL_SHADER_BIT: c_int = 16;
pub const VK_PIPELINE_STAGE_TESSELLATION_EVALUATION_SHADER_BIT: c_int = 32;
pub const VK_PIPELINE_STAGE_GEOMETRY_SHADER_BIT: c_int = 64;
pub const VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT: c_int = 128;
pub const VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT: c_int = 256;
pub const VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT: c_int = 512;
pub const VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT: c_int = 1024;
pub const VK_PIPELINE_STAGE_COMPUTE_SHADER_BIT: c_int = 2048;
pub const VK_PIPELINE_STAGE_TRANSFER_BIT: c_int = 4096;
pub const VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT: c_int = 8192;
pub const VK_PIPELINE_STAGE_HOST_BIT: c_int = 16384;
pub const VK_PIPELINE_STAGE_ALL_GRAPHICS_BIT: c_int = 32768;
pub const VK_PIPELINE_STAGE_ALL_COMMANDS_BIT: c_int = 65536;
pub const VK_PIPELINE_STAGE_TRANSFORM_FEEDBACK_BIT_EXT: c_int = 16777216;
pub const VK_PIPELINE_STAGE_CONDITIONAL_RENDERING_BIT_EXT: c_int = 262144;
pub const VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_KHR: c_int = 33554432;
pub const VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_KHR: c_int = 2097152;
pub const VK_PIPELINE_STAGE_TASK_SHADER_BIT_NV: c_int = 524288;
pub const VK_PIPELINE_STAGE_MESH_SHADER_BIT_NV: c_int = 1048576;
pub const VK_PIPELINE_STAGE_FRAGMENT_DENSITY_PROCESS_BIT_EXT: c_int = 8388608;
pub const VK_PIPELINE_STAGE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR: c_int = 4194304;
pub const VK_PIPELINE_STAGE_COMMAND_PREPROCESS_BIT_NV: c_int = 131072;
pub const VK_PIPELINE_STAGE_NONE_KHR: c_int = 0;
pub const VK_PIPELINE_STAGE_SHADING_RATE_IMAGE_BIT_NV: c_int = 4194304;
pub const VK_PIPELINE_STAGE_RAY_TRACING_SHADER_BIT_NV: c_int = 2097152;
pub const VK_PIPELINE_STAGE_ACCELERATION_STRUCTURE_BUILD_BIT_NV: c_int = 33554432;
pub const VK_PIPELINE_STAGE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPipelineStageFlagBits = c_uint;
pub const VkPipelineStageFlagBits = enum_VkPipelineStageFlagBits;
pub const VkPipelineStageFlags = VkFlags;
pub const VkMemoryMapFlags = VkFlags;
pub const VK_SPARSE_MEMORY_BIND_METADATA_BIT: c_int = 1;
pub const VK_SPARSE_MEMORY_BIND_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSparseMemoryBindFlagBits = c_uint;
pub const VkSparseMemoryBindFlagBits = enum_VkSparseMemoryBindFlagBits;
pub const VkSparseMemoryBindFlags = VkFlags;
pub const VK_SPARSE_IMAGE_FORMAT_SINGLE_MIPTAIL_BIT: c_int = 1;
pub const VK_SPARSE_IMAGE_FORMAT_ALIGNED_MIP_SIZE_BIT: c_int = 2;
pub const VK_SPARSE_IMAGE_FORMAT_NONSTANDARD_BLOCK_SIZE_BIT: c_int = 4;
pub const VK_SPARSE_IMAGE_FORMAT_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSparseImageFormatFlagBits = c_uint;
pub const VkSparseImageFormatFlagBits = enum_VkSparseImageFormatFlagBits;
pub const VkSparseImageFormatFlags = VkFlags;
pub const VK_FENCE_CREATE_SIGNALED_BIT: c_int = 1;
pub const VK_FENCE_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkFenceCreateFlagBits = c_uint;
pub const VkFenceCreateFlagBits = enum_VkFenceCreateFlagBits;
pub const VkFenceCreateFlags = VkFlags;
pub const VkSemaphoreCreateFlags = VkFlags;
pub const VK_EVENT_CREATE_DEVICE_ONLY_BIT_KHR: c_int = 1;
pub const VK_EVENT_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkEventCreateFlagBits = c_uint;
pub const VkEventCreateFlagBits = enum_VkEventCreateFlagBits;
pub const VkEventCreateFlags = VkFlags;
pub const VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_VERTICES_BIT: c_int = 1;
pub const VK_QUERY_PIPELINE_STATISTIC_INPUT_ASSEMBLY_PRIMITIVES_BIT: c_int = 2;
pub const VK_QUERY_PIPELINE_STATISTIC_VERTEX_SHADER_INVOCATIONS_BIT: c_int = 4;
pub const VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_INVOCATIONS_BIT: c_int = 8;
pub const VK_QUERY_PIPELINE_STATISTIC_GEOMETRY_SHADER_PRIMITIVES_BIT: c_int = 16;
pub const VK_QUERY_PIPELINE_STATISTIC_CLIPPING_INVOCATIONS_BIT: c_int = 32;
pub const VK_QUERY_PIPELINE_STATISTIC_CLIPPING_PRIMITIVES_BIT: c_int = 64;
pub const VK_QUERY_PIPELINE_STATISTIC_FRAGMENT_SHADER_INVOCATIONS_BIT: c_int = 128;
pub const VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_CONTROL_SHADER_PATCHES_BIT: c_int = 256;
pub const VK_QUERY_PIPELINE_STATISTIC_TESSELLATION_EVALUATION_SHADER_INVOCATIONS_BIT: c_int = 512;
pub const VK_QUERY_PIPELINE_STATISTIC_COMPUTE_SHADER_INVOCATIONS_BIT: c_int = 1024;
pub const VK_QUERY_PIPELINE_STATISTIC_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkQueryPipelineStatisticFlagBits = c_uint;
pub const VkQueryPipelineStatisticFlagBits = enum_VkQueryPipelineStatisticFlagBits;
pub const VkQueryPipelineStatisticFlags = VkFlags;
pub const VkQueryPoolCreateFlags = VkFlags;
pub const VK_QUERY_RESULT_64_BIT: c_int = 1;
pub const VK_QUERY_RESULT_WAIT_BIT: c_int = 2;
pub const VK_QUERY_RESULT_WITH_AVAILABILITY_BIT: c_int = 4;
pub const VK_QUERY_RESULT_PARTIAL_BIT: c_int = 8;
pub const VK_QUERY_RESULT_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkQueryResultFlagBits = c_uint;
pub const VkQueryResultFlagBits = enum_VkQueryResultFlagBits;
pub const VkQueryResultFlags = VkFlags;
pub const VK_BUFFER_CREATE_SPARSE_BINDING_BIT: c_int = 1;
pub const VK_BUFFER_CREATE_SPARSE_RESIDENCY_BIT: c_int = 2;
pub const VK_BUFFER_CREATE_SPARSE_ALIASED_BIT: c_int = 4;
pub const VK_BUFFER_CREATE_PROTECTED_BIT: c_int = 8;
pub const VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT: c_int = 16;
pub const VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_EXT: c_int = 16;
pub const VK_BUFFER_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_KHR: c_int = 16;
pub const VK_BUFFER_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkBufferCreateFlagBits = c_uint;
pub const VkBufferCreateFlagBits = enum_VkBufferCreateFlagBits;
pub const VkBufferCreateFlags = VkFlags;
pub const VK_BUFFER_USAGE_TRANSFER_SRC_BIT: c_int = 1;
pub const VK_BUFFER_USAGE_TRANSFER_DST_BIT: c_int = 2;
pub const VK_BUFFER_USAGE_UNIFORM_TEXEL_BUFFER_BIT: c_int = 4;
pub const VK_BUFFER_USAGE_STORAGE_TEXEL_BUFFER_BIT: c_int = 8;
pub const VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT: c_int = 16;
pub const VK_BUFFER_USAGE_STORAGE_BUFFER_BIT: c_int = 32;
pub const VK_BUFFER_USAGE_INDEX_BUFFER_BIT: c_int = 64;
pub const VK_BUFFER_USAGE_VERTEX_BUFFER_BIT: c_int = 128;
pub const VK_BUFFER_USAGE_INDIRECT_BUFFER_BIT: c_int = 256;
pub const VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT: c_int = 131072;
pub const VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_BUFFER_BIT_EXT: c_int = 2048;
pub const VK_BUFFER_USAGE_TRANSFORM_FEEDBACK_COUNTER_BUFFER_BIT_EXT: c_int = 4096;
pub const VK_BUFFER_USAGE_CONDITIONAL_RENDERING_BIT_EXT: c_int = 512;
pub const VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY_BIT_KHR: c_int = 524288;
pub const VK_BUFFER_USAGE_ACCELERATION_STRUCTURE_STORAGE_BIT_KHR: c_int = 1048576;
pub const VK_BUFFER_USAGE_SHADER_BINDING_TABLE_BIT_KHR: c_int = 1024;
pub const VK_BUFFER_USAGE_RAY_TRACING_BIT_NV: c_int = 1024;
pub const VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_EXT: c_int = 131072;
pub const VK_BUFFER_USAGE_SHADER_DEVICE_ADDRESS_BIT_KHR: c_int = 131072;
pub const VK_BUFFER_USAGE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkBufferUsageFlagBits = c_uint;
pub const VkBufferUsageFlagBits = enum_VkBufferUsageFlagBits;
pub const VkBufferUsageFlags = VkFlags;
pub const VkBufferViewCreateFlags = VkFlags;
pub const VK_IMAGE_VIEW_CREATE_FRAGMENT_DENSITY_MAP_DYNAMIC_BIT_EXT: c_int = 1;
pub const VK_IMAGE_VIEW_CREATE_FRAGMENT_DENSITY_MAP_DEFERRED_BIT_EXT: c_int = 2;
pub const VK_IMAGE_VIEW_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkImageViewCreateFlagBits = c_uint;
pub const VkImageViewCreateFlagBits = enum_VkImageViewCreateFlagBits;
pub const VkImageViewCreateFlags = VkFlags;
pub const VkShaderModuleCreateFlags = VkFlags;
pub const VK_PIPELINE_CACHE_CREATE_EXTERNALLY_SYNCHRONIZED_BIT_EXT: c_int = 1;
pub const VK_PIPELINE_CACHE_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPipelineCacheCreateFlagBits = c_uint;
pub const VkPipelineCacheCreateFlagBits = enum_VkPipelineCacheCreateFlagBits;
pub const VkPipelineCacheCreateFlags = VkFlags;
pub const VK_COLOR_COMPONENT_R_BIT: c_int = 1;
pub const VK_COLOR_COMPONENT_G_BIT: c_int = 2;
pub const VK_COLOR_COMPONENT_B_BIT: c_int = 4;
pub const VK_COLOR_COMPONENT_A_BIT: c_int = 8;
pub const VK_COLOR_COMPONENT_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkColorComponentFlagBits = c_uint;
pub const VkColorComponentFlagBits = enum_VkColorComponentFlagBits;
pub const VkColorComponentFlags = VkFlags;
pub const VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT: c_int = 1;
pub const VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT: c_int = 2;
pub const VK_PIPELINE_CREATE_DERIVATIVE_BIT: c_int = 4;
pub const VK_PIPELINE_CREATE_VIEW_INDEX_FROM_DEVICE_INDEX_BIT: c_int = 8;
pub const VK_PIPELINE_CREATE_DISPATCH_BASE_BIT: c_int = 16;
pub const VK_PIPELINE_CREATE_RENDERING_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR: c_int = 2097152;
pub const VK_PIPELINE_CREATE_RENDERING_FRAGMENT_DENSITY_MAP_ATTACHMENT_BIT_EXT: c_int = 4194304;
pub const VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_ANY_HIT_SHADERS_BIT_KHR: c_int = 16384;
pub const VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_CLOSEST_HIT_SHADERS_BIT_KHR: c_int = 32768;
pub const VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_MISS_SHADERS_BIT_KHR: c_int = 65536;
pub const VK_PIPELINE_CREATE_RAY_TRACING_NO_NULL_INTERSECTION_SHADERS_BIT_KHR: c_int = 131072;
pub const VK_PIPELINE_CREATE_RAY_TRACING_SKIP_TRIANGLES_BIT_KHR: c_int = 4096;
pub const VK_PIPELINE_CREATE_RAY_TRACING_SKIP_AABBS_BIT_KHR: c_int = 8192;
pub const VK_PIPELINE_CREATE_RAY_TRACING_SHADER_GROUP_HANDLE_CAPTURE_REPLAY_BIT_KHR: c_int = 524288;
pub const VK_PIPELINE_CREATE_DEFER_COMPILE_BIT_NV: c_int = 32;
pub const VK_PIPELINE_CREATE_CAPTURE_STATISTICS_BIT_KHR: c_int = 64;
pub const VK_PIPELINE_CREATE_CAPTURE_INTERNAL_REPRESENTATIONS_BIT_KHR: c_int = 128;
pub const VK_PIPELINE_CREATE_INDIRECT_BINDABLE_BIT_NV: c_int = 262144;
pub const VK_PIPELINE_CREATE_LIBRARY_BIT_KHR: c_int = 2048;
pub const VK_PIPELINE_CREATE_FAIL_ON_PIPELINE_COMPILE_REQUIRED_BIT_EXT: c_int = 256;
pub const VK_PIPELINE_CREATE_EARLY_RETURN_ON_FAILURE_BIT_EXT: c_int = 512;
pub const VK_PIPELINE_CREATE_RAY_TRACING_ALLOW_MOTION_BIT_NV: c_int = 1048576;
pub const VK_PIPELINE_CREATE_DISPATCH_BASE: c_int = 16;
pub const VK_PIPELINE_RASTERIZATION_STATE_CREATE_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR: c_int = 2097152;
pub const VK_PIPELINE_RASTERIZATION_STATE_CREATE_FRAGMENT_DENSITY_MAP_ATTACHMENT_BIT_EXT: c_int = 4194304;
pub const VK_PIPELINE_CREATE_VIEW_INDEX_FROM_DEVICE_INDEX_BIT_KHR: c_int = 8;
pub const VK_PIPELINE_CREATE_DISPATCH_BASE_KHR: c_int = 16;
pub const VK_PIPELINE_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPipelineCreateFlagBits = c_uint;
pub const VkPipelineCreateFlagBits = enum_VkPipelineCreateFlagBits;
pub const VkPipelineCreateFlags = VkFlags;
pub const VK_PIPELINE_SHADER_STAGE_CREATE_ALLOW_VARYING_SUBGROUP_SIZE_BIT_EXT: c_int = 1;
pub const VK_PIPELINE_SHADER_STAGE_CREATE_REQUIRE_FULL_SUBGROUPS_BIT_EXT: c_int = 2;
pub const VK_PIPELINE_SHADER_STAGE_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPipelineShaderStageCreateFlagBits = c_uint;
pub const VkPipelineShaderStageCreateFlagBits = enum_VkPipelineShaderStageCreateFlagBits;
pub const VkPipelineShaderStageCreateFlags = VkFlags;
pub const VK_SHADER_STAGE_VERTEX_BIT: c_int = 1;
pub const VK_SHADER_STAGE_TESSELLATION_CONTROL_BIT: c_int = 2;
pub const VK_SHADER_STAGE_TESSELLATION_EVALUATION_BIT: c_int = 4;
pub const VK_SHADER_STAGE_GEOMETRY_BIT: c_int = 8;
pub const VK_SHADER_STAGE_FRAGMENT_BIT: c_int = 16;
pub const VK_SHADER_STAGE_COMPUTE_BIT: c_int = 32;
pub const VK_SHADER_STAGE_ALL_GRAPHICS: c_int = 31;
pub const VK_SHADER_STAGE_ALL: c_int = 2147483647;
pub const VK_SHADER_STAGE_RAYGEN_BIT_KHR: c_int = 256;
pub const VK_SHADER_STAGE_ANY_HIT_BIT_KHR: c_int = 512;
pub const VK_SHADER_STAGE_CLOSEST_HIT_BIT_KHR: c_int = 1024;
pub const VK_SHADER_STAGE_MISS_BIT_KHR: c_int = 2048;
pub const VK_SHADER_STAGE_INTERSECTION_BIT_KHR: c_int = 4096;
pub const VK_SHADER_STAGE_CALLABLE_BIT_KHR: c_int = 8192;
pub const VK_SHADER_STAGE_TASK_BIT_NV: c_int = 64;
pub const VK_SHADER_STAGE_MESH_BIT_NV: c_int = 128;
pub const VK_SHADER_STAGE_SUBPASS_SHADING_BIT_HUAWEI: c_int = 16384;
pub const VK_SHADER_STAGE_RAYGEN_BIT_NV: c_int = 256;
pub const VK_SHADER_STAGE_ANY_HIT_BIT_NV: c_int = 512;
pub const VK_SHADER_STAGE_CLOSEST_HIT_BIT_NV: c_int = 1024;
pub const VK_SHADER_STAGE_MISS_BIT_NV: c_int = 2048;
pub const VK_SHADER_STAGE_INTERSECTION_BIT_NV: c_int = 4096;
pub const VK_SHADER_STAGE_CALLABLE_BIT_NV: c_int = 8192;
pub const VK_SHADER_STAGE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkShaderStageFlagBits = c_uint;
pub const VkShaderStageFlagBits = enum_VkShaderStageFlagBits;
pub const VK_CULL_MODE_NONE: c_int = 0;
pub const VK_CULL_MODE_FRONT_BIT: c_int = 1;
pub const VK_CULL_MODE_BACK_BIT: c_int = 2;
pub const VK_CULL_MODE_FRONT_AND_BACK: c_int = 3;
pub const VK_CULL_MODE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkCullModeFlagBits = c_uint;
pub const VkCullModeFlagBits = enum_VkCullModeFlagBits;
pub const VkCullModeFlags = VkFlags;
pub const VkPipelineVertexInputStateCreateFlags = VkFlags;
pub const VkPipelineInputAssemblyStateCreateFlags = VkFlags;
pub const VkPipelineTessellationStateCreateFlags = VkFlags;
pub const VkPipelineViewportStateCreateFlags = VkFlags;
pub const VkPipelineRasterizationStateCreateFlags = VkFlags;
pub const VkPipelineMultisampleStateCreateFlags = VkFlags;
pub const VK_PIPELINE_DEPTH_STENCIL_STATE_CREATE_RASTERIZATION_ORDER_ATTACHMENT_DEPTH_ACCESS_BIT_ARM: c_int = 1;
pub const VK_PIPELINE_DEPTH_STENCIL_STATE_CREATE_RASTERIZATION_ORDER_ATTACHMENT_STENCIL_ACCESS_BIT_ARM: c_int = 2;
pub const VK_PIPELINE_DEPTH_STENCIL_STATE_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPipelineDepthStencilStateCreateFlagBits = c_uint;
pub const VkPipelineDepthStencilStateCreateFlagBits = enum_VkPipelineDepthStencilStateCreateFlagBits;
pub const VkPipelineDepthStencilStateCreateFlags = VkFlags;
pub const VK_PIPELINE_COLOR_BLEND_STATE_CREATE_RASTERIZATION_ORDER_ATTACHMENT_ACCESS_BIT_ARM: c_int = 1;
pub const VK_PIPELINE_COLOR_BLEND_STATE_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPipelineColorBlendStateCreateFlagBits = c_uint;
pub const VkPipelineColorBlendStateCreateFlagBits = enum_VkPipelineColorBlendStateCreateFlagBits;
pub const VkPipelineColorBlendStateCreateFlags = VkFlags;
pub const VkPipelineDynamicStateCreateFlags = VkFlags;
pub const VkPipelineLayoutCreateFlags = VkFlags;
pub const VkShaderStageFlags = VkFlags;
pub const VK_SAMPLER_CREATE_SUBSAMPLED_BIT_EXT: c_int = 1;
pub const VK_SAMPLER_CREATE_SUBSAMPLED_COARSE_RECONSTRUCTION_BIT_EXT: c_int = 2;
pub const VK_SAMPLER_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSamplerCreateFlagBits = c_uint;
pub const VkSamplerCreateFlagBits = enum_VkSamplerCreateFlagBits;
pub const VkSamplerCreateFlags = VkFlags;
pub const VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT: c_int = 1;
pub const VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT: c_int = 2;
pub const VK_DESCRIPTOR_POOL_CREATE_HOST_ONLY_BIT_VALVE: c_int = 4;
pub const VK_DESCRIPTOR_POOL_CREATE_UPDATE_AFTER_BIND_BIT_EXT: c_int = 2;
pub const VK_DESCRIPTOR_POOL_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkDescriptorPoolCreateFlagBits = c_uint;
pub const VkDescriptorPoolCreateFlagBits = enum_VkDescriptorPoolCreateFlagBits;
pub const VkDescriptorPoolCreateFlags = VkFlags;
pub const VkDescriptorPoolResetFlags = VkFlags;
pub const VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT: c_int = 2;
pub const VK_DESCRIPTOR_SET_LAYOUT_CREATE_PUSH_DESCRIPTOR_BIT_KHR: c_int = 1;
pub const VK_DESCRIPTOR_SET_LAYOUT_CREATE_HOST_ONLY_POOL_BIT_VALVE: c_int = 4;
pub const VK_DESCRIPTOR_SET_LAYOUT_CREATE_UPDATE_AFTER_BIND_POOL_BIT_EXT: c_int = 2;
pub const VK_DESCRIPTOR_SET_LAYOUT_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkDescriptorSetLayoutCreateFlagBits = c_uint;
pub const VkDescriptorSetLayoutCreateFlagBits = enum_VkDescriptorSetLayoutCreateFlagBits;
pub const VkDescriptorSetLayoutCreateFlags = VkFlags;
pub const VK_ATTACHMENT_DESCRIPTION_MAY_ALIAS_BIT: c_int = 1;
pub const VK_ATTACHMENT_DESCRIPTION_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkAttachmentDescriptionFlagBits = c_uint;
pub const VkAttachmentDescriptionFlagBits = enum_VkAttachmentDescriptionFlagBits;
pub const VkAttachmentDescriptionFlags = VkFlags;
pub const VK_DEPENDENCY_BY_REGION_BIT: c_int = 1;
pub const VK_DEPENDENCY_DEVICE_GROUP_BIT: c_int = 4;
pub const VK_DEPENDENCY_VIEW_LOCAL_BIT: c_int = 2;
pub const VK_DEPENDENCY_VIEW_LOCAL_BIT_KHR: c_int = 2;
pub const VK_DEPENDENCY_DEVICE_GROUP_BIT_KHR: c_int = 4;
pub const VK_DEPENDENCY_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkDependencyFlagBits = c_uint;
pub const VkDependencyFlagBits = enum_VkDependencyFlagBits;
pub const VkDependencyFlags = VkFlags;
pub const VK_FRAMEBUFFER_CREATE_IMAGELESS_BIT: c_int = 1;
pub const VK_FRAMEBUFFER_CREATE_IMAGELESS_BIT_KHR: c_int = 1;
pub const VK_FRAMEBUFFER_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkFramebufferCreateFlagBits = c_uint;
pub const VkFramebufferCreateFlagBits = enum_VkFramebufferCreateFlagBits;
pub const VkFramebufferCreateFlags = VkFlags;
pub const VK_RENDER_PASS_CREATE_TRANSFORM_BIT_QCOM: c_int = 2;
pub const VK_RENDER_PASS_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkRenderPassCreateFlagBits = c_uint;
pub const VkRenderPassCreateFlagBits = enum_VkRenderPassCreateFlagBits;
pub const VkRenderPassCreateFlags = VkFlags;
pub const VK_SUBPASS_DESCRIPTION_PER_VIEW_ATTRIBUTES_BIT_NVX: c_int = 1;
pub const VK_SUBPASS_DESCRIPTION_PER_VIEW_POSITION_X_ONLY_BIT_NVX: c_int = 2;
pub const VK_SUBPASS_DESCRIPTION_FRAGMENT_REGION_BIT_QCOM: c_int = 4;
pub const VK_SUBPASS_DESCRIPTION_SHADER_RESOLVE_BIT_QCOM: c_int = 8;
pub const VK_SUBPASS_DESCRIPTION_RASTERIZATION_ORDER_ATTACHMENT_COLOR_ACCESS_BIT_ARM: c_int = 16;
pub const VK_SUBPASS_DESCRIPTION_RASTERIZATION_ORDER_ATTACHMENT_DEPTH_ACCESS_BIT_ARM: c_int = 32;
pub const VK_SUBPASS_DESCRIPTION_RASTERIZATION_ORDER_ATTACHMENT_STENCIL_ACCESS_BIT_ARM: c_int = 64;
pub const VK_SUBPASS_DESCRIPTION_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSubpassDescriptionFlagBits = c_uint;
pub const VkSubpassDescriptionFlagBits = enum_VkSubpassDescriptionFlagBits;
pub const VkSubpassDescriptionFlags = VkFlags;
pub const VK_COMMAND_POOL_CREATE_TRANSIENT_BIT: c_int = 1;
pub const VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT: c_int = 2;
pub const VK_COMMAND_POOL_CREATE_PROTECTED_BIT: c_int = 4;
pub const VK_COMMAND_POOL_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkCommandPoolCreateFlagBits = c_uint;
pub const VkCommandPoolCreateFlagBits = enum_VkCommandPoolCreateFlagBits;
pub const VkCommandPoolCreateFlags = VkFlags;
pub const VK_COMMAND_POOL_RESET_RELEASE_RESOURCES_BIT: c_int = 1;
pub const VK_COMMAND_POOL_RESET_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkCommandPoolResetFlagBits = c_uint;
pub const VkCommandPoolResetFlagBits = enum_VkCommandPoolResetFlagBits;
pub const VkCommandPoolResetFlags = VkFlags;
pub const VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT: c_int = 1;
pub const VK_COMMAND_BUFFER_USAGE_RENDER_PASS_CONTINUE_BIT: c_int = 2;
pub const VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT: c_int = 4;
pub const VK_COMMAND_BUFFER_USAGE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkCommandBufferUsageFlagBits = c_uint;
pub const VkCommandBufferUsageFlagBits = enum_VkCommandBufferUsageFlagBits;
pub const VkCommandBufferUsageFlags = VkFlags;
pub const VK_QUERY_CONTROL_PRECISE_BIT: c_int = 1;
pub const VK_QUERY_CONTROL_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkQueryControlFlagBits = c_uint;
pub const VkQueryControlFlagBits = enum_VkQueryControlFlagBits;
pub const VkQueryControlFlags = VkFlags;
pub const VK_COMMAND_BUFFER_RESET_RELEASE_RESOURCES_BIT: c_int = 1;
pub const VK_COMMAND_BUFFER_RESET_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkCommandBufferResetFlagBits = c_uint;
pub const VkCommandBufferResetFlagBits = enum_VkCommandBufferResetFlagBits;
pub const VkCommandBufferResetFlags = VkFlags;
pub const VK_STENCIL_FACE_FRONT_BIT: c_int = 1;
pub const VK_STENCIL_FACE_BACK_BIT: c_int = 2;
pub const VK_STENCIL_FACE_FRONT_AND_BACK: c_int = 3;
pub const VK_STENCIL_FRONT_AND_BACK: c_int = 3;
pub const VK_STENCIL_FACE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkStencilFaceFlagBits = c_uint;
pub const VkStencilFaceFlagBits = enum_VkStencilFaceFlagBits;
pub const VkStencilFaceFlags = VkFlags;
pub const struct_VkExtent2D = extern struct {
    width: u32,
    height: u32,
};
pub const VkExtent2D = struct_VkExtent2D;
pub const struct_VkExtent3D = extern struct {
    width: u32,
    height: u32,
    depth: u32,
};
pub const VkExtent3D = struct_VkExtent3D;
pub const struct_VkOffset2D = extern struct {
    x: i32,
    y: i32,
};
pub const VkOffset2D = struct_VkOffset2D;
pub const struct_VkOffset3D = extern struct {
    x: i32,
    y: i32,
    z: i32,
};
pub const VkOffset3D = struct_VkOffset3D;
pub const struct_VkRect2D = extern struct {
    offset: VkOffset2D,
    extent: VkExtent2D,
};
pub const VkRect2D = struct_VkRect2D;
pub const struct_VkBaseInStructure = extern struct {
    sType: VkStructureType,
    pNext: [*c]const struct_VkBaseInStructure,
};
pub const VkBaseInStructure = struct_VkBaseInStructure;
pub const struct_VkBaseOutStructure = extern struct {
    sType: VkStructureType,
    pNext: [*c]struct_VkBaseOutStructure,
};
pub const VkBaseOutStructure = struct_VkBaseOutStructure;
pub const struct_VkBufferMemoryBarrier = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcAccessMask: VkAccessFlags,
    dstAccessMask: VkAccessFlags,
    srcQueueFamilyIndex: u32,
    dstQueueFamilyIndex: u32,
    buffer: VkBuffer,
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
};
pub const VkBufferMemoryBarrier = struct_VkBufferMemoryBarrier;
pub const struct_VkDispatchIndirectCommand = extern struct {
    x: u32,
    y: u32,
    z: u32,
};
pub const VkDispatchIndirectCommand = struct_VkDispatchIndirectCommand;
pub const struct_VkDrawIndexedIndirectCommand = extern struct {
    indexCount: u32,
    instanceCount: u32,
    firstIndex: u32,
    vertexOffset: i32,
    firstInstance: u32,
};
pub const VkDrawIndexedIndirectCommand = struct_VkDrawIndexedIndirectCommand;
pub const struct_VkDrawIndirectCommand = extern struct {
    vertexCount: u32,
    instanceCount: u32,
    firstVertex: u32,
    firstInstance: u32,
};
pub const VkDrawIndirectCommand = struct_VkDrawIndirectCommand;
pub const struct_VkImageSubresourceRange = extern struct {
    aspectMask: VkImageAspectFlags,
    baseMipLevel: u32,
    levelCount: u32,
    baseArrayLayer: u32,
    layerCount: u32,
};
pub const VkImageSubresourceRange = struct_VkImageSubresourceRange;
pub const struct_VkImageMemoryBarrier = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcAccessMask: VkAccessFlags,
    dstAccessMask: VkAccessFlags,
    oldLayout: VkImageLayout,
    newLayout: VkImageLayout,
    srcQueueFamilyIndex: u32,
    dstQueueFamilyIndex: u32,
    image: VkImage,
    subresourceRange: VkImageSubresourceRange,
};
pub const VkImageMemoryBarrier = struct_VkImageMemoryBarrier;
pub const struct_VkMemoryBarrier = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcAccessMask: VkAccessFlags,
    dstAccessMask: VkAccessFlags,
};
pub const VkMemoryBarrier = struct_VkMemoryBarrier;
pub const struct_VkPipelineCacheHeaderVersionOne = extern struct {
    headerSize: u32,
    headerVersion: VkPipelineCacheHeaderVersion,
    vendorID: u32,
    deviceID: u32,
    pipelineCacheUUID: [16]u8,
};
pub const VkPipelineCacheHeaderVersionOne = struct_VkPipelineCacheHeaderVersionOne;
pub const PFN_vkAllocationFunction = ?fn (?*anyopaque, usize, usize, VkSystemAllocationScope) callconv(.C) ?*anyopaque;
pub const PFN_vkFreeFunction = ?fn (?*anyopaque, ?*anyopaque) callconv(.C) void;
pub const PFN_vkInternalAllocationNotification = ?fn (?*anyopaque, usize, VkInternalAllocationType, VkSystemAllocationScope) callconv(.C) void;
pub const PFN_vkInternalFreeNotification = ?fn (?*anyopaque, usize, VkInternalAllocationType, VkSystemAllocationScope) callconv(.C) void;
pub const PFN_vkReallocationFunction = ?fn (?*anyopaque, ?*anyopaque, usize, usize, VkSystemAllocationScope) callconv(.C) ?*anyopaque;
pub const PFN_vkVoidFunction = ?fn () callconv(.C) void;
pub const struct_VkAllocationCallbacks = extern struct {
    pUserData: ?*anyopaque,
    pfnAllocation: PFN_vkAllocationFunction,
    pfnReallocation: PFN_vkReallocationFunction,
    pfnFree: PFN_vkFreeFunction,
    pfnInternalAllocation: PFN_vkInternalAllocationNotification,
    pfnInternalFree: PFN_vkInternalFreeNotification,
};
pub const VkAllocationCallbacks = struct_VkAllocationCallbacks;
pub const struct_VkApplicationInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pApplicationName: [*c]const u8,
    applicationVersion: u32,
    pEngineName: [*c]const u8,
    engineVersion: u32,
    apiVersion: u32,
};
pub const VkApplicationInfo = struct_VkApplicationInfo;
pub const struct_VkFormatProperties = extern struct {
    linearTilingFeatures: VkFormatFeatureFlags,
    optimalTilingFeatures: VkFormatFeatureFlags,
    bufferFeatures: VkFormatFeatureFlags,
};
pub const VkFormatProperties = struct_VkFormatProperties;
pub const struct_VkImageFormatProperties = extern struct {
    maxExtent: VkExtent3D,
    maxMipLevels: u32,
    maxArrayLayers: u32,
    sampleCounts: VkSampleCountFlags,
    maxResourceSize: vk.DeviceSize,
};
pub const VkImageFormatProperties = struct_VkImageFormatProperties;
pub const struct_vk.InstanceCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: vk.InstanceCreateFlags,
    pApplicationInfo: [*c]const VkApplicationInfo,
    enabledLayerCount: u32,
    ppEnabledLayerNames: [*c]const [*c]const u8,
    enabledExtensionCount: u32,
    ppEnabledExtensionNames: [*c]const [*c]const u8,
};
pub const vk.InstanceCreateInfo = struct_vk.InstanceCreateInfo;
pub const struct_VkMemoryHeap = extern struct {
    size: vk.DeviceSize,
    flags: VkMemoryHeapFlags,
};
pub const VkMemoryHeap = struct_VkMemoryHeap;
pub const struct_VkMemoryType = extern struct {
    propertyFlags: VkMemoryPropertyFlags,
    heapIndex: u32,
};
pub const VkMemoryType = struct_VkMemoryType;
pub const struct_vk.PhysicalDeviceFeatures = extern struct {
    robustBufferAccess: VkBool32,
    fullDrawIndexUint32: VkBool32,
    imageCubeArray: VkBool32,
    independentBlend: VkBool32,
    geometryShader: VkBool32,
    tessellationShader: VkBool32,
    sampleRateShading: VkBool32,
    dualSrcBlend: VkBool32,
    logicOp: VkBool32,
    multiDrawIndirect: VkBool32,
    drawIndirectFirstInstance: VkBool32,
    depthClamp: VkBool32,
    depthBiasClamp: VkBool32,
    fillModeNonSolid: VkBool32,
    depthBounds: VkBool32,
    wideLines: VkBool32,
    largePoints: VkBool32,
    alphaToOne: VkBool32,
    multiViewport: VkBool32,
    samplerAnisotropy: VkBool32,
    textureCompressionETC2: VkBool32,
    textureCompressionASTC_LDR: VkBool32,
    textureCompressionBC: VkBool32,
    occlusionQueryPrecise: VkBool32,
    pipelineStatisticsQuery: VkBool32,
    vertexPipelineStoresAndAtomics: VkBool32,
    fragmentStoresAndAtomics: VkBool32,
    shaderTessellationAndGeometryPointSize: VkBool32,
    shaderImageGatherExtended: VkBool32,
    shaderStorageImageExtendedFormats: VkBool32,
    shaderStorageImageMultisample: VkBool32,
    shaderStorageImageReadWithoutFormat: VkBool32,
    shaderStorageImageWriteWithoutFormat: VkBool32,
    shaderUniformBufferArrayDynamicIndexing: VkBool32,
    shaderSampledImageArrayDynamicIndexing: VkBool32,
    shaderStorageBufferArrayDynamicIndexing: VkBool32,
    shaderStorageImageArrayDynamicIndexing: VkBool32,
    shaderClipDistance: VkBool32,
    shaderCullDistance: VkBool32,
    shaderFloat64: VkBool32,
    shaderInt64: VkBool32,
    shaderInt16: VkBool32,
    shaderResourceResidency: VkBool32,
    shaderResourceMinLod: VkBool32,
    sparseBinding: VkBool32,
    sparseResidencyBuffer: VkBool32,
    sparseResidencyImage2D: VkBool32,
    sparseResidencyImage3D: VkBool32,
    sparseResidency2Samples: VkBool32,
    sparseResidency4Samples: VkBool32,
    sparseResidency8Samples: VkBool32,
    sparseResidency16Samples: VkBool32,
    sparseResidencyAliased: VkBool32,
    variableMultisampleRate: VkBool32,
    inheritedQueries: VkBool32,
};
pub const vk.PhysicalDeviceFeatures = struct_vk.PhysicalDeviceFeatures;
pub const struct_vk.PhysicalDeviceLimits = extern struct {
    maxImageDimension1D: u32,
    maxImageDimension2D: u32,
    maxImageDimension3D: u32,
    maxImageDimensionCube: u32,
    maxImageArrayLayers: u32,
    maxTexelBufferElements: u32,
    maxUniformBufferRange: u32,
    maxStorageBufferRange: u32,
    maxPushConstantsSize: u32,
    maxMemoryAllocationCount: u32,
    maxSamplerAllocationCount: u32,
    bufferImageGranularity: vk.DeviceSize,
    sparseAddressSpaceSize: vk.DeviceSize,
    maxBoundDescriptorSets: u32,
    maxPerStageDescriptorSamplers: u32,
    maxPerStageDescriptorUniformBuffers: u32,
    maxPerStageDescriptorStorageBuffers: u32,
    maxPerStageDescriptorSampledImages: u32,
    maxPerStageDescriptorStorageImages: u32,
    maxPerStageDescriptorInputAttachments: u32,
    maxPerStageResources: u32,
    maxDescriptorSetSamplers: u32,
    maxDescriptorSetUniformBuffers: u32,
    maxDescriptorSetUniformBuffersDynamic: u32,
    maxDescriptorSetStorageBuffers: u32,
    maxDescriptorSetStorageBuffersDynamic: u32,
    maxDescriptorSetSampledImages: u32,
    maxDescriptorSetStorageImages: u32,
    maxDescriptorSetInputAttachments: u32,
    maxVertexInputAttributes: u32,
    maxVertexInputBindings: u32,
    maxVertexInputAttributeOffset: u32,
    maxVertexInputBindingStride: u32,
    maxVertexOutputComponents: u32,
    maxTessellationGenerationLevel: u32,
    maxTessellationPatchSize: u32,
    maxTessellationControlPerVertexInputComponents: u32,
    maxTessellationControlPerVertexOutputComponents: u32,
    maxTessellationControlPerPatchOutputComponents: u32,
    maxTessellationControlTotalOutputComponents: u32,
    maxTessellationEvaluationInputComponents: u32,
    maxTessellationEvaluationOutputComponents: u32,
    maxGeometryShaderInvocations: u32,
    maxGeometryInputComponents: u32,
    maxGeometryOutputComponents: u32,
    maxGeometryOutputVertices: u32,
    maxGeometryTotalOutputComponents: u32,
    maxFragmentInputComponents: u32,
    maxFragmentOutputAttachments: u32,
    maxFragmentDualSrcAttachments: u32,
    maxFragmentCombinedOutputResources: u32,
    maxComputeSharedMemorySize: u32,
    maxComputeWorkGroupCount: [3]u32,
    maxComputeWorkGroupInvocations: u32,
    maxComputeWorkGroupSize: [3]u32,
    subPixelPrecisionBits: u32,
    subTexelPrecisionBits: u32,
    mipmapPrecisionBits: u32,
    maxDrawIndexedIndexValue: u32,
    maxDrawIndirectCount: u32,
    maxSamplerLodBias: f32,
    maxSamplerAnisotropy: f32,
    maxViewports: u32,
    maxViewportDimensions: [2]u32,
    viewportBoundsRange: [2]f32,
    viewportSubPixelBits: u32,
    minMemoryMapAlignment: usize,
    minTexelBufferOffsetAlignment: vk.DeviceSize,
    minUniformBufferOffsetAlignment: vk.DeviceSize,
    minStorageBufferOffsetAlignment: vk.DeviceSize,
    minTexelOffset: i32,
    maxTexelOffset: u32,
    minTexelGatherOffset: i32,
    maxTexelGatherOffset: u32,
    minInterpolationOffset: f32,
    maxInterpolationOffset: f32,
    subPixelInterpolationOffsetBits: u32,
    maxFramebufferWidth: u32,
    maxFramebufferHeight: u32,
    maxFramebufferLayers: u32,
    framebufferColorSampleCounts: VkSampleCountFlags,
    framebufferDepthSampleCounts: VkSampleCountFlags,
    framebufferStencilSampleCounts: VkSampleCountFlags,
    framebufferNoAttachmentsSampleCounts: VkSampleCountFlags,
    maxColorAttachments: u32,
    sampledImageColorSampleCounts: VkSampleCountFlags,
    sampledImageIntegerSampleCounts: VkSampleCountFlags,
    sampledImageDepthSampleCounts: VkSampleCountFlags,
    sampledImageStencilSampleCounts: VkSampleCountFlags,
    storageImageSampleCounts: VkSampleCountFlags,
    maxSampleMaskWords: u32,
    timestampComputeAndGraphics: VkBool32,
    timestampPeriod: f32,
    maxClipDistances: u32,
    maxCullDistances: u32,
    maxCombinedClipAndCullDistances: u32,
    discreteQueuePriorities: u32,
    pointSizeRange: [2]f32,
    lineWidthRange: [2]f32,
    pointSizeGranularity: f32,
    lineWidthGranularity: f32,
    strictLines: VkBool32,
    standardSampleLocations: VkBool32,
    optimalBufferCopyOffsetAlignment: vk.DeviceSize,
    optimalBufferCopyRowPitchAlignment: vk.DeviceSize,
    nonCoherentAtomSize: vk.DeviceSize,
};
pub const vk.PhysicalDeviceLimits = struct_vk.PhysicalDeviceLimits;
pub const struct_vk.PhysicalDeviceMemoryProperties = extern struct {
    memoryTypeCount: u32,
    memoryTypes: [32]VkMemoryType,
    memoryHeapCount: u32,
    memoryHeaps: [16]VkMemoryHeap,
};
pub const vk.PhysicalDeviceMemoryProperties = struct_vk.PhysicalDeviceMemoryProperties;
pub const struct_vk.PhysicalDeviceSparseProperties = extern struct {
    residencyStandard2DBlockShape: VkBool32,
    residencyStandard2DMultisampleBlockShape: VkBool32,
    residencyStandard3DBlockShape: VkBool32,
    residencyAlignedMipSize: VkBool32,
    residencyNonResidentStrict: VkBool32,
};
pub const vk.PhysicalDeviceSparseProperties = struct_vk.PhysicalDeviceSparseProperties;
pub const struct_vk.PhysicalDeviceProperties = extern struct {
    apiVersion: u32,
    driverVersion: u32,
    vendorID: u32,
    deviceID: u32,
    deviceType: vk.PhysicalDeviceType,
    deviceName: [256]u8,
    pipelineCacheUUID: [16]u8,
    limits: vk.PhysicalDeviceLimits,
    sparseProperties: vk.PhysicalDeviceSparseProperties,
};
pub const vk.PhysicalDeviceProperties = struct_vk.PhysicalDeviceProperties;
pub const struct_VkQueueFamilyProperties = extern struct {
    queueFlags: VkQueueFlags,
    queueCount: u32,
    timestampValidBits: u32,
    minImageTransferGranularity: VkExtent3D,
};
pub const VkQueueFamilyProperties = struct_VkQueueFamilyProperties;
pub const struct_vk.DeviceQueueCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: vk.DeviceQueueCreateFlags,
    queueFamilyIndex: u32,
    queueCount: u32,
    pQueuePriorities: [*c]const f32,
};
pub const vk.DeviceQueueCreateInfo = struct_vk.DeviceQueueCreateInfo;
pub const struct_vk.DeviceCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: vk.DeviceCreateFlags,
    queueCreateInfoCount: u32,
    pQueueCreateInfos: [*c]const vk.DeviceQueueCreateInfo,
    enabledLayerCount: u32,
    ppEnabledLayerNames: [*c]const [*c]const u8,
    enabledExtensionCount: u32,
    ppEnabledExtensionNames: [*c]const [*c]const u8,
    pEnabledFeatures: [*c]const vk.PhysicalDeviceFeatures,
};
pub const vk.DeviceCreateInfo = struct_vk.DeviceCreateInfo;
pub const struct_VkExtensionProperties = extern struct {
    extensionName: [256]u8,
    specVersion: u32,
};
pub const VkExtensionProperties = struct_VkExtensionProperties;
pub const struct_VkLayerProperties = extern struct {
    layerName: [256]u8,
    specVersion: u32,
    implementationVersion: u32,
    description: [256]u8,
};
pub const VkLayerProperties = struct_VkLayerProperties;
pub const struct_VkSubmitInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    waitSemaphoreCount: u32,
    pWaitSemaphores: [*c]const VkSemaphore,
    pWaitDstStageMask: [*c]const VkPipelineStageFlags,
    commandBufferCount: u32,
    pCommandBuffers: [*c]const VkCommandBuffer,
    signalSemaphoreCount: u32,
    pSignalSemaphores: [*c]const VkSemaphore,
};
pub const VkSubmitInfo = struct_VkSubmitInfo;
pub const struct_VkMappedMemoryRange = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    memory: vk.DeviceMemory,
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
};
pub const VkMappedMemoryRange = struct_VkMappedMemoryRange;
pub const struct_VkMemoryAllocateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    allocationSize: vk.DeviceSize,
    memoryTypeIndex: u32,
};
pub const VkMemoryAllocateInfo = struct_VkMemoryAllocateInfo;
pub const struct_VkMemoryRequirements = extern struct {
    size: vk.DeviceSize,
    alignment: vk.DeviceSize,
    memoryTypeBits: u32,
};
pub const VkMemoryRequirements = struct_VkMemoryRequirements;
pub const struct_VkSparseMemoryBind = extern struct {
    resourceOffset: vk.DeviceSize,
    size: vk.DeviceSize,
    memory: vk.DeviceMemory,
    memoryOffset: vk.DeviceSize,
    flags: VkSparseMemoryBindFlags,
};
pub const VkSparseMemoryBind = struct_VkSparseMemoryBind;
pub const struct_VkSparseBufferMemoryBindInfo = extern struct {
    buffer: VkBuffer,
    bindCount: u32,
    pBinds: [*c]const VkSparseMemoryBind,
};
pub const VkSparseBufferMemoryBindInfo = struct_VkSparseBufferMemoryBindInfo;
pub const struct_VkSparseImageOpaqueMemoryBindInfo = extern struct {
    image: VkImage,
    bindCount: u32,
    pBinds: [*c]const VkSparseMemoryBind,
};
pub const VkSparseImageOpaqueMemoryBindInfo = struct_VkSparseImageOpaqueMemoryBindInfo;
pub const struct_VkImageSubresource = extern struct {
    aspectMask: VkImageAspectFlags,
    mipLevel: u32,
    arrayLayer: u32,
};
pub const VkImageSubresource = struct_VkImageSubresource;
pub const struct_VkSparseImageMemoryBind = extern struct {
    subresource: VkImageSubresource,
    offset: VkOffset3D,
    extent: VkExtent3D,
    memory: vk.DeviceMemory,
    memoryOffset: vk.DeviceSize,
    flags: VkSparseMemoryBindFlags,
};
pub const VkSparseImageMemoryBind = struct_VkSparseImageMemoryBind;
pub const struct_VkSparseImageMemoryBindInfo = extern struct {
    image: VkImage,
    bindCount: u32,
    pBinds: [*c]const VkSparseImageMemoryBind,
};
pub const VkSparseImageMemoryBindInfo = struct_VkSparseImageMemoryBindInfo;
pub const struct_VkBindSparseInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    waitSemaphoreCount: u32,
    pWaitSemaphores: [*c]const VkSemaphore,
    bufferBindCount: u32,
    pBufferBinds: [*c]const VkSparseBufferMemoryBindInfo,
    imageOpaqueBindCount: u32,
    pImageOpaqueBinds: [*c]const VkSparseImageOpaqueMemoryBindInfo,
    imageBindCount: u32,
    pImageBinds: [*c]const VkSparseImageMemoryBindInfo,
    signalSemaphoreCount: u32,
    pSignalSemaphores: [*c]const VkSemaphore,
};
pub const VkBindSparseInfo = struct_VkBindSparseInfo;
pub const struct_VkSparseImageFormatProperties = extern struct {
    aspectMask: VkImageAspectFlags,
    imageGranularity: VkExtent3D,
    flags: VkSparseImageFormatFlags,
};
pub const VkSparseImageFormatProperties = struct_VkSparseImageFormatProperties;
pub const struct_VkSparseImageMemoryRequirements = extern struct {
    formatProperties: VkSparseImageFormatProperties,
    imageMipTailFirstLod: u32,
    imageMipTailSize: vk.DeviceSize,
    imageMipTailOffset: vk.DeviceSize,
    imageMipTailStride: vk.DeviceSize,
};
pub const VkSparseImageMemoryRequirements = struct_VkSparseImageMemoryRequirements;
pub const struct_VkFenceCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkFenceCreateFlags,
};
pub const VkFenceCreateInfo = struct_VkFenceCreateInfo;
pub const struct_VkSemaphoreCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkSemaphoreCreateFlags,
};
pub const VkSemaphoreCreateInfo = struct_VkSemaphoreCreateInfo;
pub const struct_VkEventCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkEventCreateFlags,
};
pub const VkEventCreateInfo = struct_VkEventCreateInfo;
pub const struct_VkQueryPoolCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkQueryPoolCreateFlags,
    queryType: VkQueryType,
    queryCount: u32,
    pipelineStatistics: VkQueryPipelineStatisticFlags,
};
pub const VkQueryPoolCreateInfo = struct_VkQueryPoolCreateInfo;
pub const struct_VkBufferCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkBufferCreateFlags,
    size: vk.DeviceSize,
    usage: VkBufferUsageFlags,
    sharingMode: VkSharingMode,
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: [*c]const u32,
};
pub const VkBufferCreateInfo = struct_VkBufferCreateInfo;
pub const struct_VkBufferViewCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkBufferViewCreateFlags,
    buffer: VkBuffer,
    format: VkFormat,
    offset: vk.DeviceSize,
    range: vk.DeviceSize,
};
pub const VkBufferViewCreateInfo = struct_VkBufferViewCreateInfo;
pub const struct_VkImageCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkImageCreateFlags,
    imageType: VkImageType,
    format: VkFormat,
    extent: VkExtent3D,
    mipLevels: u32,
    arrayLayers: u32,
    samples: VkSampleCountFlagBits,
    tiling: VkImageTiling,
    usage: VkImageUsageFlags,
    sharingMode: VkSharingMode,
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: [*c]const u32,
    initialLayout: VkImageLayout,
};
pub const VkImageCreateInfo = struct_VkImageCreateInfo;
pub const struct_VkSubresourceLayout = extern struct {
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
    rowPitch: vk.DeviceSize,
    arrayPitch: vk.DeviceSize,
    depthPitch: vk.DeviceSize,
};
pub const VkSubresourceLayout = struct_VkSubresourceLayout;
pub const struct_VkComponentMapping = extern struct {
    r: VkComponentSwizzle,
    g: VkComponentSwizzle,
    b: VkComponentSwizzle,
    a: VkComponentSwizzle,
};
pub const VkComponentMapping = struct_VkComponentMapping;
pub const struct_VkImageViewCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkImageViewCreateFlags,
    image: VkImage,
    viewType: VkImageViewType,
    format: VkFormat,
    components: VkComponentMapping,
    subresourceRange: VkImageSubresourceRange,
};
pub const VkImageViewCreateInfo = struct_VkImageViewCreateInfo;
pub const struct_VkShaderModuleCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkShaderModuleCreateFlags,
    codeSize: usize,
    pCode: [*c]const u32,
};
pub const VkShaderModuleCreateInfo = struct_VkShaderModuleCreateInfo;
pub const struct_VkPipelineCacheCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineCacheCreateFlags,
    initialDataSize: usize,
    pInitialData: ?*const anyopaque,
};
pub const VkPipelineCacheCreateInfo = struct_VkPipelineCacheCreateInfo;
pub const struct_VkSpecializationMapEntry = extern struct {
    constantID: u32,
    offset: u32,
    size: usize,
};
pub const VkSpecializationMapEntry = struct_VkSpecializationMapEntry;
pub const struct_VkSpecializationInfo = extern struct {
    mapEntryCount: u32,
    pMapEntries: [*c]const VkSpecializationMapEntry,
    dataSize: usize,
    pData: ?*const anyopaque,
};
pub const VkSpecializationInfo = struct_VkSpecializationInfo;
pub const struct_VkPipelineShaderStageCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineShaderStageCreateFlags,
    stage: VkShaderStageFlagBits,
    module: VkShaderModule,
    pName: [*c]const u8,
    pSpecializationInfo: [*c]const VkSpecializationInfo,
};
pub const VkPipelineShaderStageCreateInfo = struct_VkPipelineShaderStageCreateInfo;
pub const struct_VkComputePipelineCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineCreateFlags,
    stage: VkPipelineShaderStageCreateInfo,
    layout: VkPipelineLayout,
    basePipelineHandle: VkPipeline,
    basePipelineIndex: i32,
};
pub const VkComputePipelineCreateInfo = struct_VkComputePipelineCreateInfo;
pub const struct_VkVertexInputBindingDescription = extern struct {
    binding: u32,
    stride: u32,
    inputRate: VkVertexInputRate,
};
pub const VkVertexInputBindingDescription = struct_VkVertexInputBindingDescription;
pub const struct_VkVertexInputAttributeDescription = extern struct {
    location: u32,
    binding: u32,
    format: VkFormat,
    offset: u32,
};
pub const VkVertexInputAttributeDescription = struct_VkVertexInputAttributeDescription;
pub const struct_VkPipelineVertexInputStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineVertexInputStateCreateFlags,
    vertexBindingDescriptionCount: u32,
    pVertexBindingDescriptions: [*c]const VkVertexInputBindingDescription,
    vertexAttributeDescriptionCount: u32,
    pVertexAttributeDescriptions: [*c]const VkVertexInputAttributeDescription,
};
pub const VkPipelineVertexInputStateCreateInfo = struct_VkPipelineVertexInputStateCreateInfo;
pub const struct_VkPipelineInputAssemblyStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineInputAssemblyStateCreateFlags,
    topology: VkPrimitiveTopology,
    primitiveRestartEnable: VkBool32,
};
pub const VkPipelineInputAssemblyStateCreateInfo = struct_VkPipelineInputAssemblyStateCreateInfo;
pub const struct_VkPipelineTessellationStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineTessellationStateCreateFlags,
    patchControlPoints: u32,
};
pub const VkPipelineTessellationStateCreateInfo = struct_VkPipelineTessellationStateCreateInfo;
pub const struct_VkViewport = extern struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    minDepth: f32,
    maxDepth: f32,
};
pub const VkViewport = struct_VkViewport;
pub const struct_VkPipelineViewportStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineViewportStateCreateFlags,
    viewportCount: u32,
    pViewports: [*c]const VkViewport,
    scissorCount: u32,
    pScissors: [*c]const VkRect2D,
};
pub const VkPipelineViewportStateCreateInfo = struct_VkPipelineViewportStateCreateInfo;
pub const struct_VkPipelineRasterizationStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineRasterizationStateCreateFlags,
    depthClampEnable: VkBool32,
    rasterizerDiscardEnable: VkBool32,
    polygonMode: VkPolygonMode,
    cullMode: VkCullModeFlags,
    frontFace: VkFrontFace,
    depthBiasEnable: VkBool32,
    depthBiasConstantFactor: f32,
    depthBiasClamp: f32,
    depthBiasSlopeFactor: f32,
    lineWidth: f32,
};
pub const VkPipelineRasterizationStateCreateInfo = struct_VkPipelineRasterizationStateCreateInfo;
pub const struct_VkPipelineMultisampleStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineMultisampleStateCreateFlags,
    rasterizationSamples: VkSampleCountFlagBits,
    sampleShadingEnable: VkBool32,
    minSampleShading: f32,
    pSampleMask: [*c]const VkSampleMask,
    alphaToCoverageEnable: VkBool32,
    alphaToOneEnable: VkBool32,
};
pub const VkPipelineMultisampleStateCreateInfo = struct_VkPipelineMultisampleStateCreateInfo;
pub const struct_VkStencilOpState = extern struct {
    failOp: VkStencilOp,
    passOp: VkStencilOp,
    depthFailOp: VkStencilOp,
    compareOp: VkCompareOp,
    compareMask: u32,
    writeMask: u32,
    reference: u32,
};
pub const VkStencilOpState = struct_VkStencilOpState;
pub const struct_VkPipelineDepthStencilStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineDepthStencilStateCreateFlags,
    depthTestEnable: VkBool32,
    depthWriteEnable: VkBool32,
    depthCompareOp: VkCompareOp,
    depthBoundsTestEnable: VkBool32,
    stencilTestEnable: VkBool32,
    front: VkStencilOpState,
    back: VkStencilOpState,
    minDepthBounds: f32,
    maxDepthBounds: f32,
};
pub const VkPipelineDepthStencilStateCreateInfo = struct_VkPipelineDepthStencilStateCreateInfo;
pub const struct_VkPipelineColorBlendAttachmentState = extern struct {
    blendEnable: VkBool32,
    srcColorBlendFactor: VkBlendFactor,
    dstColorBlendFactor: VkBlendFactor,
    colorBlendOp: VkBlendOp,
    srcAlphaBlendFactor: VkBlendFactor,
    dstAlphaBlendFactor: VkBlendFactor,
    alphaBlendOp: VkBlendOp,
    colorWriteMask: VkColorComponentFlags,
};
pub const VkPipelineColorBlendAttachmentState = struct_VkPipelineColorBlendAttachmentState;
pub const struct_VkPipelineColorBlendStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineColorBlendStateCreateFlags,
    logicOpEnable: VkBool32,
    logicOp: VkLogicOp,
    attachmentCount: u32,
    pAttachments: [*c]const VkPipelineColorBlendAttachmentState,
    blendConstants: [4]f32,
};
pub const VkPipelineColorBlendStateCreateInfo = struct_VkPipelineColorBlendStateCreateInfo;
pub const struct_VkPipelineDynamicStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineDynamicStateCreateFlags,
    dynamicStateCount: u32,
    pDynamicStates: [*c]const VkDynamicState,
};
pub const VkPipelineDynamicStateCreateInfo = struct_VkPipelineDynamicStateCreateInfo;
pub const struct_VkGraphicsPipelineCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineCreateFlags,
    stageCount: u32,
    pStages: [*c]const VkPipelineShaderStageCreateInfo,
    pVertexInputState: [*c]const VkPipelineVertexInputStateCreateInfo,
    pInputAssemblyState: [*c]const VkPipelineInputAssemblyStateCreateInfo,
    pTessellationState: [*c]const VkPipelineTessellationStateCreateInfo,
    pViewportState: [*c]const VkPipelineViewportStateCreateInfo,
    pRasterizationState: [*c]const VkPipelineRasterizationStateCreateInfo,
    pMultisampleState: [*c]const VkPipelineMultisampleStateCreateInfo,
    pDepthStencilState: [*c]const VkPipelineDepthStencilStateCreateInfo,
    pColorBlendState: [*c]const VkPipelineColorBlendStateCreateInfo,
    pDynamicState: [*c]const VkPipelineDynamicStateCreateInfo,
    layout: VkPipelineLayout,
    renderPass: VkRenderPass,
    subpass: u32,
    basePipelineHandle: VkPipeline,
    basePipelineIndex: i32,
};
pub const VkGraphicsPipelineCreateInfo = struct_VkGraphicsPipelineCreateInfo;
pub const struct_VkPushConstantRange = extern struct {
    stageFlags: VkShaderStageFlags,
    offset: u32,
    size: u32,
};
pub const VkPushConstantRange = struct_VkPushConstantRange;
pub const struct_VkPipelineLayoutCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineLayoutCreateFlags,
    setLayoutCount: u32,
    pSetLayouts: [*c]const VkDescriptorSetLayout,
    pushConstantRangeCount: u32,
    pPushConstantRanges: [*c]const VkPushConstantRange,
};
pub const VkPipelineLayoutCreateInfo = struct_VkPipelineLayoutCreateInfo;
pub const struct_VkSamplerCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkSamplerCreateFlags,
    magFilter: VkFilter,
    minFilter: VkFilter,
    mipmapMode: VkSamplerMipmapMode,
    addressModeU: VkSamplerAddressMode,
    addressModeV: VkSamplerAddressMode,
    addressModeW: VkSamplerAddressMode,
    mipLodBias: f32,
    anisotropyEnable: VkBool32,
    maxAnisotropy: f32,
    compareEnable: VkBool32,
    compareOp: VkCompareOp,
    minLod: f32,
    maxLod: f32,
    borderColor: VkBorderColor,
    unnormalizedCoordinates: VkBool32,
};
pub const VkSamplerCreateInfo = struct_VkSamplerCreateInfo;
pub const struct_VkCopyDescriptorSet = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcSet: VkDescriptorSet,
    srcBinding: u32,
    srcArrayElement: u32,
    dstSet: VkDescriptorSet,
    dstBinding: u32,
    dstArrayElement: u32,
    descriptorCount: u32,
};
pub const VkCopyDescriptorSet = struct_VkCopyDescriptorSet;
pub const struct_VkDescriptorBufferInfo = extern struct {
    buffer: VkBuffer,
    offset: vk.DeviceSize,
    range: vk.DeviceSize,
};
pub const VkDescriptorBufferInfo = struct_VkDescriptorBufferInfo;
pub const struct_VkDescriptorImageInfo = extern struct {
    sampler: VkSampler,
    imageView: VkImageView,
    imageLayout: VkImageLayout,
};
pub const VkDescriptorImageInfo = struct_VkDescriptorImageInfo;
pub const struct_VkDescriptorPoolSize = extern struct {
    type: VkDescriptorType,
    descriptorCount: u32,
};
pub const VkDescriptorPoolSize = struct_VkDescriptorPoolSize;
pub const struct_VkDescriptorPoolCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkDescriptorPoolCreateFlags,
    maxSets: u32,
    poolSizeCount: u32,
    pPoolSizes: [*c]const VkDescriptorPoolSize,
};
pub const VkDescriptorPoolCreateInfo = struct_VkDescriptorPoolCreateInfo;
pub const struct_VkDescriptorSetAllocateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    descriptorPool: VkDescriptorPool,
    descriptorSetCount: u32,
    pSetLayouts: [*c]const VkDescriptorSetLayout,
};
pub const VkDescriptorSetAllocateInfo = struct_VkDescriptorSetAllocateInfo;
pub const struct_VkDescriptorSetLayoutBinding = extern struct {
    binding: u32,
    descriptorType: VkDescriptorType,
    descriptorCount: u32,
    stageFlags: VkShaderStageFlags,
    pImmutableSamplers: [*c]const VkSampler,
};
pub const VkDescriptorSetLayoutBinding = struct_VkDescriptorSetLayoutBinding;
pub const struct_VkDescriptorSetLayoutCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkDescriptorSetLayoutCreateFlags,
    bindingCount: u32,
    pBindings: [*c]const VkDescriptorSetLayoutBinding,
};
pub const VkDescriptorSetLayoutCreateInfo = struct_VkDescriptorSetLayoutCreateInfo;
pub const struct_VkWriteDescriptorSet = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    dstSet: VkDescriptorSet,
    dstBinding: u32,
    dstArrayElement: u32,
    descriptorCount: u32,
    descriptorType: VkDescriptorType,
    pImageInfo: [*c]const VkDescriptorImageInfo,
    pBufferInfo: [*c]const VkDescriptorBufferInfo,
    pTexelBufferView: [*c]const VkBufferView,
};
pub const VkWriteDescriptorSet = struct_VkWriteDescriptorSet;
pub const struct_VkAttachmentDescription = extern struct {
    flags: VkAttachmentDescriptionFlags,
    format: VkFormat,
    samples: VkSampleCountFlagBits,
    loadOp: VkAttachmentLoadOp,
    storeOp: VkAttachmentStoreOp,
    stencilLoadOp: VkAttachmentLoadOp,
    stencilStoreOp: VkAttachmentStoreOp,
    initialLayout: VkImageLayout,
    finalLayout: VkImageLayout,
};
pub const VkAttachmentDescription = struct_VkAttachmentDescription;
pub const struct_VkAttachmentReference = extern struct {
    attachment: u32,
    layout: VkImageLayout,
};
pub const VkAttachmentReference = struct_VkAttachmentReference;
pub const struct_VkFramebufferCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkFramebufferCreateFlags,
    renderPass: VkRenderPass,
    attachmentCount: u32,
    pAttachments: [*c]const VkImageView,
    width: u32,
    height: u32,
    layers: u32,
};
pub const VkFramebufferCreateInfo = struct_VkFramebufferCreateInfo;
pub const struct_VkSubpassDescription = extern struct {
    flags: VkSubpassDescriptionFlags,
    pipelineBindPoint: VkPipelineBindPoint,
    inputAttachmentCount: u32,
    pInputAttachments: [*c]const VkAttachmentReference,
    colorAttachmentCount: u32,
    pColorAttachments: [*c]const VkAttachmentReference,
    pResolveAttachments: [*c]const VkAttachmentReference,
    pDepthStencilAttachment: [*c]const VkAttachmentReference,
    preserveAttachmentCount: u32,
    pPreserveAttachments: [*c]const u32,
};
pub const VkSubpassDescription = struct_VkSubpassDescription;
pub const struct_VkSubpassDependency = extern struct {
    srcSubpass: u32,
    dstSubpass: u32,
    srcStageMask: VkPipelineStageFlags,
    dstStageMask: VkPipelineStageFlags,
    srcAccessMask: VkAccessFlags,
    dstAccessMask: VkAccessFlags,
    dependencyFlags: VkDependencyFlags,
};
pub const VkSubpassDependency = struct_VkSubpassDependency;
pub const struct_VkRenderPassCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkRenderPassCreateFlags,
    attachmentCount: u32,
    pAttachments: [*c]const VkAttachmentDescription,
    subpassCount: u32,
    pSubpasses: [*c]const VkSubpassDescription,
    dependencyCount: u32,
    pDependencies: [*c]const VkSubpassDependency,
};
pub const VkRenderPassCreateInfo = struct_VkRenderPassCreateInfo;
pub const struct_VkCommandPoolCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkCommandPoolCreateFlags,
    queueFamilyIndex: u32,
};
pub const VkCommandPoolCreateInfo = struct_VkCommandPoolCreateInfo;
pub const struct_VkCommandBufferAllocateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    commandPool: VkCommandPool,
    level: VkCommandBufferLevel,
    commandBufferCount: u32,
};
pub const VkCommandBufferAllocateInfo = struct_VkCommandBufferAllocateInfo;
pub const struct_VkCommandBufferInheritanceInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    renderPass: VkRenderPass,
    subpass: u32,
    framebuffer: VkFramebuffer,
    occlusionQueryEnable: VkBool32,
    queryFlags: VkQueryControlFlags,
    pipelineStatistics: VkQueryPipelineStatisticFlags,
};
pub const VkCommandBufferInheritanceInfo = struct_VkCommandBufferInheritanceInfo;
pub const struct_VkCommandBufferBeginInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkCommandBufferUsageFlags,
    pInheritanceInfo: [*c]const VkCommandBufferInheritanceInfo,
};
pub const VkCommandBufferBeginInfo = struct_VkCommandBufferBeginInfo;
pub const struct_VkBufferCopy = extern struct {
    srcOffset: vk.DeviceSize,
    dstOffset: vk.DeviceSize,
    size: vk.DeviceSize,
};
pub const VkBufferCopy = struct_VkBufferCopy;
pub const struct_VkImageSubresourceLayers = extern struct {
    aspectMask: VkImageAspectFlags,
    mipLevel: u32,
    baseArrayLayer: u32,
    layerCount: u32,
};
pub const VkImageSubresourceLayers = struct_VkImageSubresourceLayers;
pub const struct_VkBufferImageCopy = extern struct {
    bufferOffset: vk.DeviceSize,
    bufferRowLength: u32,
    bufferImageHeight: u32,
    imageSubresource: VkImageSubresourceLayers,
    imageOffset: VkOffset3D,
    imageExtent: VkExtent3D,
};
pub const VkBufferImageCopy = struct_VkBufferImageCopy;
pub const union_VkClearColorValue = extern union {
    float32: [4]f32,
    int32: [4]i32,
    uint32: [4]u32,
};
pub const VkClearColorValue = union_VkClearColorValue;
pub const struct_VkClearDepthStencilValue = extern struct {
    depth: f32,
    stencil: u32,
};
pub const VkClearDepthStencilValue = struct_VkClearDepthStencilValue;
pub const union_VkClearValue = extern union {
    color: VkClearColorValue,
    depthStencil: VkClearDepthStencilValue,
};
pub const VkClearValue = union_VkClearValue;
pub const struct_VkClearAttachment = extern struct {
    aspectMask: VkImageAspectFlags,
    colorAttachment: u32,
    clearValue: VkClearValue,
};
pub const VkClearAttachment = struct_VkClearAttachment;
pub const struct_VkClearRect = extern struct {
    rect: VkRect2D,
    baseArrayLayer: u32,
    layerCount: u32,
};
pub const VkClearRect = struct_VkClearRect;
pub const struct_VkImageBlit = extern struct {
    srcSubresource: VkImageSubresourceLayers,
    srcOffsets: [2]VkOffset3D,
    dstSubresource: VkImageSubresourceLayers,
    dstOffsets: [2]VkOffset3D,
};
pub const VkImageBlit = struct_VkImageBlit;
pub const struct_VkImageCopy = extern struct {
    srcSubresource: VkImageSubresourceLayers,
    srcOffset: VkOffset3D,
    dstSubresource: VkImageSubresourceLayers,
    dstOffset: VkOffset3D,
    extent: VkExtent3D,
};
pub const VkImageCopy = struct_VkImageCopy;
pub const struct_VkImageResolve = extern struct {
    srcSubresource: VkImageSubresourceLayers,
    srcOffset: VkOffset3D,
    dstSubresource: VkImageSubresourceLayers,
    dstOffset: VkOffset3D,
    extent: VkExtent3D,
};
pub const VkImageResolve = struct_VkImageResolve;
pub const struct_VkRenderPassBeginInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    renderPass: VkRenderPass,
    framebuffer: VkFramebuffer,
    renderArea: VkRect2D,
    clearValueCount: u32,
    pClearValues: [*c]const VkClearValue,
};
pub const VkRenderPassBeginInfo = struct_VkRenderPassBeginInfo;
pub const PFN_vkCreateInstance = ?fn ([*c]const vk.InstanceCreateInfo, [*c]const VkAllocationCallbacks, [*c]vk.Instance) callconv(.C) VkResult;
pub const PFN_vkDestroyInstance = ?fn (vk.Instance, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkEnumeratePhysicalDevices = ?fn (vk.Instance, [*c]u32, [*c]vk.PhysicalDevice) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceFeatures = ?fn (vk.PhysicalDevice, [*c]vk.PhysicalDeviceFeatures) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceFormatProperties = ?fn (vk.PhysicalDevice, VkFormat, [*c]VkFormatProperties) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceImageFormatProperties = ?fn (vk.PhysicalDevice, VkFormat, VkImageType, VkImageTiling, VkImageUsageFlags, VkImageCreateFlags, [*c]VkImageFormatProperties) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceProperties = ?fn (vk.PhysicalDevice, [*c]vk.PhysicalDeviceProperties) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceQueueFamilyProperties = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkQueueFamilyProperties) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceMemoryProperties = ?fn (vk.PhysicalDevice, [*c]vk.PhysicalDeviceMemoryProperties) callconv(.C) void;
pub const PFN_vkGetInstanceProcAddr = ?fn (vk.Instance, [*c]const u8) callconv(.C) PFN_vkVoidFunction;
pub const PFN_vkGetDeviceProcAddr = ?fn (vk.Device, [*c]const u8) callconv(.C) PFN_vkVoidFunction;
pub const PFN_vkCreateDevice = ?fn (vk.PhysicalDevice, [*c]const vk.DeviceCreateInfo, [*c]const VkAllocationCallbacks, [*c]vk.Device) callconv(.C) VkResult;
pub const PFN_vkDestroyDevice = ?fn (vk.Device, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkEnumerateInstanceExtensionProperties = ?fn ([*c]const u8, [*c]u32, [*c]VkExtensionProperties) callconv(.C) VkResult;
pub const PFN_vkEnumerateDeviceExtensionProperties = ?fn (vk.PhysicalDevice, [*c]const u8, [*c]u32, [*c]VkExtensionProperties) callconv(.C) VkResult;
pub const PFN_vkEnumerateInstanceLayerProperties = ?fn ([*c]u32, [*c]VkLayerProperties) callconv(.C) VkResult;
pub const PFN_vkEnumerateDeviceLayerProperties = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkLayerProperties) callconv(.C) VkResult;
pub const PFN_vkGetDeviceQueue = ?fn (vk.Device, u32, u32, [*c]VkQueue) callconv(.C) void;
pub const PFN_vkQueueSubmit = ?fn (VkQueue, u32, [*c]const VkSubmitInfo, VkFence) callconv(.C) VkResult;
pub const PFN_vkQueueWaitIdle = ?fn (VkQueue) callconv(.C) VkResult;
pub const PFN_vk.DeviceWaitIdle = ?fn (vk.Device) callconv(.C) VkResult;
pub const PFN_vkAllocateMemory = ?fn (vk.Device, [*c]const VkMemoryAllocateInfo, [*c]const VkAllocationCallbacks, [*c]vk.DeviceMemory) callconv(.C) VkResult;
pub const PFN_vkFreeMemory = ?fn (vk.Device, vk.DeviceMemory, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkMapMemory = ?fn (vk.Device, vk.DeviceMemory, vk.DeviceSize, vk.DeviceSize, VkMemoryMapFlags, [*c]?*anyopaque) callconv(.C) VkResult;
pub const PFN_vkUnmapMemory = ?fn (vk.Device, vk.DeviceMemory) callconv(.C) void;
pub const PFN_vkFlushMappedMemoryRanges = ?fn (vk.Device, u32, [*c]const VkMappedMemoryRange) callconv(.C) VkResult;
pub const PFN_vkInvalidateMappedMemoryRanges = ?fn (vk.Device, u32, [*c]const VkMappedMemoryRange) callconv(.C) VkResult;
pub const PFN_vkGetDeviceMemoryCommitment = ?fn (vk.Device, vk.DeviceMemory, [*c]vk.DeviceSize) callconv(.C) void;
pub const PFN_vkBindBufferMemory = ?fn (vk.Device, VkBuffer, vk.DeviceMemory, vk.DeviceSize) callconv(.C) VkResult;
pub const PFN_vkBindImageMemory = ?fn (vk.Device, VkImage, vk.DeviceMemory, vk.DeviceSize) callconv(.C) VkResult;
pub const PFN_vkGetBufferMemoryRequirements = ?fn (vk.Device, VkBuffer, [*c]VkMemoryRequirements) callconv(.C) void;
pub const PFN_vkGetImageMemoryRequirements = ?fn (vk.Device, VkImage, [*c]VkMemoryRequirements) callconv(.C) void;
pub const PFN_vkGetImageSparseMemoryRequirements = ?fn (vk.Device, VkImage, [*c]u32, [*c]VkSparseImageMemoryRequirements) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceSparseImageFormatProperties = ?fn (vk.PhysicalDevice, VkFormat, VkImageType, VkSampleCountFlagBits, VkImageUsageFlags, VkImageTiling, [*c]u32, [*c]VkSparseImageFormatProperties) callconv(.C) void;
pub const PFN_vkQueueBindSparse = ?fn (VkQueue, u32, [*c]const VkBindSparseInfo, VkFence) callconv(.C) VkResult;
pub const PFN_vkCreateFence = ?fn (vk.Device, [*c]const VkFenceCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkFence) callconv(.C) VkResult;
pub const PFN_vkDestroyFence = ?fn (vk.Device, VkFence, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkResetFences = ?fn (vk.Device, u32, [*c]const VkFence) callconv(.C) VkResult;
pub const PFN_vkGetFenceStatus = ?fn (vk.Device, VkFence) callconv(.C) VkResult;
pub const PFN_vkWaitForFences = ?fn (vk.Device, u32, [*c]const VkFence, VkBool32, u64) callconv(.C) VkResult;
pub const PFN_vkCreateSemaphore = ?fn (vk.Device, [*c]const VkSemaphoreCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkSemaphore) callconv(.C) VkResult;
pub const PFN_vkDestroySemaphore = ?fn (vk.Device, VkSemaphore, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreateEvent = ?fn (vk.Device, [*c]const VkEventCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkEvent) callconv(.C) VkResult;
pub const PFN_vkDestroyEvent = ?fn (vk.Device, VkEvent, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkGetEventStatus = ?fn (vk.Device, VkEvent) callconv(.C) VkResult;
pub const PFN_vkSetEvent = ?fn (vk.Device, VkEvent) callconv(.C) VkResult;
pub const PFN_vkResetEvent = ?fn (vk.Device, VkEvent) callconv(.C) VkResult;
pub const PFN_vkCreateQueryPool = ?fn (vk.Device, [*c]const VkQueryPoolCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkQueryPool) callconv(.C) VkResult;
pub const PFN_vkDestroyQueryPool = ?fn (vk.Device, VkQueryPool, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkGetQueryPoolResults = ?fn (vk.Device, VkQueryPool, u32, u32, usize, ?*anyopaque, vk.DeviceSize, VkQueryResultFlags) callconv(.C) VkResult;
pub const PFN_vkCreateBuffer = ?fn (vk.Device, [*c]const VkBufferCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkBuffer) callconv(.C) VkResult;
pub const PFN_vkDestroyBuffer = ?fn (vk.Device, VkBuffer, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreateBufferView = ?fn (vk.Device, [*c]const VkBufferViewCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkBufferView) callconv(.C) VkResult;
pub const PFN_vkDestroyBufferView = ?fn (vk.Device, VkBufferView, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreateImage = ?fn (vk.Device, [*c]const VkImageCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkImage) callconv(.C) VkResult;
pub const PFN_vkDestroyImage = ?fn (vk.Device, VkImage, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkGetImageSubresourceLayout = ?fn (vk.Device, VkImage, [*c]const VkImageSubresource, [*c]VkSubresourceLayout) callconv(.C) void;
pub const PFN_vkCreateImageView = ?fn (vk.Device, [*c]const VkImageViewCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkImageView) callconv(.C) VkResult;
pub const PFN_vkDestroyImageView = ?fn (vk.Device, VkImageView, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreateShaderModule = ?fn (vk.Device, [*c]const VkShaderModuleCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkShaderModule) callconv(.C) VkResult;
pub const PFN_vkDestroyShaderModule = ?fn (vk.Device, VkShaderModule, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreatePipelineCache = ?fn (vk.Device, [*c]const VkPipelineCacheCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkPipelineCache) callconv(.C) VkResult;
pub const PFN_vkDestroyPipelineCache = ?fn (vk.Device, VkPipelineCache, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkGetPipelineCacheData = ?fn (vk.Device, VkPipelineCache, [*c]usize, ?*anyopaque) callconv(.C) VkResult;
pub const PFN_vkMergePipelineCaches = ?fn (vk.Device, VkPipelineCache, u32, [*c]const VkPipelineCache) callconv(.C) VkResult;
pub const PFN_vkCreateGraphicsPipelines = ?fn (vk.Device, VkPipelineCache, u32, [*c]const VkGraphicsPipelineCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkPipeline) callconv(.C) VkResult;
pub const PFN_vkCreateComputePipelines = ?fn (vk.Device, VkPipelineCache, u32, [*c]const VkComputePipelineCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkPipeline) callconv(.C) VkResult;
pub const PFN_vkDestroyPipeline = ?fn (vk.Device, VkPipeline, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreatePipelineLayout = ?fn (vk.Device, [*c]const VkPipelineLayoutCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkPipelineLayout) callconv(.C) VkResult;
pub const PFN_vkDestroyPipelineLayout = ?fn (vk.Device, VkPipelineLayout, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreateSampler = ?fn (vk.Device, [*c]const VkSamplerCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkSampler) callconv(.C) VkResult;
pub const PFN_vkDestroySampler = ?fn (vk.Device, VkSampler, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreateDescriptorSetLayout = ?fn (vk.Device, [*c]const VkDescriptorSetLayoutCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkDescriptorSetLayout) callconv(.C) VkResult;
pub const PFN_vkDestroyDescriptorSetLayout = ?fn (vk.Device, VkDescriptorSetLayout, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreateDescriptorPool = ?fn (vk.Device, [*c]const VkDescriptorPoolCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkDescriptorPool) callconv(.C) VkResult;
pub const PFN_vkDestroyDescriptorPool = ?fn (vk.Device, VkDescriptorPool, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkResetDescriptorPool = ?fn (vk.Device, VkDescriptorPool, VkDescriptorPoolResetFlags) callconv(.C) VkResult;
pub const PFN_vkAllocateDescriptorSets = ?fn (vk.Device, [*c]const VkDescriptorSetAllocateInfo, [*c]VkDescriptorSet) callconv(.C) VkResult;
pub const PFN_vkFreeDescriptorSets = ?fn (vk.Device, VkDescriptorPool, u32, [*c]const VkDescriptorSet) callconv(.C) VkResult;
pub const PFN_vkUpdateDescriptorSets = ?fn (vk.Device, u32, [*c]const VkWriteDescriptorSet, u32, [*c]const VkCopyDescriptorSet) callconv(.C) void;
pub const PFN_vkCreateFramebuffer = ?fn (vk.Device, [*c]const VkFramebufferCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkFramebuffer) callconv(.C) VkResult;
pub const PFN_vkDestroyFramebuffer = ?fn (vk.Device, VkFramebuffer, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreateRenderPass = ?fn (vk.Device, [*c]const VkRenderPassCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkRenderPass) callconv(.C) VkResult;
pub const PFN_vkDestroyRenderPass = ?fn (vk.Device, VkRenderPass, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkGetRenderAreaGranularity = ?fn (vk.Device, VkRenderPass, [*c]VkExtent2D) callconv(.C) void;
pub const PFN_vkCreateCommandPool = ?fn (vk.Device, [*c]const VkCommandPoolCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkCommandPool) callconv(.C) VkResult;
pub const PFN_vkDestroyCommandPool = ?fn (vk.Device, VkCommandPool, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkResetCommandPool = ?fn (vk.Device, VkCommandPool, VkCommandPoolResetFlags) callconv(.C) VkResult;
pub const PFN_vkAllocateCommandBuffers = ?fn (vk.Device, [*c]const VkCommandBufferAllocateInfo, [*c]VkCommandBuffer) callconv(.C) VkResult;
pub const PFN_vkFreeCommandBuffers = ?fn (vk.Device, VkCommandPool, u32, [*c]const VkCommandBuffer) callconv(.C) void;
pub const PFN_vkBeginCommandBuffer = ?fn (VkCommandBuffer, [*c]const VkCommandBufferBeginInfo) callconv(.C) VkResult;
pub const PFN_vkEndCommandBuffer = ?fn (VkCommandBuffer) callconv(.C) VkResult;
pub const PFN_vkResetCommandBuffer = ?fn (VkCommandBuffer, VkCommandBufferResetFlags) callconv(.C) VkResult;
pub const PFN_vkCmdBindPipeline = ?fn (VkCommandBuffer, VkPipelineBindPoint, VkPipeline) callconv(.C) void;
pub const PFN_vkCmdSetViewport = ?fn (VkCommandBuffer, u32, u32, [*c]const VkViewport) callconv(.C) void;
pub const PFN_vkCmdSetScissor = ?fn (VkCommandBuffer, u32, u32, [*c]const VkRect2D) callconv(.C) void;
pub const PFN_vkCmdSetLineWidth = ?fn (VkCommandBuffer, f32) callconv(.C) void;
pub const PFN_vkCmdSetDepthBias = ?fn (VkCommandBuffer, f32, f32, f32) callconv(.C) void;
pub const PFN_vkCmdSetBlendConstants = ?fn (VkCommandBuffer, [*c]const f32) callconv(.C) void;
pub const PFN_vkCmdSetDepthBounds = ?fn (VkCommandBuffer, f32, f32) callconv(.C) void;
pub const PFN_vkCmdSetStencilCompareMask = ?fn (VkCommandBuffer, VkStencilFaceFlags, u32) callconv(.C) void;
pub const PFN_vkCmdSetStencilWriteMask = ?fn (VkCommandBuffer, VkStencilFaceFlags, u32) callconv(.C) void;
pub const PFN_vkCmdSetStencilReference = ?fn (VkCommandBuffer, VkStencilFaceFlags, u32) callconv(.C) void;
pub const PFN_vkCmdBindDescriptorSets = ?fn (VkCommandBuffer, VkPipelineBindPoint, VkPipelineLayout, u32, u32, [*c]const VkDescriptorSet, u32, [*c]const u32) callconv(.C) void;
pub const PFN_vkCmdBindIndexBuffer = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, VkIndexType) callconv(.C) void;
pub const PFN_vkCmdBindVertexBuffers = ?fn (VkCommandBuffer, u32, u32, [*c]const VkBuffer, [*c]const vk.DeviceSize) callconv(.C) void;
pub const PFN_vkCmdDraw = ?fn (VkCommandBuffer, u32, u32, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawIndexed = ?fn (VkCommandBuffer, u32, u32, u32, i32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawIndirect = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawIndexedIndirect = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDispatch = ?fn (VkCommandBuffer, u32, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDispatchIndirect = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize) callconv(.C) void;
pub const PFN_vkCmdCopyBuffer = ?fn (VkCommandBuffer, VkBuffer, VkBuffer, u32, [*c]const VkBufferCopy) callconv(.C) void;
pub const PFN_vkCmdCopyImage = ?fn (VkCommandBuffer, VkImage, VkImageLayout, VkImage, VkImageLayout, u32, [*c]const VkImageCopy) callconv(.C) void;
pub const PFN_vkCmdBlitImage = ?fn (VkCommandBuffer, VkImage, VkImageLayout, VkImage, VkImageLayout, u32, [*c]const VkImageBlit, VkFilter) callconv(.C) void;
pub const PFN_vkCmdCopyBufferToImage = ?fn (VkCommandBuffer, VkBuffer, VkImage, VkImageLayout, u32, [*c]const VkBufferImageCopy) callconv(.C) void;
pub const PFN_vkCmdCopyImageToBuffer = ?fn (VkCommandBuffer, VkImage, VkImageLayout, VkBuffer, u32, [*c]const VkBufferImageCopy) callconv(.C) void;
pub const PFN_vkCmdUpdateBuffer = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, vk.DeviceSize, ?*const anyopaque) callconv(.C) void;
pub const PFN_vkCmdFillBuffer = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, vk.DeviceSize, u32) callconv(.C) void;
pub const PFN_vkCmdClearColorImage = ?fn (VkCommandBuffer, VkImage, VkImageLayout, [*c]const VkClearColorValue, u32, [*c]const VkImageSubresourceRange) callconv(.C) void;
pub const PFN_vkCmdClearDepthStencilImage = ?fn (VkCommandBuffer, VkImage, VkImageLayout, [*c]const VkClearDepthStencilValue, u32, [*c]const VkImageSubresourceRange) callconv(.C) void;
pub const PFN_vkCmdClearAttachments = ?fn (VkCommandBuffer, u32, [*c]const VkClearAttachment, u32, [*c]const VkClearRect) callconv(.C) void;
pub const PFN_vkCmdResolveImage = ?fn (VkCommandBuffer, VkImage, VkImageLayout, VkImage, VkImageLayout, u32, [*c]const VkImageResolve) callconv(.C) void;
pub const PFN_vkCmdSetEvent = ?fn (VkCommandBuffer, VkEvent, VkPipelineStageFlags) callconv(.C) void;
pub const PFN_vkCmdResetEvent = ?fn (VkCommandBuffer, VkEvent, VkPipelineStageFlags) callconv(.C) void;
pub const PFN_vkCmdWaitEvents = ?fn (VkCommandBuffer, u32, [*c]const VkEvent, VkPipelineStageFlags, VkPipelineStageFlags, u32, [*c]const VkMemoryBarrier, u32, [*c]const VkBufferMemoryBarrier, u32, [*c]const VkImageMemoryBarrier) callconv(.C) void;
pub const PFN_vkCmdPipelineBarrier = ?fn (VkCommandBuffer, VkPipelineStageFlags, VkPipelineStageFlags, VkDependencyFlags, u32, [*c]const VkMemoryBarrier, u32, [*c]const VkBufferMemoryBarrier, u32, [*c]const VkImageMemoryBarrier) callconv(.C) void;
pub const PFN_vkCmdBeginQuery = ?fn (VkCommandBuffer, VkQueryPool, u32, VkQueryControlFlags) callconv(.C) void;
pub const PFN_vkCmdEndQuery = ?fn (VkCommandBuffer, VkQueryPool, u32) callconv(.C) void;
pub const PFN_vkCmdResetQueryPool = ?fn (VkCommandBuffer, VkQueryPool, u32, u32) callconv(.C) void;
pub const PFN_vkCmdWriteTimestamp = ?fn (VkCommandBuffer, VkPipelineStageFlagBits, VkQueryPool, u32) callconv(.C) void;
pub const PFN_vkCmdCopyQueryPoolResults = ?fn (VkCommandBuffer, VkQueryPool, u32, u32, VkBuffer, vk.DeviceSize, vk.DeviceSize, VkQueryResultFlags) callconv(.C) void;
pub const PFN_vkCmdPushConstants = ?fn (VkCommandBuffer, VkPipelineLayout, VkShaderStageFlags, u32, u32, ?*const anyopaque) callconv(.C) void;
pub const PFN_vkCmdBeginRenderPass = ?fn (VkCommandBuffer, [*c]const VkRenderPassBeginInfo, VkSubpassContents) callconv(.C) void;
pub const PFN_vkCmdNextSubpass = ?fn (VkCommandBuffer, VkSubpassContents) callconv(.C) void;
pub const PFN_vkCmdEndRenderPass = ?fn (VkCommandBuffer) callconv(.C) void;
pub const PFN_vkCmdExecuteCommands = ?fn (VkCommandBuffer, u32, [*c]const VkCommandBuffer) callconv(.C) void;
pub extern fn vkCreateInstance(pCreateInfo: [*c]const vk.InstanceCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pInstance: [*c]vk.Instance) VkResult;
pub extern fn vkDestroyInstance(instance: vk.Instance, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkEnumeratePhysicalDevices(instance: vk.Instance, pPhysicalDeviceCount: [*c]u32, pPhysicalDevices: [*c]vk.PhysicalDevice) VkResult;
pub extern fn vkGetPhysicalDeviceFeatures(physicalDevice: vk.PhysicalDevice, pFeatures: [*c]vk.PhysicalDeviceFeatures) void;
pub extern fn vkGetPhysicalDeviceFormatProperties(physicalDevice: vk.PhysicalDevice, format: VkFormat, pFormatProperties: [*c]VkFormatProperties) void;
pub extern fn vkGetPhysicalDeviceImageFormatProperties(physicalDevice: vk.PhysicalDevice, format: VkFormat, @"type": VkImageType, tiling: VkImageTiling, usage: VkImageUsageFlags, flags: VkImageCreateFlags, pImageFormatProperties: [*c]VkImageFormatProperties) VkResult;
pub extern fn vkGetPhysicalDeviceProperties(physicalDevice: vk.PhysicalDevice, pProperties: [*c]vk.PhysicalDeviceProperties) void;
pub extern fn vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice: vk.PhysicalDevice, pQueueFamilyPropertyCount: [*c]u32, pQueueFamilyProperties: [*c]VkQueueFamilyProperties) void;
pub extern fn vkGetPhysicalDeviceMemoryProperties(physicalDevice: vk.PhysicalDevice, pMemoryProperties: [*c]vk.PhysicalDeviceMemoryProperties) void;
pub extern fn vkGetInstanceProcAddr(instance: vk.Instance, pName: [*c]const u8) PFN_vkVoidFunction;
pub extern fn vkGetDeviceProcAddr(device: vk.Device, pName: [*c]const u8) PFN_vkVoidFunction;
pub extern fn vkCreateDevice(physicalDevice: vk.PhysicalDevice, pCreateInfo: [*c]const vk.DeviceCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pDevice: [*c]vk.Device) VkResult;
pub extern fn vkDestroyDevice(device: vk.Device, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkEnumerateInstanceExtensionProperties(pLayerName: [*c]const u8, pPropertyCount: [*c]u32, pProperties: [*c]VkExtensionProperties) VkResult;
pub extern fn vkEnumerateDeviceExtensionProperties(physicalDevice: vk.PhysicalDevice, pLayerName: [*c]const u8, pPropertyCount: [*c]u32, pProperties: [*c]VkExtensionProperties) VkResult;
pub extern fn vkEnumerateInstanceLayerProperties(pPropertyCount: [*c]u32, pProperties: [*c]VkLayerProperties) VkResult;
pub extern fn vkEnumerateDeviceLayerProperties(physicalDevice: vk.PhysicalDevice, pPropertyCount: [*c]u32, pProperties: [*c]VkLayerProperties) VkResult;
pub extern fn vkGetDeviceQueue(device: vk.Device, queueFamilyIndex: u32, queueIndex: u32, pQueue: [*c]VkQueue) void;
pub extern fn vkQueueSubmit(queue: VkQueue, submitCount: u32, pSubmits: [*c]const VkSubmitInfo, fence: VkFence) VkResult;
pub extern fn vkQueueWaitIdle(queue: VkQueue) VkResult;
pub extern fn vk.DeviceWaitIdle(device: vk.Device) VkResult;
pub extern fn vkAllocateMemory(device: vk.Device, pAllocateInfo: [*c]const VkMemoryAllocateInfo, pAllocator: [*c]const VkAllocationCallbacks, pMemory: [*c]vk.DeviceMemory) VkResult;
pub extern fn vkFreeMemory(device: vk.Device, memory: vk.DeviceMemory, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkMapMemory(device: vk.Device, memory: vk.DeviceMemory, offset: vk.DeviceSize, size: vk.DeviceSize, flags: VkMemoryMapFlags, ppData: [*c]?*anyopaque) VkResult;
pub extern fn vkUnmapMemory(device: vk.Device, memory: vk.DeviceMemory) void;
pub extern fn vkFlushMappedMemoryRanges(device: vk.Device, memoryRangeCount: u32, pMemoryRanges: [*c]const VkMappedMemoryRange) VkResult;
pub extern fn vkInvalidateMappedMemoryRanges(device: vk.Device, memoryRangeCount: u32, pMemoryRanges: [*c]const VkMappedMemoryRange) VkResult;
pub extern fn vkGetDeviceMemoryCommitment(device: vk.Device, memory: vk.DeviceMemory, pCommittedMemoryInBytes: [*c]vk.DeviceSize) void;
pub extern fn vkBindBufferMemory(device: vk.Device, buffer: VkBuffer, memory: vk.DeviceMemory, memoryOffset: vk.DeviceSize) VkResult;
pub extern fn vkBindImageMemory(device: vk.Device, image: VkImage, memory: vk.DeviceMemory, memoryOffset: vk.DeviceSize) VkResult;
pub extern fn vkGetBufferMemoryRequirements(device: vk.Device, buffer: VkBuffer, pMemoryRequirements: [*c]VkMemoryRequirements) void;
pub extern fn vkGetImageMemoryRequirements(device: vk.Device, image: VkImage, pMemoryRequirements: [*c]VkMemoryRequirements) void;
pub extern fn vkGetImageSparseMemoryRequirements(device: vk.Device, image: VkImage, pSparseMemoryRequirementCount: [*c]u32, pSparseMemoryRequirements: [*c]VkSparseImageMemoryRequirements) void;
pub extern fn vkGetPhysicalDeviceSparseImageFormatProperties(physicalDevice: vk.PhysicalDevice, format: VkFormat, @"type": VkImageType, samples: VkSampleCountFlagBits, usage: VkImageUsageFlags, tiling: VkImageTiling, pPropertyCount: [*c]u32, pProperties: [*c]VkSparseImageFormatProperties) void;
pub extern fn vkQueueBindSparse(queue: VkQueue, bindInfoCount: u32, pBindInfo: [*c]const VkBindSparseInfo, fence: VkFence) VkResult;
pub extern fn vkCreateFence(device: vk.Device, pCreateInfo: [*c]const VkFenceCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pFence: [*c]VkFence) VkResult;
pub extern fn vkDestroyFence(device: vk.Device, fence: VkFence, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkResetFences(device: vk.Device, fenceCount: u32, pFences: [*c]const VkFence) VkResult;
pub extern fn vkGetFenceStatus(device: vk.Device, fence: VkFence) VkResult;
pub extern fn vkWaitForFences(device: vk.Device, fenceCount: u32, pFences: [*c]const VkFence, waitAll: VkBool32, timeout: u64) VkResult;
pub extern fn vkCreateSemaphore(device: vk.Device, pCreateInfo: [*c]const VkSemaphoreCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pSemaphore: [*c]VkSemaphore) VkResult;
pub extern fn vkDestroySemaphore(device: vk.Device, semaphore: VkSemaphore, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreateEvent(device: vk.Device, pCreateInfo: [*c]const VkEventCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pEvent: [*c]VkEvent) VkResult;
pub extern fn vkDestroyEvent(device: vk.Device, event: VkEvent, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkGetEventStatus(device: vk.Device, event: VkEvent) VkResult;
pub extern fn vkSetEvent(device: vk.Device, event: VkEvent) VkResult;
pub extern fn vkResetEvent(device: vk.Device, event: VkEvent) VkResult;
pub extern fn vkCreateQueryPool(device: vk.Device, pCreateInfo: [*c]const VkQueryPoolCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pQueryPool: [*c]VkQueryPool) VkResult;
pub extern fn vkDestroyQueryPool(device: vk.Device, queryPool: VkQueryPool, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkGetQueryPoolResults(device: vk.Device, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32, dataSize: usize, pData: ?*anyopaque, stride: vk.DeviceSize, flags: VkQueryResultFlags) VkResult;
pub extern fn vkCreateBuffer(device: vk.Device, pCreateInfo: [*c]const VkBufferCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pBuffer: [*c]VkBuffer) VkResult;
pub extern fn vkDestroyBuffer(device: vk.Device, buffer: VkBuffer, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreateBufferView(device: vk.Device, pCreateInfo: [*c]const VkBufferViewCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pView: [*c]VkBufferView) VkResult;
pub extern fn vkDestroyBufferView(device: vk.Device, bufferView: VkBufferView, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreateImage(device: vk.Device, pCreateInfo: [*c]const VkImageCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pImage: [*c]VkImage) VkResult;
pub extern fn vkDestroyImage(device: vk.Device, image: VkImage, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkGetImageSubresourceLayout(device: vk.Device, image: VkImage, pSubresource: [*c]const VkImageSubresource, pLayout: [*c]VkSubresourceLayout) void;
pub extern fn vkCreateImageView(device: vk.Device, pCreateInfo: [*c]const VkImageViewCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pView: [*c]VkImageView) VkResult;
pub extern fn vkDestroyImageView(device: vk.Device, imageView: VkImageView, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreateShaderModule(device: vk.Device, pCreateInfo: [*c]const VkShaderModuleCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pShaderModule: [*c]VkShaderModule) VkResult;
pub extern fn vkDestroyShaderModule(device: vk.Device, shaderModule: VkShaderModule, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreatePipelineCache(device: vk.Device, pCreateInfo: [*c]const VkPipelineCacheCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pPipelineCache: [*c]VkPipelineCache) VkResult;
pub extern fn vkDestroyPipelineCache(device: vk.Device, pipelineCache: VkPipelineCache, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkGetPipelineCacheData(device: vk.Device, pipelineCache: VkPipelineCache, pDataSize: [*c]usize, pData: ?*anyopaque) VkResult;
pub extern fn vkMergePipelineCaches(device: vk.Device, dstCache: VkPipelineCache, srcCacheCount: u32, pSrcCaches: [*c]const VkPipelineCache) VkResult;
pub extern fn vkCreateGraphicsPipelines(device: vk.Device, pipelineCache: VkPipelineCache, createInfoCount: u32, pCreateInfos: [*c]const VkGraphicsPipelineCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pPipelines: [*c]VkPipeline) VkResult;
pub extern fn vkCreateComputePipelines(device: vk.Device, pipelineCache: VkPipelineCache, createInfoCount: u32, pCreateInfos: [*c]const VkComputePipelineCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pPipelines: [*c]VkPipeline) VkResult;
pub extern fn vkDestroyPipeline(device: vk.Device, pipeline: VkPipeline, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreatePipelineLayout(device: vk.Device, pCreateInfo: [*c]const VkPipelineLayoutCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pPipelineLayout: [*c]VkPipelineLayout) VkResult;
pub extern fn vkDestroyPipelineLayout(device: vk.Device, pipelineLayout: VkPipelineLayout, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreateSampler(device: vk.Device, pCreateInfo: [*c]const VkSamplerCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pSampler: [*c]VkSampler) VkResult;
pub extern fn vkDestroySampler(device: vk.Device, sampler: VkSampler, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreateDescriptorSetLayout(device: vk.Device, pCreateInfo: [*c]const VkDescriptorSetLayoutCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pSetLayout: [*c]VkDescriptorSetLayout) VkResult;
pub extern fn vkDestroyDescriptorSetLayout(device: vk.Device, descriptorSetLayout: VkDescriptorSetLayout, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreateDescriptorPool(device: vk.Device, pCreateInfo: [*c]const VkDescriptorPoolCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pDescriptorPool: [*c]VkDescriptorPool) VkResult;
pub extern fn vkDestroyDescriptorPool(device: vk.Device, descriptorPool: VkDescriptorPool, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkResetDescriptorPool(device: vk.Device, descriptorPool: VkDescriptorPool, flags: VkDescriptorPoolResetFlags) VkResult;
pub extern fn vkAllocateDescriptorSets(device: vk.Device, pAllocateInfo: [*c]const VkDescriptorSetAllocateInfo, pDescriptorSets: [*c]VkDescriptorSet) VkResult;
pub extern fn vkFreeDescriptorSets(device: vk.Device, descriptorPool: VkDescriptorPool, descriptorSetCount: u32, pDescriptorSets: [*c]const VkDescriptorSet) VkResult;
pub extern fn vkUpdateDescriptorSets(device: vk.Device, descriptorWriteCount: u32, pDescriptorWrites: [*c]const VkWriteDescriptorSet, descriptorCopyCount: u32, pDescriptorCopies: [*c]const VkCopyDescriptorSet) void;
pub extern fn vkCreateFramebuffer(device: vk.Device, pCreateInfo: [*c]const VkFramebufferCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pFramebuffer: [*c]VkFramebuffer) VkResult;
pub extern fn vkDestroyFramebuffer(device: vk.Device, framebuffer: VkFramebuffer, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreateRenderPass(device: vk.Device, pCreateInfo: [*c]const VkRenderPassCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pRenderPass: [*c]VkRenderPass) VkResult;
pub extern fn vkDestroyRenderPass(device: vk.Device, renderPass: VkRenderPass, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkGetRenderAreaGranularity(device: vk.Device, renderPass: VkRenderPass, pGranularity: [*c]VkExtent2D) void;
pub extern fn vkCreateCommandPool(device: vk.Device, pCreateInfo: [*c]const VkCommandPoolCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pCommandPool: [*c]VkCommandPool) VkResult;
pub extern fn vkDestroyCommandPool(device: vk.Device, commandPool: VkCommandPool, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkResetCommandPool(device: vk.Device, commandPool: VkCommandPool, flags: VkCommandPoolResetFlags) VkResult;
pub extern fn vkAllocateCommandBuffers(device: vk.Device, pAllocateInfo: [*c]const VkCommandBufferAllocateInfo, pCommandBuffers: [*c]VkCommandBuffer) VkResult;
pub extern fn vkFreeCommandBuffers(device: vk.Device, commandPool: VkCommandPool, commandBufferCount: u32, pCommandBuffers: [*c]const VkCommandBuffer) void;
pub extern fn vkBeginCommandBuffer(commandBuffer: VkCommandBuffer, pBeginInfo: [*c]const VkCommandBufferBeginInfo) VkResult;
pub extern fn vkEndCommandBuffer(commandBuffer: VkCommandBuffer) VkResult;
pub extern fn vkResetCommandBuffer(commandBuffer: VkCommandBuffer, flags: VkCommandBufferResetFlags) VkResult;
pub extern fn vkCmdBindPipeline(commandBuffer: VkCommandBuffer, pipelineBindPoint: VkPipelineBindPoint, pipeline: VkPipeline) void;
pub extern fn vkCmdSetViewport(commandBuffer: VkCommandBuffer, firstViewport: u32, viewportCount: u32, pViewports: [*c]const VkViewport) void;
pub extern fn vkCmdSetScissor(commandBuffer: VkCommandBuffer, firstScissor: u32, scissorCount: u32, pScissors: [*c]const VkRect2D) void;
pub extern fn vkCmdSetLineWidth(commandBuffer: VkCommandBuffer, lineWidth: f32) void;
pub extern fn vkCmdSetDepthBias(commandBuffer: VkCommandBuffer, depthBiasConstantFactor: f32, depthBiasClamp: f32, depthBiasSlopeFactor: f32) void;
pub extern fn vkCmdSetBlendConstants(commandBuffer: VkCommandBuffer, blendConstants: [*c]const f32) void;
pub extern fn vkCmdSetDepthBounds(commandBuffer: VkCommandBuffer, minDepthBounds: f32, maxDepthBounds: f32) void;
pub extern fn vkCmdSetStencilCompareMask(commandBuffer: VkCommandBuffer, faceMask: VkStencilFaceFlags, compareMask: u32) void;
pub extern fn vkCmdSetStencilWriteMask(commandBuffer: VkCommandBuffer, faceMask: VkStencilFaceFlags, writeMask: u32) void;
pub extern fn vkCmdSetStencilReference(commandBuffer: VkCommandBuffer, faceMask: VkStencilFaceFlags, reference: u32) void;
pub extern fn vkCmdBindDescriptorSets(commandBuffer: VkCommandBuffer, pipelineBindPoint: VkPipelineBindPoint, layout: VkPipelineLayout, firstSet: u32, descriptorSetCount: u32, pDescriptorSets: [*c]const VkDescriptorSet, dynamicOffsetCount: u32, pDynamicOffsets: [*c]const u32) void;
pub extern fn vkCmdBindIndexBuffer(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, indexType: VkIndexType) void;
pub extern fn vkCmdBindVertexBuffers(commandBuffer: VkCommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: [*c]const VkBuffer, pOffsets: [*c]const vk.DeviceSize) void;
pub extern fn vkCmdDraw(commandBuffer: VkCommandBuffer, vertexCount: u32, instanceCount: u32, firstVertex: u32, firstInstance: u32) void;
pub extern fn vkCmdDrawIndexed(commandBuffer: VkCommandBuffer, indexCount: u32, instanceCount: u32, firstIndex: u32, vertexOffset: i32, firstInstance: u32) void;
pub extern fn vkCmdDrawIndirect(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, drawCount: u32, stride: u32) void;
pub extern fn vkCmdDrawIndexedIndirect(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, drawCount: u32, stride: u32) void;
pub extern fn vkCmdDispatch(commandBuffer: VkCommandBuffer, groupCountX: u32, groupCountY: u32, groupCountZ: u32) void;
pub extern fn vkCmdDispatchIndirect(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize) void;
pub extern fn vkCmdCopyBuffer(commandBuffer: VkCommandBuffer, srcBuffer: VkBuffer, dstBuffer: VkBuffer, regionCount: u32, pRegions: [*c]const VkBufferCopy) void;
pub extern fn vkCmdCopyImage(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: VkImageLayout, dstImage: VkImage, dstImageLayout: VkImageLayout, regionCount: u32, pRegions: [*c]const VkImageCopy) void;
pub extern fn vkCmdBlitImage(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: VkImageLayout, dstImage: VkImage, dstImageLayout: VkImageLayout, regionCount: u32, pRegions: [*c]const VkImageBlit, filter: VkFilter) void;
pub extern fn vkCmdCopyBufferToImage(commandBuffer: VkCommandBuffer, srcBuffer: VkBuffer, dstImage: VkImage, dstImageLayout: VkImageLayout, regionCount: u32, pRegions: [*c]const VkBufferImageCopy) void;
pub extern fn vkCmdCopyImageToBuffer(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: VkImageLayout, dstBuffer: VkBuffer, regionCount: u32, pRegions: [*c]const VkBufferImageCopy) void;
pub extern fn vkCmdUpdateBuffer(commandBuffer: VkCommandBuffer, dstBuffer: VkBuffer, dstOffset: vk.DeviceSize, dataSize: vk.DeviceSize, pData: ?*const anyopaque) void;
pub extern fn vkCmdFillBuffer(commandBuffer: VkCommandBuffer, dstBuffer: VkBuffer, dstOffset: vk.DeviceSize, size: vk.DeviceSize, data: u32) void;
pub extern fn vkCmdClearColorImage(commandBuffer: VkCommandBuffer, image: VkImage, imageLayout: VkImageLayout, pColor: [*c]const VkClearColorValue, rangeCount: u32, pRanges: [*c]const VkImageSubresourceRange) void;
pub extern fn vkCmdClearDepthStencilImage(commandBuffer: VkCommandBuffer, image: VkImage, imageLayout: VkImageLayout, pDepthStencil: [*c]const VkClearDepthStencilValue, rangeCount: u32, pRanges: [*c]const VkImageSubresourceRange) void;
pub extern fn vkCmdClearAttachments(commandBuffer: VkCommandBuffer, attachmentCount: u32, pAttachments: [*c]const VkClearAttachment, rectCount: u32, pRects: [*c]const VkClearRect) void;
pub extern fn vkCmdResolveImage(commandBuffer: VkCommandBuffer, srcImage: VkImage, srcImageLayout: VkImageLayout, dstImage: VkImage, dstImageLayout: VkImageLayout, regionCount: u32, pRegions: [*c]const VkImageResolve) void;
pub extern fn vkCmdSetEvent(commandBuffer: VkCommandBuffer, event: VkEvent, stageMask: VkPipelineStageFlags) void;
pub extern fn vkCmdResetEvent(commandBuffer: VkCommandBuffer, event: VkEvent, stageMask: VkPipelineStageFlags) void;
pub extern fn vkCmdWaitEvents(commandBuffer: VkCommandBuffer, eventCount: u32, pEvents: [*c]const VkEvent, srcStageMask: VkPipelineStageFlags, dstStageMask: VkPipelineStageFlags, memoryBarrierCount: u32, pMemoryBarriers: [*c]const VkMemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: [*c]const VkBufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: [*c]const VkImageMemoryBarrier) void;
pub extern fn vkCmdPipelineBarrier(commandBuffer: VkCommandBuffer, srcStageMask: VkPipelineStageFlags, dstStageMask: VkPipelineStageFlags, dependencyFlags: VkDependencyFlags, memoryBarrierCount: u32, pMemoryBarriers: [*c]const VkMemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: [*c]const VkBufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: [*c]const VkImageMemoryBarrier) void;
pub extern fn vkCmdBeginQuery(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, query: u32, flags: VkQueryControlFlags) void;
pub extern fn vkCmdEndQuery(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, query: u32) void;
pub extern fn vkCmdResetQueryPool(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32) void;
pub extern fn vkCmdWriteTimestamp(commandBuffer: VkCommandBuffer, pipelineStage: VkPipelineStageFlagBits, queryPool: VkQueryPool, query: u32) void;
pub extern fn vkCmdCopyQueryPoolResults(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32, dstBuffer: VkBuffer, dstOffset: vk.DeviceSize, stride: vk.DeviceSize, flags: VkQueryResultFlags) void;
pub extern fn vkCmdPushConstants(commandBuffer: VkCommandBuffer, layout: VkPipelineLayout, stageFlags: VkShaderStageFlags, offset: u32, size: u32, pValues: ?*const anyopaque) void;
pub extern fn vkCmdBeginRenderPass(commandBuffer: VkCommandBuffer, pRenderPassBegin: [*c]const VkRenderPassBeginInfo, contents: VkSubpassContents) void;
pub extern fn vkCmdNextSubpass(commandBuffer: VkCommandBuffer, contents: VkSubpassContents) void;
pub extern fn vkCmdEndRenderPass(commandBuffer: VkCommandBuffer) void;
pub extern fn vkCmdExecuteCommands(commandBuffer: VkCommandBuffer, commandBufferCount: u32, pCommandBuffers: [*c]const VkCommandBuffer) void;
pub const struct_VkSamplerYcbcrConversion_T = opaque {};
pub const VkSamplerYcbcrConversion = ?*struct_VkSamplerYcbcrConversion_T;
pub const struct_VkDescriptorUpdateTemplate_T = opaque {};
pub const VkDescriptorUpdateTemplate = ?*struct_VkDescriptorUpdateTemplate_T;
pub const VK_POINT_CLIPPING_BEHAVIOR_ALL_CLIP_PLANES: c_int = 0;
pub const VK_POINT_CLIPPING_BEHAVIOR_USER_CLIP_PLANES_ONLY: c_int = 1;
pub const VK_POINT_CLIPPING_BEHAVIOR_ALL_CLIP_PLANES_KHR: c_int = 0;
pub const VK_POINT_CLIPPING_BEHAVIOR_USER_CLIP_PLANES_ONLY_KHR: c_int = 1;
pub const VK_POINT_CLIPPING_BEHAVIOR_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPointClippingBehavior = c_uint;
pub const VkPointClippingBehavior = enum_VkPointClippingBehavior;
pub const VK_TESSELLATION_DOMAIN_ORIGIN_UPPER_LEFT: c_int = 0;
pub const VK_TESSELLATION_DOMAIN_ORIGIN_LOWER_LEFT: c_int = 1;
pub const VK_TESSELLATION_DOMAIN_ORIGIN_UPPER_LEFT_KHR: c_int = 0;
pub const VK_TESSELLATION_DOMAIN_ORIGIN_LOWER_LEFT_KHR: c_int = 1;
pub const VK_TESSELLATION_DOMAIN_ORIGIN_MAX_ENUM: c_int = 2147483647;
pub const enum_VkTessellationDomainOrigin = c_uint;
pub const VkTessellationDomainOrigin = enum_VkTessellationDomainOrigin;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_RGB_IDENTITY: c_int = 0;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_IDENTITY: c_int = 1;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_709: c_int = 2;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_601: c_int = 3;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_2020: c_int = 4;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_RGB_IDENTITY_KHR: c_int = 0;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_IDENTITY_KHR: c_int = 1;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_709_KHR: c_int = 2;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_601_KHR: c_int = 3;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_YCBCR_2020_KHR: c_int = 4;
pub const VK_SAMPLER_YCBCR_MODEL_CONVERSION_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSamplerYcbcrModelConversion = c_uint;
pub const VkSamplerYcbcrModelConversion = enum_VkSamplerYcbcrModelConversion;
pub const VK_SAMPLER_YCBCR_RANGE_ITU_FULL: c_int = 0;
pub const VK_SAMPLER_YCBCR_RANGE_ITU_NARROW: c_int = 1;
pub const VK_SAMPLER_YCBCR_RANGE_ITU_FULL_KHR: c_int = 0;
pub const VK_SAMPLER_YCBCR_RANGE_ITU_NARROW_KHR: c_int = 1;
pub const VK_SAMPLER_YCBCR_RANGE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSamplerYcbcrRange = c_uint;
pub const VkSamplerYcbcrRange = enum_VkSamplerYcbcrRange;
pub const VK_CHROMA_LOCATION_COSITED_EVEN: c_int = 0;
pub const VK_CHROMA_LOCATION_MIDPOINT: c_int = 1;
pub const VK_CHROMA_LOCATION_COSITED_EVEN_KHR: c_int = 0;
pub const VK_CHROMA_LOCATION_MIDPOINT_KHR: c_int = 1;
pub const VK_CHROMA_LOCATION_MAX_ENUM: c_int = 2147483647;
pub const enum_VkChromaLocation = c_uint;
pub const VkChromaLocation = enum_VkChromaLocation;
pub const VK_DESCRIPTOR_UPDATE_TEMPLATE_TYPE_DESCRIPTOR_SET: c_int = 0;
pub const VK_DESCRIPTOR_UPDATE_TEMPLATE_TYPE_PUSH_DESCRIPTORS_KHR: c_int = 1;
pub const VK_DESCRIPTOR_UPDATE_TEMPLATE_TYPE_DESCRIPTOR_SET_KHR: c_int = 0;
pub const VK_DESCRIPTOR_UPDATE_TEMPLATE_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkDescriptorUpdateTemplateType = c_uint;
pub const VkDescriptorUpdateTemplateType = enum_VkDescriptorUpdateTemplateType;
pub const VK_SUBGROUP_FEATURE_BASIC_BIT: c_int = 1;
pub const VK_SUBGROUP_FEATURE_VOTE_BIT: c_int = 2;
pub const VK_SUBGROUP_FEATURE_ARITHMETIC_BIT: c_int = 4;
pub const VK_SUBGROUP_FEATURE_BALLOT_BIT: c_int = 8;
pub const VK_SUBGROUP_FEATURE_SHUFFLE_BIT: c_int = 16;
pub const VK_SUBGROUP_FEATURE_SHUFFLE_RELATIVE_BIT: c_int = 32;
pub const VK_SUBGROUP_FEATURE_CLUSTERED_BIT: c_int = 64;
pub const VK_SUBGROUP_FEATURE_QUAD_BIT: c_int = 128;
pub const VK_SUBGROUP_FEATURE_PARTITIONED_BIT_NV: c_int = 256;
pub const VK_SUBGROUP_FEATURE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSubgroupFeatureFlagBits = c_uint;
pub const VkSubgroupFeatureFlagBits = enum_VkSubgroupFeatureFlagBits;
pub const VkSubgroupFeatureFlags = VkFlags;
pub const VK_PEER_MEMORY_FEATURE_COPY_SRC_BIT: c_int = 1;
pub const VK_PEER_MEMORY_FEATURE_COPY_DST_BIT: c_int = 2;
pub const VK_PEER_MEMORY_FEATURE_GENERIC_SRC_BIT: c_int = 4;
pub const VK_PEER_MEMORY_FEATURE_GENERIC_DST_BIT: c_int = 8;
pub const VK_PEER_MEMORY_FEATURE_COPY_SRC_BIT_KHR: c_int = 1;
pub const VK_PEER_MEMORY_FEATURE_COPY_DST_BIT_KHR: c_int = 2;
pub const VK_PEER_MEMORY_FEATURE_GENERIC_SRC_BIT_KHR: c_int = 4;
pub const VK_PEER_MEMORY_FEATURE_GENERIC_DST_BIT_KHR: c_int = 8;
pub const VK_PEER_MEMORY_FEATURE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkPeerMemoryFeatureFlagBits = c_uint;
pub const VkPeerMemoryFeatureFlagBits = enum_VkPeerMemoryFeatureFlagBits;
pub const VkPeerMemoryFeatureFlags = VkFlags;
pub const VK_MEMORY_ALLOCATE_DEVICE_MASK_BIT: c_int = 1;
pub const VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT: c_int = 2;
pub const VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT: c_int = 4;
pub const VK_MEMORY_ALLOCATE_DEVICE_MASK_BIT_KHR: c_int = 1;
pub const VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_BIT_KHR: c_int = 2;
pub const VK_MEMORY_ALLOCATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_KHR: c_int = 4;
pub const VK_MEMORY_ALLOCATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkMemoryAllocateFlagBits = c_uint;
pub const VkMemoryAllocateFlagBits = enum_VkMemoryAllocateFlagBits;
pub const VkMemoryAllocateFlags = VkFlags;
pub const VkCommandPoolTrimFlags = VkFlags;
pub const VkDescriptorUpdateTemplateCreateFlags = VkFlags;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT: c_int = 1;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT: c_int = 2;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT: c_int = 4;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_TEXTURE_BIT: c_int = 8;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_TEXTURE_KMT_BIT: c_int = 16;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_HEAP_BIT: c_int = 32;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_RESOURCE_BIT: c_int = 64;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_DMA_BUF_BIT_EXT: c_int = 512;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_ANDROID_HARDWARE_BUFFER_BIT_ANDROID: c_int = 1024;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_HOST_ALLOCATION_BIT_EXT: c_int = 128;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_HOST_MAPPED_FOREIGN_MEMORY_BIT_EXT: c_int = 256;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_ZIRCON_VMO_BIT_FUCHSIA: c_int = 2048;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_RDMA_ADDRESS_BIT_NV: c_int = 4096;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_FD_BIT_KHR: c_int = 1;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT_KHR: c_int = 2;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT_KHR: c_int = 4;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_TEXTURE_BIT_KHR: c_int = 8;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_TEXTURE_KMT_BIT_KHR: c_int = 16;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_HEAP_BIT_KHR: c_int = 32;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D12_RESOURCE_BIT_KHR: c_int = 64;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkExternalMemoryHandleTypeFlagBits = c_uint;
pub const VkExternalMemoryHandleTypeFlagBits = enum_VkExternalMemoryHandleTypeFlagBits;
pub const VkExternalMemoryHandleTypeFlags = VkFlags;
pub const VK_EXTERNAL_MEMORY_FEATURE_DEDICATED_ONLY_BIT: c_int = 1;
pub const VK_EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT: c_int = 2;
pub const VK_EXTERNAL_MEMORY_FEATURE_IMPORTABLE_BIT: c_int = 4;
pub const VK_EXTERNAL_MEMORY_FEATURE_DEDICATED_ONLY_BIT_KHR: c_int = 1;
pub const VK_EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT_KHR: c_int = 2;
pub const VK_EXTERNAL_MEMORY_FEATURE_IMPORTABLE_BIT_KHR: c_int = 4;
pub const VK_EXTERNAL_MEMORY_FEATURE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkExternalMemoryFeatureFlagBits = c_uint;
pub const VkExternalMemoryFeatureFlagBits = enum_VkExternalMemoryFeatureFlagBits;
pub const VkExternalMemoryFeatureFlags = VkFlags;
pub const VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_FD_BIT: c_int = 1;
pub const VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_BIT: c_int = 2;
pub const VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT: c_int = 4;
pub const VK_EXTERNAL_FENCE_HANDLE_TYPE_SYNC_FD_BIT: c_int = 8;
pub const VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_FD_BIT_KHR: c_int = 1;
pub const VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_BIT_KHR: c_int = 2;
pub const VK_EXTERNAL_FENCE_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT_KHR: c_int = 4;
pub const VK_EXTERNAL_FENCE_HANDLE_TYPE_SYNC_FD_BIT_KHR: c_int = 8;
pub const VK_EXTERNAL_FENCE_HANDLE_TYPE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkExternalFenceHandleTypeFlagBits = c_uint;
pub const VkExternalFenceHandleTypeFlagBits = enum_VkExternalFenceHandleTypeFlagBits;
pub const VkExternalFenceHandleTypeFlags = VkFlags;
pub const VK_EXTERNAL_FENCE_FEATURE_EXPORTABLE_BIT: c_int = 1;
pub const VK_EXTERNAL_FENCE_FEATURE_IMPORTABLE_BIT: c_int = 2;
pub const VK_EXTERNAL_FENCE_FEATURE_EXPORTABLE_BIT_KHR: c_int = 1;
pub const VK_EXTERNAL_FENCE_FEATURE_IMPORTABLE_BIT_KHR: c_int = 2;
pub const VK_EXTERNAL_FENCE_FEATURE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkExternalFenceFeatureFlagBits = c_uint;
pub const VkExternalFenceFeatureFlagBits = enum_VkExternalFenceFeatureFlagBits;
pub const VkExternalFenceFeatureFlags = VkFlags;
pub const VK_FENCE_IMPORT_TEMPORARY_BIT: c_int = 1;
pub const VK_FENCE_IMPORT_TEMPORARY_BIT_KHR: c_int = 1;
pub const VK_FENCE_IMPORT_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkFenceImportFlagBits = c_uint;
pub const VkFenceImportFlagBits = enum_VkFenceImportFlagBits;
pub const VkFenceImportFlags = VkFlags;
pub const VK_SEMAPHORE_IMPORT_TEMPORARY_BIT: c_int = 1;
pub const VK_SEMAPHORE_IMPORT_TEMPORARY_BIT_KHR: c_int = 1;
pub const VK_SEMAPHORE_IMPORT_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSemaphoreImportFlagBits = c_uint;
pub const VkSemaphoreImportFlagBits = enum_VkSemaphoreImportFlagBits;
pub const VkSemaphoreImportFlags = VkFlags;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_FD_BIT: c_int = 1;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT: c_int = 2;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT: c_int = 4;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_D3D12_FENCE_BIT: c_int = 8;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_SYNC_FD_BIT: c_int = 16;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_ZIRCON_EVENT_BIT_FUCHSIA: c_int = 128;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_D3D11_FENCE_BIT: c_int = 8;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_FD_BIT_KHR: c_int = 1;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_BIT_KHR: c_int = 2;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT_KHR: c_int = 4;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_D3D12_FENCE_BIT_KHR: c_int = 8;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_SYNC_FD_BIT_KHR: c_int = 16;
pub const VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkExternalSemaphoreHandleTypeFlagBits = c_uint;
pub const VkExternalSemaphoreHandleTypeFlagBits = enum_VkExternalSemaphoreHandleTypeFlagBits;
pub const VkExternalSemaphoreHandleTypeFlags = VkFlags;
pub const VK_EXTERNAL_SEMAPHORE_FEATURE_EXPORTABLE_BIT: c_int = 1;
pub const VK_EXTERNAL_SEMAPHORE_FEATURE_IMPORTABLE_BIT: c_int = 2;
pub const VK_EXTERNAL_SEMAPHORE_FEATURE_EXPORTABLE_BIT_KHR: c_int = 1;
pub const VK_EXTERNAL_SEMAPHORE_FEATURE_IMPORTABLE_BIT_KHR: c_int = 2;
pub const VK_EXTERNAL_SEMAPHORE_FEATURE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkExternalSemaphoreFeatureFlagBits = c_uint;
pub const VkExternalSemaphoreFeatureFlagBits = enum_VkExternalSemaphoreFeatureFlagBits;
pub const VkExternalSemaphoreFeatureFlags = VkFlags;
pub const struct_vk.PhysicalDeviceSubgroupProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    subgroupSize: u32,
    supportedStages: VkShaderStageFlags,
    supportedOperations: VkSubgroupFeatureFlags,
    quadOperationsInAllStages: VkBool32,
};
pub const vk.PhysicalDeviceSubgroupProperties = struct_vk.PhysicalDeviceSubgroupProperties;
pub const struct_VkBindBufferMemoryInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    buffer: VkBuffer,
    memory: vk.DeviceMemory,
    memoryOffset: vk.DeviceSize,
};
pub const VkBindBufferMemoryInfo = struct_VkBindBufferMemoryInfo;
pub const struct_VkBindImageMemoryInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    image: VkImage,
    memory: vk.DeviceMemory,
    memoryOffset: vk.DeviceSize,
};
pub const VkBindImageMemoryInfo = struct_VkBindImageMemoryInfo;
pub const struct_vk.PhysicalDevice16BitStorageFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    storageBuffer16BitAccess: VkBool32,
    uniformAndStorageBuffer16BitAccess: VkBool32,
    storagePushConstant16: VkBool32,
    storageInputOutput16: VkBool32,
};
pub const vk.PhysicalDevice16BitStorageFeatures = struct_vk.PhysicalDevice16BitStorageFeatures;
pub const struct_VkMemoryDedicatedRequirements = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    prefersDedicatedAllocation: VkBool32,
    requiresDedicatedAllocation: VkBool32,
};
pub const VkMemoryDedicatedRequirements = struct_VkMemoryDedicatedRequirements;
pub const struct_VkMemoryDedicatedAllocateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    image: VkImage,
    buffer: VkBuffer,
};
pub const VkMemoryDedicatedAllocateInfo = struct_VkMemoryDedicatedAllocateInfo;
pub const struct_VkMemoryAllocateFlagsInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkMemoryAllocateFlags,
    deviceMask: u32,
};
pub const VkMemoryAllocateFlagsInfo = struct_VkMemoryAllocateFlagsInfo;
pub const struct_vk.DeviceGroupRenderPassBeginInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    deviceMask: u32,
    deviceRenderAreaCount: u32,
    pDeviceRenderAreas: [*c]const VkRect2D,
};
pub const vk.DeviceGroupRenderPassBeginInfo = struct_vk.DeviceGroupRenderPassBeginInfo;
pub const struct_vk.DeviceGroupCommandBufferBeginInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    deviceMask: u32,
};
pub const vk.DeviceGroupCommandBufferBeginInfo = struct_vk.DeviceGroupCommandBufferBeginInfo;
pub const struct_vk.DeviceGroupSubmitInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    waitSemaphoreCount: u32,
    pWaitSemaphoreDeviceIndices: [*c]const u32,
    commandBufferCount: u32,
    pCommandBufferDeviceMasks: [*c]const u32,
    signalSemaphoreCount: u32,
    pSignalSemaphoreDeviceIndices: [*c]const u32,
};
pub const vk.DeviceGroupSubmitInfo = struct_vk.DeviceGroupSubmitInfo;
pub const struct_vk.DeviceGroupBindSparseInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    resourceDeviceIndex: u32,
    memoryDeviceIndex: u32,
};
pub const vk.DeviceGroupBindSparseInfo = struct_vk.DeviceGroupBindSparseInfo;
pub const struct_VkBindBufferMemoryDeviceGroupInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    deviceIndexCount: u32,
    pDeviceIndices: [*c]const u32,
};
pub const VkBindBufferMemoryDeviceGroupInfo = struct_VkBindBufferMemoryDeviceGroupInfo;
pub const struct_VkBindImageMemoryDeviceGroupInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    deviceIndexCount: u32,
    pDeviceIndices: [*c]const u32,
    splitInstanceBindRegionCount: u32,
    pSplitInstanceBindRegions: [*c]const VkRect2D,
};
pub const VkBindImageMemoryDeviceGroupInfo = struct_VkBindImageMemoryDeviceGroupInfo;
pub const struct_vk.PhysicalDeviceGroupProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    physicalDeviceCount: u32,
    physicalDevices: [32]vk.PhysicalDevice,
    subsetAllocation: VkBool32,
};
pub const vk.PhysicalDeviceGroupProperties = struct_vk.PhysicalDeviceGroupProperties;
pub const struct_vk.DeviceGroupDeviceCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    physicalDeviceCount: u32,
    pPhysicalDevices: [*c]const vk.PhysicalDevice,
};
pub const vk.DeviceGroupDeviceCreateInfo = struct_vk.DeviceGroupDeviceCreateInfo;
pub const struct_VkBufferMemoryRequirementsInfo2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    buffer: VkBuffer,
};
pub const VkBufferMemoryRequirementsInfo2 = struct_VkBufferMemoryRequirementsInfo2;
pub const struct_VkImageMemoryRequirementsInfo2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    image: VkImage,
};
pub const VkImageMemoryRequirementsInfo2 = struct_VkImageMemoryRequirementsInfo2;
pub const struct_VkImageSparseMemoryRequirementsInfo2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    image: VkImage,
};
pub const VkImageSparseMemoryRequirementsInfo2 = struct_VkImageSparseMemoryRequirementsInfo2;
pub const struct_VkMemoryRequirements2 = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    memoryRequirements: VkMemoryRequirements,
};
pub const VkMemoryRequirements2 = struct_VkMemoryRequirements2;
pub const struct_VkSparseImageMemoryRequirements2 = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    memoryRequirements: VkSparseImageMemoryRequirements,
};
pub const VkSparseImageMemoryRequirements2 = struct_VkSparseImageMemoryRequirements2;
pub const struct_vk.PhysicalDeviceFeatures2 = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    features: vk.PhysicalDeviceFeatures,
};
pub const vk.PhysicalDeviceFeatures2 = struct_vk.PhysicalDeviceFeatures2;
pub const struct_vk.PhysicalDeviceProperties2 = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    properties: vk.PhysicalDeviceProperties,
};
pub const vk.PhysicalDeviceProperties2 = struct_vk.PhysicalDeviceProperties2;
pub const struct_VkFormatProperties2 = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    formatProperties: VkFormatProperties,
};
pub const VkFormatProperties2 = struct_VkFormatProperties2;
pub const struct_VkImageFormatProperties2 = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    imageFormatProperties: VkImageFormatProperties,
};
pub const VkImageFormatProperties2 = struct_VkImageFormatProperties2;
pub const struct_vk.PhysicalDeviceImageFormatInfo2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    format: VkFormat,
    type: VkImageType,
    tiling: VkImageTiling,
    usage: VkImageUsageFlags,
    flags: VkImageCreateFlags,
};
pub const vk.PhysicalDeviceImageFormatInfo2 = struct_vk.PhysicalDeviceImageFormatInfo2;
pub const struct_VkQueueFamilyProperties2 = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    queueFamilyProperties: VkQueueFamilyProperties,
};
pub const VkQueueFamilyProperties2 = struct_VkQueueFamilyProperties2;
pub const struct_vk.PhysicalDeviceMemoryProperties2 = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    memoryProperties: vk.PhysicalDeviceMemoryProperties,
};
pub const vk.PhysicalDeviceMemoryProperties2 = struct_vk.PhysicalDeviceMemoryProperties2;
pub const struct_VkSparseImageFormatProperties2 = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    properties: VkSparseImageFormatProperties,
};
pub const VkSparseImageFormatProperties2 = struct_VkSparseImageFormatProperties2;
pub const struct_vk.PhysicalDeviceSparseImageFormatInfo2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    format: VkFormat,
    type: VkImageType,
    samples: VkSampleCountFlagBits,
    usage: VkImageUsageFlags,
    tiling: VkImageTiling,
};
pub const vk.PhysicalDeviceSparseImageFormatInfo2 = struct_vk.PhysicalDeviceSparseImageFormatInfo2;
pub const struct_vk.PhysicalDevicePointClippingProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    pointClippingBehavior: VkPointClippingBehavior,
};
pub const vk.PhysicalDevicePointClippingProperties = struct_vk.PhysicalDevicePointClippingProperties;
pub const struct_VkInputAttachmentAspectReference = extern struct {
    subpass: u32,
    inputAttachmentIndex: u32,
    aspectMask: VkImageAspectFlags,
};
pub const VkInputAttachmentAspectReference = struct_VkInputAttachmentAspectReference;
pub const struct_VkRenderPassInputAttachmentAspectCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    aspectReferenceCount: u32,
    pAspectReferences: [*c]const VkInputAttachmentAspectReference,
};
pub const VkRenderPassInputAttachmentAspectCreateInfo = struct_VkRenderPassInputAttachmentAspectCreateInfo;
pub const struct_VkImageViewUsageCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    usage: VkImageUsageFlags,
};
pub const VkImageViewUsageCreateInfo = struct_VkImageViewUsageCreateInfo;
pub const struct_VkPipelineTessellationDomainOriginStateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    domainOrigin: VkTessellationDomainOrigin,
};
pub const VkPipelineTessellationDomainOriginStateCreateInfo = struct_VkPipelineTessellationDomainOriginStateCreateInfo;
pub const struct_VkRenderPassMultiviewCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    subpassCount: u32,
    pViewMasks: [*c]const u32,
    dependencyCount: u32,
    pViewOffsets: [*c]const i32,
    correlationMaskCount: u32,
    pCorrelationMasks: [*c]const u32,
};
pub const VkRenderPassMultiviewCreateInfo = struct_VkRenderPassMultiviewCreateInfo;
pub const struct_vk.PhysicalDeviceMultiviewFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    multiview: VkBool32,
    multiviewGeometryShader: VkBool32,
    multiviewTessellationShader: VkBool32,
};
pub const vk.PhysicalDeviceMultiviewFeatures = struct_vk.PhysicalDeviceMultiviewFeatures;
pub const struct_vk.PhysicalDeviceMultiviewProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxMultiviewViewCount: u32,
    maxMultiviewInstanceIndex: u32,
};
pub const vk.PhysicalDeviceMultiviewProperties = struct_vk.PhysicalDeviceMultiviewProperties;
pub const struct_vk.PhysicalDeviceVariablePointersFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    variablePointersStorageBuffer: VkBool32,
    variablePointers: VkBool32,
};
pub const vk.PhysicalDeviceVariablePointersFeatures = struct_vk.PhysicalDeviceVariablePointersFeatures;
pub const vk.PhysicalDeviceVariablePointerFeatures = vk.PhysicalDeviceVariablePointersFeatures;
pub const struct_vk.PhysicalDeviceProtectedMemoryFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    protectedMemory: VkBool32,
};
pub const vk.PhysicalDeviceProtectedMemoryFeatures = struct_vk.PhysicalDeviceProtectedMemoryFeatures;
pub const struct_vk.PhysicalDeviceProtectedMemoryProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    protectedNoFault: VkBool32,
};
pub const vk.PhysicalDeviceProtectedMemoryProperties = struct_vk.PhysicalDeviceProtectedMemoryProperties;
pub const struct_vk.DeviceQueueInfo2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: vk.DeviceQueueCreateFlags,
    queueFamilyIndex: u32,
    queueIndex: u32,
};
pub const vk.DeviceQueueInfo2 = struct_vk.DeviceQueueInfo2;
pub const struct_VkProtectedSubmitInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    protectedSubmit: VkBool32,
};
pub const VkProtectedSubmitInfo = struct_VkProtectedSubmitInfo;
pub const struct_VkSamplerYcbcrConversionCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    format: VkFormat,
    ycbcrModel: VkSamplerYcbcrModelConversion,
    ycbcrRange: VkSamplerYcbcrRange,
    components: VkComponentMapping,
    xChromaOffset: VkChromaLocation,
    yChromaOffset: VkChromaLocation,
    chromaFilter: VkFilter,
    forceExplicitReconstruction: VkBool32,
};
pub const VkSamplerYcbcrConversionCreateInfo = struct_VkSamplerYcbcrConversionCreateInfo;
pub const struct_VkSamplerYcbcrConversionInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    conversion: VkSamplerYcbcrConversion,
};
pub const VkSamplerYcbcrConversionInfo = struct_VkSamplerYcbcrConversionInfo;
pub const struct_VkBindImagePlaneMemoryInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    planeAspect: VkImageAspectFlagBits,
};
pub const VkBindImagePlaneMemoryInfo = struct_VkBindImagePlaneMemoryInfo;
pub const struct_VkImagePlaneMemoryRequirementsInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    planeAspect: VkImageAspectFlagBits,
};
pub const VkImagePlaneMemoryRequirementsInfo = struct_VkImagePlaneMemoryRequirementsInfo;
pub const struct_vk.PhysicalDeviceSamplerYcbcrConversionFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    samplerYcbcrConversion: VkBool32,
};
pub const vk.PhysicalDeviceSamplerYcbcrConversionFeatures = struct_vk.PhysicalDeviceSamplerYcbcrConversionFeatures;
pub const struct_VkSamplerYcbcrConversionImageFormatProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    combinedImageSamplerDescriptorCount: u32,
};
pub const VkSamplerYcbcrConversionImageFormatProperties = struct_VkSamplerYcbcrConversionImageFormatProperties;
pub const struct_VkDescriptorUpdateTemplateEntry = extern struct {
    dstBinding: u32,
    dstArrayElement: u32,
    descriptorCount: u32,
    descriptorType: VkDescriptorType,
    offset: usize,
    stride: usize,
};
pub const VkDescriptorUpdateTemplateEntry = struct_VkDescriptorUpdateTemplateEntry;
pub const struct_VkDescriptorUpdateTemplateCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkDescriptorUpdateTemplateCreateFlags,
    descriptorUpdateEntryCount: u32,
    pDescriptorUpdateEntries: [*c]const VkDescriptorUpdateTemplateEntry,
    templateType: VkDescriptorUpdateTemplateType,
    descriptorSetLayout: VkDescriptorSetLayout,
    pipelineBindPoint: VkPipelineBindPoint,
    pipelineLayout: VkPipelineLayout,
    set: u32,
};
pub const VkDescriptorUpdateTemplateCreateInfo = struct_VkDescriptorUpdateTemplateCreateInfo;
pub const struct_VkExternalMemoryProperties = extern struct {
    externalMemoryFeatures: VkExternalMemoryFeatureFlags,
    exportFromImportedHandleTypes: VkExternalMemoryHandleTypeFlags,
    compatibleHandleTypes: VkExternalMemoryHandleTypeFlags,
};
pub const VkExternalMemoryProperties = struct_VkExternalMemoryProperties;
pub const struct_vk.PhysicalDeviceExternalImageFormatInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleType: VkExternalMemoryHandleTypeFlagBits,
};
pub const vk.PhysicalDeviceExternalImageFormatInfo = struct_vk.PhysicalDeviceExternalImageFormatInfo;
pub const struct_VkExternalImageFormatProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    externalMemoryProperties: VkExternalMemoryProperties,
};
pub const VkExternalImageFormatProperties = struct_VkExternalImageFormatProperties;
pub const struct_vk.PhysicalDeviceExternalBufferInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkBufferCreateFlags,
    usage: VkBufferUsageFlags,
    handleType: VkExternalMemoryHandleTypeFlagBits,
};
pub const vk.PhysicalDeviceExternalBufferInfo = struct_vk.PhysicalDeviceExternalBufferInfo;
pub const struct_VkExternalBufferProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    externalMemoryProperties: VkExternalMemoryProperties,
};
pub const VkExternalBufferProperties = struct_VkExternalBufferProperties;
pub const struct_vk.PhysicalDeviceIDProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    deviceUUID: [16]u8,
    driverUUID: [16]u8,
    deviceLUID: [8]u8,
    deviceNodeMask: u32,
    deviceLUIDValid: VkBool32,
};
pub const vk.PhysicalDeviceIDProperties = struct_vk.PhysicalDeviceIDProperties;
pub const struct_VkExternalMemoryImageCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleTypes: VkExternalMemoryHandleTypeFlags,
};
pub const VkExternalMemoryImageCreateInfo = struct_VkExternalMemoryImageCreateInfo;
pub const struct_VkExternalMemoryBufferCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleTypes: VkExternalMemoryHandleTypeFlags,
};
pub const VkExternalMemoryBufferCreateInfo = struct_VkExternalMemoryBufferCreateInfo;
pub const struct_VkExportMemoryAllocateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleTypes: VkExternalMemoryHandleTypeFlags,
};
pub const VkExportMemoryAllocateInfo = struct_VkExportMemoryAllocateInfo;
pub const struct_vk.PhysicalDeviceExternalFenceInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleType: VkExternalFenceHandleTypeFlagBits,
};
pub const vk.PhysicalDeviceExternalFenceInfo = struct_vk.PhysicalDeviceExternalFenceInfo;
pub const struct_VkExternalFenceProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    exportFromImportedHandleTypes: VkExternalFenceHandleTypeFlags,
    compatibleHandleTypes: VkExternalFenceHandleTypeFlags,
    externalFenceFeatures: VkExternalFenceFeatureFlags,
};
pub const VkExternalFenceProperties = struct_VkExternalFenceProperties;
pub const struct_VkExportFenceCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleTypes: VkExternalFenceHandleTypeFlags,
};
pub const VkExportFenceCreateInfo = struct_VkExportFenceCreateInfo;
pub const struct_VkExportSemaphoreCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleTypes: VkExternalSemaphoreHandleTypeFlags,
};
pub const VkExportSemaphoreCreateInfo = struct_VkExportSemaphoreCreateInfo;
pub const struct_vk.PhysicalDeviceExternalSemaphoreInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleType: VkExternalSemaphoreHandleTypeFlagBits,
};
pub const vk.PhysicalDeviceExternalSemaphoreInfo = struct_vk.PhysicalDeviceExternalSemaphoreInfo;
pub const struct_VkExternalSemaphoreProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    exportFromImportedHandleTypes: VkExternalSemaphoreHandleTypeFlags,
    compatibleHandleTypes: VkExternalSemaphoreHandleTypeFlags,
    externalSemaphoreFeatures: VkExternalSemaphoreFeatureFlags,
};
pub const VkExternalSemaphoreProperties = struct_VkExternalSemaphoreProperties;
pub const struct_vk.PhysicalDeviceMaintenance3Properties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxPerSetDescriptors: u32,
    maxMemoryAllocationSize: vk.DeviceSize,
};
pub const vk.PhysicalDeviceMaintenance3Properties = struct_vk.PhysicalDeviceMaintenance3Properties;
pub const struct_VkDescriptorSetLayoutSupport = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    supported: VkBool32,
};
pub const VkDescriptorSetLayoutSupport = struct_VkDescriptorSetLayoutSupport;
pub const struct_vk.PhysicalDeviceShaderDrawParametersFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderDrawParameters: VkBool32,
};
pub const vk.PhysicalDeviceShaderDrawParametersFeatures = struct_vk.PhysicalDeviceShaderDrawParametersFeatures;
pub const vk.PhysicalDeviceShaderDrawParameterFeatures = vk.PhysicalDeviceShaderDrawParametersFeatures;
pub const PFN_vkEnumerateInstanceVersion = ?fn ([*c]u32) callconv(.C) VkResult;
pub const PFN_vkBindBufferMemory2 = ?fn (vk.Device, u32, [*c]const VkBindBufferMemoryInfo) callconv(.C) VkResult;
pub const PFN_vkBindImageMemory2 = ?fn (vk.Device, u32, [*c]const VkBindImageMemoryInfo) callconv(.C) VkResult;
pub const PFN_vkGetDeviceGroupPeerMemoryFeatures = ?fn (vk.Device, u32, u32, u32, [*c]VkPeerMemoryFeatureFlags) callconv(.C) void;
pub const PFN_vkCmdSetDeviceMask = ?fn (VkCommandBuffer, u32) callconv(.C) void;
pub const PFN_vkCmdDispatchBase = ?fn (VkCommandBuffer, u32, u32, u32, u32, u32, u32) callconv(.C) void;
pub const PFN_vkEnumeratePhysicalDeviceGroups = ?fn (vk.Instance, [*c]u32, [*c]vk.PhysicalDeviceGroupProperties) callconv(.C) VkResult;
pub const PFN_vkGetImageMemoryRequirements2 = ?fn (vk.Device, [*c]const VkImageMemoryRequirementsInfo2, [*c]VkMemoryRequirements2) callconv(.C) void;
pub const PFN_vkGetBufferMemoryRequirements2 = ?fn (vk.Device, [*c]const VkBufferMemoryRequirementsInfo2, [*c]VkMemoryRequirements2) callconv(.C) void;
pub const PFN_vkGetImageSparseMemoryRequirements2 = ?fn (vk.Device, [*c]const VkImageSparseMemoryRequirementsInfo2, [*c]u32, [*c]VkSparseImageMemoryRequirements2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceFeatures2 = ?fn (vk.PhysicalDevice, [*c]vk.PhysicalDeviceFeatures2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceProperties2 = ?fn (vk.PhysicalDevice, [*c]vk.PhysicalDeviceProperties2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceFormatProperties2 = ?fn (vk.PhysicalDevice, VkFormat, [*c]VkFormatProperties2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceImageFormatProperties2 = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceImageFormatInfo2, [*c]VkImageFormatProperties2) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceQueueFamilyProperties2 = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkQueueFamilyProperties2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceMemoryProperties2 = ?fn (vk.PhysicalDevice, [*c]vk.PhysicalDeviceMemoryProperties2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceSparseImageFormatProperties2 = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceSparseImageFormatInfo2, [*c]u32, [*c]VkSparseImageFormatProperties2) callconv(.C) void;
pub const PFN_vkTrimCommandPool = ?fn (vk.Device, VkCommandPool, VkCommandPoolTrimFlags) callconv(.C) void;
pub const PFN_vkGetDeviceQueue2 = ?fn (vk.Device, [*c]const vk.DeviceQueueInfo2, [*c]VkQueue) callconv(.C) void;
pub const PFN_vkCreateSamplerYcbcrConversion = ?fn (vk.Device, [*c]const VkSamplerYcbcrConversionCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkSamplerYcbcrConversion) callconv(.C) VkResult;
pub const PFN_vkDestroySamplerYcbcrConversion = ?fn (vk.Device, VkSamplerYcbcrConversion, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCreateDescriptorUpdateTemplate = ?fn (vk.Device, [*c]const VkDescriptorUpdateTemplateCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkDescriptorUpdateTemplate) callconv(.C) VkResult;
pub const PFN_vkDestroyDescriptorUpdateTemplate = ?fn (vk.Device, VkDescriptorUpdateTemplate, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkUpdateDescriptorSetWithTemplate = ?fn (vk.Device, VkDescriptorSet, VkDescriptorUpdateTemplate, ?*const anyopaque) callconv(.C) void;
pub const PFN_vkGetPhysicalDevicexternalBufferProperties = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceExternalBufferInfo, [*c]VkExternalBufferProperties) callconv(.C) void;
pub const PFN_vkGetPhysicalDevicexternalFenceProperties = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceExternalFenceInfo, [*c]VkExternalFenceProperties) callconv(.C) void;
pub const PFN_vkGetPhysicalDevicexternalSemaphoreProperties = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceExternalSemaphoreInfo, [*c]VkExternalSemaphoreProperties) callconv(.C) void;
pub const PFN_vkGetDescriptorSetLayoutSupport = ?fn (vk.Device, [*c]const VkDescriptorSetLayoutCreateInfo, [*c]VkDescriptorSetLayoutSupport) callconv(.C) void;
pub extern fn vkEnumerateInstanceVersion(pApiVersion: [*c]u32) VkResult;
pub extern fn vkBindBufferMemory2(device: vk.Device, bindInfoCount: u32, pBindInfos: [*c]const VkBindBufferMemoryInfo) VkResult;
pub extern fn vkBindImageMemory2(device: vk.Device, bindInfoCount: u32, pBindInfos: [*c]const VkBindImageMemoryInfo) VkResult;
pub extern fn vkGetDeviceGroupPeerMemoryFeatures(device: vk.Device, heapIndex: u32, localDeviceIndex: u32, remoteDeviceIndex: u32, pPeerMemoryFeatures: [*c]VkPeerMemoryFeatureFlags) void;
pub extern fn vkCmdSetDeviceMask(commandBuffer: VkCommandBuffer, deviceMask: u32) void;
pub extern fn vkCmdDispatchBase(commandBuffer: VkCommandBuffer, baseGroupX: u32, baseGroupY: u32, baseGroupZ: u32, groupCountX: u32, groupCountY: u32, groupCountZ: u32) void;
pub extern fn vkEnumeratePhysicalDeviceGroups(instance: vk.Instance, pPhysicalDeviceGroupCount: [*c]u32, pPhysicalDeviceGroupProperties: [*c]vk.PhysicalDeviceGroupProperties) VkResult;
pub extern fn vkGetImageMemoryRequirements2(device: vk.Device, pInfo: [*c]const VkImageMemoryRequirementsInfo2, pMemoryRequirements: [*c]VkMemoryRequirements2) void;
pub extern fn vkGetBufferMemoryRequirements2(device: vk.Device, pInfo: [*c]const VkBufferMemoryRequirementsInfo2, pMemoryRequirements: [*c]VkMemoryRequirements2) void;
pub extern fn vkGetImageSparseMemoryRequirements2(device: vk.Device, pInfo: [*c]const VkImageSparseMemoryRequirementsInfo2, pSparseMemoryRequirementCount: [*c]u32, pSparseMemoryRequirements: [*c]VkSparseImageMemoryRequirements2) void;
pub extern fn vkGetPhysicalDeviceFeatures2(physicalDevice: vk.PhysicalDevice, pFeatures: [*c]vk.PhysicalDeviceFeatures2) void;
pub extern fn vkGetPhysicalDeviceProperties2(physicalDevice: vk.PhysicalDevice, pProperties: [*c]vk.PhysicalDeviceProperties2) void;
pub extern fn vkGetPhysicalDeviceFormatProperties2(physicalDevice: vk.PhysicalDevice, format: VkFormat, pFormatProperties: [*c]VkFormatProperties2) void;
pub extern fn vkGetPhysicalDeviceImageFormatProperties2(physicalDevice: vk.PhysicalDevice, pImageFormatInfo: [*c]const vk.PhysicalDeviceImageFormatInfo2, pImageFormatProperties: [*c]VkImageFormatProperties2) VkResult;
pub extern fn vkGetPhysicalDeviceQueueFamilyProperties2(physicalDevice: vk.PhysicalDevice, pQueueFamilyPropertyCount: [*c]u32, pQueueFamilyProperties: [*c]VkQueueFamilyProperties2) void;
pub extern fn vkGetPhysicalDeviceMemoryProperties2(physicalDevice: vk.PhysicalDevice, pMemoryProperties: [*c]vk.PhysicalDeviceMemoryProperties2) void;
pub extern fn vkGetPhysicalDeviceSparseImageFormatProperties2(physicalDevice: vk.PhysicalDevice, pFormatInfo: [*c]const vk.PhysicalDeviceSparseImageFormatInfo2, pPropertyCount: [*c]u32, pProperties: [*c]VkSparseImageFormatProperties2) void;
pub extern fn vkTrimCommandPool(device: vk.Device, commandPool: VkCommandPool, flags: VkCommandPoolTrimFlags) void;
pub extern fn vkGetDeviceQueue2(device: vk.Device, pQueueInfo: [*c]const vk.DeviceQueueInfo2, pQueue: [*c]VkQueue) void;
pub extern fn vkCreateSamplerYcbcrConversion(device: vk.Device, pCreateInfo: [*c]const VkSamplerYcbcrConversionCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pYcbcrConversion: [*c]VkSamplerYcbcrConversion) VkResult;
pub extern fn vkDestroySamplerYcbcrConversion(device: vk.Device, ycbcrConversion: VkSamplerYcbcrConversion, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCreateDescriptorUpdateTemplate(device: vk.Device, pCreateInfo: [*c]const VkDescriptorUpdateTemplateCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pDescriptorUpdateTemplate: [*c]VkDescriptorUpdateTemplate) VkResult;
pub extern fn vkDestroyDescriptorUpdateTemplate(device: vk.Device, descriptorUpdateTemplate: VkDescriptorUpdateTemplate, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkUpdateDescriptorSetWithTemplate(device: vk.Device, descriptorSet: VkDescriptorSet, descriptorUpdateTemplate: VkDescriptorUpdateTemplate, pData: ?*const anyopaque) void;
pub extern fn vkGetPhysicalDevicexternalBufferProperties(physicalDevice: vk.PhysicalDevice, pExternalBufferInfo: [*c]const vk.PhysicalDeviceExternalBufferInfo, pExternalBufferProperties: [*c]VkExternalBufferProperties) void;
pub extern fn vkGetPhysicalDevicexternalFenceProperties(physicalDevice: vk.PhysicalDevice, pExternalFenceInfo: [*c]const vk.PhysicalDeviceExternalFenceInfo, pExternalFenceProperties: [*c]VkExternalFenceProperties) void;
pub extern fn vkGetPhysicalDevicexternalSemaphoreProperties(physicalDevice: vk.PhysicalDevice, pExternalSemaphoreInfo: [*c]const vk.PhysicalDeviceExternalSemaphoreInfo, pExternalSemaphoreProperties: [*c]VkExternalSemaphoreProperties) void;
pub extern fn vkGetDescriptorSetLayoutSupport(device: vk.Device, pCreateInfo: [*c]const VkDescriptorSetLayoutCreateInfo, pSupport: [*c]VkDescriptorSetLayoutSupport) void;
pub const VK_DRIVER_ID_AMD_PROPRIETARY: c_int = 1;
pub const VK_DRIVER_ID_AMD_OPEN_SOURCE: c_int = 2;
pub const VK_DRIVER_ID_MESA_RADV: c_int = 3;
pub const VK_DRIVER_ID_NVIDIA_PROPRIETARY: c_int = 4;
pub const VK_DRIVER_ID_INTEL_PROPRIETARY_WINDOWS: c_int = 5;
pub const VK_DRIVER_ID_INTEL_OPEN_SOURCE_MESA: c_int = 6;
pub const VK_DRIVER_ID_IMAGINATION_PROPRIETARY: c_int = 7;
pub const VK_DRIVER_ID_QUALCOMM_PROPRIETARY: c_int = 8;
pub const VK_DRIVER_ID_ARM_PROPRIETARY: c_int = 9;
pub const VK_DRIVER_ID_GOOGLE_SWIFTSHADER: c_int = 10;
pub const VK_DRIVER_ID_GGP_PROPRIETARY: c_int = 11;
pub const VK_DRIVER_ID_BROADCOM_PROPRIETARY: c_int = 12;
pub const VK_DRIVER_ID_MESA_LLVMPIPE: c_int = 13;
pub const VK_DRIVER_ID_MOLTENVK: c_int = 14;
pub const VK_DRIVER_ID_COREAVI_PROPRIETARY: c_int = 15;
pub const VK_DRIVER_ID_JUICE_PROPRIETARY: c_int = 16;
pub const VK_DRIVER_ID_VERISILICON_PROPRIETARY: c_int = 17;
pub const VK_DRIVER_ID_MESA_TURNIP: c_int = 18;
pub const VK_DRIVER_ID_MESA_V3DV: c_int = 19;
pub const VK_DRIVER_ID_MESA_PANVK: c_int = 20;
pub const VK_DRIVER_ID_SAMSUNG_PROPRIETARY: c_int = 21;
pub const VK_DRIVER_ID_AMD_PROPRIETARY_KHR: c_int = 1;
pub const VK_DRIVER_ID_AMD_OPEN_SOURCE_KHR: c_int = 2;
pub const VK_DRIVER_ID_MESA_RADV_KHR: c_int = 3;
pub const VK_DRIVER_ID_NVIDIA_PROPRIETARY_KHR: c_int = 4;
pub const VK_DRIVER_ID_INTEL_PROPRIETARY_WINDOWS_KHR: c_int = 5;
pub const VK_DRIVER_ID_INTEL_OPEN_SOURCE_MESA_KHR: c_int = 6;
pub const VK_DRIVER_ID_IMAGINATION_PROPRIETARY_KHR: c_int = 7;
pub const VK_DRIVER_ID_QUALCOMM_PROPRIETARY_KHR: c_int = 8;
pub const VK_DRIVER_ID_ARM_PROPRIETARY_KHR: c_int = 9;
pub const VK_DRIVER_ID_GOOGLE_SWIFTSHADER_KHR: c_int = 10;
pub const VK_DRIVER_ID_GGP_PROPRIETARY_KHR: c_int = 11;
pub const VK_DRIVER_ID_BROADCOM_PROPRIETARY_KHR: c_int = 12;
pub const VK_DRIVER_ID_MAX_ENUM: c_int = 2147483647;
pub const enum_VkDriverId = c_uint;
pub const VkDriverId = enum_VkDriverId;
pub const VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_32_BIT_ONLY: c_int = 0;
pub const VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_ALL: c_int = 1;
pub const VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_NONE: c_int = 2;
pub const VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_32_BIT_ONLY_KHR: c_int = 0;
pub const VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_ALL_KHR: c_int = 1;
pub const VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_NONE_KHR: c_int = 2;
pub const VK_SHADER_FLOAT_CONTROLS_INDEPENDENCE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkShaderFloatControlsIndependence = c_uint;
pub const VkShaderFloatControlsIndependence = enum_VkShaderFloatControlsIndependence;
pub const VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE: c_int = 0;
pub const VK_SAMPLER_REDUCTION_MODE_MIN: c_int = 1;
pub const VK_SAMPLER_REDUCTION_MODE_MAX: c_int = 2;
pub const VK_SAMPLER_REDUCTION_MODE_WEIGHTED_AVERAGE_EXT: c_int = 0;
pub const VK_SAMPLER_REDUCTION_MODE_MIN_EXT: c_int = 1;
pub const VK_SAMPLER_REDUCTION_MODE_MAX_EXT: c_int = 2;
pub const VK_SAMPLER_REDUCTION_MODE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSamplerReductionMode = c_uint;
pub const VkSamplerReductionMode = enum_VkSamplerReductionMode;
pub const VK_SEMAPHORE_TYPE_BINARY: c_int = 0;
pub const VK_SEMAPHORE_TYPE_TIMELINE: c_int = 1;
pub const VK_SEMAPHORE_TYPE_BINARY_KHR: c_int = 0;
pub const VK_SEMAPHORE_TYPE_TIMELINE_KHR: c_int = 1;
pub const VK_SEMAPHORE_TYPE_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSemaphoreType = c_uint;
pub const VkSemaphoreType = enum_VkSemaphoreType;
pub const VK_RESOLVE_MODE_NONE: c_int = 0;
pub const VK_RESOLVE_MODE_SAMPLE_ZERO_BIT: c_int = 1;
pub const VK_RESOLVE_MODE_AVERAGE_BIT: c_int = 2;
pub const VK_RESOLVE_MODE_MIN_BIT: c_int = 4;
pub const VK_RESOLVE_MODE_MAX_BIT: c_int = 8;
pub const VK_RESOLVE_MODE_NONE_KHR: c_int = 0;
pub const VK_RESOLVE_MODE_SAMPLE_ZERO_BIT_KHR: c_int = 1;
pub const VK_RESOLVE_MODE_AVERAGE_BIT_KHR: c_int = 2;
pub const VK_RESOLVE_MODE_MIN_BIT_KHR: c_int = 4;
pub const VK_RESOLVE_MODE_MAX_BIT_KHR: c_int = 8;
pub const VK_RESOLVE_MODE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkResolveModeFlagBits = c_uint;
pub const VkResolveModeFlagBits = enum_VkResolveModeFlagBits;
pub const VkResolveModeFlags = VkFlags;
pub const VK_DESCRIPTOR_BINDING_UPDATE_AFTER_BIND_BIT: c_int = 1;
pub const VK_DESCRIPTOR_BINDING_UPDATE_UNUSED_WHILE_PENDING_BIT: c_int = 2;
pub const VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT: c_int = 4;
pub const VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT: c_int = 8;
pub const VK_DESCRIPTOR_BINDING_UPDATE_AFTER_BIND_BIT_EXT: c_int = 1;
pub const VK_DESCRIPTOR_BINDING_UPDATE_UNUSED_WHILE_PENDING_BIT_EXT: c_int = 2;
pub const VK_DESCRIPTOR_BINDING_PARTIALLY_BOUND_BIT_EXT: c_int = 4;
pub const VK_DESCRIPTOR_BINDING_VARIABLE_DESCRIPTOR_COUNT_BIT_EXT: c_int = 8;
pub const VK_DESCRIPTOR_BINDING_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkDescriptorBindingFlagBits = c_uint;
pub const VkDescriptorBindingFlagBits = enum_VkDescriptorBindingFlagBits;
pub const VkDescriptorBindingFlags = VkFlags;
pub const VK_SEMAPHORE_WAIT_ANY_BIT: c_int = 1;
pub const VK_SEMAPHORE_WAIT_ANY_BIT_KHR: c_int = 1;
pub const VK_SEMAPHORE_WAIT_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VkSemaphoreWaitFlagBits = c_uint;
pub const VkSemaphoreWaitFlagBits = enum_VkSemaphoreWaitFlagBits;
pub const VkSemaphoreWaitFlags = VkFlags;
pub const struct_vk.PhysicalDeviceVulkan11Features = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    storageBuffer16BitAccess: VkBool32,
    uniformAndStorageBuffer16BitAccess: VkBool32,
    storagePushConstant16: VkBool32,
    storageInputOutput16: VkBool32,
    multiview: VkBool32,
    multiviewGeometryShader: VkBool32,
    multiviewTessellationShader: VkBool32,
    variablePointersStorageBuffer: VkBool32,
    variablePointers: VkBool32,
    protectedMemory: VkBool32,
    samplerYcbcrConversion: VkBool32,
    shaderDrawParameters: VkBool32,
};
pub const vk.PhysicalDeviceVulkan11Features = struct_vk.PhysicalDeviceVulkan11Features;
pub const struct_vk.PhysicalDeviceVulkan11Properties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    deviceUUID: [16]u8,
    driverUUID: [16]u8,
    deviceLUID: [8]u8,
    deviceNodeMask: u32,
    deviceLUIDValid: VkBool32,
    subgroupSize: u32,
    subgroupSupportedStages: VkShaderStageFlags,
    subgroupSupportedOperations: VkSubgroupFeatureFlags,
    subgroupQuadOperationsInAllStages: VkBool32,
    pointClippingBehavior: VkPointClippingBehavior,
    maxMultiviewViewCount: u32,
    maxMultiviewInstanceIndex: u32,
    protectedNoFault: VkBool32,
    maxPerSetDescriptors: u32,
    maxMemoryAllocationSize: vk.DeviceSize,
};
pub const vk.PhysicalDeviceVulkan11Properties = struct_vk.PhysicalDeviceVulkan11Properties;
pub const struct_vk.PhysicalDeviceVulkan12Features = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    samplerMirrorClampToEdge: VkBool32,
    drawIndirectCount: VkBool32,
    storageBuffer8BitAccess: VkBool32,
    uniformAndStorageBuffer8BitAccess: VkBool32,
    storagePushConstant8: VkBool32,
    shaderBufferInt64Atomics: VkBool32,
    shaderSharedInt64Atomics: VkBool32,
    shaderFloat16: VkBool32,
    shaderInt8: VkBool32,
    descriptorIndexing: VkBool32,
    shaderInputAttachmentArrayDynamicIndexing: VkBool32,
    shaderUniformTexelBufferArrayDynamicIndexing: VkBool32,
    shaderStorageTexelBufferArrayDynamicIndexing: VkBool32,
    shaderUniformBufferArrayNonUniformIndexing: VkBool32,
    shaderSampledImageArrayNonUniformIndexing: VkBool32,
    shaderStorageBufferArrayNonUniformIndexing: VkBool32,
    shaderStorageImageArrayNonUniformIndexing: VkBool32,
    shaderInputAttachmentArrayNonUniformIndexing: VkBool32,
    shaderUniformTexelBufferArrayNonUniformIndexing: VkBool32,
    shaderStorageTexelBufferArrayNonUniformIndexing: VkBool32,
    descriptorBindingUniformBufferUpdateAfterBind: VkBool32,
    descriptorBindingSampledImageUpdateAfterBind: VkBool32,
    descriptorBindingStorageImageUpdateAfterBind: VkBool32,
    descriptorBindingStorageBufferUpdateAfterBind: VkBool32,
    descriptorBindingUniformTexelBufferUpdateAfterBind: VkBool32,
    descriptorBindingStorageTexelBufferUpdateAfterBind: VkBool32,
    descriptorBindingUpdateUnusedWhilePending: VkBool32,
    descriptorBindingPartiallyBound: VkBool32,
    descriptorBindingVariableDescriptorCount: VkBool32,
    runtimeDescriptorArray: VkBool32,
    samplerFilterMinmax: VkBool32,
    scalarBlockLayout: VkBool32,
    imagelessFramebuffer: VkBool32,
    uniformBufferStandardLayout: VkBool32,
    shaderSubgroupExtendedTypes: VkBool32,
    separateDepthStencilLayouts: VkBool32,
    hostQueryReset: VkBool32,
    timelineSemaphore: VkBool32,
    bufferDeviceAddress: VkBool32,
    bufferDeviceAddressCaptureReplay: VkBool32,
    bufferDeviceAddressMultiDevice: VkBool32,
    vulkanMemoryModel: VkBool32,
    vulkanMemoryModelDeviceScope: VkBool32,
    vulkanMemoryModelAvailabilityVisibilityChains: VkBool32,
    shaderOutputViewportIndex: VkBool32,
    shaderOutputLayer: VkBool32,
    subgroupBroadcastDynamicId: VkBool32,
};
pub const vk.PhysicalDeviceVulkan12Features = struct_vk.PhysicalDeviceVulkan12Features;
pub const struct_VkConformanceVersion = extern struct {
    major: u8,
    minor: u8,
    subminor: u8,
    patch: u8,
};
pub const VkConformanceVersion = struct_VkConformanceVersion;
pub const struct_vk.PhysicalDeviceVulkan12Properties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    driverID: VkDriverId,
    driverName: [256]u8,
    driverInfo: [256]u8,
    conformanceVersion: VkConformanceVersion,
    denormBehaviorIndependence: VkShaderFloatControlsIndependence,
    roundingModeIndependence: VkShaderFloatControlsIndependence,
    shaderSignedZeroInfNanPreserveFloat16: VkBool32,
    shaderSignedZeroInfNanPreserveFloat32: VkBool32,
    shaderSignedZeroInfNanPreserveFloat64: VkBool32,
    shaderDenormPreserveFloat16: VkBool32,
    shaderDenormPreserveFloat32: VkBool32,
    shaderDenormPreserveFloat64: VkBool32,
    shaderDenormFlushToZeroFloat16: VkBool32,
    shaderDenormFlushToZeroFloat32: VkBool32,
    shaderDenormFlushToZeroFloat64: VkBool32,
    shaderRoundingModeRTEFloat16: VkBool32,
    shaderRoundingModeRTEFloat32: VkBool32,
    shaderRoundingModeRTEFloat64: VkBool32,
    shaderRoundingModeRTZFloat16: VkBool32,
    shaderRoundingModeRTZFloat32: VkBool32,
    shaderRoundingModeRTZFloat64: VkBool32,
    maxUpdateAfterBindDescriptorsInAllPools: u32,
    shaderUniformBufferArrayNonUniformIndexingNative: VkBool32,
    shaderSampledImageArrayNonUniformIndexingNative: VkBool32,
    shaderStorageBufferArrayNonUniformIndexingNative: VkBool32,
    shaderStorageImageArrayNonUniformIndexingNative: VkBool32,
    shaderInputAttachmentArrayNonUniformIndexingNative: VkBool32,
    robustBufferAccessUpdateAfterBind: VkBool32,
    quadDivergentImplicitLod: VkBool32,
    maxPerStageDescriptorUpdateAfterBindSamplers: u32,
    maxPerStageDescriptorUpdateAfterBindUniformBuffers: u32,
    maxPerStageDescriptorUpdateAfterBindStorageBuffers: u32,
    maxPerStageDescriptorUpdateAfterBindSampledImages: u32,
    maxPerStageDescriptorUpdateAfterBindStorageImages: u32,
    maxPerStageDescriptorUpdateAfterBindInputAttachments: u32,
    maxPerStageUpdateAfterBindResources: u32,
    maxDescriptorSetUpdateAfterBindSamplers: u32,
    maxDescriptorSetUpdateAfterBindUniformBuffers: u32,
    maxDescriptorSetUpdateAfterBindUniformBuffersDynamic: u32,
    maxDescriptorSetUpdateAfterBindStorageBuffers: u32,
    maxDescriptorSetUpdateAfterBindStorageBuffersDynamic: u32,
    maxDescriptorSetUpdateAfterBindSampledImages: u32,
    maxDescriptorSetUpdateAfterBindStorageImages: u32,
    maxDescriptorSetUpdateAfterBindInputAttachments: u32,
    supportedDepthResolveModes: VkResolveModeFlags,
    supportedStencilResolveModes: VkResolveModeFlags,
    independentResolveNone: VkBool32,
    independentResolve: VkBool32,
    filterMinmaxSingleComponentFormats: VkBool32,
    filterMinmaxImageComponentMapping: VkBool32,
    maxTimelineSemaphoreValueDifference: u64,
    framebufferIntegerColorSampleCounts: VkSampleCountFlags,
};
pub const vk.PhysicalDeviceVulkan12Properties = struct_vk.PhysicalDeviceVulkan12Properties;
pub const struct_VkImageFormatListCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    viewFormatCount: u32,
    pViewFormats: [*c]const VkFormat,
};
pub const VkImageFormatListCreateInfo = struct_VkImageFormatListCreateInfo;
pub const struct_VkAttachmentDescription2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkAttachmentDescriptionFlags,
    format: VkFormat,
    samples: VkSampleCountFlagBits,
    loadOp: VkAttachmentLoadOp,
    storeOp: VkAttachmentStoreOp,
    stencilLoadOp: VkAttachmentLoadOp,
    stencilStoreOp: VkAttachmentStoreOp,
    initialLayout: VkImageLayout,
    finalLayout: VkImageLayout,
};
pub const VkAttachmentDescription2 = struct_VkAttachmentDescription2;
pub const struct_VkAttachmentReference2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    attachment: u32,
    layout: VkImageLayout,
    aspectMask: VkImageAspectFlags,
};
pub const VkAttachmentReference2 = struct_VkAttachmentReference2;
pub const struct_VkSubpassDescription2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkSubpassDescriptionFlags,
    pipelineBindPoint: VkPipelineBindPoint,
    viewMask: u32,
    inputAttachmentCount: u32,
    pInputAttachments: [*c]const VkAttachmentReference2,
    colorAttachmentCount: u32,
    pColorAttachments: [*c]const VkAttachmentReference2,
    pResolveAttachments: [*c]const VkAttachmentReference2,
    pDepthStencilAttachment: [*c]const VkAttachmentReference2,
    preserveAttachmentCount: u32,
    pPreserveAttachments: [*c]const u32,
};
pub const VkSubpassDescription2 = struct_VkSubpassDescription2;
pub const struct_VkSubpassDependency2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcSubpass: u32,
    dstSubpass: u32,
    srcStageMask: VkPipelineStageFlags,
    dstStageMask: VkPipelineStageFlags,
    srcAccessMask: VkAccessFlags,
    dstAccessMask: VkAccessFlags,
    dependencyFlags: VkDependencyFlags,
    viewOffset: i32,
};
pub const VkSubpassDependency2 = struct_VkSubpassDependency2;
pub const struct_VkRenderPassCreateInfo2 = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkRenderPassCreateFlags,
    attachmentCount: u32,
    pAttachments: [*c]const VkAttachmentDescription2,
    subpassCount: u32,
    pSubpasses: [*c]const VkSubpassDescription2,
    dependencyCount: u32,
    pDependencies: [*c]const VkSubpassDependency2,
    correlatedViewMaskCount: u32,
    pCorrelatedViewMasks: [*c]const u32,
};
pub const VkRenderPassCreateInfo2 = struct_VkRenderPassCreateInfo2;
pub const struct_VkSubpassBeginInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    contents: VkSubpassContents,
};
pub const VkSubpassBeginInfo = struct_VkSubpassBeginInfo;
pub const struct_VkSubpassEndInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
};
pub const VkSubpassEndInfo = struct_VkSubpassEndInfo;
pub const struct_vk.PhysicalDevice8BitStorageFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    storageBuffer8BitAccess: VkBool32,
    uniformAndStorageBuffer8BitAccess: VkBool32,
    storagePushConstant8: VkBool32,
};
pub const vk.PhysicalDevice8BitStorageFeatures = struct_vk.PhysicalDevice8BitStorageFeatures;
pub const struct_vk.PhysicalDeviceDriverProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    driverID: VkDriverId,
    driverName: [256]u8,
    driverInfo: [256]u8,
    conformanceVersion: VkConformanceVersion,
};
pub const vk.PhysicalDeviceDriverProperties = struct_vk.PhysicalDeviceDriverProperties;
pub const struct_vk.PhysicalDeviceShaderAtomicInt64Features = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderBufferInt64Atomics: VkBool32,
    shaderSharedInt64Atomics: VkBool32,
};
pub const vk.PhysicalDeviceShaderAtomicInt64Features = struct_vk.PhysicalDeviceShaderAtomicInt64Features;
pub const struct_vk.PhysicalDeviceShaderFloat16Int8Features = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderFloat16: VkBool32,
    shaderInt8: VkBool32,
};
pub const vk.PhysicalDeviceShaderFloat16Int8Features = struct_vk.PhysicalDeviceShaderFloat16Int8Features;
pub const struct_vk.PhysicalDeviceFloatControlsProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    denormBehaviorIndependence: VkShaderFloatControlsIndependence,
    roundingModeIndependence: VkShaderFloatControlsIndependence,
    shaderSignedZeroInfNanPreserveFloat16: VkBool32,
    shaderSignedZeroInfNanPreserveFloat32: VkBool32,
    shaderSignedZeroInfNanPreserveFloat64: VkBool32,
    shaderDenormPreserveFloat16: VkBool32,
    shaderDenormPreserveFloat32: VkBool32,
    shaderDenormPreserveFloat64: VkBool32,
    shaderDenormFlushToZeroFloat16: VkBool32,
    shaderDenormFlushToZeroFloat32: VkBool32,
    shaderDenormFlushToZeroFloat64: VkBool32,
    shaderRoundingModeRTEFloat16: VkBool32,
    shaderRoundingModeRTEFloat32: VkBool32,
    shaderRoundingModeRTEFloat64: VkBool32,
    shaderRoundingModeRTZFloat16: VkBool32,
    shaderRoundingModeRTZFloat32: VkBool32,
    shaderRoundingModeRTZFloat64: VkBool32,
};
pub const vk.PhysicalDeviceFloatControlsProperties = struct_vk.PhysicalDeviceFloatControlsProperties;
pub const struct_VkDescriptorSetLayoutBindingFlagsCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    bindingCount: u32,
    pBindingFlags: [*c]const VkDescriptorBindingFlags,
};
pub const VkDescriptorSetLayoutBindingFlagsCreateInfo = struct_VkDescriptorSetLayoutBindingFlagsCreateInfo;
pub const struct_vk.PhysicalDeviceDescriptorIndexingFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderInputAttachmentArrayDynamicIndexing: VkBool32,
    shaderUniformTexelBufferArrayDynamicIndexing: VkBool32,
    shaderStorageTexelBufferArrayDynamicIndexing: VkBool32,
    shaderUniformBufferArrayNonUniformIndexing: VkBool32,
    shaderSampledImageArrayNonUniformIndexing: VkBool32,
    shaderStorageBufferArrayNonUniformIndexing: VkBool32,
    shaderStorageImageArrayNonUniformIndexing: VkBool32,
    shaderInputAttachmentArrayNonUniformIndexing: VkBool32,
    shaderUniformTexelBufferArrayNonUniformIndexing: VkBool32,
    shaderStorageTexelBufferArrayNonUniformIndexing: VkBool32,
    descriptorBindingUniformBufferUpdateAfterBind: VkBool32,
    descriptorBindingSampledImageUpdateAfterBind: VkBool32,
    descriptorBindingStorageImageUpdateAfterBind: VkBool32,
    descriptorBindingStorageBufferUpdateAfterBind: VkBool32,
    descriptorBindingUniformTexelBufferUpdateAfterBind: VkBool32,
    descriptorBindingStorageTexelBufferUpdateAfterBind: VkBool32,
    descriptorBindingUpdateUnusedWhilePending: VkBool32,
    descriptorBindingPartiallyBound: VkBool32,
    descriptorBindingVariableDescriptorCount: VkBool32,
    runtimeDescriptorArray: VkBool32,
};
pub const vk.PhysicalDeviceDescriptorIndexingFeatures = struct_vk.PhysicalDeviceDescriptorIndexingFeatures;
pub const struct_vk.PhysicalDeviceDescriptorIndexingProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxUpdateAfterBindDescriptorsInAllPools: u32,
    shaderUniformBufferArrayNonUniformIndexingNative: VkBool32,
    shaderSampledImageArrayNonUniformIndexingNative: VkBool32,
    shaderStorageBufferArrayNonUniformIndexingNative: VkBool32,
    shaderStorageImageArrayNonUniformIndexingNative: VkBool32,
    shaderInputAttachmentArrayNonUniformIndexingNative: VkBool32,
    robustBufferAccessUpdateAfterBind: VkBool32,
    quadDivergentImplicitLod: VkBool32,
    maxPerStageDescriptorUpdateAfterBindSamplers: u32,
    maxPerStageDescriptorUpdateAfterBindUniformBuffers: u32,
    maxPerStageDescriptorUpdateAfterBindStorageBuffers: u32,
    maxPerStageDescriptorUpdateAfterBindSampledImages: u32,
    maxPerStageDescriptorUpdateAfterBindStorageImages: u32,
    maxPerStageDescriptorUpdateAfterBindInputAttachments: u32,
    maxPerStageUpdateAfterBindResources: u32,
    maxDescriptorSetUpdateAfterBindSamplers: u32,
    maxDescriptorSetUpdateAfterBindUniformBuffers: u32,
    maxDescriptorSetUpdateAfterBindUniformBuffersDynamic: u32,
    maxDescriptorSetUpdateAfterBindStorageBuffers: u32,
    maxDescriptorSetUpdateAfterBindStorageBuffersDynamic: u32,
    maxDescriptorSetUpdateAfterBindSampledImages: u32,
    maxDescriptorSetUpdateAfterBindStorageImages: u32,
    maxDescriptorSetUpdateAfterBindInputAttachments: u32,
};
pub const vk.PhysicalDeviceDescriptorIndexingProperties = struct_vk.PhysicalDeviceDescriptorIndexingProperties;
pub const struct_VkDescriptorSetVariableDescriptorCountAllocateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    descriptorSetCount: u32,
    pDescriptorCounts: [*c]const u32,
};
pub const VkDescriptorSetVariableDescriptorCountAllocateInfo = struct_VkDescriptorSetVariableDescriptorCountAllocateInfo;
pub const struct_VkDescriptorSetVariableDescriptorCountLayoutSupport = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxVariableDescriptorCount: u32,
};
pub const VkDescriptorSetVariableDescriptorCountLayoutSupport = struct_VkDescriptorSetVariableDescriptorCountLayoutSupport;
pub const struct_VkSubpassDescriptionDepthStencilResolve = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    depthResolveMode: VkResolveModeFlagBits,
    stencilResolveMode: VkResolveModeFlagBits,
    pDepthStencilResolveAttachment: [*c]const VkAttachmentReference2,
};
pub const VkSubpassDescriptionDepthStencilResolve = struct_VkSubpassDescriptionDepthStencilResolve;
pub const struct_vk.PhysicalDeviceDepthStencilResolveProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    supportedDepthResolveModes: VkResolveModeFlags,
    supportedStencilResolveModes: VkResolveModeFlags,
    independentResolveNone: VkBool32,
    independentResolve: VkBool32,
};
pub const vk.PhysicalDeviceDepthStencilResolveProperties = struct_vk.PhysicalDeviceDepthStencilResolveProperties;
pub const struct_vk.PhysicalDeviceScalarBlockLayoutFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    scalarBlockLayout: VkBool32,
};
pub const vk.PhysicalDeviceScalarBlockLayoutFeatures = struct_vk.PhysicalDeviceScalarBlockLayoutFeatures;
pub const struct_VkImageStencilUsageCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    stencilUsage: VkImageUsageFlags,
};
pub const VkImageStencilUsageCreateInfo = struct_VkImageStencilUsageCreateInfo;
pub const struct_VkSamplerReductionModeCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    reductionMode: VkSamplerReductionMode,
};
pub const VkSamplerReductionModeCreateInfo = struct_VkSamplerReductionModeCreateInfo;
pub const struct_vk.PhysicalDeviceSamplerFilterMinmaxProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    filterMinmaxSingleComponentFormats: VkBool32,
    filterMinmaxImageComponentMapping: VkBool32,
};
pub const vk.PhysicalDeviceSamplerFilterMinmaxProperties = struct_vk.PhysicalDeviceSamplerFilterMinmaxProperties;
pub const struct_vk.PhysicalDeviceVulkanMemoryModelFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    vulkanMemoryModel: VkBool32,
    vulkanMemoryModelDeviceScope: VkBool32,
    vulkanMemoryModelAvailabilityVisibilityChains: VkBool32,
};
pub const vk.PhysicalDeviceVulkanMemoryModelFeatures = struct_vk.PhysicalDeviceVulkanMemoryModelFeatures;
pub const struct_vk.PhysicalDeviceImagelessFramebufferFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    imagelessFramebuffer: VkBool32,
};
pub const vk.PhysicalDeviceImagelessFramebufferFeatures = struct_vk.PhysicalDeviceImagelessFramebufferFeatures;
pub const struct_VkFramebufferAttachmentImageInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkImageCreateFlags,
    usage: VkImageUsageFlags,
    width: u32,
    height: u32,
    layerCount: u32,
    viewFormatCount: u32,
    pViewFormats: [*c]const VkFormat,
};
pub const VkFramebufferAttachmentImageInfo = struct_VkFramebufferAttachmentImageInfo;
pub const struct_VkFramebufferAttachmentsCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    attachmentImageInfoCount: u32,
    pAttachmentImageInfos: [*c]const VkFramebufferAttachmentImageInfo,
};
pub const VkFramebufferAttachmentsCreateInfo = struct_VkFramebufferAttachmentsCreateInfo;
pub const struct_VkRenderPassAttachmentBeginInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    attachmentCount: u32,
    pAttachments: [*c]const VkImageView,
};
pub const VkRenderPassAttachmentBeginInfo = struct_VkRenderPassAttachmentBeginInfo;
pub const struct_vk.PhysicalDeviceUniformBufferStandardLayoutFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    uniformBufferStandardLayout: VkBool32,
};
pub const vk.PhysicalDeviceUniformBufferStandardLayoutFeatures = struct_vk.PhysicalDeviceUniformBufferStandardLayoutFeatures;
pub const struct_vk.PhysicalDeviceShaderSubgroupExtendedTypesFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderSubgroupExtendedTypes: VkBool32,
};
pub const vk.PhysicalDeviceShaderSubgroupExtendedTypesFeatures = struct_vk.PhysicalDeviceShaderSubgroupExtendedTypesFeatures;
pub const struct_vk.PhysicalDeviceSeparateDepthStencilLayoutsFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    separateDepthStencilLayouts: VkBool32,
};
pub const vk.PhysicalDeviceSeparateDepthStencilLayoutsFeatures = struct_vk.PhysicalDeviceSeparateDepthStencilLayoutsFeatures;
pub const struct_VkAttachmentReferenceStencilLayout = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    stencilLayout: VkImageLayout,
};
pub const VkAttachmentReferenceStencilLayout = struct_VkAttachmentReferenceStencilLayout;
pub const struct_VkAttachmentDescriptionStencilLayout = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    stencilInitialLayout: VkImageLayout,
    stencilFinalLayout: VkImageLayout,
};
pub const VkAttachmentDescriptionStencilLayout = struct_VkAttachmentDescriptionStencilLayout;
pub const struct_vk.PhysicalDeviceHostQueryResetFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    hostQueryReset: VkBool32,
};
pub const vk.PhysicalDeviceHostQueryResetFeatures = struct_vk.PhysicalDeviceHostQueryResetFeatures;
pub const struct_vk.PhysicalDeviceTimelineSemaphoreFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    timelineSemaphore: VkBool32,
};
pub const vk.PhysicalDeviceTimelineSemaphoreFeatures = struct_vk.PhysicalDeviceTimelineSemaphoreFeatures;
pub const struct_vk.PhysicalDeviceTimelineSemaphoreProperties = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxTimelineSemaphoreValueDifference: u64,
};
pub const vk.PhysicalDeviceTimelineSemaphoreProperties = struct_vk.PhysicalDeviceTimelineSemaphoreProperties;
pub const struct_VkSemaphoreTypeCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    semaphoreType: VkSemaphoreType,
    initialValue: u64,
};
pub const VkSemaphoreTypeCreateInfo = struct_VkSemaphoreTypeCreateInfo;
pub const struct_VkTimelineSemaphoreSubmitInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    waitSemaphoreValueCount: u32,
    pWaitSemaphoreValues: [*c]const u64,
    signalSemaphoreValueCount: u32,
    pSignalSemaphoreValues: [*c]const u64,
};
pub const VkTimelineSemaphoreSubmitInfo = struct_VkTimelineSemaphoreSubmitInfo;
pub const struct_VkSemaphoreWaitInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkSemaphoreWaitFlags,
    semaphoreCount: u32,
    pSemaphores: [*c]const VkSemaphore,
    pValues: [*c]const u64,
};
pub const VkSemaphoreWaitInfo = struct_VkSemaphoreWaitInfo;
pub const struct_VkSemaphoreSignalInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    semaphore: VkSemaphore,
    value: u64,
};
pub const VkSemaphoreSignalInfo = struct_VkSemaphoreSignalInfo;
pub const struct_vk.PhysicalDeviceBufferDeviceAddressFeatures = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    bufferDeviceAddress: VkBool32,
    bufferDeviceAddressCaptureReplay: VkBool32,
    bufferDeviceAddressMultiDevice: VkBool32,
};
pub const vk.PhysicalDeviceBufferDeviceAddressFeatures = struct_vk.PhysicalDeviceBufferDeviceAddressFeatures;
pub const struct_VkBufferDeviceAddressInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    buffer: VkBuffer,
};
pub const VkBufferDeviceAddressInfo = struct_VkBufferDeviceAddressInfo;
pub const struct_VkBufferOpaqueCaptureAddressCreateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    opaqueCaptureAddress: u64,
};
pub const VkBufferOpaqueCaptureAddressCreateInfo = struct_VkBufferOpaqueCaptureAddressCreateInfo;
pub const struct_VkMemoryOpaqueCaptureAddressAllocateInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    opaqueCaptureAddress: u64,
};
pub const VkMemoryOpaqueCaptureAddressAllocateInfo = struct_VkMemoryOpaqueCaptureAddressAllocateInfo;
pub const struct_vk.DeviceMemoryOpaqueCaptureAddressInfo = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    memory: vk.DeviceMemory,
};
pub const vk.DeviceMemoryOpaqueCaptureAddressInfo = struct_vk.DeviceMemoryOpaqueCaptureAddressInfo;
pub const PFN_vkCmdDrawIndirectCount = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawIndexedIndirectCount = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub const PFN_vkCreateRenderPass2 = ?fn (vk.Device, [*c]const VkRenderPassCreateInfo2, [*c]const VkAllocationCallbacks, [*c]VkRenderPass) callconv(.C) VkResult;
pub const PFN_vkCmdBeginRenderPass2 = ?fn (VkCommandBuffer, [*c]const VkRenderPassBeginInfo, [*c]const VkSubpassBeginInfo) callconv(.C) void;
pub const PFN_vkCmdNextSubpass2 = ?fn (VkCommandBuffer, [*c]const VkSubpassBeginInfo, [*c]const VkSubpassEndInfo) callconv(.C) void;
pub const PFN_vkCmdEndRenderPass2 = ?fn (VkCommandBuffer, [*c]const VkSubpassEndInfo) callconv(.C) void;
pub const PFN_vkResetQueryPool = ?fn (vk.Device, VkQueryPool, u32, u32) callconv(.C) void;
pub const PFN_vkGetSemaphoreCounterValue = ?fn (vk.Device, VkSemaphore, [*c]u64) callconv(.C) VkResult;
pub const PFN_vkWaitSemaphores = ?fn (vk.Device, [*c]const VkSemaphoreWaitInfo, u64) callconv(.C) VkResult;
pub const PFN_vkSignalSemaphore = ?fn (vk.Device, [*c]const VkSemaphoreSignalInfo) callconv(.C) VkResult;
pub const PFN_vkGetBufferDeviceAddress = ?fn (vk.Device, [*c]const VkBufferDeviceAddressInfo) callconv(.C) vk.DeviceAddress;
pub const PFN_vkGetBufferOpaqueCaptureAddress = ?fn (vk.Device, [*c]const VkBufferDeviceAddressInfo) callconv(.C) u64;
pub const PFN_vkGetDeviceMemoryOpaqueCaptureAddress = ?fn (vk.Device, [*c]const vk.DeviceMemoryOpaqueCaptureAddressInfo) callconv(.C) u64;
pub extern fn vkCmdDrawIndirectCount(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, countBuffer: VkBuffer, countBufferOffset: vk.DeviceSize, maxDrawCount: u32, stride: u32) void;
pub extern fn vkCmdDrawIndexedIndirectCount(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, countBuffer: VkBuffer, countBufferOffset: vk.DeviceSize, maxDrawCount: u32, stride: u32) void;
pub extern fn vkCreateRenderPass2(device: vk.Device, pCreateInfo: [*c]const VkRenderPassCreateInfo2, pAllocator: [*c]const VkAllocationCallbacks, pRenderPass: [*c]VkRenderPass) VkResult;
pub extern fn vkCmdBeginRenderPass2(commandBuffer: VkCommandBuffer, pRenderPassBegin: [*c]const VkRenderPassBeginInfo, pSubpassBeginInfo: [*c]const VkSubpassBeginInfo) void;
pub extern fn vkCmdNextSubpass2(commandBuffer: VkCommandBuffer, pSubpassBeginInfo: [*c]const VkSubpassBeginInfo, pSubpassEndInfo: [*c]const VkSubpassEndInfo) void;
pub extern fn vkCmdEndRenderPass2(commandBuffer: VkCommandBuffer, pSubpassEndInfo: [*c]const VkSubpassEndInfo) void;
pub extern fn vkResetQueryPool(device: vk.Device, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32) void;
pub extern fn vkGetSemaphoreCounterValue(device: vk.Device, semaphore: VkSemaphore, pValue: [*c]u64) VkResult;
pub extern fn vkWaitSemaphores(device: vk.Device, pWaitInfo: [*c]const VkSemaphoreWaitInfo, timeout: u64) VkResult;
pub extern fn vkSignalSemaphore(device: vk.Device, pSignalInfo: [*c]const VkSemaphoreSignalInfo) VkResult;
pub extern fn vkGetBufferDeviceAddress(device: vk.Device, pInfo: [*c]const VkBufferDeviceAddressInfo) vk.DeviceAddress;
pub extern fn vkGetBufferOpaqueCaptureAddress(device: vk.Device, pInfo: [*c]const VkBufferDeviceAddressInfo) u64;
pub extern fn vkGetDeviceMemoryOpaqueCaptureAddress(device: vk.Device, pInfo: [*c]const vk.DeviceMemoryOpaqueCaptureAddressInfo) u64;
pub const struct_VkSurfaceKHR_T = opaque {};
pub const VkSurfaceKHR = ?*struct_VkSurfaceKHR_T;
pub const VK_PRESENT_MODE_IMMEDIATE_KHR: c_int = 0;
pub const VK_PRESENT_MODE_MAILBOX_KHR: c_int = 1;
pub const VK_PRESENT_MODE_FIFO_KHR: c_int = 2;
pub const VK_PRESENT_MODE_FIFO_RELAXED_KHR: c_int = 3;
pub const VK_PRESENT_MODE_SHARED_DEMAND_REFRESH_KHR: c_int = 1000111000;
pub const VK_PRESENT_MODE_SHARED_CONTINUOUS_REFRESH_KHR: c_int = 1000111001;
pub const VK_PRESENT_MODE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkPresentModeKHR = c_uint;
pub const VkPresentModeKHR = enum_VkPresentModeKHR;
pub const VK_COLOR_SPACE_SRGB_NONLINEAR_KHR: c_int = 0;
pub const VK_COLOR_SPACE_DISPLAY_P3_NONLINEAR_EXT: c_int = 1000104001;
pub const VK_COLOR_SPACE_EXTENDED_SRGB_LINEAR_EXT: c_int = 1000104002;
pub const VK_COLOR_SPACE_DISPLAY_P3_LINEAR_EXT: c_int = 1000104003;
pub const VK_COLOR_SPACE_DCI_P3_NONLINEAR_EXT: c_int = 1000104004;
pub const VK_COLOR_SPACE_BT709_LINEAR_EXT: c_int = 1000104005;
pub const VK_COLOR_SPACE_BT709_NONLINEAR_EXT: c_int = 1000104006;
pub const VK_COLOR_SPACE_BT2020_LINEAR_EXT: c_int = 1000104007;
pub const VK_COLOR_SPACE_HDR10_ST2084_EXT: c_int = 1000104008;
pub const VK_COLOR_SPACE_DOLBYVISION_EXT: c_int = 1000104009;
pub const VK_COLOR_SPACE_HDR10_HLG_EXT: c_int = 1000104010;
pub const VK_COLOR_SPACE_ADOBERGB_LINEAR_EXT: c_int = 1000104011;
pub const VK_COLOR_SPACE_ADOBERGB_NONLINEAR_EXT: c_int = 1000104012;
pub const VK_COLOR_SPACE_PASS_THROUGH_EXT: c_int = 1000104013;
pub const VK_COLOR_SPACE_EXTENDED_SRGB_NONLINEAR_EXT: c_int = 1000104014;
pub const VK_COLOR_SPACE_DISPLAY_NATIVE_AMD: c_int = 1000213000;
pub const VK_COLORSPACE_SRGB_NONLINEAR_KHR: c_int = 0;
pub const VK_COLOR_SPACE_DCI_P3_LINEAR_EXT: c_int = 1000104003;
pub const VK_COLOR_SPACE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkColorSpaceKHR = c_uint;
pub const VkColorSpaceKHR = enum_VkColorSpaceKHR;
pub const VK_SURFACE_TRANSFORM_IDENTITY_BIT_KHR: c_int = 1;
pub const VK_SURFACE_TRANSFORM_ROTATE_90_BIT_KHR: c_int = 2;
pub const VK_SURFACE_TRANSFORM_ROTATE_180_BIT_KHR: c_int = 4;
pub const VK_SURFACE_TRANSFORM_ROTATE_270_BIT_KHR: c_int = 8;
pub const VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_BIT_KHR: c_int = 16;
pub const VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_90_BIT_KHR: c_int = 32;
pub const VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_180_BIT_KHR: c_int = 64;
pub const VK_SURFACE_TRANSFORM_HORIZONTAL_MIRROR_ROTATE_270_BIT_KHR: c_int = 128;
pub const VK_SURFACE_TRANSFORM_INHERIT_BIT_KHR: c_int = 256;
pub const VK_SURFACE_TRANSFORM_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkSurfaceTransformFlagBitsKHR = c_uint;
pub const VkSurfaceTransformFlagBitsKHR = enum_VkSurfaceTransformFlagBitsKHR;
pub const VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR: c_int = 1;
pub const VK_COMPOSITE_ALPHA_PRE_MULTIPLIED_BIT_KHR: c_int = 2;
pub const VK_COMPOSITE_ALPHA_POST_MULTIPLIED_BIT_KHR: c_int = 4;
pub const VK_COMPOSITE_ALPHA_INHERIT_BIT_KHR: c_int = 8;
pub const VK_COMPOSITE_ALPHA_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkCompositeAlphaFlagBitsKHR = c_uint;
pub const VkCompositeAlphaFlagBitsKHR = enum_VkCompositeAlphaFlagBitsKHR;
pub const VkCompositeAlphaFlagsKHR = VkFlags;
pub const VkSurfaceTransformFlagsKHR = VkFlags;
pub const struct_VkSurfaceCapabilitiesKHR = extern struct {
    minImageCount: u32,
    maxImageCount: u32,
    currentExtent: VkExtent2D,
    minImageExtent: VkExtent2D,
    maxImageExtent: VkExtent2D,
    maxImageArrayLayers: u32,
    supportedTransforms: VkSurfaceTransformFlagsKHR,
    currentTransform: VkSurfaceTransformFlagBitsKHR,
    supportedCompositeAlpha: VkCompositeAlphaFlagsKHR,
    supportedUsageFlags: VkImageUsageFlags,
};
pub const VkSurfaceCapabilitiesKHR = struct_VkSurfaceCapabilitiesKHR;
pub const struct_VkSurfaceFormatKHR = extern struct {
    format: VkFormat,
    colorSpace: VkColorSpaceKHR,
};
pub const VkSurfaceFormatKHR = struct_VkSurfaceFormatKHR;
pub const PFN_vkDestroySurfaceKHR = ?fn (vk.Instance, VkSurfaceKHR, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceSurfaceSupportKHR = ?fn (vk.PhysicalDevice, u32, VkSurfaceKHR, [*c]VkBool32) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceSurfaceCapabilitiesKHR = ?fn (vk.PhysicalDevice, VkSurfaceKHR, [*c]VkSurfaceCapabilitiesKHR) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceSurfaceFormatsKHR = ?fn (vk.PhysicalDevice, VkSurfaceKHR, [*c]u32, [*c]VkSurfaceFormatKHR) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceSurfacePresentModesKHR = ?fn (vk.PhysicalDevice, VkSurfaceKHR, [*c]u32, [*c]VkPresentModeKHR) callconv(.C) VkResult;
pub extern fn vkDestroySurfaceKHR(instance: vk.Instance, surface: VkSurfaceKHR, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice: vk.PhysicalDevice, queueFamilyIndex: u32, surface: VkSurfaceKHR, pSupported: [*c]VkBool32) VkResult;
pub extern fn vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice: vk.PhysicalDevice, surface: VkSurfaceKHR, pSurfaceCapabilities: [*c]VkSurfaceCapabilitiesKHR) VkResult;
pub extern fn vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice: vk.PhysicalDevice, surface: VkSurfaceKHR, pSurfaceFormatCount: [*c]u32, pSurfaceFormats: [*c]VkSurfaceFormatKHR) VkResult;
pub extern fn vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice: vk.PhysicalDevice, surface: VkSurfaceKHR, pPresentModeCount: [*c]u32, pPresentModes: [*c]VkPresentModeKHR) VkResult;
pub const struct_VkSwapchainKHR_T = opaque {};
pub const VkSwapchainKHR = ?*struct_VkSwapchainKHR_T;
pub const VK_SWAPCHAIN_CREATE_SPLIT_INSTANCE_BIND_REGIONS_BIT_KHR: c_int = 1;
pub const VK_SWAPCHAIN_CREATE_PROTECTED_BIT_KHR: c_int = 2;
pub const VK_SWAPCHAIN_CREATE_MUTABLE_FORMAT_BIT_KHR: c_int = 4;
pub const VK_SWAPCHAIN_CREATE_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkSwapchainCreateFlagBitsKHR = c_uint;
pub const VkSwapchainCreateFlagBitsKHR = enum_VkSwapchainCreateFlagBitsKHR;
pub const VkSwapchainCreateFlagsKHR = VkFlags;
pub const VK_DEVICE_GROUP_PRESENT_MODE_LOCAL_BIT_KHR: c_int = 1;
pub const VK_DEVICE_GROUP_PRESENT_MODE_REMOTE_BIT_KHR: c_int = 2;
pub const VK_DEVICE_GROUP_PRESENT_MODE_SUM_BIT_KHR: c_int = 4;
pub const VK_DEVICE_GROUP_PRESENT_MODE_LOCAL_MULTI_DEVICE_BIT_KHR: c_int = 8;
pub const VK_DEVICE_GROUP_PRESENT_MODE_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_vk.DeviceGroupPresentModeFlagBitsKHR = c_uint;
pub const vk.DeviceGroupPresentModeFlagBitsKHR = enum_vk.DeviceGroupPresentModeFlagBitsKHR;
pub const vk.DeviceGroupPresentModeFlagsKHR = VkFlags;
pub const struct_VkSwapchainCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkSwapchainCreateFlagsKHR,
    surface: VkSurfaceKHR,
    minImageCount: u32,
    imageFormat: VkFormat,
    imageColorSpace: VkColorSpaceKHR,
    imageExtent: VkExtent2D,
    imageArrayLayers: u32,
    imageUsage: VkImageUsageFlags,
    imageSharingMode: VkSharingMode,
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: [*c]const u32,
    preTransform: VkSurfaceTransformFlagBitsKHR,
    compositeAlpha: VkCompositeAlphaFlagBitsKHR,
    presentMode: VkPresentModeKHR,
    clipped: VkBool32,
    oldSwapchain: VkSwapchainKHR,
};
pub const VkSwapchainCreateInfoKHR = struct_VkSwapchainCreateInfoKHR;
pub const struct_VkPresentInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    waitSemaphoreCount: u32,
    pWaitSemaphores: [*c]const VkSemaphore,
    swapchainCount: u32,
    pSwapchains: [*c]const VkSwapchainKHR,
    pImageIndices: [*c]const u32,
    pResults: [*c]VkResult,
};
pub const VkPresentInfoKHR = struct_VkPresentInfoKHR;
pub const struct_VkImageSwapchainCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    swapchain: VkSwapchainKHR,
};
pub const VkImageSwapchainCreateInfoKHR = struct_VkImageSwapchainCreateInfoKHR;
pub const struct_VkBindImageMemorySwapchainInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    swapchain: VkSwapchainKHR,
    imageIndex: u32,
};
pub const VkBindImageMemorySwapchainInfoKHR = struct_VkBindImageMemorySwapchainInfoKHR;
pub const struct_VkAcquireNextImageInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    swapchain: VkSwapchainKHR,
    timeout: u64,
    semaphore: VkSemaphore,
    fence: VkFence,
    deviceMask: u32,
};
pub const VkAcquireNextImageInfoKHR = struct_VkAcquireNextImageInfoKHR;
pub const struct_vk.DeviceGroupPresentCapabilitiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    presentMask: [32]u32,
    modes: vk.DeviceGroupPresentModeFlagsKHR,
};
pub const vk.DeviceGroupPresentCapabilitiesKHR = struct_vk.DeviceGroupPresentCapabilitiesKHR;
pub const struct_vk.DeviceGroupPresentInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    swapchainCount: u32,
    pDeviceMasks: [*c]const u32,
    mode: vk.DeviceGroupPresentModeFlagBitsKHR,
};
pub const vk.DeviceGroupPresentInfoKHR = struct_vk.DeviceGroupPresentInfoKHR;
pub const struct_vk.DeviceGroupSwapchainCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    modes: vk.DeviceGroupPresentModeFlagsKHR,
};
pub const vk.DeviceGroupSwapchainCreateInfoKHR = struct_vk.DeviceGroupSwapchainCreateInfoKHR;
pub const PFN_vkCreateSwapchainKHR = ?fn (vk.Device, [*c]const VkSwapchainCreateInfoKHR, [*c]const VkAllocationCallbacks, [*c]VkSwapchainKHR) callconv(.C) VkResult;
pub const PFN_vkDestroySwapchainKHR = ?fn (vk.Device, VkSwapchainKHR, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkGetSwapchainImagesKHR = ?fn (vk.Device, VkSwapchainKHR, [*c]u32, [*c]VkImage) callconv(.C) VkResult;
pub const PFN_vkAcquireNextImageKHR = ?fn (vk.Device, VkSwapchainKHR, u64, VkSemaphore, VkFence, [*c]u32) callconv(.C) VkResult;
pub const PFN_vkQueuePresentKHR = ?fn (VkQueue, [*c]const VkPresentInfoKHR) callconv(.C) VkResult;
pub const PFN_vkGetDeviceGroupPresentCapabilitiesKHR = ?fn (vk.Device, [*c]vk.DeviceGroupPresentCapabilitiesKHR) callconv(.C) VkResult;
pub const PFN_vkGetDeviceGroupSurfacePresentModesKHR = ?fn (vk.Device, VkSurfaceKHR, [*c]vk.DeviceGroupPresentModeFlagsKHR) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDevicePresentRectanglesKHR = ?fn (vk.PhysicalDevice, VkSurfaceKHR, [*c]u32, [*c]VkRect2D) callconv(.C) VkResult;
pub const PFN_vkAcquireNextImage2KHR = ?fn (vk.Device, [*c]const VkAcquireNextImageInfoKHR, [*c]u32) callconv(.C) VkResult;
pub extern fn vkCreateSwapchainKHR(device: vk.Device, pCreateInfo: [*c]const VkSwapchainCreateInfoKHR, pAllocator: [*c]const VkAllocationCallbacks, pSwapchain: [*c]VkSwapchainKHR) VkResult;
pub extern fn vkDestroySwapchainKHR(device: vk.Device, swapchain: VkSwapchainKHR, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkGetSwapchainImagesKHR(device: vk.Device, swapchain: VkSwapchainKHR, pSwapchainImageCount: [*c]u32, pSwapchainImages: [*c]VkImage) VkResult;
pub extern fn vkAcquireNextImageKHR(device: vk.Device, swapchain: VkSwapchainKHR, timeout: u64, semaphore: VkSemaphore, fence: VkFence, pImageIndex: [*c]u32) VkResult;
pub extern fn vkQueuePresentKHR(queue: VkQueue, pPresentInfo: [*c]const VkPresentInfoKHR) VkResult;
pub extern fn vkGetDeviceGroupPresentCapabilitiesKHR(device: vk.Device, pDeviceGroupPresentCapabilities: [*c]vk.DeviceGroupPresentCapabilitiesKHR) VkResult;
pub extern fn vkGetDeviceGroupSurfacePresentModesKHR(device: vk.Device, surface: VkSurfaceKHR, pModes: [*c]vk.DeviceGroupPresentModeFlagsKHR) VkResult;
pub extern fn vkGetPhysicalDevicePresentRectanglesKHR(physicalDevice: vk.PhysicalDevice, surface: VkSurfaceKHR, pRectCount: [*c]u32, pRects: [*c]VkRect2D) VkResult;
pub extern fn vkAcquireNextImage2KHR(device: vk.Device, pAcquireInfo: [*c]const VkAcquireNextImageInfoKHR, pImageIndex: [*c]u32) VkResult;
pub const struct_VkDisplayKHR_T = opaque {};
pub const VkDisplayKHR = ?*struct_VkDisplayKHR_T;
pub const struct_VkDisplayModeKHR_T = opaque {};
pub const VkDisplayModeKHR = ?*struct_VkDisplayModeKHR_T;
pub const VkDisplayModeCreateFlagsKHR = VkFlags;
pub const VK_DISPLAY_PLANE_ALPHA_OPAQUE_BIT_KHR: c_int = 1;
pub const VK_DISPLAY_PLANE_ALPHA_GLOBAL_BIT_KHR: c_int = 2;
pub const VK_DISPLAY_PLANE_ALPHA_PER_PIXEL_BIT_KHR: c_int = 4;
pub const VK_DISPLAY_PLANE_ALPHA_PER_PIXEL_PREMULTIPLIED_BIT_KHR: c_int = 8;
pub const VK_DISPLAY_PLANE_ALPHA_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkDisplayPlaneAlphaFlagBitsKHR = c_uint;
pub const VkDisplayPlaneAlphaFlagBitsKHR = enum_VkDisplayPlaneAlphaFlagBitsKHR;
pub const VkDisplayPlaneAlphaFlagsKHR = VkFlags;
pub const VkDisplaySurfaceCreateFlagsKHR = VkFlags;
pub const struct_VkDisplayModeParametersKHR = extern struct {
    visibleRegion: VkExtent2D,
    refreshRate: u32,
};
pub const VkDisplayModeParametersKHR = struct_VkDisplayModeParametersKHR;
pub const struct_VkDisplayModeCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkDisplayModeCreateFlagsKHR,
    parameters: VkDisplayModeParametersKHR,
};
pub const VkDisplayModeCreateInfoKHR = struct_VkDisplayModeCreateInfoKHR;
pub const struct_VkDisplayModePropertiesKHR = extern struct {
    displayMode: VkDisplayModeKHR,
    parameters: VkDisplayModeParametersKHR,
};
pub const VkDisplayModePropertiesKHR = struct_VkDisplayModePropertiesKHR;
pub const struct_VkDisplayPlaneCapabilitiesKHR = extern struct {
    supportedAlpha: VkDisplayPlaneAlphaFlagsKHR,
    minSrcPosition: VkOffset2D,
    maxSrcPosition: VkOffset2D,
    minSrcExtent: VkExtent2D,
    maxSrcExtent: VkExtent2D,
    minDstPosition: VkOffset2D,
    maxDstPosition: VkOffset2D,
    minDstExtent: VkExtent2D,
    maxDstExtent: VkExtent2D,
};
pub const VkDisplayPlaneCapabilitiesKHR = struct_VkDisplayPlaneCapabilitiesKHR;
pub const struct_VkDisplayPlanePropertiesKHR = extern struct {
    currentDisplay: VkDisplayKHR,
    currentStackIndex: u32,
};
pub const VkDisplayPlanePropertiesKHR = struct_VkDisplayPlanePropertiesKHR;
pub const struct_VkDisplayPropertiesKHR = extern struct {
    display: VkDisplayKHR,
    displayName: [*c]const u8,
    physicalDimensions: VkExtent2D,
    physicalResolution: VkExtent2D,
    supportedTransforms: VkSurfaceTransformFlagsKHR,
    planeReorderPossible: VkBool32,
    persistentContent: VkBool32,
};
pub const VkDisplayPropertiesKHR = struct_VkDisplayPropertiesKHR;
pub const struct_VkDisplaySurfaceCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkDisplaySurfaceCreateFlagsKHR,
    displayMode: VkDisplayModeKHR,
    planeIndex: u32,
    planeStackIndex: u32,
    transform: VkSurfaceTransformFlagBitsKHR,
    globalAlpha: f32,
    alphaMode: VkDisplayPlaneAlphaFlagBitsKHR,
    imageExtent: VkExtent2D,
};
pub const VkDisplaySurfaceCreateInfoKHR = struct_VkDisplaySurfaceCreateInfoKHR;
pub const PFN_vkGetPhysicalDeviceDisplayPropertiesKHR = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkDisplayPropertiesKHR) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceDisplayPlanePropertiesKHR = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkDisplayPlanePropertiesKHR) callconv(.C) VkResult;
pub const PFN_vkGetDisplayPlaneSupportedDisplaysKHR = ?fn (vk.PhysicalDevice, u32, [*c]u32, [*c]VkDisplayKHR) callconv(.C) VkResult;
pub const PFN_vkGetDisplayModePropertiesKHR = ?fn (vk.PhysicalDevice, VkDisplayKHR, [*c]u32, [*c]VkDisplayModePropertiesKHR) callconv(.C) VkResult;
pub const PFN_vkCreateDisplayModeKHR = ?fn (vk.PhysicalDevice, VkDisplayKHR, [*c]const VkDisplayModeCreateInfoKHR, [*c]const VkAllocationCallbacks, [*c]VkDisplayModeKHR) callconv(.C) VkResult;
pub const PFN_vkGetDisplayPlaneCapabilitiesKHR = ?fn (vk.PhysicalDevice, VkDisplayModeKHR, u32, [*c]VkDisplayPlaneCapabilitiesKHR) callconv(.C) VkResult;
pub const PFN_vkCreateDisplayPlaneSurfaceKHR = ?fn (vk.Instance, [*c]const VkDisplaySurfaceCreateInfoKHR, [*c]const VkAllocationCallbacks, [*c]VkSurfaceKHR) callconv(.C) VkResult;
pub extern fn vkGetPhysicalDeviceDisplayPropertiesKHR(physicalDevice: vk.PhysicalDevice, pPropertyCount: [*c]u32, pProperties: [*c]VkDisplayPropertiesKHR) VkResult;
pub extern fn vkGetPhysicalDeviceDisplayPlanePropertiesKHR(physicalDevice: vk.PhysicalDevice, pPropertyCount: [*c]u32, pProperties: [*c]VkDisplayPlanePropertiesKHR) VkResult;
pub extern fn vkGetDisplayPlaneSupportedDisplaysKHR(physicalDevice: vk.PhysicalDevice, planeIndex: u32, pDisplayCount: [*c]u32, pDisplays: [*c]VkDisplayKHR) VkResult;
pub extern fn vkGetDisplayModePropertiesKHR(physicalDevice: vk.PhysicalDevice, display: VkDisplayKHR, pPropertyCount: [*c]u32, pProperties: [*c]VkDisplayModePropertiesKHR) VkResult;
pub extern fn vkCreateDisplayModeKHR(physicalDevice: vk.PhysicalDevice, display: VkDisplayKHR, pCreateInfo: [*c]const VkDisplayModeCreateInfoKHR, pAllocator: [*c]const VkAllocationCallbacks, pMode: [*c]VkDisplayModeKHR) VkResult;
pub extern fn vkGetDisplayPlaneCapabilitiesKHR(physicalDevice: vk.PhysicalDevice, mode: VkDisplayModeKHR, planeIndex: u32, pCapabilities: [*c]VkDisplayPlaneCapabilitiesKHR) VkResult;
pub extern fn vkCreateDisplayPlaneSurfaceKHR(instance: vk.Instance, pCreateInfo: [*c]const VkDisplaySurfaceCreateInfoKHR, pAllocator: [*c]const VkAllocationCallbacks, pSurface: [*c]VkSurfaceKHR) VkResult;
pub const struct_VkDisplayPresentInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcRect: VkRect2D,
    dstRect: VkRect2D,
    persistent: VkBool32,
};
pub const VkDisplayPresentInfoKHR = struct_VkDisplayPresentInfoKHR;
pub const PFN_vkCreateSharedSwapchainsKHR = ?fn (vk.Device, u32, [*c]const VkSwapchainCreateInfoKHR, [*c]const VkAllocationCallbacks, [*c]VkSwapchainKHR) callconv(.C) VkResult;
pub extern fn vkCreateSharedSwapchainsKHR(device: vk.Device, swapchainCount: u32, pCreateInfos: [*c]const VkSwapchainCreateInfoKHR, pAllocator: [*c]const VkAllocationCallbacks, pSwapchains: [*c]VkSwapchainKHR) VkResult;
pub const VK_RENDERING_CONTENTS_SECONDARY_COMMAND_BUFFERS_BIT_KHR: c_int = 1;
pub const VK_RENDERING_SUSPENDING_BIT_KHR: c_int = 2;
pub const VK_RENDERING_RESUMING_BIT_KHR: c_int = 4;
pub const VK_RENDERING_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkRenderingFlagBitsKHR = c_uint;
pub const VkRenderingFlagBitsKHR = enum_VkRenderingFlagBitsKHR;
pub const VkRenderingFlagsKHR = VkFlags;
pub const struct_VkRenderingAttachmentInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    imageView: VkImageView,
    imageLayout: VkImageLayout,
    resolveMode: VkResolveModeFlagBits,
    resolveImageView: VkImageView,
    resolveImageLayout: VkImageLayout,
    loadOp: VkAttachmentLoadOp,
    storeOp: VkAttachmentStoreOp,
    clearValue: VkClearValue,
};
pub const VkRenderingAttachmentInfoKHR = struct_VkRenderingAttachmentInfoKHR;
pub const struct_VkRenderingInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkRenderingFlagsKHR,
    renderArea: VkRect2D,
    layerCount: u32,
    viewMask: u32,
    colorAttachmentCount: u32,
    pColorAttachments: [*c]const VkRenderingAttachmentInfoKHR,
    pDepthAttachment: [*c]const VkRenderingAttachmentInfoKHR,
    pStencilAttachment: [*c]const VkRenderingAttachmentInfoKHR,
};
pub const VkRenderingInfoKHR = struct_VkRenderingInfoKHR;
pub const struct_VkPipelineRenderingCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    viewMask: u32,
    colorAttachmentCount: u32,
    pColorAttachmentFormats: [*c]const VkFormat,
    depthAttachmentFormat: VkFormat,
    stencilAttachmentFormat: VkFormat,
};
pub const VkPipelineRenderingCreateInfoKHR = struct_VkPipelineRenderingCreateInfoKHR;
pub const struct_vk.PhysicalDeviceDynamicRenderingFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    dynamicRendering: VkBool32,
};
pub const vk.PhysicalDeviceDynamicRenderingFeaturesKHR = struct_vk.PhysicalDeviceDynamicRenderingFeaturesKHR;
pub const struct_VkCommandBufferInheritanceRenderingInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkRenderingFlagsKHR,
    viewMask: u32,
    colorAttachmentCount: u32,
    pColorAttachmentFormats: [*c]const VkFormat,
    depthAttachmentFormat: VkFormat,
    stencilAttachmentFormat: VkFormat,
    rasterizationSamples: VkSampleCountFlagBits,
};
pub const VkCommandBufferInheritanceRenderingInfoKHR = struct_VkCommandBufferInheritanceRenderingInfoKHR;
pub const struct_VkRenderingFragmentShadingRateAttachmentInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    imageView: VkImageView,
    imageLayout: VkImageLayout,
    shadingRateAttachmentTexelSize: VkExtent2D,
};
pub const VkRenderingFragmentShadingRateAttachmentInfoKHR = struct_VkRenderingFragmentShadingRateAttachmentInfoKHR;
pub const struct_VkRenderingFragmentDensityMapAttachmentInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    imageView: VkImageView,
    imageLayout: VkImageLayout,
};
pub const VkRenderingFragmentDensityMapAttachmentInfoEXT = struct_VkRenderingFragmentDensityMapAttachmentInfoEXT;
pub const struct_VkAttachmentSampleCountInfoAMD = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    colorAttachmentCount: u32,
    pColorAttachmentSamples: [*c]const VkSampleCountFlagBits,
    depthStencilAttachmentSamples: VkSampleCountFlagBits,
};
pub const VkAttachmentSampleCountInfoAMD = struct_VkAttachmentSampleCountInfoAMD;
pub const VkAttachmentSampleCountInfoNV = VkAttachmentSampleCountInfoAMD;
pub const struct_VkMultiviewPerViewAttributesInfoNVX = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    perViewAttributes: VkBool32,
    perViewAttributesPositionXOnly: VkBool32,
};
pub const VkMultiviewPerViewAttributesInfoNVX = struct_VkMultiviewPerViewAttributesInfoNVX;
pub const PFN_vkCmdBeginRenderingKHR = ?fn (VkCommandBuffer, [*c]const VkRenderingInfoKHR) callconv(.C) void;
pub const PFN_vkCmdEndRenderingKHR = ?fn (VkCommandBuffer) callconv(.C) void;
pub extern fn vkCmdBeginRenderingKHR(commandBuffer: VkCommandBuffer, pRenderingInfo: [*c]const VkRenderingInfoKHR) void;
pub extern fn vkCmdEndRenderingKHR(commandBuffer: VkCommandBuffer) void;
pub const VkRenderPassMultiviewCreateInfoKHR = VkRenderPassMultiviewCreateInfo;
pub const vk.PhysicalDeviceMultiviewFeaturesKHR = vk.PhysicalDeviceMultiviewFeatures;
pub const vk.PhysicalDeviceMultiviewPropertiesKHR = vk.PhysicalDeviceMultiviewProperties;
pub const vk.PhysicalDeviceFeatures2KHR = vk.PhysicalDeviceFeatures2;
pub const vk.PhysicalDeviceProperties2KHR = vk.PhysicalDeviceProperties2;
pub const VkFormatProperties2KHR = VkFormatProperties2;
pub const VkImageFormatProperties2KHR = VkImageFormatProperties2;
pub const vk.PhysicalDeviceImageFormatInfo2KHR = vk.PhysicalDeviceImageFormatInfo2;
pub const VkQueueFamilyProperties2KHR = VkQueueFamilyProperties2;
pub const vk.PhysicalDeviceMemoryProperties2KHR = vk.PhysicalDeviceMemoryProperties2;
pub const VkSparseImageFormatProperties2KHR = VkSparseImageFormatProperties2;
pub const vk.PhysicalDeviceSparseImageFormatInfo2KHR = vk.PhysicalDeviceSparseImageFormatInfo2;
pub const PFN_vkGetPhysicalDeviceFeatures2KHR = ?fn (vk.PhysicalDevice, [*c]vk.PhysicalDeviceFeatures2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceProperties2KHR = ?fn (vk.PhysicalDevice, [*c]vk.PhysicalDeviceProperties2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceFormatProperties2KHR = ?fn (vk.PhysicalDevice, VkFormat, [*c]VkFormatProperties2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceImageFormatProperties2KHR = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceImageFormatInfo2, [*c]VkImageFormatProperties2) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceQueueFamilyProperties2KHR = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkQueueFamilyProperties2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceMemoryProperties2KHR = ?fn (vk.PhysicalDevice, [*c]vk.PhysicalDeviceMemoryProperties2) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceSparseImageFormatProperties2KHR = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceSparseImageFormatInfo2, [*c]u32, [*c]VkSparseImageFormatProperties2) callconv(.C) void;
pub extern fn vkGetPhysicalDeviceFeatures2KHR(physicalDevice: vk.PhysicalDevice, pFeatures: [*c]vk.PhysicalDeviceFeatures2) void;
pub extern fn vkGetPhysicalDeviceProperties2KHR(physicalDevice: vk.PhysicalDevice, pProperties: [*c]vk.PhysicalDeviceProperties2) void;
pub extern fn vkGetPhysicalDeviceFormatProperties2KHR(physicalDevice: vk.PhysicalDevice, format: VkFormat, pFormatProperties: [*c]VkFormatProperties2) void;
pub extern fn vkGetPhysicalDeviceImageFormatProperties2KHR(physicalDevice: vk.PhysicalDevice, pImageFormatInfo: [*c]const vk.PhysicalDeviceImageFormatInfo2, pImageFormatProperties: [*c]VkImageFormatProperties2) VkResult;
pub extern fn vkGetPhysicalDeviceQueueFamilyProperties2KHR(physicalDevice: vk.PhysicalDevice, pQueueFamilyPropertyCount: [*c]u32, pQueueFamilyProperties: [*c]VkQueueFamilyProperties2) void;
pub extern fn vkGetPhysicalDeviceMemoryProperties2KHR(physicalDevice: vk.PhysicalDevice, pMemoryProperties: [*c]vk.PhysicalDeviceMemoryProperties2) void;
pub extern fn vkGetPhysicalDeviceSparseImageFormatProperties2KHR(physicalDevice: vk.PhysicalDevice, pFormatInfo: [*c]const vk.PhysicalDeviceSparseImageFormatInfo2, pPropertyCount: [*c]u32, pProperties: [*c]VkSparseImageFormatProperties2) void;
pub const VkPeerMemoryFeatureFlagsKHR = VkPeerMemoryFeatureFlags;
pub const VkPeerMemoryFeatureFlagBitsKHR = VkPeerMemoryFeatureFlagBits;
pub const VkMemoryAllocateFlagsKHR = VkMemoryAllocateFlags;
pub const VkMemoryAllocateFlagBitsKHR = VkMemoryAllocateFlagBits;
pub const VkMemoryAllocateFlagsInfoKHR = VkMemoryAllocateFlagsInfo;
pub const vk.DeviceGroupRenderPassBeginInfoKHR = vk.DeviceGroupRenderPassBeginInfo;
pub const vk.DeviceGroupCommandBufferBeginInfoKHR = vk.DeviceGroupCommandBufferBeginInfo;
pub const vk.DeviceGroupSubmitInfoKHR = vk.DeviceGroupSubmitInfo;
pub const vk.DeviceGroupBindSparseInfoKHR = vk.DeviceGroupBindSparseInfo;
pub const VkBindBufferMemoryDeviceGroupInfoKHR = VkBindBufferMemoryDeviceGroupInfo;
pub const VkBindImageMemoryDeviceGroupInfoKHR = VkBindImageMemoryDeviceGroupInfo;
pub const PFN_vkGetDeviceGroupPeerMemoryFeaturesKHR = ?fn (vk.Device, u32, u32, u32, [*c]VkPeerMemoryFeatureFlags) callconv(.C) void;
pub const PFN_vkCmdSetDeviceMaskKHR = ?fn (VkCommandBuffer, u32) callconv(.C) void;
pub const PFN_vkCmdDispatchBaseKHR = ?fn (VkCommandBuffer, u32, u32, u32, u32, u32, u32) callconv(.C) void;
pub extern fn vkGetDeviceGroupPeerMemoryFeaturesKHR(device: vk.Device, heapIndex: u32, localDeviceIndex: u32, remoteDeviceIndex: u32, pPeerMemoryFeatures: [*c]VkPeerMemoryFeatureFlags) void;
pub extern fn vkCmdSetDeviceMaskKHR(commandBuffer: VkCommandBuffer, deviceMask: u32) void;
pub extern fn vkCmdDispatchBaseKHR(commandBuffer: VkCommandBuffer, baseGroupX: u32, baseGroupY: u32, baseGroupZ: u32, groupCountX: u32, groupCountY: u32, groupCountZ: u32) void;
pub const VkCommandPoolTrimFlagsKHR = VkCommandPoolTrimFlags;
pub const PFN_vkTrimCommandPoolKHR = ?fn (vk.Device, VkCommandPool, VkCommandPoolTrimFlags) callconv(.C) void;
pub extern fn vkTrimCommandPoolKHR(device: vk.Device, commandPool: VkCommandPool, flags: VkCommandPoolTrimFlags) void;
pub const vk.PhysicalDeviceGroupPropertiesKHR = vk.PhysicalDeviceGroupProperties;
pub const vk.DeviceGroupDeviceCreateInfoKHR = vk.DeviceGroupDeviceCreateInfo;
pub const PFN_vkEnumeratePhysicalDeviceGroupsKHR = ?fn (vk.Instance, [*c]u32, [*c]vk.PhysicalDeviceGroupProperties) callconv(.C) VkResult;
pub extern fn vkEnumeratePhysicalDeviceGroupsKHR(instance: vk.Instance, pPhysicalDeviceGroupCount: [*c]u32, pPhysicalDeviceGroupProperties: [*c]vk.PhysicalDeviceGroupProperties) VkResult;
pub const VkExternalMemoryHandleTypeFlagsKHR = VkExternalMemoryHandleTypeFlags;
pub const VkExternalMemoryHandleTypeFlagBitsKHR = VkExternalMemoryHandleTypeFlagBits;
pub const VkExternalMemoryFeatureFlagsKHR = VkExternalMemoryFeatureFlags;
pub const VkExternalMemoryFeatureFlagBitsKHR = VkExternalMemoryFeatureFlagBits;
pub const VkExternalMemoryPropertiesKHR = VkExternalMemoryProperties;
pub const vk.PhysicalDeviceExternalImageFormatInfoKHR = vk.PhysicalDeviceExternalImageFormatInfo;
pub const VkExternalImageFormatPropertiesKHR = VkExternalImageFormatProperties;
pub const vk.PhysicalDeviceExternalBufferInfoKHR = vk.PhysicalDeviceExternalBufferInfo;
pub const VkExternalBufferPropertiesKHR = VkExternalBufferProperties;
pub const vk.PhysicalDeviceIDPropertiesKHR = vk.PhysicalDeviceIDProperties;
pub const PFN_vkGetPhysicalDevicexternalBufferPropertiesKHR = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceExternalBufferInfo, [*c]VkExternalBufferProperties) callconv(.C) void;
pub extern fn vkGetPhysicalDevicexternalBufferPropertiesKHR(physicalDevice: vk.PhysicalDevice, pExternalBufferInfo: [*c]const vk.PhysicalDeviceExternalBufferInfo, pExternalBufferProperties: [*c]VkExternalBufferProperties) void;
pub const VkExternalMemoryImageCreateInfoKHR = VkExternalMemoryImageCreateInfo;
pub const VkExternalMemoryBufferCreateInfoKHR = VkExternalMemoryBufferCreateInfo;
pub const VkExportMemoryAllocateInfoKHR = VkExportMemoryAllocateInfo;
pub const struct_VkImportMemoryFdInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleType: VkExternalMemoryHandleTypeFlagBits,
    fd: c_int,
};
pub const VkImportMemoryFdInfoKHR = struct_VkImportMemoryFdInfoKHR;
pub const struct_VkMemoryFdPropertiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    memoryTypeBits: u32,
};
pub const VkMemoryFdPropertiesKHR = struct_VkMemoryFdPropertiesKHR;
pub const struct_VkMemoryGetFdInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    memory: vk.DeviceMemory,
    handleType: VkExternalMemoryHandleTypeFlagBits,
};
pub const VkMemoryGetFdInfoKHR = struct_VkMemoryGetFdInfoKHR;
pub const PFN_vkGetMemoryFdKHR = ?fn (vk.Device, [*c]const VkMemoryGetFdInfoKHR, [*c]c_int) callconv(.C) VkResult;
pub const PFN_vkGetMemoryFdPropertiesKHR = ?fn (vk.Device, VkExternalMemoryHandleTypeFlagBits, c_int, [*c]VkMemoryFdPropertiesKHR) callconv(.C) VkResult;
pub extern fn vkGetMemoryFdKHR(device: vk.Device, pGetFdInfo: [*c]const VkMemoryGetFdInfoKHR, pFd: [*c]c_int) VkResult;
pub extern fn vkGetMemoryFdPropertiesKHR(device: vk.Device, handleType: VkExternalMemoryHandleTypeFlagBits, fd: c_int, pMemoryFdProperties: [*c]VkMemoryFdPropertiesKHR) VkResult;
pub const VkExternalSemaphoreHandleTypeFlagsKHR = VkExternalSemaphoreHandleTypeFlags;
pub const VkExternalSemaphoreHandleTypeFlagBitsKHR = VkExternalSemaphoreHandleTypeFlagBits;
pub const VkExternalSemaphoreFeatureFlagsKHR = VkExternalSemaphoreFeatureFlags;
pub const VkExternalSemaphoreFeatureFlagBitsKHR = VkExternalSemaphoreFeatureFlagBits;
pub const vk.PhysicalDeviceExternalSemaphoreInfoKHR = vk.PhysicalDeviceExternalSemaphoreInfo;
pub const VkExternalSemaphorePropertiesKHR = VkExternalSemaphoreProperties;
pub const PFN_vkGetPhysicalDevicexternalSemaphorePropertiesKHR = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceExternalSemaphoreInfo, [*c]VkExternalSemaphoreProperties) callconv(.C) void;
pub extern fn vkGetPhysicalDevicexternalSemaphorePropertiesKHR(physicalDevice: vk.PhysicalDevice, pExternalSemaphoreInfo: [*c]const vk.PhysicalDeviceExternalSemaphoreInfo, pExternalSemaphoreProperties: [*c]VkExternalSemaphoreProperties) void;
pub const VkSemaphoreImportFlagsKHR = VkSemaphoreImportFlags;
pub const VkSemaphoreImportFlagBitsKHR = VkSemaphoreImportFlagBits;
pub const VkExportSemaphoreCreateInfoKHR = VkExportSemaphoreCreateInfo;
pub const struct_VkImportSemaphoreFdInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    semaphore: VkSemaphore,
    flags: VkSemaphoreImportFlags,
    handleType: VkExternalSemaphoreHandleTypeFlagBits,
    fd: c_int,
};
pub const VkImportSemaphoreFdInfoKHR = struct_VkImportSemaphoreFdInfoKHR;
pub const struct_VkSemaphoreGetFdInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    semaphore: VkSemaphore,
    handleType: VkExternalSemaphoreHandleTypeFlagBits,
};
pub const VkSemaphoreGetFdInfoKHR = struct_VkSemaphoreGetFdInfoKHR;
pub const PFN_vkImportSemaphoreFdKHR = ?fn (vk.Device, [*c]const VkImportSemaphoreFdInfoKHR) callconv(.C) VkResult;
pub const PFN_vkGetSemaphoreFdKHR = ?fn (vk.Device, [*c]const VkSemaphoreGetFdInfoKHR, [*c]c_int) callconv(.C) VkResult;
pub extern fn vkImportSemaphoreFdKHR(device: vk.Device, pImportSemaphoreFdInfo: [*c]const VkImportSemaphoreFdInfoKHR) VkResult;
pub extern fn vkGetSemaphoreFdKHR(device: vk.Device, pGetFdInfo: [*c]const VkSemaphoreGetFdInfoKHR, pFd: [*c]c_int) VkResult;
pub const struct_vk.PhysicalDevicePushDescriptorPropertiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxPushDescriptors: u32,
};
pub const vk.PhysicalDevicePushDescriptorPropertiesKHR = struct_vk.PhysicalDevicePushDescriptorPropertiesKHR;
pub const PFN_vkCmdPushDescriptorSetKHR = ?fn (VkCommandBuffer, VkPipelineBindPoint, VkPipelineLayout, u32, u32, [*c]const VkWriteDescriptorSet) callconv(.C) void;
pub const PFN_vkCmdPushDescriptorSetWithTemplateKHR = ?fn (VkCommandBuffer, VkDescriptorUpdateTemplate, VkPipelineLayout, u32, ?*const anyopaque) callconv(.C) void;
pub extern fn vkCmdPushDescriptorSetKHR(commandBuffer: VkCommandBuffer, pipelineBindPoint: VkPipelineBindPoint, layout: VkPipelineLayout, set: u32, descriptorWriteCount: u32, pDescriptorWrites: [*c]const VkWriteDescriptorSet) void;
pub extern fn vkCmdPushDescriptorSetWithTemplateKHR(commandBuffer: VkCommandBuffer, descriptorUpdateTemplate: VkDescriptorUpdateTemplate, layout: VkPipelineLayout, set: u32, pData: ?*const anyopaque) void;
pub const vk.PhysicalDeviceShaderFloat16Int8FeaturesKHR = vk.PhysicalDeviceShaderFloat16Int8Features;
pub const vk.PhysicalDeviceFloat16Int8FeaturesKHR = vk.PhysicalDeviceShaderFloat16Int8Features;
pub const vk.PhysicalDevice16BitStorageFeaturesKHR = vk.PhysicalDevice16BitStorageFeatures;
pub const struct_VkRectLayerKHR = extern struct {
    offset: VkOffset2D,
    extent: VkExtent2D,
    layer: u32,
};
pub const VkRectLayerKHR = struct_VkRectLayerKHR;
pub const struct_VkPresentRegionKHR = extern struct {
    rectangleCount: u32,
    pRectangles: [*c]const VkRectLayerKHR,
};
pub const VkPresentRegionKHR = struct_VkPresentRegionKHR;
pub const struct_VkPresentRegionsKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    swapchainCount: u32,
    pRegions: [*c]const VkPresentRegionKHR,
};
pub const VkPresentRegionsKHR = struct_VkPresentRegionsKHR;
pub const VkDescriptorUpdateTemplateKHR = VkDescriptorUpdateTemplate;
pub const VkDescriptorUpdateTemplateTypeKHR = VkDescriptorUpdateTemplateType;
pub const VkDescriptorUpdateTemplateCreateFlagsKHR = VkDescriptorUpdateTemplateCreateFlags;
pub const VkDescriptorUpdateTemplateEntryKHR = VkDescriptorUpdateTemplateEntry;
pub const VkDescriptorUpdateTemplateCreateInfoKHR = VkDescriptorUpdateTemplateCreateInfo;
pub const PFN_vkCreateDescriptorUpdateTemplateKHR = ?fn (vk.Device, [*c]const VkDescriptorUpdateTemplateCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkDescriptorUpdateTemplate) callconv(.C) VkResult;
pub const PFN_vkDestroyDescriptorUpdateTemplateKHR = ?fn (vk.Device, VkDescriptorUpdateTemplate, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkUpdateDescriptorSetWithTemplateKHR = ?fn (vk.Device, VkDescriptorSet, VkDescriptorUpdateTemplate, ?*const anyopaque) callconv(.C) void;
pub extern fn vkCreateDescriptorUpdateTemplateKHR(device: vk.Device, pCreateInfo: [*c]const VkDescriptorUpdateTemplateCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pDescriptorUpdateTemplate: [*c]VkDescriptorUpdateTemplate) VkResult;
pub extern fn vkDestroyDescriptorUpdateTemplateKHR(device: vk.Device, descriptorUpdateTemplate: VkDescriptorUpdateTemplate, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkUpdateDescriptorSetWithTemplateKHR(device: vk.Device, descriptorSet: VkDescriptorSet, descriptorUpdateTemplate: VkDescriptorUpdateTemplate, pData: ?*const anyopaque) void;
pub const vk.PhysicalDeviceImagelessFramebufferFeaturesKHR = vk.PhysicalDeviceImagelessFramebufferFeatures;
pub const VkFramebufferAttachmentsCreateInfoKHR = VkFramebufferAttachmentsCreateInfo;
pub const VkFramebufferAttachmentImageInfoKHR = VkFramebufferAttachmentImageInfo;
pub const VkRenderPassAttachmentBeginInfoKHR = VkRenderPassAttachmentBeginInfo;
pub const VkRenderPassCreateInfo2KHR = VkRenderPassCreateInfo2;
pub const VkAttachmentDescription2KHR = VkAttachmentDescription2;
pub const VkAttachmentReference2KHR = VkAttachmentReference2;
pub const VkSubpassDescription2KHR = VkSubpassDescription2;
pub const VkSubpassDependency2KHR = VkSubpassDependency2;
pub const VkSubpassBeginInfoKHR = VkSubpassBeginInfo;
pub const VkSubpassEndInfoKHR = VkSubpassEndInfo;
pub const PFN_vkCreateRenderPass2KHR = ?fn (vk.Device, [*c]const VkRenderPassCreateInfo2, [*c]const VkAllocationCallbacks, [*c]VkRenderPass) callconv(.C) VkResult;
pub const PFN_vkCmdBeginRenderPass2KHR = ?fn (VkCommandBuffer, [*c]const VkRenderPassBeginInfo, [*c]const VkSubpassBeginInfo) callconv(.C) void;
pub const PFN_vkCmdNextSubpass2KHR = ?fn (VkCommandBuffer, [*c]const VkSubpassBeginInfo, [*c]const VkSubpassEndInfo) callconv(.C) void;
pub const PFN_vkCmdEndRenderPass2KHR = ?fn (VkCommandBuffer, [*c]const VkSubpassEndInfo) callconv(.C) void;
pub extern fn vkCreateRenderPass2KHR(device: vk.Device, pCreateInfo: [*c]const VkRenderPassCreateInfo2, pAllocator: [*c]const VkAllocationCallbacks, pRenderPass: [*c]VkRenderPass) VkResult;
pub extern fn vkCmdBeginRenderPass2KHR(commandBuffer: VkCommandBuffer, pRenderPassBegin: [*c]const VkRenderPassBeginInfo, pSubpassBeginInfo: [*c]const VkSubpassBeginInfo) void;
pub extern fn vkCmdNextSubpass2KHR(commandBuffer: VkCommandBuffer, pSubpassBeginInfo: [*c]const VkSubpassBeginInfo, pSubpassEndInfo: [*c]const VkSubpassEndInfo) void;
pub extern fn vkCmdEndRenderPass2KHR(commandBuffer: VkCommandBuffer, pSubpassEndInfo: [*c]const VkSubpassEndInfo) void;
pub const struct_VkSharedPresentSurfaceCapabilitiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    sharedPresentSupportedUsageFlags: VkImageUsageFlags,
};
pub const VkSharedPresentSurfaceCapabilitiesKHR = struct_VkSharedPresentSurfaceCapabilitiesKHR;
pub const PFN_vkGetSwapchainStatusKHR = ?fn (vk.Device, VkSwapchainKHR) callconv(.C) VkResult;
pub extern fn vkGetSwapchainStatusKHR(device: vk.Device, swapchain: VkSwapchainKHR) VkResult;
pub const VkExternalFenceHandleTypeFlagsKHR = VkExternalFenceHandleTypeFlags;
pub const VkExternalFenceHandleTypeFlagBitsKHR = VkExternalFenceHandleTypeFlagBits;
pub const VkExternalFenceFeatureFlagsKHR = VkExternalFenceFeatureFlags;
pub const VkExternalFenceFeatureFlagBitsKHR = VkExternalFenceFeatureFlagBits;
pub const vk.PhysicalDeviceExternalFenceInfoKHR = vk.PhysicalDeviceExternalFenceInfo;
pub const VkExternalFencePropertiesKHR = VkExternalFenceProperties;
pub const PFN_vkGetPhysicalDevicexternalFencePropertiesKHR = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceExternalFenceInfo, [*c]VkExternalFenceProperties) callconv(.C) void;
pub extern fn vkGetPhysicalDevicexternalFencePropertiesKHR(physicalDevice: vk.PhysicalDevice, pExternalFenceInfo: [*c]const vk.PhysicalDeviceExternalFenceInfo, pExternalFenceProperties: [*c]VkExternalFenceProperties) void;
pub const VkFenceImportFlagsKHR = VkFenceImportFlags;
pub const VkFenceImportFlagBitsKHR = VkFenceImportFlagBits;
pub const VkExportFenceCreateInfoKHR = VkExportFenceCreateInfo;
pub const struct_VkImportFenceFdInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    fence: VkFence,
    flags: VkFenceImportFlags,
    handleType: VkExternalFenceHandleTypeFlagBits,
    fd: c_int,
};
pub const VkImportFenceFdInfoKHR = struct_VkImportFenceFdInfoKHR;
pub const struct_VkFenceGetFdInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    fence: VkFence,
    handleType: VkExternalFenceHandleTypeFlagBits,
};
pub const VkFenceGetFdInfoKHR = struct_VkFenceGetFdInfoKHR;
pub const PFN_vkImportFenceFdKHR = ?fn (vk.Device, [*c]const VkImportFenceFdInfoKHR) callconv(.C) VkResult;
pub const PFN_vkGetFenceFdKHR = ?fn (vk.Device, [*c]const VkFenceGetFdInfoKHR, [*c]c_int) callconv(.C) VkResult;
pub extern fn vkImportFenceFdKHR(device: vk.Device, pImportFenceFdInfo: [*c]const VkImportFenceFdInfoKHR) VkResult;
pub extern fn vkGetFenceFdKHR(device: vk.Device, pGetFdInfo: [*c]const VkFenceGetFdInfoKHR, pFd: [*c]c_int) VkResult;
pub const VK_PERFORMANCE_COUNTER_UNIT_GENERIC_KHR: c_int = 0;
pub const VK_PERFORMANCE_COUNTER_UNIT_PERCENTAGE_KHR: c_int = 1;
pub const VK_PERFORMANCE_COUNTER_UNIT_NANOSECONDS_KHR: c_int = 2;
pub const VK_PERFORMANCE_COUNTER_UNIT_BYTES_KHR: c_int = 3;
pub const VK_PERFORMANCE_COUNTER_UNIT_BYTES_PER_SECOND_KHR: c_int = 4;
pub const VK_PERFORMANCE_COUNTER_UNIT_KELVIN_KHR: c_int = 5;
pub const VK_PERFORMANCE_COUNTER_UNIT_WATTS_KHR: c_int = 6;
pub const VK_PERFORMANCE_COUNTER_UNIT_VOLTS_KHR: c_int = 7;
pub const VK_PERFORMANCE_COUNTER_UNIT_AMPS_KHR: c_int = 8;
pub const VK_PERFORMANCE_COUNTER_UNIT_HERTZ_KHR: c_int = 9;
pub const VK_PERFORMANCE_COUNTER_UNIT_CYCLES_KHR: c_int = 10;
pub const VK_PERFORMANCE_COUNTER_UNIT_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkPerformanceCounterUnitKHR = c_uint;
pub const VkPerformanceCounterUnitKHR = enum_VkPerformanceCounterUnitKHR;
pub const VK_PERFORMANCE_COUNTER_SCOPE_COMMAND_BUFFER_KHR: c_int = 0;
pub const VK_PERFORMANCE_COUNTER_SCOPE_RENDER_PASS_KHR: c_int = 1;
pub const VK_PERFORMANCE_COUNTER_SCOPE_COMMAND_KHR: c_int = 2;
pub const VK_QUERY_SCOPE_COMMAND_BUFFER_KHR: c_int = 0;
pub const VK_QUERY_SCOPE_RENDER_PASS_KHR: c_int = 1;
pub const VK_QUERY_SCOPE_COMMAND_KHR: c_int = 2;
pub const VK_PERFORMANCE_COUNTER_SCOPE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkPerformanceCounterScopeKHR = c_uint;
pub const VkPerformanceCounterScopeKHR = enum_VkPerformanceCounterScopeKHR;
pub const VK_PERFORMANCE_COUNTER_STORAGE_INT32_KHR: c_int = 0;
pub const VK_PERFORMANCE_COUNTER_STORAGE_INT64_KHR: c_int = 1;
pub const VK_PERFORMANCE_COUNTER_STORAGE_UINT32_KHR: c_int = 2;
pub const VK_PERFORMANCE_COUNTER_STORAGE_UINT64_KHR: c_int = 3;
pub const VK_PERFORMANCE_COUNTER_STORAGE_FLOAT32_KHR: c_int = 4;
pub const VK_PERFORMANCE_COUNTER_STORAGE_FLOAT64_KHR: c_int = 5;
pub const VK_PERFORMANCE_COUNTER_STORAGE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkPerformanceCounterStorageKHR = c_uint;
pub const VkPerformanceCounterStorageKHR = enum_VkPerformanceCounterStorageKHR;
pub const VK_PERFORMANCE_COUNTER_DESCRIPTION_PERFORMANCE_IMPACTING_BIT_KHR: c_int = 1;
pub const VK_PERFORMANCE_COUNTER_DESCRIPTION_CONCURRENTLY_IMPACTED_BIT_KHR: c_int = 2;
pub const VK_PERFORMANCE_COUNTER_DESCRIPTION_PERFORMANCE_IMPACTING_KHR: c_int = 1;
pub const VK_PERFORMANCE_COUNTER_DESCRIPTION_CONCURRENTLY_IMPACTED_KHR: c_int = 2;
pub const VK_PERFORMANCE_COUNTER_DESCRIPTION_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkPerformanceCounterDescriptionFlagBitsKHR = c_uint;
pub const VkPerformanceCounterDescriptionFlagBitsKHR = enum_VkPerformanceCounterDescriptionFlagBitsKHR;
pub const VkPerformanceCounterDescriptionFlagsKHR = VkFlags;
pub const VK_ACQUIRE_PROFILING_LOCK_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkAcquireProfilingLockFlagBitsKHR = c_uint;
pub const VkAcquireProfilingLockFlagBitsKHR = enum_VkAcquireProfilingLockFlagBitsKHR;
pub const VkAcquireProfilingLockFlagsKHR = VkFlags;
pub const struct_vk.PhysicalDevicePerformanceQueryFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    performanceCounterQueryPools: VkBool32,
    performanceCounterMultipleQueryPools: VkBool32,
};
pub const vk.PhysicalDevicePerformanceQueryFeaturesKHR = struct_vk.PhysicalDevicePerformanceQueryFeaturesKHR;
pub const struct_vk.PhysicalDevicePerformanceQueryPropertiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    allowCommandBufferQueryCopies: VkBool32,
};
pub const vk.PhysicalDevicePerformanceQueryPropertiesKHR = struct_vk.PhysicalDevicePerformanceQueryPropertiesKHR;
pub const struct_VkPerformanceCounterKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    unit: VkPerformanceCounterUnitKHR,
    scope: VkPerformanceCounterScopeKHR,
    storage: VkPerformanceCounterStorageKHR,
    uuid: [16]u8,
};
pub const VkPerformanceCounterKHR = struct_VkPerformanceCounterKHR;
pub const struct_VkPerformanceCounterDescriptionKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    flags: VkPerformanceCounterDescriptionFlagsKHR,
    name: [256]u8,
    category: [256]u8,
    description: [256]u8,
};
pub const VkPerformanceCounterDescriptionKHR = struct_VkPerformanceCounterDescriptionKHR;
pub const struct_VkQueryPoolPerformanceCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    queueFamilyIndex: u32,
    counterIndexCount: u32,
    pCounterIndices: [*c]const u32,
};
pub const VkQueryPoolPerformanceCreateInfoKHR = struct_VkQueryPoolPerformanceCreateInfoKHR;
pub const union_VkPerformanceCounterResultKHR = extern union {
    int32: i32,
    int64: i64,
    uint32: u32,
    uint64: u64,
    float32: f32,
    float64: f64,
};
pub const VkPerformanceCounterResultKHR = union_VkPerformanceCounterResultKHR;
pub const struct_VkAcquireProfilingLockInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkAcquireProfilingLockFlagsKHR,
    timeout: u64,
};
pub const VkAcquireProfilingLockInfoKHR = struct_VkAcquireProfilingLockInfoKHR;
pub const struct_VkPerformanceQuerySubmitInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    counterPassIndex: u32,
};
pub const VkPerformanceQuerySubmitInfoKHR = struct_VkPerformanceQuerySubmitInfoKHR;
pub const PFN_vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR = ?fn (vk.PhysicalDevice, u32, [*c]u32, [*c]VkPerformanceCounterKHR, [*c]VkPerformanceCounterDescriptionKHR) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR = ?fn (vk.PhysicalDevice, [*c]const VkQueryPoolPerformanceCreateInfoKHR, [*c]u32) callconv(.C) void;
pub const PFN_vkAcquireProfilingLockKHR = ?fn (vk.Device, [*c]const VkAcquireProfilingLockInfoKHR) callconv(.C) VkResult;
pub const PFN_vkReleaseProfilingLockKHR = ?fn (vk.Device) callconv(.C) void;
pub extern fn vkEnumeratePhysicalDeviceQueueFamilyPerformanceQueryCountersKHR(physicalDevice: vk.PhysicalDevice, queueFamilyIndex: u32, pCounterCount: [*c]u32, pCounters: [*c]VkPerformanceCounterKHR, pCounterDescriptions: [*c]VkPerformanceCounterDescriptionKHR) VkResult;
pub extern fn vkGetPhysicalDeviceQueueFamilyPerformanceQueryPassesKHR(physicalDevice: vk.PhysicalDevice, pPerformanceQueryCreateInfo: [*c]const VkQueryPoolPerformanceCreateInfoKHR, pNumPasses: [*c]u32) void;
pub extern fn vkAcquireProfilingLockKHR(device: vk.Device, pInfo: [*c]const VkAcquireProfilingLockInfoKHR) VkResult;
pub extern fn vkReleaseProfilingLockKHR(device: vk.Device) void;
pub const VkPointClippingBehaviorKHR = VkPointClippingBehavior;
pub const VkTessellationDomainOriginKHR = VkTessellationDomainOrigin;
pub const vk.PhysicalDevicePointClippingPropertiesKHR = vk.PhysicalDevicePointClippingProperties;
pub const VkRenderPassInputAttachmentAspectCreateInfoKHR = VkRenderPassInputAttachmentAspectCreateInfo;
pub const VkInputAttachmentAspectReferenceKHR = VkInputAttachmentAspectReference;
pub const VkImageViewUsageCreateInfoKHR = VkImageViewUsageCreateInfo;
pub const VkPipelineTessellationDomainOriginStateCreateInfoKHR = VkPipelineTessellationDomainOriginStateCreateInfo;
pub const struct_vk.PhysicalDeviceSurfaceInfo2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    surface: VkSurfaceKHR,
};
pub const vk.PhysicalDeviceSurfaceInfo2KHR = struct_vk.PhysicalDeviceSurfaceInfo2KHR;
pub const struct_VkSurfaceCapabilities2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    surfaceCapabilities: VkSurfaceCapabilitiesKHR,
};
pub const VkSurfaceCapabilities2KHR = struct_VkSurfaceCapabilities2KHR;
pub const struct_VkSurfaceFormat2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    surfaceFormat: VkSurfaceFormatKHR,
};
pub const VkSurfaceFormat2KHR = struct_VkSurfaceFormat2KHR;
pub const PFN_vkGetPhysicalDeviceSurfaceCapabilities2KHR = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceSurfaceInfo2KHR, [*c]VkSurfaceCapabilities2KHR) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceSurfaceFormats2KHR = ?fn (vk.PhysicalDevice, [*c]const vk.PhysicalDeviceSurfaceInfo2KHR, [*c]u32, [*c]VkSurfaceFormat2KHR) callconv(.C) VkResult;
pub extern fn vkGetPhysicalDeviceSurfaceCapabilities2KHR(physicalDevice: vk.PhysicalDevice, pSurfaceInfo: [*c]const vk.PhysicalDeviceSurfaceInfo2KHR, pSurfaceCapabilities: [*c]VkSurfaceCapabilities2KHR) VkResult;
pub extern fn vkGetPhysicalDeviceSurfaceFormats2KHR(physicalDevice: vk.PhysicalDevice, pSurfaceInfo: [*c]const vk.PhysicalDeviceSurfaceInfo2KHR, pSurfaceFormatCount: [*c]u32, pSurfaceFormats: [*c]VkSurfaceFormat2KHR) VkResult;
pub const vk.PhysicalDeviceVariablePointerFeaturesKHR = vk.PhysicalDeviceVariablePointersFeatures;
pub const vk.PhysicalDeviceVariablePointersFeaturesKHR = vk.PhysicalDeviceVariablePointersFeatures;
pub const struct_VkDisplayProperties2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    displayProperties: VkDisplayPropertiesKHR,
};
pub const VkDisplayProperties2KHR = struct_VkDisplayProperties2KHR;
pub const struct_VkDisplayPlaneProperties2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    displayPlaneProperties: VkDisplayPlanePropertiesKHR,
};
pub const VkDisplayPlaneProperties2KHR = struct_VkDisplayPlaneProperties2KHR;
pub const struct_VkDisplayModeProperties2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    displayModeProperties: VkDisplayModePropertiesKHR,
};
pub const VkDisplayModeProperties2KHR = struct_VkDisplayModeProperties2KHR;
pub const struct_VkDisplayPlaneInfo2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    mode: VkDisplayModeKHR,
    planeIndex: u32,
};
pub const VkDisplayPlaneInfo2KHR = struct_VkDisplayPlaneInfo2KHR;
pub const struct_VkDisplayPlaneCapabilities2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    capabilities: VkDisplayPlaneCapabilitiesKHR,
};
pub const VkDisplayPlaneCapabilities2KHR = struct_VkDisplayPlaneCapabilities2KHR;
pub const PFN_vkGetPhysicalDeviceDisplayProperties2KHR = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkDisplayProperties2KHR) callconv(.C) VkResult;
pub const PFN_vkGetPhysicalDeviceDisplayPlaneProperties2KHR = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkDisplayPlaneProperties2KHR) callconv(.C) VkResult;
pub const PFN_vkGetDisplayModeProperties2KHR = ?fn (vk.PhysicalDevice, VkDisplayKHR, [*c]u32, [*c]VkDisplayModeProperties2KHR) callconv(.C) VkResult;
pub const PFN_vkGetDisplayPlaneCapabilities2KHR = ?fn (vk.PhysicalDevice, [*c]const VkDisplayPlaneInfo2KHR, [*c]VkDisplayPlaneCapabilities2KHR) callconv(.C) VkResult;
pub extern fn vkGetPhysicalDeviceDisplayProperties2KHR(physicalDevice: vk.PhysicalDevice, pPropertyCount: [*c]u32, pProperties: [*c]VkDisplayProperties2KHR) VkResult;
pub extern fn vkGetPhysicalDeviceDisplayPlaneProperties2KHR(physicalDevice: vk.PhysicalDevice, pPropertyCount: [*c]u32, pProperties: [*c]VkDisplayPlaneProperties2KHR) VkResult;
pub extern fn vkGetDisplayModeProperties2KHR(physicalDevice: vk.PhysicalDevice, display: VkDisplayKHR, pPropertyCount: [*c]u32, pProperties: [*c]VkDisplayModeProperties2KHR) VkResult;
pub extern fn vkGetDisplayPlaneCapabilities2KHR(physicalDevice: vk.PhysicalDevice, pDisplayPlaneInfo: [*c]const VkDisplayPlaneInfo2KHR, pCapabilities: [*c]VkDisplayPlaneCapabilities2KHR) VkResult;
pub const VkMemoryDedicatedRequirementsKHR = VkMemoryDedicatedRequirements;
pub const VkMemoryDedicatedAllocateInfoKHR = VkMemoryDedicatedAllocateInfo;
pub const VkBufferMemoryRequirementsInfo2KHR = VkBufferMemoryRequirementsInfo2;
pub const VkImageMemoryRequirementsInfo2KHR = VkImageMemoryRequirementsInfo2;
pub const VkImageSparseMemoryRequirementsInfo2KHR = VkImageSparseMemoryRequirementsInfo2;
pub const VkMemoryRequirements2KHR = VkMemoryRequirements2;
pub const VkSparseImageMemoryRequirements2KHR = VkSparseImageMemoryRequirements2;
pub const PFN_vkGetImageMemoryRequirements2KHR = ?fn (vk.Device, [*c]const VkImageMemoryRequirementsInfo2, [*c]VkMemoryRequirements2) callconv(.C) void;
pub const PFN_vkGetBufferMemoryRequirements2KHR = ?fn (vk.Device, [*c]const VkBufferMemoryRequirementsInfo2, [*c]VkMemoryRequirements2) callconv(.C) void;
pub const PFN_vkGetImageSparseMemoryRequirements2KHR = ?fn (vk.Device, [*c]const VkImageSparseMemoryRequirementsInfo2, [*c]u32, [*c]VkSparseImageMemoryRequirements2) callconv(.C) void;
pub extern fn vkGetImageMemoryRequirements2KHR(device: vk.Device, pInfo: [*c]const VkImageMemoryRequirementsInfo2, pMemoryRequirements: [*c]VkMemoryRequirements2) void;
pub extern fn vkGetBufferMemoryRequirements2KHR(device: vk.Device, pInfo: [*c]const VkBufferMemoryRequirementsInfo2, pMemoryRequirements: [*c]VkMemoryRequirements2) void;
pub extern fn vkGetImageSparseMemoryRequirements2KHR(device: vk.Device, pInfo: [*c]const VkImageSparseMemoryRequirementsInfo2, pSparseMemoryRequirementCount: [*c]u32, pSparseMemoryRequirements: [*c]VkSparseImageMemoryRequirements2) void;
pub const VkImageFormatListCreateInfoKHR = VkImageFormatListCreateInfo;
pub const VkSamplerYcbcrConversionKHR = VkSamplerYcbcrConversion;
pub const VkSamplerYcbcrModelConversionKHR = VkSamplerYcbcrModelConversion;
pub const VkSamplerYcbcrRangeKHR = VkSamplerYcbcrRange;
pub const VkChromaLocationKHR = VkChromaLocation;
pub const VkSamplerYcbcrConversionCreateInfoKHR = VkSamplerYcbcrConversionCreateInfo;
pub const VkSamplerYcbcrConversionInfoKHR = VkSamplerYcbcrConversionInfo;
pub const VkBindImagePlaneMemoryInfoKHR = VkBindImagePlaneMemoryInfo;
pub const VkImagePlaneMemoryRequirementsInfoKHR = VkImagePlaneMemoryRequirementsInfo;
pub const vk.PhysicalDeviceSamplerYcbcrConversionFeaturesKHR = vk.PhysicalDeviceSamplerYcbcrConversionFeatures;
pub const VkSamplerYcbcrConversionImageFormatPropertiesKHR = VkSamplerYcbcrConversionImageFormatProperties;
pub const PFN_vkCreateSamplerYcbcrConversionKHR = ?fn (vk.Device, [*c]const VkSamplerYcbcrConversionCreateInfo, [*c]const VkAllocationCallbacks, [*c]VkSamplerYcbcrConversion) callconv(.C) VkResult;
pub const PFN_vkDestroySamplerYcbcrConversionKHR = ?fn (vk.Device, VkSamplerYcbcrConversion, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub extern fn vkCreateSamplerYcbcrConversionKHR(device: vk.Device, pCreateInfo: [*c]const VkSamplerYcbcrConversionCreateInfo, pAllocator: [*c]const VkAllocationCallbacks, pYcbcrConversion: [*c]VkSamplerYcbcrConversion) VkResult;
pub extern fn vkDestroySamplerYcbcrConversionKHR(device: vk.Device, ycbcrConversion: VkSamplerYcbcrConversion, pAllocator: [*c]const VkAllocationCallbacks) void;
pub const VkBindBufferMemoryInfoKHR = VkBindBufferMemoryInfo;
pub const VkBindImageMemoryInfoKHR = VkBindImageMemoryInfo;
pub const PFN_vkBindBufferMemory2KHR = ?fn (vk.Device, u32, [*c]const VkBindBufferMemoryInfo) callconv(.C) VkResult;
pub const PFN_vkBindImageMemory2KHR = ?fn (vk.Device, u32, [*c]const VkBindImageMemoryInfo) callconv(.C) VkResult;
pub extern fn vkBindBufferMemory2KHR(device: vk.Device, bindInfoCount: u32, pBindInfos: [*c]const VkBindBufferMemoryInfo) VkResult;
pub extern fn vkBindImageMemory2KHR(device: vk.Device, bindInfoCount: u32, pBindInfos: [*c]const VkBindImageMemoryInfo) VkResult;
pub const vk.PhysicalDeviceMaintenance3PropertiesKHR = vk.PhysicalDeviceMaintenance3Properties;
pub const VkDescriptorSetLayoutSupportKHR = VkDescriptorSetLayoutSupport;
pub const PFN_vkGetDescriptorSetLayoutSupportKHR = ?fn (vk.Device, [*c]const VkDescriptorSetLayoutCreateInfo, [*c]VkDescriptorSetLayoutSupport) callconv(.C) void;
pub extern fn vkGetDescriptorSetLayoutSupportKHR(device: vk.Device, pCreateInfo: [*c]const VkDescriptorSetLayoutCreateInfo, pSupport: [*c]VkDescriptorSetLayoutSupport) void;
pub const PFN_vkCmdDrawIndirectCountKHR = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawIndexedIndirectCountKHR = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub extern fn vkCmdDrawIndirectCountKHR(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, countBuffer: VkBuffer, countBufferOffset: vk.DeviceSize, maxDrawCount: u32, stride: u32) void;
pub extern fn vkCmdDrawIndexedIndirectCountKHR(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, countBuffer: VkBuffer, countBufferOffset: vk.DeviceSize, maxDrawCount: u32, stride: u32) void;
pub const vk.PhysicalDeviceShaderSubgroupExtendedTypesFeaturesKHR = vk.PhysicalDeviceShaderSubgroupExtendedTypesFeatures;
pub const vk.PhysicalDevice8BitStorageFeaturesKHR = vk.PhysicalDevice8BitStorageFeatures;
pub const vk.PhysicalDeviceShaderAtomicInt64FeaturesKHR = vk.PhysicalDeviceShaderAtomicInt64Features;
pub const struct_vk.PhysicalDeviceShaderClockFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderSubgroupClock: VkBool32,
    shaderDeviceClock: VkBool32,
};
pub const vk.PhysicalDeviceShaderClockFeaturesKHR = struct_vk.PhysicalDeviceShaderClockFeaturesKHR;
pub const VkDriverIdKHR = VkDriverId;
pub const VkConformanceVersionKHR = VkConformanceVersion;
pub const vk.PhysicalDeviceDriverPropertiesKHR = vk.PhysicalDeviceDriverProperties;
pub const VkShaderFloatControlsIndependenceKHR = VkShaderFloatControlsIndependence;
pub const vk.PhysicalDeviceFloatControlsPropertiesKHR = vk.PhysicalDeviceFloatControlsProperties;
pub const VkResolveModeFlagBitsKHR = VkResolveModeFlagBits;
pub const VkResolveModeFlagsKHR = VkResolveModeFlags;
pub const VkSubpassDescriptionDepthStencilResolveKHR = VkSubpassDescriptionDepthStencilResolve;
pub const vk.PhysicalDeviceDepthStencilResolvePropertiesKHR = vk.PhysicalDeviceDepthStencilResolveProperties;
pub const VkSemaphoreTypeKHR = VkSemaphoreType;
pub const VkSemaphoreWaitFlagBitsKHR = VkSemaphoreWaitFlagBits;
pub const VkSemaphoreWaitFlagsKHR = VkSemaphoreWaitFlags;
pub const vk.PhysicalDeviceTimelineSemaphoreFeaturesKHR = vk.PhysicalDeviceTimelineSemaphoreFeatures;
pub const vk.PhysicalDeviceTimelineSemaphorePropertiesKHR = vk.PhysicalDeviceTimelineSemaphoreProperties;
pub const VkSemaphoreTypeCreateInfoKHR = VkSemaphoreTypeCreateInfo;
pub const VkTimelineSemaphoreSubmitInfoKHR = VkTimelineSemaphoreSubmitInfo;
pub const VkSemaphoreWaitInfoKHR = VkSemaphoreWaitInfo;
pub const VkSemaphoreSignalInfoKHR = VkSemaphoreSignalInfo;
pub const PFN_vkGetSemaphoreCounterValueKHR = ?fn (vk.Device, VkSemaphore, [*c]u64) callconv(.C) VkResult;
pub const PFN_vkWaitSemaphoresKHR = ?fn (vk.Device, [*c]const VkSemaphoreWaitInfo, u64) callconv(.C) VkResult;
pub const PFN_vkSignalSemaphoreKHR = ?fn (vk.Device, [*c]const VkSemaphoreSignalInfo) callconv(.C) VkResult;
pub extern fn vkGetSemaphoreCounterValueKHR(device: vk.Device, semaphore: VkSemaphore, pValue: [*c]u64) VkResult;
pub extern fn vkWaitSemaphoresKHR(device: vk.Device, pWaitInfo: [*c]const VkSemaphoreWaitInfo, timeout: u64) VkResult;
pub extern fn vkSignalSemaphoreKHR(device: vk.Device, pSignalInfo: [*c]const VkSemaphoreSignalInfo) VkResult;
pub const vk.PhysicalDeviceVulkanMemoryModelFeaturesKHR = vk.PhysicalDeviceVulkanMemoryModelFeatures;
pub const struct_vk.PhysicalDeviceShaderTerminateInvocationFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderTerminateInvocation: VkBool32,
};
pub const vk.PhysicalDeviceShaderTerminateInvocationFeaturesKHR = struct_vk.PhysicalDeviceShaderTerminateInvocationFeaturesKHR;
pub const VK_FRAGMENT_SHADING_RATE_COMBINER_OP_KEEP_KHR: c_int = 0;
pub const VK_FRAGMENT_SHADING_RATE_COMBINER_OP_REPLACE_KHR: c_int = 1;
pub const VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MIN_KHR: c_int = 2;
pub const VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MAX_KHR: c_int = 3;
pub const VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MUL_KHR: c_int = 4;
pub const VK_FRAGMENT_SHADING_RATE_COMBINER_OP_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkFragmentShadingRateCombinerOpKHR = c_uint;
pub const VkFragmentShadingRateCombinerOpKHR = enum_VkFragmentShadingRateCombinerOpKHR;
pub const struct_VkFragmentShadingRateAttachmentInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pFragmentShadingRateAttachment: [*c]const VkAttachmentReference2,
    shadingRateAttachmentTexelSize: VkExtent2D,
};
pub const VkFragmentShadingRateAttachmentInfoKHR = struct_VkFragmentShadingRateAttachmentInfoKHR;
pub const struct_VkPipelineFragmentShadingRateStateCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    fragmentSize: VkExtent2D,
    combinerOps: [2]VkFragmentShadingRateCombinerOpKHR,
};
pub const VkPipelineFragmentShadingRateStateCreateInfoKHR = struct_VkPipelineFragmentShadingRateStateCreateInfoKHR;
pub const struct_vk.PhysicalDeviceFragmentShadingRateFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    pipelineFragmentShadingRate: VkBool32,
    primitiveFragmentShadingRate: VkBool32,
    attachmentFragmentShadingRate: VkBool32,
};
pub const vk.PhysicalDeviceFragmentShadingRateFeaturesKHR = struct_vk.PhysicalDeviceFragmentShadingRateFeaturesKHR;
pub const struct_vk.PhysicalDeviceFragmentShadingRatePropertiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    minFragmentShadingRateAttachmentTexelSize: VkExtent2D,
    maxFragmentShadingRateAttachmentTexelSize: VkExtent2D,
    maxFragmentShadingRateAttachmentTexelSizeAspectRatio: u32,
    primitiveFragmentShadingRateWithMultipleViewports: VkBool32,
    layeredShadingRateAttachments: VkBool32,
    fragmentShadingRateNonTrivialCombinerOps: VkBool32,
    maxFragmentSize: VkExtent2D,
    maxFragmentSizeAspectRatio: u32,
    maxFragmentShadingRateCoverageSamples: u32,
    maxFragmentShadingRateRasterizationSamples: VkSampleCountFlagBits,
    fragmentShadingRateWithShaderDepthStencilWrites: VkBool32,
    fragmentShadingRateWithSampleMask: VkBool32,
    fragmentShadingRateWithShaderSampleMask: VkBool32,
    fragmentShadingRateWithConservativeRasterization: VkBool32,
    fragmentShadingRateWithFragmentShaderInterlock: VkBool32,
    fragmentShadingRateWithCustomSampleLocations: VkBool32,
    fragmentShadingRateStrictMultiplyCombiner: VkBool32,
};
pub const vk.PhysicalDeviceFragmentShadingRatePropertiesKHR = struct_vk.PhysicalDeviceFragmentShadingRatePropertiesKHR;
pub const struct_vk.PhysicalDeviceFragmentShadingRateKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    sampleCounts: VkSampleCountFlags,
    fragmentSize: VkExtent2D,
};
pub const vk.PhysicalDeviceFragmentShadingRateKHR = struct_vk.PhysicalDeviceFragmentShadingRateKHR;
pub const PFN_vkGetPhysicalDeviceFragmentShadingRatesKHR = ?fn (vk.PhysicalDevice, [*c]u32, [*c]vk.PhysicalDeviceFragmentShadingRateKHR) callconv(.C) VkResult;
pub const PFN_vkCmdSetFragmentShadingRateKHR = ?fn (VkCommandBuffer, [*c]const VkExtent2D, [*c]const VkFragmentShadingRateCombinerOpKHR) callconv(.C) void;
pub extern fn vkGetPhysicalDeviceFragmentShadingRatesKHR(physicalDevice: vk.PhysicalDevice, pFragmentShadingRateCount: [*c]u32, pFragmentShadingRates: [*c]vk.PhysicalDeviceFragmentShadingRateKHR) VkResult;
pub extern fn vkCmdSetFragmentShadingRateKHR(commandBuffer: VkCommandBuffer, pFragmentSize: [*c]const VkExtent2D, combinerOps: [*c]const VkFragmentShadingRateCombinerOpKHR) void;
pub const struct_VkSurfaceProtectedCapabilitiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    supportsProtected: VkBool32,
};
pub const VkSurfaceProtectedCapabilitiesKHR = struct_VkSurfaceProtectedCapabilitiesKHR;
pub const vk.PhysicalDeviceSeparateDepthStencilLayoutsFeaturesKHR = vk.PhysicalDeviceSeparateDepthStencilLayoutsFeatures;
pub const VkAttachmentReferenceStencilLayoutKHR = VkAttachmentReferenceStencilLayout;
pub const VkAttachmentDescriptionStencilLayoutKHR = VkAttachmentDescriptionStencilLayout;
pub const struct_vk.PhysicalDevicePresentWaitFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    presentWait: VkBool32,
};
pub const vk.PhysicalDevicePresentWaitFeaturesKHR = struct_vk.PhysicalDevicePresentWaitFeaturesKHR;
pub const PFN_vkWaitForPresentKHR = ?fn (vk.Device, VkSwapchainKHR, u64, u64) callconv(.C) VkResult;
pub extern fn vkWaitForPresentKHR(device: vk.Device, swapchain: VkSwapchainKHR, presentId: u64, timeout: u64) VkResult;
pub const vk.PhysicalDeviceUniformBufferStandardLayoutFeaturesKHR = vk.PhysicalDeviceUniformBufferStandardLayoutFeatures;
pub const vk.PhysicalDeviceBufferDeviceAddressFeaturesKHR = vk.PhysicalDeviceBufferDeviceAddressFeatures;
pub const VkBufferDeviceAddressInfoKHR = VkBufferDeviceAddressInfo;
pub const VkBufferOpaqueCaptureAddressCreateInfoKHR = VkBufferOpaqueCaptureAddressCreateInfo;
pub const VkMemoryOpaqueCaptureAddressAllocateInfoKHR = VkMemoryOpaqueCaptureAddressAllocateInfo;
pub const vk.DeviceMemoryOpaqueCaptureAddressInfoKHR = vk.DeviceMemoryOpaqueCaptureAddressInfo;
pub const PFN_vkGetBufferDeviceAddressKHR = ?fn (vk.Device, [*c]const VkBufferDeviceAddressInfo) callconv(.C) vk.DeviceAddress;
pub const PFN_vkGetBufferOpaqueCaptureAddressKHR = ?fn (vk.Device, [*c]const VkBufferDeviceAddressInfo) callconv(.C) u64;
pub const PFN_vkGetDeviceMemoryOpaqueCaptureAddressKHR = ?fn (vk.Device, [*c]const vk.DeviceMemoryOpaqueCaptureAddressInfo) callconv(.C) u64;
pub extern fn vkGetBufferDeviceAddressKHR(device: vk.Device, pInfo: [*c]const VkBufferDeviceAddressInfo) vk.DeviceAddress;
pub extern fn vkGetBufferOpaqueCaptureAddressKHR(device: vk.Device, pInfo: [*c]const VkBufferDeviceAddressInfo) u64;
pub extern fn vkGetDeviceMemoryOpaqueCaptureAddressKHR(device: vk.Device, pInfo: [*c]const vk.DeviceMemoryOpaqueCaptureAddressInfo) u64;
pub const struct_VkDeferredOperationKHR_T = opaque {};
pub const VkDeferredOperationKHR = ?*struct_VkDeferredOperationKHR_T;
pub const PFN_vkCreateDeferredOperationKHR = ?fn (vk.Device, [*c]const VkAllocationCallbacks, [*c]VkDeferredOperationKHR) callconv(.C) VkResult;
pub const PFN_vkDestroyDeferredOperationKHR = ?fn (vk.Device, VkDeferredOperationKHR, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkGetDeferredOperationMaxConcurrencyKHR = ?fn (vk.Device, VkDeferredOperationKHR) callconv(.C) u32;
pub const PFN_vkGetDeferredOperationResultKHR = ?fn (vk.Device, VkDeferredOperationKHR) callconv(.C) VkResult;
pub const PFN_vkDeferredOperationJoinKHR = ?fn (vk.Device, VkDeferredOperationKHR) callconv(.C) VkResult;
pub extern fn vkCreateDeferredOperationKHR(device: vk.Device, pAllocator: [*c]const VkAllocationCallbacks, pDeferredOperation: [*c]VkDeferredOperationKHR) VkResult;
pub extern fn vkDestroyDeferredOperationKHR(device: vk.Device, operation: VkDeferredOperationKHR, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkGetDeferredOperationMaxConcurrencyKHR(device: vk.Device, operation: VkDeferredOperationKHR) u32;
pub extern fn vkGetDeferredOperationResultKHR(device: vk.Device, operation: VkDeferredOperationKHR) VkResult;
pub extern fn vkDeferredOperationJoinKHR(device: vk.Device, operation: VkDeferredOperationKHR) VkResult;
pub const VK_PIPELINE_EXECUTABLE_STATISTIC_FORMAT_BOOL32_KHR: c_int = 0;
pub const VK_PIPELINE_EXECUTABLE_STATISTIC_FORMAT_INT64_KHR: c_int = 1;
pub const VK_PIPELINE_EXECUTABLE_STATISTIC_FORMAT_UINT64_KHR: c_int = 2;
pub const VK_PIPELINE_EXECUTABLE_STATISTIC_FORMAT_FLOAT64_KHR: c_int = 3;
pub const VK_PIPELINE_EXECUTABLE_STATISTIC_FORMAT_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkPipelineExecutableStatisticFormatKHR = c_uint;
pub const VkPipelineExecutableStatisticFormatKHR = enum_VkPipelineExecutableStatisticFormatKHR;
pub const struct_vk.PhysicalDevicePipelineExecutablePropertiesFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    pipelineExecutableInfo: VkBool32,
};
pub const vk.PhysicalDevicePipelineExecutablePropertiesFeaturesKHR = struct_vk.PhysicalDevicePipelineExecutablePropertiesFeaturesKHR;
pub const struct_VkPipelineInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pipeline: VkPipeline,
};
pub const VkPipelineInfoKHR = struct_VkPipelineInfoKHR;
pub const struct_VkPipelineExecutablePropertiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    stages: VkShaderStageFlags,
    name: [256]u8,
    description: [256]u8,
    subgroupSize: u32,
};
pub const VkPipelineExecutablePropertiesKHR = struct_VkPipelineExecutablePropertiesKHR;
pub const struct_VkPipelineExecutableInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pipeline: VkPipeline,
    executableIndex: u32,
};
pub const VkPipelineExecutableInfoKHR = struct_VkPipelineExecutableInfoKHR;
pub const union_VkPipelineExecutableStatisticValueKHR = extern union {
    b32: VkBool32,
    i64: i64,
    u64: u64,
    f64: f64,
};
pub const VkPipelineExecutableStatisticValueKHR = union_VkPipelineExecutableStatisticValueKHR;
pub const struct_VkPipelineExecutableStatisticKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    name: [256]u8,
    description: [256]u8,
    format: VkPipelineExecutableStatisticFormatKHR,
    value: VkPipelineExecutableStatisticValueKHR,
};
pub const VkPipelineExecutableStatisticKHR = struct_VkPipelineExecutableStatisticKHR;
pub const struct_VkPipelineExecutableInternalRepresentationKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    name: [256]u8,
    description: [256]u8,
    isText: VkBool32,
    dataSize: usize,
    pData: ?*anyopaque,
};
pub const VkPipelineExecutableInternalRepresentationKHR = struct_VkPipelineExecutableInternalRepresentationKHR;
pub const PFN_vkGetPipelineExecutablePropertiesKHR = ?fn (vk.Device, [*c]const VkPipelineInfoKHR, [*c]u32, [*c]VkPipelineExecutablePropertiesKHR) callconv(.C) VkResult;
pub const PFN_vkGetPipelineExecutableStatisticsKHR = ?fn (vk.Device, [*c]const VkPipelineExecutableInfoKHR, [*c]u32, [*c]VkPipelineExecutableStatisticKHR) callconv(.C) VkResult;
pub const PFN_vkGetPipelineExecutableInternalRepresentationsKHR = ?fn (vk.Device, [*c]const VkPipelineExecutableInfoKHR, [*c]u32, [*c]VkPipelineExecutableInternalRepresentationKHR) callconv(.C) VkResult;
pub extern fn vkGetPipelineExecutablePropertiesKHR(device: vk.Device, pPipelineInfo: [*c]const VkPipelineInfoKHR, pExecutableCount: [*c]u32, pProperties: [*c]VkPipelineExecutablePropertiesKHR) VkResult;
pub extern fn vkGetPipelineExecutableStatisticsKHR(device: vk.Device, pExecutableInfo: [*c]const VkPipelineExecutableInfoKHR, pStatisticCount: [*c]u32, pStatistics: [*c]VkPipelineExecutableStatisticKHR) VkResult;
pub extern fn vkGetPipelineExecutableInternalRepresentationsKHR(device: vk.Device, pExecutableInfo: [*c]const VkPipelineExecutableInfoKHR, pInternalRepresentationCount: [*c]u32, pInternalRepresentations: [*c]VkPipelineExecutableInternalRepresentationKHR) VkResult;
pub const struct_vk.PhysicalDeviceShaderIntegerDotProductFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderIntegerDotProduct: VkBool32,
};
pub const vk.PhysicalDeviceShaderIntegerDotProductFeaturesKHR = struct_vk.PhysicalDeviceShaderIntegerDotProductFeaturesKHR;
pub const struct_vk.PhysicalDeviceShaderIntegerDotProductPropertiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    integerDotProduct8BitUnsignedAccelerated: VkBool32,
    integerDotProduct8BitSignedAccelerated: VkBool32,
    integerDotProduct8BitMixedSignednessAccelerated: VkBool32,
    integerDotProduct4x8BitPackedUnsignedAccelerated: VkBool32,
    integerDotProduct4x8BitPackedSignedAccelerated: VkBool32,
    integerDotProduct4x8BitPackedMixedSignednessAccelerated: VkBool32,
    integerDotProduct16BitUnsignedAccelerated: VkBool32,
    integerDotProduct16BitSignedAccelerated: VkBool32,
    integerDotProduct16BitMixedSignednessAccelerated: VkBool32,
    integerDotProduct32BitUnsignedAccelerated: VkBool32,
    integerDotProduct32BitSignedAccelerated: VkBool32,
    integerDotProduct32BitMixedSignednessAccelerated: VkBool32,
    integerDotProduct64BitUnsignedAccelerated: VkBool32,
    integerDotProduct64BitSignedAccelerated: VkBool32,
    integerDotProduct64BitMixedSignednessAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating8BitUnsignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating8BitSignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating8BitMixedSignednessAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating4x8BitPackedUnsignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating4x8BitPackedSignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating4x8BitPackedMixedSignednessAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating16BitUnsignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating16BitSignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating16BitMixedSignednessAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating32BitUnsignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating32BitSignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating32BitMixedSignednessAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating64BitUnsignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating64BitSignedAccelerated: VkBool32,
    integerDotProductAccumulatingSaturating64BitMixedSignednessAccelerated: VkBool32,
};
pub const vk.PhysicalDeviceShaderIntegerDotProductPropertiesKHR = struct_vk.PhysicalDeviceShaderIntegerDotProductPropertiesKHR;
pub const struct_VkPipelineLibraryCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    libraryCount: u32,
    pLibraries: [*c]const VkPipeline,
};
pub const VkPipelineLibraryCreateInfoKHR = struct_VkPipelineLibraryCreateInfoKHR;
pub const struct_VkPresentIdKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    swapchainCount: u32,
    pPresentIds: [*c]const u64,
};
pub const VkPresentIdKHR = struct_VkPresentIdKHR;
pub const struct_vk.PhysicalDevicePresentIdFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    presentId: VkBool32,
};
pub const vk.PhysicalDevicePresentIdFeaturesKHR = struct_vk.PhysicalDevicePresentIdFeaturesKHR;
pub const VkFlags64 = u64;
pub const VkPipelineStageFlags2KHR = VkFlags64;
pub const VkPipelineStageFlagBits2KHR = VkFlags64;
pub const VK_PIPELINE_STAGE_2_NONE_KHR: VkPipelineStageFlagBits2KHR = 0;
pub const VK_PIPELINE_STAGE_2_TOP_OF_PIPE_BIT_KHR: VkPipelineStageFlagBits2KHR = 1;
pub const VK_PIPELINE_STAGE_2_DRAW_INDIRECT_BIT_KHR: VkPipelineStageFlagBits2KHR = 2;
pub const VK_PIPELINE_STAGE_2_VERTEX_INPUT_BIT_KHR: VkPipelineStageFlagBits2KHR = 4;
pub const VK_PIPELINE_STAGE_2_VERTEX_SHADER_BIT_KHR: VkPipelineStageFlagBits2KHR = 8;
pub const VK_PIPELINE_STAGE_2_TESSELLATION_CONTROL_SHADER_BIT_KHR: VkPipelineStageFlagBits2KHR = 16;
pub const VK_PIPELINE_STAGE_2_TESSELLATION_EVALUATION_SHADER_BIT_KHR: VkPipelineStageFlagBits2KHR = 32;
pub const VK_PIPELINE_STAGE_2_GEOMETRY_SHADER_BIT_KHR: VkPipelineStageFlagBits2KHR = 64;
pub const VK_PIPELINE_STAGE_2_FRAGMENT_SHADER_BIT_KHR: VkPipelineStageFlagBits2KHR = 128;
pub const VK_PIPELINE_STAGE_2_EARLY_FRAGMENT_TESTS_BIT_KHR: VkPipelineStageFlagBits2KHR = 256;
pub const VK_PIPELINE_STAGE_2_LATE_FRAGMENT_TESTS_BIT_KHR: VkPipelineStageFlagBits2KHR = 512;
pub const VK_PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT_KHR: VkPipelineStageFlagBits2KHR = 1024;
pub const VK_PIPELINE_STAGE_2_COMPUTE_SHADER_BIT_KHR: VkPipelineStageFlagBits2KHR = 2048;
pub const VK_PIPELINE_STAGE_2_ALL_TRANSFER_BIT_KHR: VkPipelineStageFlagBits2KHR = 4096;
pub const VK_PIPELINE_STAGE_2_TRANSFER_BIT_KHR: VkPipelineStageFlagBits2KHR = 4096;
pub const VK_PIPELINE_STAGE_2_BOTTOM_OF_PIPE_BIT_KHR: VkPipelineStageFlagBits2KHR = 8192;
pub const VK_PIPELINE_STAGE_2_HOST_BIT_KHR: VkPipelineStageFlagBits2KHR = 16384;
pub const VK_PIPELINE_STAGE_2_ALL_GRAPHICS_BIT_KHR: VkPipelineStageFlagBits2KHR = 32768;
pub const VK_PIPELINE_STAGE_2_ALL_COMMANDS_BIT_KHR: VkPipelineStageFlagBits2KHR = 65536;
pub const VK_PIPELINE_STAGE_2_COPY_BIT_KHR: VkPipelineStageFlagBits2KHR = 4294967296;
pub const VK_PIPELINE_STAGE_2_RESOLVE_BIT_KHR: VkPipelineStageFlagBits2KHR = 8589934592;
pub const VK_PIPELINE_STAGE_2_BLIT_BIT_KHR: VkPipelineStageFlagBits2KHR = 17179869184;
pub const VK_PIPELINE_STAGE_2_CLEAR_BIT_KHR: VkPipelineStageFlagBits2KHR = 34359738368;
pub const VK_PIPELINE_STAGE_2_INDEX_INPUT_BIT_KHR: VkPipelineStageFlagBits2KHR = 68719476736;
pub const VK_PIPELINE_STAGE_2_VERTEX_ATTRIBUTE_INPUT_BIT_KHR: VkPipelineStageFlagBits2KHR = 137438953472;
pub const VK_PIPELINE_STAGE_2_PRE_RASTERIZATION_SHADERS_BIT_KHR: VkPipelineStageFlagBits2KHR = 274877906944;
pub const VK_PIPELINE_STAGE_2_TRANSFORM_FEEDBACK_BIT_EXT: VkPipelineStageFlagBits2KHR = 16777216;
pub const VK_PIPELINE_STAGE_2_CONDITIONAL_RENDERING_BIT_EXT: VkPipelineStageFlagBits2KHR = 262144;
pub const VK_PIPELINE_STAGE_2_COMMAND_PREPROCESS_BIT_NV: VkPipelineStageFlagBits2KHR = 131072;
pub const VK_PIPELINE_STAGE_2_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR: VkPipelineStageFlagBits2KHR = 4194304;
pub const VK_PIPELINE_STAGE_2_SHADING_RATE_IMAGE_BIT_NV: VkPipelineStageFlagBits2KHR = 4194304;
pub const VK_PIPELINE_STAGE_2_ACCELERATION_STRUCTURE_BUILD_BIT_KHR: VkPipelineStageFlagBits2KHR = 33554432;
pub const VK_PIPELINE_STAGE_2_RAY_TRACING_SHADER_BIT_KHR: VkPipelineStageFlagBits2KHR = 2097152;
pub const VK_PIPELINE_STAGE_2_RAY_TRACING_SHADER_BIT_NV: VkPipelineStageFlagBits2KHR = 2097152;
pub const VK_PIPELINE_STAGE_2_ACCELERATION_STRUCTURE_BUILD_BIT_NV: VkPipelineStageFlagBits2KHR = 33554432;
pub const VK_PIPELINE_STAGE_2_FRAGMENT_DENSITY_PROCESS_BIT_EXT: VkPipelineStageFlagBits2KHR = 8388608;
pub const VK_PIPELINE_STAGE_2_TASK_SHADER_BIT_NV: VkPipelineStageFlagBits2KHR = 524288;
pub const VK_PIPELINE_STAGE_2_MESH_SHADER_BIT_NV: VkPipelineStageFlagBits2KHR = 1048576;
pub const VK_PIPELINE_STAGE_2_SUBPASS_SHADING_BIT_HUAWEI: VkPipelineStageFlagBits2KHR = 549755813888;
pub const VK_PIPELINE_STAGE_2_INVOCATION_MASK_BIT_HUAWEI: VkPipelineStageFlagBits2KHR = 1099511627776;
pub const VkAccessFlags2KHR = VkFlags64;
pub const VkAccessFlagBits2KHR = VkFlags64;
pub const VK_ACCESS_2_NONE_KHR: VkAccessFlagBits2KHR = 0;
pub const VK_ACCESS_2_INDIRECT_COMMAND_READ_BIT_KHR: VkAccessFlagBits2KHR = 1;
pub const VK_ACCESS_2_INDEX_READ_BIT_KHR: VkAccessFlagBits2KHR = 2;
pub const VK_ACCESS_2_VERTEX_ATTRIBUTE_READ_BIT_KHR: VkAccessFlagBits2KHR = 4;
pub const VK_ACCESS_2_UNIFORM_READ_BIT_KHR: VkAccessFlagBits2KHR = 8;
pub const VK_ACCESS_2_INPUT_ATTACHMENT_READ_BIT_KHR: VkAccessFlagBits2KHR = 16;
pub const VK_ACCESS_2_SHADER_READ_BIT_KHR: VkAccessFlagBits2KHR = 32;
pub const VK_ACCESS_2_SHADER_WRITE_BIT_KHR: VkAccessFlagBits2KHR = 64;
pub const VK_ACCESS_2_COLOR_ATTACHMENT_READ_BIT_KHR: VkAccessFlagBits2KHR = 128;
pub const VK_ACCESS_2_COLOR_ATTACHMENT_WRITE_BIT_KHR: VkAccessFlagBits2KHR = 256;
pub const VK_ACCESS_2_DEPTH_STENCIL_ATTACHMENT_READ_BIT_KHR: VkAccessFlagBits2KHR = 512;
pub const VK_ACCESS_2_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT_KHR: VkAccessFlagBits2KHR = 1024;
pub const VK_ACCESS_2_TRANSFER_READ_BIT_KHR: VkAccessFlagBits2KHR = 2048;
pub const VK_ACCESS_2_TRANSFER_WRITE_BIT_KHR: VkAccessFlagBits2KHR = 4096;
pub const VK_ACCESS_2_HOST_READ_BIT_KHR: VkAccessFlagBits2KHR = 8192;
pub const VK_ACCESS_2_HOST_WRITE_BIT_KHR: VkAccessFlagBits2KHR = 16384;
pub const VK_ACCESS_2_MEMORY_READ_BIT_KHR: VkAccessFlagBits2KHR = 32768;
pub const VK_ACCESS_2_MEMORY_WRITE_BIT_KHR: VkAccessFlagBits2KHR = 65536;
pub const VK_ACCESS_2_SHADER_SAMPLED_READ_BIT_KHR: VkAccessFlagBits2KHR = 4294967296;
pub const VK_ACCESS_2_SHADER_STORAGE_READ_BIT_KHR: VkAccessFlagBits2KHR = 8589934592;
pub const VK_ACCESS_2_SHADER_STORAGE_WRITE_BIT_KHR: VkAccessFlagBits2KHR = 17179869184;
pub const VK_ACCESS_2_TRANSFORM_FEEDBACK_WRITE_BIT_EXT: VkAccessFlagBits2KHR = 33554432;
pub const VK_ACCESS_2_TRANSFORM_FEEDBACK_COUNTER_READ_BIT_EXT: VkAccessFlagBits2KHR = 67108864;
pub const VK_ACCESS_2_TRANSFORM_FEEDBACK_COUNTER_WRITE_BIT_EXT: VkAccessFlagBits2KHR = 134217728;
pub const VK_ACCESS_2_CONDITIONAL_RENDERING_READ_BIT_EXT: VkAccessFlagBits2KHR = 1048576;
pub const VK_ACCESS_2_COMMAND_PREPROCESS_READ_BIT_NV: VkAccessFlagBits2KHR = 131072;
pub const VK_ACCESS_2_COMMAND_PREPROCESS_WRITE_BIT_NV: VkAccessFlagBits2KHR = 262144;
pub const VK_ACCESS_2_FRAGMENT_SHADING_RATE_ATTACHMENT_READ_BIT_KHR: VkAccessFlagBits2KHR = 8388608;
pub const VK_ACCESS_2_SHADING_RATE_IMAGE_READ_BIT_NV: VkAccessFlagBits2KHR = 8388608;
pub const VK_ACCESS_2_ACCELERATION_STRUCTURE_READ_BIT_KHR: VkAccessFlagBits2KHR = 2097152;
pub const VK_ACCESS_2_ACCELERATION_STRUCTURE_WRITE_BIT_KHR: VkAccessFlagBits2KHR = 4194304;
pub const VK_ACCESS_2_ACCELERATION_STRUCTURE_READ_BIT_NV: VkAccessFlagBits2KHR = 2097152;
pub const VK_ACCESS_2_ACCELERATION_STRUCTURE_WRITE_BIT_NV: VkAccessFlagBits2KHR = 4194304;
pub const VK_ACCESS_2_FRAGMENT_DENSITY_MAP_READ_BIT_EXT: VkAccessFlagBits2KHR = 16777216;
pub const VK_ACCESS_2_COLOR_ATTACHMENT_READ_NONCOHERENT_BIT_EXT: VkAccessFlagBits2KHR = 524288;
pub const VK_ACCESS_2_INVOCATION_MASK_READ_BIT_HUAWEI: VkAccessFlagBits2KHR = 549755813888;
pub const VK_SUBMIT_PROTECTED_BIT_KHR: c_int = 1;
pub const VK_SUBMIT_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkSubmitFlagBitsKHR = c_uint;
pub const VkSubmitFlagBitsKHR = enum_VkSubmitFlagBitsKHR;
pub const VkSubmitFlagsKHR = VkFlags;
pub const struct_VkMemoryBarrier2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcStageMask: VkPipelineStageFlags2KHR,
    srcAccessMask: VkAccessFlags2KHR,
    dstStageMask: VkPipelineStageFlags2KHR,
    dstAccessMask: VkAccessFlags2KHR,
};
pub const VkMemoryBarrier2KHR = struct_VkMemoryBarrier2KHR;
pub const struct_VkBufferMemoryBarrier2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcStageMask: VkPipelineStageFlags2KHR,
    srcAccessMask: VkAccessFlags2KHR,
    dstStageMask: VkPipelineStageFlags2KHR,
    dstAccessMask: VkAccessFlags2KHR,
    srcQueueFamilyIndex: u32,
    dstQueueFamilyIndex: u32,
    buffer: VkBuffer,
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
};
pub const VkBufferMemoryBarrier2KHR = struct_VkBufferMemoryBarrier2KHR;
pub const struct_VkImageMemoryBarrier2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcStageMask: VkPipelineStageFlags2KHR,
    srcAccessMask: VkAccessFlags2KHR,
    dstStageMask: VkPipelineStageFlags2KHR,
    dstAccessMask: VkAccessFlags2KHR,
    oldLayout: VkImageLayout,
    newLayout: VkImageLayout,
    srcQueueFamilyIndex: u32,
    dstQueueFamilyIndex: u32,
    image: VkImage,
    subresourceRange: VkImageSubresourceRange,
};
pub const VkImageMemoryBarrier2KHR = struct_VkImageMemoryBarrier2KHR;
pub const struct_VkDependencyInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    dependencyFlags: VkDependencyFlags,
    memoryBarrierCount: u32,
    pMemoryBarriers: [*c]const VkMemoryBarrier2KHR,
    bufferMemoryBarrierCount: u32,
    pBufferMemoryBarriers: [*c]const VkBufferMemoryBarrier2KHR,
    imageMemoryBarrierCount: u32,
    pImageMemoryBarriers: [*c]const VkImageMemoryBarrier2KHR,
};
pub const VkDependencyInfoKHR = struct_VkDependencyInfoKHR;
pub const struct_VkSemaphoreSubmitInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    semaphore: VkSemaphore,
    value: u64,
    stageMask: VkPipelineStageFlags2KHR,
    deviceIndex: u32,
};
pub const VkSemaphoreSubmitInfoKHR = struct_VkSemaphoreSubmitInfoKHR;
pub const struct_VkCommandBufferSubmitInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    commandBuffer: VkCommandBuffer,
    deviceMask: u32,
};
pub const VkCommandBufferSubmitInfoKHR = struct_VkCommandBufferSubmitInfoKHR;
pub const struct_VkSubmitInfo2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkSubmitFlagsKHR,
    waitSemaphoreInfoCount: u32,
    pWaitSemaphoreInfos: [*c]const VkSemaphoreSubmitInfoKHR,
    commandBufferInfoCount: u32,
    pCommandBufferInfos: [*c]const VkCommandBufferSubmitInfoKHR,
    signalSemaphoreInfoCount: u32,
    pSignalSemaphoreInfos: [*c]const VkSemaphoreSubmitInfoKHR,
};
pub const VkSubmitInfo2KHR = struct_VkSubmitInfo2KHR;
pub const struct_vk.PhysicalDeviceSynchronization2FeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    synchronization2: VkBool32,
};
pub const vk.PhysicalDeviceSynchronization2FeaturesKHR = struct_vk.PhysicalDeviceSynchronization2FeaturesKHR;
pub const struct_VkQueueFamilyCheckpointProperties2NV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    checkpointExecutionStageMask: VkPipelineStageFlags2KHR,
};
pub const VkQueueFamilyCheckpointProperties2NV = struct_VkQueueFamilyCheckpointProperties2NV;
pub const struct_VkCheckpointData2NV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    stage: VkPipelineStageFlags2KHR,
    pCheckpointMarker: ?*anyopaque,
};
pub const VkCheckpointData2NV = struct_VkCheckpointData2NV;
pub const PFN_vkCmdSetEvent2KHR = ?fn (VkCommandBuffer, VkEvent, [*c]const VkDependencyInfoKHR) callconv(.C) void;
pub const PFN_vkCmdResetEvent2KHR = ?fn (VkCommandBuffer, VkEvent, VkPipelineStageFlags2KHR) callconv(.C) void;
pub const PFN_vkCmdWaitEvents2KHR = ?fn (VkCommandBuffer, u32, [*c]const VkEvent, [*c]const VkDependencyInfoKHR) callconv(.C) void;
pub const PFN_vkCmdPipelineBarrier2KHR = ?fn (VkCommandBuffer, [*c]const VkDependencyInfoKHR) callconv(.C) void;
pub const PFN_vkCmdWriteTimestamp2KHR = ?fn (VkCommandBuffer, VkPipelineStageFlags2KHR, VkQueryPool, u32) callconv(.C) void;
pub const PFN_vkQueueSubmit2KHR = ?fn (VkQueue, u32, [*c]const VkSubmitInfo2KHR, VkFence) callconv(.C) VkResult;
pub const PFN_vkCmdWriteBufferMarker2AMD = ?fn (VkCommandBuffer, VkPipelineStageFlags2KHR, VkBuffer, vk.DeviceSize, u32) callconv(.C) void;
pub const PFN_vkGetQueueCheckpointData2NV = ?fn (VkQueue, [*c]u32, [*c]VkCheckpointData2NV) callconv(.C) void;
pub extern fn vkCmdSetEvent2KHR(commandBuffer: VkCommandBuffer, event: VkEvent, pDependencyInfo: [*c]const VkDependencyInfoKHR) void;
pub extern fn vkCmdResetEvent2KHR(commandBuffer: VkCommandBuffer, event: VkEvent, stageMask: VkPipelineStageFlags2KHR) void;
pub extern fn vkCmdWaitEvents2KHR(commandBuffer: VkCommandBuffer, eventCount: u32, pEvents: [*c]const VkEvent, pDependencyInfos: [*c]const VkDependencyInfoKHR) void;
pub extern fn vkCmdPipelineBarrier2KHR(commandBuffer: VkCommandBuffer, pDependencyInfo: [*c]const VkDependencyInfoKHR) void;
pub extern fn vkCmdWriteTimestamp2KHR(commandBuffer: VkCommandBuffer, stage: VkPipelineStageFlags2KHR, queryPool: VkQueryPool, query: u32) void;
pub extern fn vkQueueSubmit2KHR(queue: VkQueue, submitCount: u32, pSubmits: [*c]const VkSubmitInfo2KHR, fence: VkFence) VkResult;
pub extern fn vkCmdWriteBufferMarker2AMD(commandBuffer: VkCommandBuffer, stage: VkPipelineStageFlags2KHR, dstBuffer: VkBuffer, dstOffset: vk.DeviceSize, marker: u32) void;
pub extern fn vkGetQueueCheckpointData2NV(queue: VkQueue, pCheckpointDataCount: [*c]u32, pCheckpointData: [*c]VkCheckpointData2NV) void;
pub const struct_vk.PhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderSubgroupUniformControlFlow: VkBool32,
};
pub const vk.PhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR = struct_vk.PhysicalDeviceShaderSubgroupUniformControlFlowFeaturesKHR;
pub const struct_vk.PhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderZeroInitializeWorkgroupMemory: VkBool32,
};
pub const vk.PhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR = struct_vk.PhysicalDeviceZeroInitializeWorkgroupMemoryFeaturesKHR;
pub const struct_vk.PhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    workgroupMemoryExplicitLayout: VkBool32,
    workgroupMemoryExplicitLayoutScalarBlockLayout: VkBool32,
    workgroupMemoryExplicitLayout8BitAccess: VkBool32,
    workgroupMemoryExplicitLayout16BitAccess: VkBool32,
};
pub const vk.PhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR = struct_vk.PhysicalDeviceWorkgroupMemoryExplicitLayoutFeaturesKHR;
pub const struct_VkBufferCopy2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcOffset: vk.DeviceSize,
    dstOffset: vk.DeviceSize,
    size: vk.DeviceSize,
};
pub const VkBufferCopy2KHR = struct_VkBufferCopy2KHR;
pub const struct_VkCopyBufferInfo2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcBuffer: VkBuffer,
    dstBuffer: VkBuffer,
    regionCount: u32,
    pRegions: [*c]const VkBufferCopy2KHR,
};
pub const VkCopyBufferInfo2KHR = struct_VkCopyBufferInfo2KHR;
pub const struct_VkImageCopy2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcSubresource: VkImageSubresourceLayers,
    srcOffset: VkOffset3D,
    dstSubresource: VkImageSubresourceLayers,
    dstOffset: VkOffset3D,
    extent: VkExtent3D,
};
pub const VkImageCopy2KHR = struct_VkImageCopy2KHR;
pub const struct_VkCopyImageInfo2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcImage: VkImage,
    srcImageLayout: VkImageLayout,
    dstImage: VkImage,
    dstImageLayout: VkImageLayout,
    regionCount: u32,
    pRegions: [*c]const VkImageCopy2KHR,
};
pub const VkCopyImageInfo2KHR = struct_VkCopyImageInfo2KHR;
pub const struct_VkBufferImageCopy2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    bufferOffset: vk.DeviceSize,
    bufferRowLength: u32,
    bufferImageHeight: u32,
    imageSubresource: VkImageSubresourceLayers,
    imageOffset: VkOffset3D,
    imageExtent: VkExtent3D,
};
pub const VkBufferImageCopy2KHR = struct_VkBufferImageCopy2KHR;
pub const struct_VkCopyBufferToImageInfo2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcBuffer: VkBuffer,
    dstImage: VkImage,
    dstImageLayout: VkImageLayout,
    regionCount: u32,
    pRegions: [*c]const VkBufferImageCopy2KHR,
};
pub const VkCopyBufferToImageInfo2KHR = struct_VkCopyBufferToImageInfo2KHR;
pub const struct_VkCopyImageToBufferInfo2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcImage: VkImage,
    srcImageLayout: VkImageLayout,
    dstBuffer: VkBuffer,
    regionCount: u32,
    pRegions: [*c]const VkBufferImageCopy2KHR,
};
pub const VkCopyImageToBufferInfo2KHR = struct_VkCopyImageToBufferInfo2KHR;
pub const struct_VkImageBlit2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcSubresource: VkImageSubresourceLayers,
    srcOffsets: [2]VkOffset3D,
    dstSubresource: VkImageSubresourceLayers,
    dstOffsets: [2]VkOffset3D,
};
pub const VkImageBlit2KHR = struct_VkImageBlit2KHR;
pub const struct_VkBlitImageInfo2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcImage: VkImage,
    srcImageLayout: VkImageLayout,
    dstImage: VkImage,
    dstImageLayout: VkImageLayout,
    regionCount: u32,
    pRegions: [*c]const VkImageBlit2KHR,
    filter: VkFilter,
};
pub const VkBlitImageInfo2KHR = struct_VkBlitImageInfo2KHR;
pub const struct_VkImageResolve2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcSubresource: VkImageSubresourceLayers,
    srcOffset: VkOffset3D,
    dstSubresource: VkImageSubresourceLayers,
    dstOffset: VkOffset3D,
    extent: VkExtent3D,
};
pub const VkImageResolve2KHR = struct_VkImageResolve2KHR;
pub const struct_VkResolveImageInfo2KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcImage: VkImage,
    srcImageLayout: VkImageLayout,
    dstImage: VkImage,
    dstImageLayout: VkImageLayout,
    regionCount: u32,
    pRegions: [*c]const VkImageResolve2KHR,
};
pub const VkResolveImageInfo2KHR = struct_VkResolveImageInfo2KHR;
pub const PFN_vkCmdCopyBuffer2KHR = ?fn (VkCommandBuffer, [*c]const VkCopyBufferInfo2KHR) callconv(.C) void;
pub const PFN_vkCmdCopyImage2KHR = ?fn (VkCommandBuffer, [*c]const VkCopyImageInfo2KHR) callconv(.C) void;
pub const PFN_vkCmdCopyBufferToImage2KHR = ?fn (VkCommandBuffer, [*c]const VkCopyBufferToImageInfo2KHR) callconv(.C) void;
pub const PFN_vkCmdCopyImageToBuffer2KHR = ?fn (VkCommandBuffer, [*c]const VkCopyImageToBufferInfo2KHR) callconv(.C) void;
pub const PFN_vkCmdBlitImage2KHR = ?fn (VkCommandBuffer, [*c]const VkBlitImageInfo2KHR) callconv(.C) void;
pub const PFN_vkCmdResolveImage2KHR = ?fn (VkCommandBuffer, [*c]const VkResolveImageInfo2KHR) callconv(.C) void;
pub extern fn vkCmdCopyBuffer2KHR(commandBuffer: VkCommandBuffer, pCopyBufferInfo: [*c]const VkCopyBufferInfo2KHR) void;
pub extern fn vkCmdCopyImage2KHR(commandBuffer: VkCommandBuffer, pCopyImageInfo: [*c]const VkCopyImageInfo2KHR) void;
pub extern fn vkCmdCopyBufferToImage2KHR(commandBuffer: VkCommandBuffer, pCopyBufferToImageInfo: [*c]const VkCopyBufferToImageInfo2KHR) void;
pub extern fn vkCmdCopyImageToBuffer2KHR(commandBuffer: VkCommandBuffer, pCopyImageToBufferInfo: [*c]const VkCopyImageToBufferInfo2KHR) void;
pub extern fn vkCmdBlitImage2KHR(commandBuffer: VkCommandBuffer, pBlitImageInfo: [*c]const VkBlitImageInfo2KHR) void;
pub extern fn vkCmdResolveImage2KHR(commandBuffer: VkCommandBuffer, pResolveImageInfo: [*c]const VkResolveImageInfo2KHR) void;
pub const VkFormatFeatureFlags2KHR = VkFlags64;
pub const VkFormatFeatureFlagBits2KHR = VkFlags64;
pub const VK_FORMAT_FEATURE_2_SAMPLED_IMAGE_BIT_KHR: VkFormatFeatureFlagBits2KHR = 1;
pub const VK_FORMAT_FEATURE_2_STORAGE_IMAGE_BIT_KHR: VkFormatFeatureFlagBits2KHR = 2;
pub const VK_FORMAT_FEATURE_2_STORAGE_IMAGE_ATOMIC_BIT_KHR: VkFormatFeatureFlagBits2KHR = 4;
pub const VK_FORMAT_FEATURE_2_UNIFORM_TEXEL_BUFFER_BIT_KHR: VkFormatFeatureFlagBits2KHR = 8;
pub const VK_FORMAT_FEATURE_2_STORAGE_TEXEL_BUFFER_BIT_KHR: VkFormatFeatureFlagBits2KHR = 16;
pub const VK_FORMAT_FEATURE_2_STORAGE_TEXEL_BUFFER_ATOMIC_BIT_KHR: VkFormatFeatureFlagBits2KHR = 32;
pub const VK_FORMAT_FEATURE_2_VERTEX_BUFFER_BIT_KHR: VkFormatFeatureFlagBits2KHR = 64;
pub const VK_FORMAT_FEATURE_2_COLOR_ATTACHMENT_BIT_KHR: VkFormatFeatureFlagBits2KHR = 128;
pub const VK_FORMAT_FEATURE_2_COLOR_ATTACHMENT_BLEND_BIT_KHR: VkFormatFeatureFlagBits2KHR = 256;
pub const VK_FORMAT_FEATURE_2_DEPTH_STENCIL_ATTACHMENT_BIT_KHR: VkFormatFeatureFlagBits2KHR = 512;
pub const VK_FORMAT_FEATURE_2_BLIT_SRC_BIT_KHR: VkFormatFeatureFlagBits2KHR = 1024;
pub const VK_FORMAT_FEATURE_2_BLIT_DST_BIT_KHR: VkFormatFeatureFlagBits2KHR = 2048;
pub const VK_FORMAT_FEATURE_2_SAMPLED_IMAGE_FILTER_LINEAR_BIT_KHR: VkFormatFeatureFlagBits2KHR = 4096;
pub const VK_FORMAT_FEATURE_2_SAMPLED_IMAGE_FILTER_CUBIC_BIT_EXT: VkFormatFeatureFlagBits2KHR = 8192;
pub const VK_FORMAT_FEATURE_2_TRANSFER_SRC_BIT_KHR: VkFormatFeatureFlagBits2KHR = 16384;
pub const VK_FORMAT_FEATURE_2_TRANSFER_DST_BIT_KHR: VkFormatFeatureFlagBits2KHR = 32768;
pub const VK_FORMAT_FEATURE_2_SAMPLED_IMAGE_FILTER_MINMAX_BIT_KHR: VkFormatFeatureFlagBits2KHR = 65536;
pub const VK_FORMAT_FEATURE_2_MIDPOINT_CHROMA_SAMPLES_BIT_KHR: VkFormatFeatureFlagBits2KHR = 131072;
pub const VK_FORMAT_FEATURE_2_SAMPLED_IMAGE_YCBCR_CONVERSION_LINEAR_FILTER_BIT_KHR: VkFormatFeatureFlagBits2KHR = 262144;
pub const VK_FORMAT_FEATURE_2_SAMPLED_IMAGE_YCBCR_CONVERSION_SEPARATE_RECONSTRUCTION_FILTER_BIT_KHR: VkFormatFeatureFlagBits2KHR = 524288;
pub const VK_FORMAT_FEATURE_2_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_BIT_KHR: VkFormatFeatureFlagBits2KHR = 1048576;
pub const VK_FORMAT_FEATURE_2_SAMPLED_IMAGE_YCBCR_CONVERSION_CHROMA_RECONSTRUCTION_EXPLICIT_FORCEABLE_BIT_KHR: VkFormatFeatureFlagBits2KHR = 2097152;
pub const VK_FORMAT_FEATURE_2_DISJOINT_BIT_KHR: VkFormatFeatureFlagBits2KHR = 4194304;
pub const VK_FORMAT_FEATURE_2_COSITED_CHROMA_SAMPLES_BIT_KHR: VkFormatFeatureFlagBits2KHR = 8388608;
pub const VK_FORMAT_FEATURE_2_STORAGE_READ_WITHOUT_FORMAT_BIT_KHR: VkFormatFeatureFlagBits2KHR = 2147483648;
pub const VK_FORMAT_FEATURE_2_STORAGE_WRITE_WITHOUT_FORMAT_BIT_KHR: VkFormatFeatureFlagBits2KHR = 4294967296;
pub const VK_FORMAT_FEATURE_2_SAMPLED_IMAGE_DEPTH_COMPARISON_BIT_KHR: VkFormatFeatureFlagBits2KHR = 8589934592;
pub const VK_FORMAT_FEATURE_2_ACCELERATION_STRUCTURE_VERTEX_BUFFER_BIT_KHR: VkFormatFeatureFlagBits2KHR = 536870912;
pub const VK_FORMAT_FEATURE_2_FRAGMENT_DENSITY_MAP_BIT_EXT: VkFormatFeatureFlagBits2KHR = 16777216;
pub const VK_FORMAT_FEATURE_2_FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR: VkFormatFeatureFlagBits2KHR = 1073741824;
pub const VK_FORMAT_FEATURE_2_LINEAR_COLOR_ATTACHMENT_BIT_NV: VkFormatFeatureFlagBits2KHR = 274877906944;
pub const struct_VkFormatProperties3KHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    linearTilingFeatures: VkFormatFeatureFlags2KHR,
    optimalTilingFeatures: VkFormatFeatureFlags2KHR,
    bufferFeatures: VkFormatFeatureFlags2KHR,
};
pub const VkFormatProperties3KHR = struct_VkFormatProperties3KHR;
pub const struct_vk.PhysicalDeviceMaintenance4FeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maintenance4: VkBool32,
};
pub const vk.PhysicalDeviceMaintenance4FeaturesKHR = struct_vk.PhysicalDeviceMaintenance4FeaturesKHR;
pub const struct_vk.PhysicalDeviceMaintenance4PropertiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxBufferSize: vk.DeviceSize,
};
pub const vk.PhysicalDeviceMaintenance4PropertiesKHR = struct_vk.PhysicalDeviceMaintenance4PropertiesKHR;
pub const struct_vk.DeviceBufferMemoryRequirementsKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pCreateInfo: [*c]const VkBufferCreateInfo,
};
pub const vk.DeviceBufferMemoryRequirementsKHR = struct_vk.DeviceBufferMemoryRequirementsKHR;
pub const struct_vk.DeviceImageMemoryRequirementsKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pCreateInfo: [*c]const VkImageCreateInfo,
    planeAspect: VkImageAspectFlagBits,
};
pub const vk.DeviceImageMemoryRequirementsKHR = struct_vk.DeviceImageMemoryRequirementsKHR;
pub const PFN_vkGetDeviceBufferMemoryRequirementsKHR = ?fn (vk.Device, [*c]const vk.DeviceBufferMemoryRequirementsKHR, [*c]VkMemoryRequirements2) callconv(.C) void;
pub const PFN_vkGetDeviceImageMemoryRequirementsKHR = ?fn (vk.Device, [*c]const vk.DeviceImageMemoryRequirementsKHR, [*c]VkMemoryRequirements2) callconv(.C) void;
pub const PFN_vkGetDeviceImageSparseMemoryRequirementsKHR = ?fn (vk.Device, [*c]const vk.DeviceImageMemoryRequirementsKHR, [*c]u32, [*c]VkSparseImageMemoryRequirements2) callconv(.C) void;
pub extern fn vkGetDeviceBufferMemoryRequirementsKHR(device: vk.Device, pInfo: [*c]const vk.DeviceBufferMemoryRequirementsKHR, pMemoryRequirements: [*c]VkMemoryRequirements2) void;
pub extern fn vkGetDeviceImageMemoryRequirementsKHR(device: vk.Device, pInfo: [*c]const vk.DeviceImageMemoryRequirementsKHR, pMemoryRequirements: [*c]VkMemoryRequirements2) void;
pub extern fn vkGetDeviceImageSparseMemoryRequirementsKHR(device: vk.Device, pInfo: [*c]const vk.DeviceImageMemoryRequirementsKHR, pSparseMemoryRequirementCount: [*c]u32, pSparseMemoryRequirements: [*c]VkSparseImageMemoryRequirements2) void;
pub const struct_VkDebugReportCallbackEXT_T = opaque {};
pub const VkDebugReportCallbackEXT = ?*struct_VkDebugReportCallbackEXT_T;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_UNKNOWN_EXT: c_int = 0;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_INSTANCE_EXT: c_int = 1;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_PHYSICAL_DEVICE_EXT: c_int = 2;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DEVICE_EXT: c_int = 3;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_QUEUE_EXT: c_int = 4;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_SEMAPHORE_EXT: c_int = 5;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_BUFFER_EXT: c_int = 6;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_FENCE_EXT: c_int = 7;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DEVICE_MEMORY_EXT: c_int = 8;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_EXT: c_int = 9;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_EXT: c_int = 10;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_EVENT_EXT: c_int = 11;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_QUERY_POOL_EXT: c_int = 12;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_VIEW_EXT: c_int = 13;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_IMAGE_VIEW_EXT: c_int = 14;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_SHADER_MODULE_EXT: c_int = 15;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_CACHE_EXT: c_int = 16;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_LAYOUT_EXT: c_int = 17;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_RENDER_PASS_EXT: c_int = 18;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_PIPELINE_EXT: c_int = 19;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT_EXT: c_int = 20;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_EXT: c_int = 21;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_POOL_EXT: c_int = 22;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_SET_EXT: c_int = 23;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_FRAMEBUFFER_EXT: c_int = 24;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_COMMAND_POOL_EXT: c_int = 25;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_SURFACE_KHR_EXT: c_int = 26;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_SWAPCHAIN_KHR_EXT: c_int = 27;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DEBUG_REPORT_CALLBACK_EXT_EXT: c_int = 28;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DISPLAY_KHR_EXT: c_int = 29;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DISPLAY_MODE_KHR_EXT: c_int = 30;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_VALIDATION_CACHE_EXT_EXT: c_int = 33;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION_EXT: c_int = 1000156000;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_EXT: c_int = 1000085000;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_CU_MODULE_NVX_EXT: c_int = 1000029000;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_CU_FUNCTION_NVX_EXT: c_int = 1000029001;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_ACCELERATION_STRUCTURE_KHR_EXT: c_int = 1000150000;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_ACCELERATION_STRUCTURE_NV_EXT: c_int = 1000165000;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_BUFFER_COLLECTION_FUCHSIA_EXT: c_int = 1000366000;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DEBUG_REPORT_EXT: c_int = 28;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_VALIDATION_CACHE_EXT: c_int = 33;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE_KHR_EXT: c_int = 1000085000;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION_KHR_EXT: c_int = 1000156000;
pub const VK_DEBUG_REPORT_OBJECT_TYPE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkDebugReportObjectTypeEXT = c_uint;
pub const VkDebugReportObjectTypeEXT = enum_VkDebugReportObjectTypeEXT;
pub const VK_DEBUG_REPORT_INFORMATION_BIT_EXT: c_int = 1;
pub const VK_DEBUG_REPORT_WARNING_BIT_EXT: c_int = 2;
pub const VK_DEBUG_REPORT_PERFORMANCE_WARNING_BIT_EXT: c_int = 4;
pub const VK_DEBUG_REPORT_ERROR_BIT_EXT: c_int = 8;
pub const VK_DEBUG_REPORT_DEBUG_BIT_EXT: c_int = 16;
pub const VK_DEBUG_REPORT_FLAG_BITS_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkDebugReportFlagBitsEXT = c_uint;
pub const VkDebugReportFlagBitsEXT = enum_VkDebugReportFlagBitsEXT;
pub const VkDebugReportFlagsEXT = VkFlags;
pub const PFN_vkDebugReportCallbackEXT = ?fn (VkDebugReportFlagsEXT, VkDebugReportObjectTypeEXT, u64, usize, i32, [*c]const u8, [*c]const u8, ?*anyopaque) callconv(.C) VkBool32;
pub const struct_VkDebugReportCallbackCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkDebugReportFlagsEXT,
    pfnCallback: PFN_vkDebugReportCallbackEXT,
    pUserData: ?*anyopaque,
};
pub const VkDebugReportCallbackCreateInfoEXT = struct_VkDebugReportCallbackCreateInfoEXT;
pub const PFN_vkCreateDebugReportCallbackEXT = ?fn (vk.Instance, [*c]const VkDebugReportCallbackCreateInfoEXT, [*c]const VkAllocationCallbacks, [*c]VkDebugReportCallbackEXT) callconv(.C) VkResult;
pub const PFN_vkDestroyDebugReportCallbackEXT = ?fn (vk.Instance, VkDebugReportCallbackEXT, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkDebugReportMessageEXT = ?fn (vk.Instance, VkDebugReportFlagsEXT, VkDebugReportObjectTypeEXT, u64, usize, i32, [*c]const u8, [*c]const u8) callconv(.C) void;
pub extern fn vkCreateDebugReportCallbackEXT(instance: vk.Instance, pCreateInfo: [*c]const VkDebugReportCallbackCreateInfoEXT, pAllocator: [*c]const VkAllocationCallbacks, pCallback: [*c]VkDebugReportCallbackEXT) VkResult;
pub extern fn vkDestroyDebugReportCallbackEXT(instance: vk.Instance, callback: VkDebugReportCallbackEXT, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkDebugReportMessageEXT(instance: vk.Instance, flags: VkDebugReportFlagsEXT, objectType: VkDebugReportObjectTypeEXT, object: u64, location: usize, messageCode: i32, pLayerPrefix: [*c]const u8, pMessage: [*c]const u8) void;
pub const VK_RASTERIZATION_ORDER_STRICT_AMD: c_int = 0;
pub const VK_RASTERIZATION_ORDER_RELAXED_AMD: c_int = 1;
pub const VK_RASTERIZATION_ORDER_MAX_ENUM_AMD: c_int = 2147483647;
pub const enum_VkRasterizationOrderAMD = c_uint;
pub const VkRasterizationOrderAMD = enum_VkRasterizationOrderAMD;
pub const struct_VkPipelineRasterizationStateRasterizationOrderAMD = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    rasterizationOrder: VkRasterizationOrderAMD,
};
pub const VkPipelineRasterizationStateRasterizationOrderAMD = struct_VkPipelineRasterizationStateRasterizationOrderAMD;
pub const struct_VkDebugMarkerObjectNameInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    objectType: VkDebugReportObjectTypeEXT,
    object: u64,
    pObjectName: [*c]const u8,
};
pub const VkDebugMarkerObjectNameInfoEXT = struct_VkDebugMarkerObjectNameInfoEXT;
pub const struct_VkDebugMarkerObjectTagInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    objectType: VkDebugReportObjectTypeEXT,
    object: u64,
    tagName: u64,
    tagSize: usize,
    pTag: ?*const anyopaque,
};
pub const VkDebugMarkerObjectTagInfoEXT = struct_VkDebugMarkerObjectTagInfoEXT;
pub const struct_VkDebugMarkerMarkerInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pMarkerName: [*c]const u8,
    color: [4]f32,
};
pub const VkDebugMarkerMarkerInfoEXT = struct_VkDebugMarkerMarkerInfoEXT;
pub const PFN_vkDebugMarkerSetObjectTagEXT = ?fn (vk.Device, [*c]const VkDebugMarkerObjectTagInfoEXT) callconv(.C) VkResult;
pub const PFN_vkDebugMarkerSetObjectNameEXT = ?fn (vk.Device, [*c]const VkDebugMarkerObjectNameInfoEXT) callconv(.C) VkResult;
pub const PFN_vkCmdDebugMarkerBeginEXT = ?fn (VkCommandBuffer, [*c]const VkDebugMarkerMarkerInfoEXT) callconv(.C) void;
pub const PFN_vkCmdDebugMarkerEndEXT = ?fn (VkCommandBuffer) callconv(.C) void;
pub const PFN_vkCmdDebugMarkerInsertEXT = ?fn (VkCommandBuffer, [*c]const VkDebugMarkerMarkerInfoEXT) callconv(.C) void;
pub extern fn vkDebugMarkerSetObjectTagEXT(device: vk.Device, pTagInfo: [*c]const VkDebugMarkerObjectTagInfoEXT) VkResult;
pub extern fn vkDebugMarkerSetObjectNameEXT(device: vk.Device, pNameInfo: [*c]const VkDebugMarkerObjectNameInfoEXT) VkResult;
pub extern fn vkCmdDebugMarkerBeginEXT(commandBuffer: VkCommandBuffer, pMarkerInfo: [*c]const VkDebugMarkerMarkerInfoEXT) void;
pub extern fn vkCmdDebugMarkerEndEXT(commandBuffer: VkCommandBuffer) void;
pub extern fn vkCmdDebugMarkerInsertEXT(commandBuffer: VkCommandBuffer, pMarkerInfo: [*c]const VkDebugMarkerMarkerInfoEXT) void;
pub const struct_VkDedicatedAllocationImageCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    dedicatedAllocation: VkBool32,
};
pub const VkDedicatedAllocationImageCreateInfoNV = struct_VkDedicatedAllocationImageCreateInfoNV;
pub const struct_VkDedicatedAllocationBufferCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    dedicatedAllocation: VkBool32,
};
pub const VkDedicatedAllocationBufferCreateInfoNV = struct_VkDedicatedAllocationBufferCreateInfoNV;
pub const struct_VkDedicatedAllocationMemoryAllocateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    image: VkImage,
    buffer: VkBuffer,
};
pub const VkDedicatedAllocationMemoryAllocateInfoNV = struct_VkDedicatedAllocationMemoryAllocateInfoNV;
pub const VkPipelineRasterizationStateStreamCreateFlagsEXT = VkFlags;
pub const struct_vk.PhysicalDeviceTransformFeedbackFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    transformFeedback: VkBool32,
    geometryStreams: VkBool32,
};
pub const vk.PhysicalDeviceTransformFeedbackFeaturesEXT = struct_vk.PhysicalDeviceTransformFeedbackFeaturesEXT;
pub const struct_vk.PhysicalDeviceTransformFeedbackPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxTransformFeedbackStreams: u32,
    maxTransformFeedbackBuffers: u32,
    maxTransformFeedbackBufferSize: vk.DeviceSize,
    maxTransformFeedbackStreamDataSize: u32,
    maxTransformFeedbackBufferDataSize: u32,
    maxTransformFeedbackBufferDataStride: u32,
    transformFeedbackQueries: VkBool32,
    transformFeedbackStreamsLinesTriangles: VkBool32,
    transformFeedbackRasterizationStreamSelect: VkBool32,
    transformFeedbackDraw: VkBool32,
};
pub const vk.PhysicalDeviceTransformFeedbackPropertiesEXT = struct_vk.PhysicalDeviceTransformFeedbackPropertiesEXT;
pub const struct_VkPipelineRasterizationStateStreamCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineRasterizationStateStreamCreateFlagsEXT,
    rasterizationStream: u32,
};
pub const VkPipelineRasterizationStateStreamCreateInfoEXT = struct_VkPipelineRasterizationStateStreamCreateInfoEXT;
pub const PFN_vkCmdBindTransformFeedbackBuffersEXT = ?fn (VkCommandBuffer, u32, u32, [*c]const VkBuffer, [*c]const vk.DeviceSize, [*c]const vk.DeviceSize) callconv(.C) void;
pub const PFN_vkCmdBeginTransformFeedbackEXT = ?fn (VkCommandBuffer, u32, u32, [*c]const VkBuffer, [*c]const vk.DeviceSize) callconv(.C) void;
pub const PFN_vkCmdEndTransformFeedbackEXT = ?fn (VkCommandBuffer, u32, u32, [*c]const VkBuffer, [*c]const vk.DeviceSize) callconv(.C) void;
pub const PFN_vkCmdBeginQueryIndexedEXT = ?fn (VkCommandBuffer, VkQueryPool, u32, VkQueryControlFlags, u32) callconv(.C) void;
pub const PFN_vkCmdEndQueryIndexedEXT = ?fn (VkCommandBuffer, VkQueryPool, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawIndirectByteCountEXT = ?fn (VkCommandBuffer, u32, u32, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub extern fn vkCmdBindTransformFeedbackBuffersEXT(commandBuffer: VkCommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: [*c]const VkBuffer, pOffsets: [*c]const vk.DeviceSize, pSizes: [*c]const vk.DeviceSize) void;
pub extern fn vkCmdBeginTransformFeedbackEXT(commandBuffer: VkCommandBuffer, firstCounterBuffer: u32, counterBufferCount: u32, pCounterBuffers: [*c]const VkBuffer, pCounterBufferOffsets: [*c]const vk.DeviceSize) void;
pub extern fn vkCmdEndTransformFeedbackEXT(commandBuffer: VkCommandBuffer, firstCounterBuffer: u32, counterBufferCount: u32, pCounterBuffers: [*c]const VkBuffer, pCounterBufferOffsets: [*c]const vk.DeviceSize) void;
pub extern fn vkCmdBeginQueryIndexedEXT(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, query: u32, flags: VkQueryControlFlags, index: u32) void;
pub extern fn vkCmdEndQueryIndexedEXT(commandBuffer: VkCommandBuffer, queryPool: VkQueryPool, query: u32, index: u32) void;
pub extern fn vkCmdDrawIndirectByteCountEXT(commandBuffer: VkCommandBuffer, instanceCount: u32, firstInstance: u32, counterBuffer: VkBuffer, counterBufferOffset: vk.DeviceSize, counterOffset: u32, vertexStride: u32) void;
pub const struct_VkCuModuleNVX_T = opaque {};
pub const VkCuModuleNVX = ?*struct_VkCuModuleNVX_T;
pub const struct_VkCuFunctionNVX_T = opaque {};
pub const VkCuFunctionNVX = ?*struct_VkCuFunctionNVX_T;
pub const struct_VkCuModuleCreateInfoNVX = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    dataSize: usize,
    pData: ?*const anyopaque,
};
pub const VkCuModuleCreateInfoNVX = struct_VkCuModuleCreateInfoNVX;
pub const struct_VkCuFunctionCreateInfoNVX = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    module: VkCuModuleNVX,
    pName: [*c]const u8,
};
pub const VkCuFunctionCreateInfoNVX = struct_VkCuFunctionCreateInfoNVX;
pub const struct_VkCuLaunchInfoNVX = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    function: VkCuFunctionNVX,
    gridDimX: u32,
    gridDimY: u32,
    gridDimZ: u32,
    blockDimX: u32,
    blockDimY: u32,
    blockDimZ: u32,
    sharedMemBytes: u32,
    paramCount: usize,
    pParams: [*c]const ?*const anyopaque,
    extraCount: usize,
    pExtras: [*c]const ?*const anyopaque,
};
pub const VkCuLaunchInfoNVX = struct_VkCuLaunchInfoNVX;
pub const PFN_vkCreateCuModuleNVX = ?fn (vk.Device, [*c]const VkCuModuleCreateInfoNVX, [*c]const VkAllocationCallbacks, [*c]VkCuModuleNVX) callconv(.C) VkResult;
pub const PFN_vkCreateCuFunctionNVX = ?fn (vk.Device, [*c]const VkCuFunctionCreateInfoNVX, [*c]const VkAllocationCallbacks, [*c]VkCuFunctionNVX) callconv(.C) VkResult;
pub const PFN_vkDestroyCuModuleNVX = ?fn (vk.Device, VkCuModuleNVX, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkDestroyCuFunctionNVX = ?fn (vk.Device, VkCuFunctionNVX, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCmdCuLaunchKernelNVX = ?fn (VkCommandBuffer, [*c]const VkCuLaunchInfoNVX) callconv(.C) void;
pub extern fn vkCreateCuModuleNVX(device: vk.Device, pCreateInfo: [*c]const VkCuModuleCreateInfoNVX, pAllocator: [*c]const VkAllocationCallbacks, pModule: [*c]VkCuModuleNVX) VkResult;
pub extern fn vkCreateCuFunctionNVX(device: vk.Device, pCreateInfo: [*c]const VkCuFunctionCreateInfoNVX, pAllocator: [*c]const VkAllocationCallbacks, pFunction: [*c]VkCuFunctionNVX) VkResult;
pub extern fn vkDestroyCuModuleNVX(device: vk.Device, module: VkCuModuleNVX, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkDestroyCuFunctionNVX(device: vk.Device, function: VkCuFunctionNVX, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCmdCuLaunchKernelNVX(commandBuffer: VkCommandBuffer, pLaunchInfo: [*c]const VkCuLaunchInfoNVX) void;
pub const struct_VkImageViewHandleInfoNVX = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    imageView: VkImageView,
    descriptorType: VkDescriptorType,
    sampler: VkSampler,
};
pub const VkImageViewHandleInfoNVX = struct_VkImageViewHandleInfoNVX;
pub const struct_VkImageViewAddressPropertiesNVX = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    deviceAddress: vk.DeviceAddress,
    size: vk.DeviceSize,
};
pub const VkImageViewAddressPropertiesNVX = struct_VkImageViewAddressPropertiesNVX;
pub const PFN_vkGetImageViewHandleNVX = ?fn (vk.Device, [*c]const VkImageViewHandleInfoNVX) callconv(.C) u32;
pub const PFN_vkGetImageViewAddressNVX = ?fn (vk.Device, VkImageView, [*c]VkImageViewAddressPropertiesNVX) callconv(.C) VkResult;
pub extern fn vkGetImageViewHandleNVX(device: vk.Device, pInfo: [*c]const VkImageViewHandleInfoNVX) u32;
pub extern fn vkGetImageViewAddressNVX(device: vk.Device, imageView: VkImageView, pProperties: [*c]VkImageViewAddressPropertiesNVX) VkResult;
pub const PFN_vkCmdDrawIndirectCountAMD = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawIndexedIndirectCountAMD = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub extern fn vkCmdDrawIndirectCountAMD(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, countBuffer: VkBuffer, countBufferOffset: vk.DeviceSize, maxDrawCount: u32, stride: u32) void;
pub extern fn vkCmdDrawIndexedIndirectCountAMD(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, countBuffer: VkBuffer, countBufferOffset: vk.DeviceSize, maxDrawCount: u32, stride: u32) void;
pub const struct_VkTextureLODGatherFormatPropertiesAMD = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    supportsTextureGatherLODBiasAMD: VkBool32,
};
pub const VkTextureLODGatherFormatPropertiesAMD = struct_VkTextureLODGatherFormatPropertiesAMD;
pub const VK_SHADER_INFO_TYPE_STATISTICS_AMD: c_int = 0;
pub const VK_SHADER_INFO_TYPE_BINARY_AMD: c_int = 1;
pub const VK_SHADER_INFO_TYPE_DISASSEMBLY_AMD: c_int = 2;
pub const VK_SHADER_INFO_TYPE_MAX_ENUM_AMD: c_int = 2147483647;
pub const enum_VkShaderInfoTypeAMD = c_uint;
pub const VkShaderInfoTypeAMD = enum_VkShaderInfoTypeAMD;
pub const struct_VkShaderResourceUsageAMD = extern struct {
    numUsedVgprs: u32,
    numUsedSgprs: u32,
    ldsSizePerLocalWorkGroup: u32,
    ldsUsageSizeInBytes: usize,
    scratchMemUsageInBytes: usize,
};
pub const VkShaderResourceUsageAMD = struct_VkShaderResourceUsageAMD;
pub const struct_VkShaderStatisticsInfoAMD = extern struct {
    shaderStageMask: VkShaderStageFlags,
    resourceUsage: VkShaderResourceUsageAMD,
    numPhysicalVgprs: u32,
    numPhysicalSgprs: u32,
    numAvailableVgprs: u32,
    numAvailableSgprs: u32,
    computeWorkGroupSize: [3]u32,
};
pub const VkShaderStatisticsInfoAMD = struct_VkShaderStatisticsInfoAMD;
pub const PFN_vkGetShaderInfoAMD = ?fn (vk.Device, VkPipeline, VkShaderStageFlagBits, VkShaderInfoTypeAMD, [*c]usize, ?*anyopaque) callconv(.C) VkResult;
pub extern fn vkGetShaderInfoAMD(device: vk.Device, pipeline: VkPipeline, shaderStage: VkShaderStageFlagBits, infoType: VkShaderInfoTypeAMD, pInfoSize: [*c]usize, pInfo: ?*anyopaque) VkResult;
pub const struct_vk.PhysicalDeviceCornerSampledImageFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    cornerSampledImage: VkBool32,
};
pub const vk.PhysicalDeviceCornerSampledImageFeaturesNV = struct_vk.PhysicalDeviceCornerSampledImageFeaturesNV;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_BIT_NV: c_int = 1;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_OPAQUE_WIN32_KMT_BIT_NV: c_int = 2;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_IMAGE_BIT_NV: c_int = 4;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_D3D11_IMAGE_KMT_BIT_NV: c_int = 8;
pub const VK_EXTERNAL_MEMORY_HANDLE_TYPE_FLAG_BITS_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkExternalMemoryHandleTypeFlagBitsNV = c_uint;
pub const VkExternalMemoryHandleTypeFlagBitsNV = enum_VkExternalMemoryHandleTypeFlagBitsNV;
pub const VkExternalMemoryHandleTypeFlagsNV = VkFlags;
pub const VK_EXTERNAL_MEMORY_FEATURE_DEDICATED_ONLY_BIT_NV: c_int = 1;
pub const VK_EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT_NV: c_int = 2;
pub const VK_EXTERNAL_MEMORY_FEATURE_IMPORTABLE_BIT_NV: c_int = 4;
pub const VK_EXTERNAL_MEMORY_FEATURE_FLAG_BITS_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkExternalMemoryFeatureFlagBitsNV = c_uint;
pub const VkExternalMemoryFeatureFlagBitsNV = enum_VkExternalMemoryFeatureFlagBitsNV;
pub const VkExternalMemoryFeatureFlagsNV = VkFlags;
pub const struct_VkExternalImageFormatPropertiesNV = extern struct {
    imageFormatProperties: VkImageFormatProperties,
    externalMemoryFeatures: VkExternalMemoryFeatureFlagsNV,
    exportFromImportedHandleTypes: VkExternalMemoryHandleTypeFlagsNV,
    compatibleHandleTypes: VkExternalMemoryHandleTypeFlagsNV,
};
pub const VkExternalImageFormatPropertiesNV = struct_VkExternalImageFormatPropertiesNV;
pub const PFN_vkGetPhysicalDevicexternalImageFormatPropertiesNV = ?fn (vk.PhysicalDevice, VkFormat, VkImageType, VkImageTiling, VkImageUsageFlags, VkImageCreateFlags, VkExternalMemoryHandleTypeFlagsNV, [*c]VkExternalImageFormatPropertiesNV) callconv(.C) VkResult;
pub extern fn vkGetPhysicalDevicexternalImageFormatPropertiesNV(physicalDevice: vk.PhysicalDevice, format: VkFormat, @"type": VkImageType, tiling: VkImageTiling, usage: VkImageUsageFlags, flags: VkImageCreateFlags, externalHandleType: VkExternalMemoryHandleTypeFlagsNV, pExternalImageFormatProperties: [*c]VkExternalImageFormatPropertiesNV) VkResult;
pub const struct_VkExternalMemoryImageCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleTypes: VkExternalMemoryHandleTypeFlagsNV,
};
pub const VkExternalMemoryImageCreateInfoNV = struct_VkExternalMemoryImageCreateInfoNV;
pub const struct_VkExportMemoryAllocateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleTypes: VkExternalMemoryHandleTypeFlagsNV,
};
pub const VkExportMemoryAllocateInfoNV = struct_VkExportMemoryAllocateInfoNV;
pub const VK_VALIDATION_CHECK_ALL_EXT: c_int = 0;
pub const VK_VALIDATION_CHECK_SHADERS_EXT: c_int = 1;
pub const VK_VALIDATION_CHECK_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkValidationCheckEXT = c_uint;
pub const VkValidationCheckEXT = enum_VkValidationCheckEXT;
pub const struct_VkValidationFlagsEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    disabledValidationCheckCount: u32,
    pDisabledValidationChecks: [*c]const VkValidationCheckEXT,
};
pub const VkValidationFlagsEXT = struct_VkValidationFlagsEXT;
pub const struct_vk.PhysicalDeviceTextureCompressionASTCHDRFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    textureCompressionASTC_HDR: VkBool32,
};
pub const vk.PhysicalDeviceTextureCompressionASTCHDRFeaturesEXT = struct_vk.PhysicalDeviceTextureCompressionASTCHDRFeaturesEXT;
pub const struct_VkImageViewASTCDecodeModeEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    decodeMode: VkFormat,
};
pub const VkImageViewASTCDecodeModeEXT = struct_VkImageViewASTCDecodeModeEXT;
pub const struct_vk.PhysicalDeviceASTCDecodeFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    decodeModeSharedExponent: VkBool32,
};
pub const vk.PhysicalDeviceASTCDecodeFeaturesEXT = struct_vk.PhysicalDeviceASTCDecodeFeaturesEXT;
pub const VK_CONDITIONAL_RENDERING_INVERTED_BIT_EXT: c_int = 1;
pub const VK_CONDITIONAL_RENDERING_FLAG_BITS_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkConditionalRenderingFlagBitsEXT = c_uint;
pub const VkConditionalRenderingFlagBitsEXT = enum_VkConditionalRenderingFlagBitsEXT;
pub const VkConditionalRenderingFlagsEXT = VkFlags;
pub const struct_VkConditionalRenderingBeginInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    buffer: VkBuffer,
    offset: vk.DeviceSize,
    flags: VkConditionalRenderingFlagsEXT,
};
pub const VkConditionalRenderingBeginInfoEXT = struct_VkConditionalRenderingBeginInfoEXT;
pub const struct_vk.PhysicalDeviceConditionalRenderingFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    conditionalRendering: VkBool32,
    inheritedConditionalRendering: VkBool32,
};
pub const vk.PhysicalDeviceConditionalRenderingFeaturesEXT = struct_vk.PhysicalDeviceConditionalRenderingFeaturesEXT;
pub const struct_VkCommandBufferInheritanceConditionalRenderingInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    conditionalRenderingEnable: VkBool32,
};
pub const VkCommandBufferInheritanceConditionalRenderingInfoEXT = struct_VkCommandBufferInheritanceConditionalRenderingInfoEXT;
pub const PFN_vkCmdBeginConditionalRenderingEXT = ?fn (VkCommandBuffer, [*c]const VkConditionalRenderingBeginInfoEXT) callconv(.C) void;
pub const PFN_vkCmdEndConditionalRenderingEXT = ?fn (VkCommandBuffer) callconv(.C) void;
pub extern fn vkCmdBeginConditionalRenderingEXT(commandBuffer: VkCommandBuffer, pConditionalRenderingBegin: [*c]const VkConditionalRenderingBeginInfoEXT) void;
pub extern fn vkCmdEndConditionalRenderingEXT(commandBuffer: VkCommandBuffer) void;
pub const struct_VkViewportWScalingNV = extern struct {
    xcoeff: f32,
    ycoeff: f32,
};
pub const VkViewportWScalingNV = struct_VkViewportWScalingNV;
pub const struct_VkPipelineViewportWScalingStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    viewportWScalingEnable: VkBool32,
    viewportCount: u32,
    pViewportWScalings: [*c]const VkViewportWScalingNV,
};
pub const VkPipelineViewportWScalingStateCreateInfoNV = struct_VkPipelineViewportWScalingStateCreateInfoNV;
pub const PFN_vkCmdSetViewportWScalingNV = ?fn (VkCommandBuffer, u32, u32, [*c]const VkViewportWScalingNV) callconv(.C) void;
pub extern fn vkCmdSetViewportWScalingNV(commandBuffer: VkCommandBuffer, firstViewport: u32, viewportCount: u32, pViewportWScalings: [*c]const VkViewportWScalingNV) void;
pub const PFN_vkReleaseDisplayEXT = ?fn (vk.PhysicalDevice, VkDisplayKHR) callconv(.C) VkResult;
pub extern fn vkReleaseDisplayEXT(physicalDevice: vk.PhysicalDevice, display: VkDisplayKHR) VkResult;
pub const VK_SURFACE_COUNTER_VBLANK_BIT_EXT: c_int = 1;
pub const VK_SURFACE_COUNTER_VBLANK_EXT: c_int = 1;
pub const VK_SURFACE_COUNTER_FLAG_BITS_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkSurfaceCounterFlagBitsEXT = c_uint;
pub const VkSurfaceCounterFlagBitsEXT = enum_VkSurfaceCounterFlagBitsEXT;
pub const VkSurfaceCounterFlagsEXT = VkFlags;
pub const struct_VkSurfaceCapabilities2EXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    minImageCount: u32,
    maxImageCount: u32,
    currentExtent: VkExtent2D,
    minImageExtent: VkExtent2D,
    maxImageExtent: VkExtent2D,
    maxImageArrayLayers: u32,
    supportedTransforms: VkSurfaceTransformFlagsKHR,
    currentTransform: VkSurfaceTransformFlagBitsKHR,
    supportedCompositeAlpha: VkCompositeAlphaFlagsKHR,
    supportedUsageFlags: VkImageUsageFlags,
    supportedSurfaceCounters: VkSurfaceCounterFlagsEXT,
};
pub const VkSurfaceCapabilities2EXT = struct_VkSurfaceCapabilities2EXT;
pub const PFN_vkGetPhysicalDeviceSurfaceCapabilities2EXT = ?fn (vk.PhysicalDevice, VkSurfaceKHR, [*c]VkSurfaceCapabilities2EXT) callconv(.C) VkResult;
pub extern fn vkGetPhysicalDeviceSurfaceCapabilities2EXT(physicalDevice: vk.PhysicalDevice, surface: VkSurfaceKHR, pSurfaceCapabilities: [*c]VkSurfaceCapabilities2EXT) VkResult;
pub const VK_DISPLAY_POWER_STATE_OFF_EXT: c_int = 0;
pub const VK_DISPLAY_POWER_STATE_SUSPEND_EXT: c_int = 1;
pub const VK_DISPLAY_POWER_STATE_ON_EXT: c_int = 2;
pub const VK_DISPLAY_POWER_STATE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkDisplayPowerStateEXT = c_uint;
pub const VkDisplayPowerStateEXT = enum_VkDisplayPowerStateEXT;
pub const VK_DEVICE_EVENT_TYPE_DISPLAY_HOTPLUG_EXT: c_int = 0;
pub const VK_DEVICE_EVENT_TYPE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_vk.DeviceEventTypeEXT = c_uint;
pub const vk.DeviceEventTypeEXT = enum_vk.DeviceEventTypeEXT;
pub const VK_DISPLAY_EVENT_TYPE_FIRST_PIXEL_OUT_EXT: c_int = 0;
pub const VK_DISPLAY_EVENT_TYPE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkDisplayEventTypeEXT = c_uint;
pub const VkDisplayEventTypeEXT = enum_VkDisplayEventTypeEXT;
pub const struct_VkDisplayPowerInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    powerState: VkDisplayPowerStateEXT,
};
pub const VkDisplayPowerInfoEXT = struct_VkDisplayPowerInfoEXT;
pub const struct_vk.DeviceEventInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    deviceEvent: vk.DeviceEventTypeEXT,
};
pub const vk.DeviceEventInfoEXT = struct_vk.DeviceEventInfoEXT;
pub const struct_VkDisplayEventInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    displayEvent: VkDisplayEventTypeEXT,
};
pub const VkDisplayEventInfoEXT = struct_VkDisplayEventInfoEXT;
pub const struct_VkSwapchainCounterCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    surfaceCounters: VkSurfaceCounterFlagsEXT,
};
pub const VkSwapchainCounterCreateInfoEXT = struct_VkSwapchainCounterCreateInfoEXT;
pub const PFN_vkDisplayPowerControlEXT = ?fn (vk.Device, VkDisplayKHR, [*c]const VkDisplayPowerInfoEXT) callconv(.C) VkResult;
pub const PFN_vkRegisterDeviceEventEXT = ?fn (vk.Device, [*c]const vk.DeviceEventInfoEXT, [*c]const VkAllocationCallbacks, [*c]VkFence) callconv(.C) VkResult;
pub const PFN_vkRegisterDisplayEventEXT = ?fn (vk.Device, VkDisplayKHR, [*c]const VkDisplayEventInfoEXT, [*c]const VkAllocationCallbacks, [*c]VkFence) callconv(.C) VkResult;
pub const PFN_vkGetSwapchainCounterEXT = ?fn (vk.Device, VkSwapchainKHR, VkSurfaceCounterFlagBitsEXT, [*c]u64) callconv(.C) VkResult;
pub extern fn vkDisplayPowerControlEXT(device: vk.Device, display: VkDisplayKHR, pDisplayPowerInfo: [*c]const VkDisplayPowerInfoEXT) VkResult;
pub extern fn vkRegisterDeviceEventEXT(device: vk.Device, pDeviceEventInfo: [*c]const vk.DeviceEventInfoEXT, pAllocator: [*c]const VkAllocationCallbacks, pFence: [*c]VkFence) VkResult;
pub extern fn vkRegisterDisplayEventEXT(device: vk.Device, display: VkDisplayKHR, pDisplayEventInfo: [*c]const VkDisplayEventInfoEXT, pAllocator: [*c]const VkAllocationCallbacks, pFence: [*c]VkFence) VkResult;
pub extern fn vkGetSwapchainCounterEXT(device: vk.Device, swapchain: VkSwapchainKHR, counter: VkSurfaceCounterFlagBitsEXT, pCounterValue: [*c]u64) VkResult;
pub const struct_VkRefreshCycleDurationGOOGLE = extern struct {
    refreshDuration: u64,
};
pub const VkRefreshCycleDurationGOOGLE = struct_VkRefreshCycleDurationGOOGLE;
pub const struct_VkPastPresentationTimingGOOGLE = extern struct {
    presentID: u32,
    desiredPresentTime: u64,
    actualPresentTime: u64,
    earliestPresentTime: u64,
    presentMargin: u64,
};
pub const VkPastPresentationTimingGOOGLE = struct_VkPastPresentationTimingGOOGLE;
pub const struct_VkPresentTimeGOOGLE = extern struct {
    presentID: u32,
    desiredPresentTime: u64,
};
pub const VkPresentTimeGOOGLE = struct_VkPresentTimeGOOGLE;
pub const struct_VkPresentTimesInfoGOOGLE = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    swapchainCount: u32,
    pTimes: [*c]const VkPresentTimeGOOGLE,
};
pub const VkPresentTimesInfoGOOGLE = struct_VkPresentTimesInfoGOOGLE;
pub const PFN_vkGetRefreshCycleDurationGOOGLE = ?fn (vk.Device, VkSwapchainKHR, [*c]VkRefreshCycleDurationGOOGLE) callconv(.C) VkResult;
pub const PFN_vkGetPastPresentationTimingGOOGLE = ?fn (vk.Device, VkSwapchainKHR, [*c]u32, [*c]VkPastPresentationTimingGOOGLE) callconv(.C) VkResult;
pub extern fn vkGetRefreshCycleDurationGOOGLE(device: vk.Device, swapchain: VkSwapchainKHR, pDisplayTimingProperties: [*c]VkRefreshCycleDurationGOOGLE) VkResult;
pub extern fn vkGetPastPresentationTimingGOOGLE(device: vk.Device, swapchain: VkSwapchainKHR, pPresentationTimingCount: [*c]u32, pPresentationTimings: [*c]VkPastPresentationTimingGOOGLE) VkResult;
pub const struct_vk.PhysicalDeviceMultiviewPerViewAttributesPropertiesNVX = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    perViewPositionAllComponents: VkBool32,
};
pub const vk.PhysicalDeviceMultiviewPerViewAttributesPropertiesNVX = struct_vk.PhysicalDeviceMultiviewPerViewAttributesPropertiesNVX;
pub const VK_VIEWPORT_COORDINATE_SWIZZLE_POSITIVE_X_NV: c_int = 0;
pub const VK_VIEWPORT_COORDINATE_SWIZZLE_NEGATIVE_X_NV: c_int = 1;
pub const VK_VIEWPORT_COORDINATE_SWIZZLE_POSITIVE_Y_NV: c_int = 2;
pub const VK_VIEWPORT_COORDINATE_SWIZZLE_NEGATIVE_Y_NV: c_int = 3;
pub const VK_VIEWPORT_COORDINATE_SWIZZLE_POSITIVE_Z_NV: c_int = 4;
pub const VK_VIEWPORT_COORDINATE_SWIZZLE_NEGATIVE_Z_NV: c_int = 5;
pub const VK_VIEWPORT_COORDINATE_SWIZZLE_POSITIVE_W_NV: c_int = 6;
pub const VK_VIEWPORT_COORDINATE_SWIZZLE_NEGATIVE_W_NV: c_int = 7;
pub const VK_VIEWPORT_COORDINATE_SWIZZLE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkViewportCoordinateSwizzleNV = c_uint;
pub const VkViewportCoordinateSwizzleNV = enum_VkViewportCoordinateSwizzleNV;
pub const VkPipelineViewportSwizzleStateCreateFlagsNV = VkFlags;
pub const struct_VkViewportSwizzleNV = extern struct {
    x: VkViewportCoordinateSwizzleNV,
    y: VkViewportCoordinateSwizzleNV,
    z: VkViewportCoordinateSwizzleNV,
    w: VkViewportCoordinateSwizzleNV,
};
pub const VkViewportSwizzleNV = struct_VkViewportSwizzleNV;
pub const struct_VkPipelineViewportSwizzleStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineViewportSwizzleStateCreateFlagsNV,
    viewportCount: u32,
    pViewportSwizzles: [*c]const VkViewportSwizzleNV,
};
pub const VkPipelineViewportSwizzleStateCreateInfoNV = struct_VkPipelineViewportSwizzleStateCreateInfoNV;
pub const VK_DISCARD_RECTANGLE_MODE_INCLUSIVE_EXT: c_int = 0;
pub const VK_DISCARD_RECTANGLE_MODE_EXCLUSIVE_EXT: c_int = 1;
pub const VK_DISCARD_RECTANGLE_MODE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkDiscardRectangleModeEXT = c_uint;
pub const VkDiscardRectangleModeEXT = enum_VkDiscardRectangleModeEXT;
pub const VkPipelineDiscardRectangleStateCreateFlagsEXT = VkFlags;
pub const struct_vk.PhysicalDeviceDiscardRectanglePropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxDiscardRectangles: u32,
};
pub const vk.PhysicalDeviceDiscardRectanglePropertiesEXT = struct_vk.PhysicalDeviceDiscardRectanglePropertiesEXT;
pub const struct_VkPipelineDiscardRectangleStateCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineDiscardRectangleStateCreateFlagsEXT,
    discardRectangleMode: VkDiscardRectangleModeEXT,
    discardRectangleCount: u32,
    pDiscardRectangles: [*c]const VkRect2D,
};
pub const VkPipelineDiscardRectangleStateCreateInfoEXT = struct_VkPipelineDiscardRectangleStateCreateInfoEXT;
pub const PFN_vkCmdSetDiscardRectangleEXT = ?fn (VkCommandBuffer, u32, u32, [*c]const VkRect2D) callconv(.C) void;
pub extern fn vkCmdSetDiscardRectangleEXT(commandBuffer: VkCommandBuffer, firstDiscardRectangle: u32, discardRectangleCount: u32, pDiscardRectangles: [*c]const VkRect2D) void;
pub const VK_CONSERVATIVE_RASTERIZATION_MODE_DISABLED_EXT: c_int = 0;
pub const VK_CONSERVATIVE_RASTERIZATION_MODE_OVERESTIMATE_EXT: c_int = 1;
pub const VK_CONSERVATIVE_RASTERIZATION_MODE_UNDERESTIMATE_EXT: c_int = 2;
pub const VK_CONSERVATIVE_RASTERIZATION_MODE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkConservativeRasterizationModeEXT = c_uint;
pub const VkConservativeRasterizationModeEXT = enum_VkConservativeRasterizationModeEXT;
pub const VkPipelineRasterizationConservativeStateCreateFlagsEXT = VkFlags;
pub const struct_vk.PhysicalDeviceConservativeRasterizationPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    primitiveOverestimationSize: f32,
    maxExtraPrimitiveOverestimationSize: f32,
    extraPrimitiveOverestimationSizeGranularity: f32,
    primitiveUnderestimation: VkBool32,
    conservativePointAndLineRasterization: VkBool32,
    degenerateTrianglesRasterized: VkBool32,
    degenerateLinesRasterized: VkBool32,
    fullyCoveredFragmentShaderInputVariable: VkBool32,
    conservativeRasterizationPostDepthCoverage: VkBool32,
};
pub const vk.PhysicalDeviceConservativeRasterizationPropertiesEXT = struct_vk.PhysicalDeviceConservativeRasterizationPropertiesEXT;
pub const struct_VkPipelineRasterizationConservativeStateCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineRasterizationConservativeStateCreateFlagsEXT,
    conservativeRasterizationMode: VkConservativeRasterizationModeEXT,
    extraPrimitiveOverestimationSize: f32,
};
pub const VkPipelineRasterizationConservativeStateCreateInfoEXT = struct_VkPipelineRasterizationConservativeStateCreateInfoEXT;
pub const VkPipelineRasterizationDepthClipStateCreateFlagsEXT = VkFlags;
pub const struct_vk.PhysicalDeviceDepthClipEnableFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    depthClipEnable: VkBool32,
};
pub const vk.PhysicalDeviceDepthClipEnableFeaturesEXT = struct_vk.PhysicalDeviceDepthClipEnableFeaturesEXT;
pub const struct_VkPipelineRasterizationDepthClipStateCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineRasterizationDepthClipStateCreateFlagsEXT,
    depthClipEnable: VkBool32,
};
pub const VkPipelineRasterizationDepthClipStateCreateInfoEXT = struct_VkPipelineRasterizationDepthClipStateCreateInfoEXT;
pub const struct_VkXYColorEXT = extern struct {
    x: f32,
    y: f32,
};
pub const VkXYColorEXT = struct_VkXYColorEXT;
pub const struct_VkHdrMetadataEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    displayPrimaryRed: VkXYColorEXT,
    displayPrimaryGreen: VkXYColorEXT,
    displayPrimaryBlue: VkXYColorEXT,
    whitePoint: VkXYColorEXT,
    maxLuminance: f32,
    minLuminance: f32,
    maxContentLightLevel: f32,
    maxFrameAverageLightLevel: f32,
};
pub const VkHdrMetadataEXT = struct_VkHdrMetadataEXT;
pub const PFN_vkSetHdrMetadataEXT = ?fn (vk.Device, u32, [*c]const VkSwapchainKHR, [*c]const VkHdrMetadataEXT) callconv(.C) void;
pub extern fn vkSetHdrMetadataEXT(device: vk.Device, swapchainCount: u32, pSwapchains: [*c]const VkSwapchainKHR, pMetadata: [*c]const VkHdrMetadataEXT) void;
pub const struct_VkDebugUtilsMessengerEXT_T = opaque {};
pub const VkDebugUtilsMessengerEXT = ?*struct_VkDebugUtilsMessengerEXT_T;
pub const VkDebugUtilsMessengerCallbackDataFlagsEXT = VkFlags;
pub const VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT: c_int = 1;
pub const VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT: c_int = 16;
pub const VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT: c_int = 256;
pub const VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT: c_int = 4096;
pub const VK_DEBUG_UTILS_MESSAGE_SEVERITY_FLAG_BITS_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkDebugUtilsMessageSeverityFlagBitsEXT = c_uint;
pub const VkDebugUtilsMessageSeverityFlagBitsEXT = enum_VkDebugUtilsMessageSeverityFlagBitsEXT;
pub const VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT: c_int = 1;
pub const VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT: c_int = 2;
pub const VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT: c_int = 4;
pub const VK_DEBUG_UTILS_MESSAGE_TYPE_FLAG_BITS_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkDebugUtilsMessageTypeFlagBitsEXT = c_uint;
pub const VkDebugUtilsMessageTypeFlagBitsEXT = enum_VkDebugUtilsMessageTypeFlagBitsEXT;
pub const VkDebugUtilsMessageTypeFlagsEXT = VkFlags;
pub const VkDebugUtilsMessageSeverityFlagsEXT = VkFlags;
pub const VkDebugUtilsMessengerCreateFlagsEXT = VkFlags;
pub const struct_VkDebugUtilsLabelEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pLabelName: [*c]const u8,
    color: [4]f32,
};
pub const VkDebugUtilsLabelEXT = struct_VkDebugUtilsLabelEXT;
pub const struct_VkDebugUtilsObjectNameInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    objectType: VkObjectType,
    objectHandle: u64,
    pObjectName: [*c]const u8,
};
pub const VkDebugUtilsObjectNameInfoEXT = struct_VkDebugUtilsObjectNameInfoEXT;
pub const struct_VkDebugUtilsMessengerCallbackDataEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkDebugUtilsMessengerCallbackDataFlagsEXT,
    pMessageIdName: [*c]const u8,
    messageIdNumber: i32,
    pMessage: [*c]const u8,
    queueLabelCount: u32,
    pQueueLabels: [*c]const VkDebugUtilsLabelEXT,
    cmdBufLabelCount: u32,
    pCmdBufLabels: [*c]const VkDebugUtilsLabelEXT,
    objectCount: u32,
    pObjects: [*c]const VkDebugUtilsObjectNameInfoEXT,
};
pub const VkDebugUtilsMessengerCallbackDataEXT = struct_VkDebugUtilsMessengerCallbackDataEXT;
pub const PFN_vkDebugUtilsMessengerCallbackEXT = ?fn (VkDebugUtilsMessageSeverityFlagBitsEXT, VkDebugUtilsMessageTypeFlagsEXT, [*c]const VkDebugUtilsMessengerCallbackDataEXT, ?*anyopaque) callconv(.C) VkBool32;
pub const struct_VkDebugUtilsMessengerCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkDebugUtilsMessengerCreateFlagsEXT,
    messageSeverity: VkDebugUtilsMessageSeverityFlagsEXT,
    messageType: VkDebugUtilsMessageTypeFlagsEXT,
    pfnUserCallback: PFN_vkDebugUtilsMessengerCallbackEXT,
    pUserData: ?*anyopaque,
};
pub const VkDebugUtilsMessengerCreateInfoEXT = struct_VkDebugUtilsMessengerCreateInfoEXT;
pub const struct_VkDebugUtilsObjectTagInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    objectType: VkObjectType,
    objectHandle: u64,
    tagName: u64,
    tagSize: usize,
    pTag: ?*const anyopaque,
};
pub const VkDebugUtilsObjectTagInfoEXT = struct_VkDebugUtilsObjectTagInfoEXT;
pub const PFN_vkSetDebugUtilsObjectNameEXT = ?fn (vk.Device, [*c]const VkDebugUtilsObjectNameInfoEXT) callconv(.C) VkResult;
pub const PFN_vkSetDebugUtilsObjectTagEXT = ?fn (vk.Device, [*c]const VkDebugUtilsObjectTagInfoEXT) callconv(.C) VkResult;
pub const PFN_vkQueueBeginDebugUtilsLabelEXT = ?fn (VkQueue, [*c]const VkDebugUtilsLabelEXT) callconv(.C) void;
pub const PFN_vkQueueEndDebugUtilsLabelEXT = ?fn (VkQueue) callconv(.C) void;
pub const PFN_vkQueueInsertDebugUtilsLabelEXT = ?fn (VkQueue, [*c]const VkDebugUtilsLabelEXT) callconv(.C) void;
pub const PFN_vkCmdBeginDebugUtilsLabelEXT = ?fn (VkCommandBuffer, [*c]const VkDebugUtilsLabelEXT) callconv(.C) void;
pub const PFN_vkCmdEndDebugUtilsLabelEXT = ?fn (VkCommandBuffer) callconv(.C) void;
pub const PFN_vkCmdInsertDebugUtilsLabelEXT = ?fn (VkCommandBuffer, [*c]const VkDebugUtilsLabelEXT) callconv(.C) void;
pub const PFN_vkCreateDebugUtilsMessengerEXT = ?fn (vk.Instance, [*c]const VkDebugUtilsMessengerCreateInfoEXT, [*c]const VkAllocationCallbacks, [*c]VkDebugUtilsMessengerEXT) callconv(.C) VkResult;
pub const PFN_vkDestroyDebugUtilsMessengerEXT = ?fn (vk.Instance, VkDebugUtilsMessengerEXT, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkSubmitDebugUtilsMessageEXT = ?fn (vk.Instance, VkDebugUtilsMessageSeverityFlagBitsEXT, VkDebugUtilsMessageTypeFlagsEXT, [*c]const VkDebugUtilsMessengerCallbackDataEXT) callconv(.C) void;
pub extern fn vkSetDebugUtilsObjectNameEXT(device: vk.Device, pNameInfo: [*c]const VkDebugUtilsObjectNameInfoEXT) VkResult;
pub extern fn vkSetDebugUtilsObjectTagEXT(device: vk.Device, pTagInfo: [*c]const VkDebugUtilsObjectTagInfoEXT) VkResult;
pub extern fn vkQueueBeginDebugUtilsLabelEXT(queue: VkQueue, pLabelInfo: [*c]const VkDebugUtilsLabelEXT) void;
pub extern fn vkQueueEndDebugUtilsLabelEXT(queue: VkQueue) void;
pub extern fn vkQueueInsertDebugUtilsLabelEXT(queue: VkQueue, pLabelInfo: [*c]const VkDebugUtilsLabelEXT) void;
pub extern fn vkCmdBeginDebugUtilsLabelEXT(commandBuffer: VkCommandBuffer, pLabelInfo: [*c]const VkDebugUtilsLabelEXT) void;
pub extern fn vkCmdEndDebugUtilsLabelEXT(commandBuffer: VkCommandBuffer) void;
pub extern fn vkCmdInsertDebugUtilsLabelEXT(commandBuffer: VkCommandBuffer, pLabelInfo: [*c]const VkDebugUtilsLabelEXT) void;
pub extern fn vkCreateDebugUtilsMessengerEXT(instance: vk.Instance, pCreateInfo: [*c]const VkDebugUtilsMessengerCreateInfoEXT, pAllocator: [*c]const VkAllocationCallbacks, pMessenger: [*c]VkDebugUtilsMessengerEXT) VkResult;
pub extern fn vkDestroyDebugUtilsMessengerEXT(instance: vk.Instance, messenger: VkDebugUtilsMessengerEXT, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkSubmitDebugUtilsMessageEXT(instance: vk.Instance, messageSeverity: VkDebugUtilsMessageSeverityFlagBitsEXT, messageTypes: VkDebugUtilsMessageTypeFlagsEXT, pCallbackData: [*c]const VkDebugUtilsMessengerCallbackDataEXT) void;
pub const VkSamplerReductionModeEXT = VkSamplerReductionMode;
pub const VkSamplerReductionModeCreateInfoEXT = VkSamplerReductionModeCreateInfo;
pub const vk.PhysicalDeviceSamplerFilterMinmaxPropertiesEXT = vk.PhysicalDeviceSamplerFilterMinmaxProperties;
pub const struct_vk.PhysicalDeviceInlineUniformBlockFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    inlineUniformBlock: VkBool32,
    descriptorBindingInlineUniformBlockUpdateAfterBind: VkBool32,
};
pub const vk.PhysicalDeviceInlineUniformBlockFeaturesEXT = struct_vk.PhysicalDeviceInlineUniformBlockFeaturesEXT;
pub const struct_vk.PhysicalDeviceInlineUniformBlockPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxInlineUniformBlockSize: u32,
    maxPerStageDescriptorInlineUniformBlocks: u32,
    maxPerStageDescriptorUpdateAfterBindInlineUniformBlocks: u32,
    maxDescriptorSetInlineUniformBlocks: u32,
    maxDescriptorSetUpdateAfterBindInlineUniformBlocks: u32,
};
pub const vk.PhysicalDeviceInlineUniformBlockPropertiesEXT = struct_vk.PhysicalDeviceInlineUniformBlockPropertiesEXT;
pub const struct_VkWriteDescriptorSetInlineUniformBlockEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    dataSize: u32,
    pData: ?*const anyopaque,
};
pub const VkWriteDescriptorSetInlineUniformBlockEXT = struct_VkWriteDescriptorSetInlineUniformBlockEXT;
pub const struct_VkDescriptorPoolInlineUniformBlockCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    maxInlineUniformBlockBindings: u32,
};
pub const VkDescriptorPoolInlineUniformBlockCreateInfoEXT = struct_VkDescriptorPoolInlineUniformBlockCreateInfoEXT;
pub const struct_VkSampleLocationEXT = extern struct {
    x: f32,
    y: f32,
};
pub const VkSampleLocationEXT = struct_VkSampleLocationEXT;
pub const struct_VkSampleLocationsInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    sampleLocationsPerPixel: VkSampleCountFlagBits,
    sampleLocationGridSize: VkExtent2D,
    sampleLocationsCount: u32,
    pSampleLocations: [*c]const VkSampleLocationEXT,
};
pub const VkSampleLocationsInfoEXT = struct_VkSampleLocationsInfoEXT;
pub const struct_VkAttachmentSampleLocationsEXT = extern struct {
    attachmentIndex: u32,
    sampleLocationsInfo: VkSampleLocationsInfoEXT,
};
pub const VkAttachmentSampleLocationsEXT = struct_VkAttachmentSampleLocationsEXT;
pub const struct_VkSubpassSampleLocationsEXT = extern struct {
    subpassIndex: u32,
    sampleLocationsInfo: VkSampleLocationsInfoEXT,
};
pub const VkSubpassSampleLocationsEXT = struct_VkSubpassSampleLocationsEXT;
pub const struct_VkRenderPassSampleLocationsBeginInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    attachmentInitialSampleLocationsCount: u32,
    pAttachmentInitialSampleLocations: [*c]const VkAttachmentSampleLocationsEXT,
    postSubpassSampleLocationsCount: u32,
    pPostSubpassSampleLocations: [*c]const VkSubpassSampleLocationsEXT,
};
pub const VkRenderPassSampleLocationsBeginInfoEXT = struct_VkRenderPassSampleLocationsBeginInfoEXT;
pub const struct_VkPipelineSampleLocationsStateCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    sampleLocationsEnable: VkBool32,
    sampleLocationsInfo: VkSampleLocationsInfoEXT,
};
pub const VkPipelineSampleLocationsStateCreateInfoEXT = struct_VkPipelineSampleLocationsStateCreateInfoEXT;
pub const struct_vk.PhysicalDeviceSampleLocationsPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    sampleLocationSampleCounts: VkSampleCountFlags,
    maxSampleLocationGridSize: VkExtent2D,
    sampleLocationCoordinateRange: [2]f32,
    sampleLocationSubPixelBits: u32,
    variableSampleLocations: VkBool32,
};
pub const vk.PhysicalDeviceSampleLocationsPropertiesEXT = struct_vk.PhysicalDeviceSampleLocationsPropertiesEXT;
pub const struct_VkMultisamplePropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxSampleLocationGridSize: VkExtent2D,
};
pub const VkMultisamplePropertiesEXT = struct_VkMultisamplePropertiesEXT;
pub const PFN_vkCmdSetSampleLocationsEXT = ?fn (VkCommandBuffer, [*c]const VkSampleLocationsInfoEXT) callconv(.C) void;
pub const PFN_vkGetPhysicalDeviceMultisamplePropertiesEXT = ?fn (vk.PhysicalDevice, VkSampleCountFlagBits, [*c]VkMultisamplePropertiesEXT) callconv(.C) void;
pub extern fn vkCmdSetSampleLocationsEXT(commandBuffer: VkCommandBuffer, pSampleLocationsInfo: [*c]const VkSampleLocationsInfoEXT) void;
pub extern fn vkGetPhysicalDeviceMultisamplePropertiesEXT(physicalDevice: vk.PhysicalDevice, samples: VkSampleCountFlagBits, pMultisampleProperties: [*c]VkMultisamplePropertiesEXT) void;
pub const VK_BLEND_OVERLAP_UNCORRELATED_EXT: c_int = 0;
pub const VK_BLEND_OVERLAP_DISJOINT_EXT: c_int = 1;
pub const VK_BLEND_OVERLAP_CONJOINT_EXT: c_int = 2;
pub const VK_BLEND_OVERLAP_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkBlendOverlapEXT = c_uint;
pub const VkBlendOverlapEXT = enum_VkBlendOverlapEXT;
pub const struct_vk.PhysicalDeviceBlendOperationAdvancedFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    advancedBlendCoherentOperations: VkBool32,
};
pub const vk.PhysicalDeviceBlendOperationAdvancedFeaturesEXT = struct_vk.PhysicalDeviceBlendOperationAdvancedFeaturesEXT;
pub const struct_vk.PhysicalDeviceBlendOperationAdvancedPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    advancedBlendMaxColorAttachments: u32,
    advancedBlendIndependentBlend: VkBool32,
    advancedBlendNonPremultipliedSrcColor: VkBool32,
    advancedBlendNonPremultipliedDstColor: VkBool32,
    advancedBlendCorrelatedOverlap: VkBool32,
    advancedBlendAllOperations: VkBool32,
};
pub const vk.PhysicalDeviceBlendOperationAdvancedPropertiesEXT = struct_vk.PhysicalDeviceBlendOperationAdvancedPropertiesEXT;
pub const struct_VkPipelineColorBlendAdvancedStateCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    srcPremultiplied: VkBool32,
    dstPremultiplied: VkBool32,
    blendOverlap: VkBlendOverlapEXT,
};
pub const VkPipelineColorBlendAdvancedStateCreateInfoEXT = struct_VkPipelineColorBlendAdvancedStateCreateInfoEXT;
pub const VkPipelineCoverageToColorStateCreateFlagsNV = VkFlags;
pub const struct_VkPipelineCoverageToColorStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineCoverageToColorStateCreateFlagsNV,
    coverageToColorEnable: VkBool32,
    coverageToColorLocation: u32,
};
pub const VkPipelineCoverageToColorStateCreateInfoNV = struct_VkPipelineCoverageToColorStateCreateInfoNV;
pub const VK_COVERAGE_MODULATION_MODE_NONE_NV: c_int = 0;
pub const VK_COVERAGE_MODULATION_MODE_RGB_NV: c_int = 1;
pub const VK_COVERAGE_MODULATION_MODE_ALPHA_NV: c_int = 2;
pub const VK_COVERAGE_MODULATION_MODE_RGBA_NV: c_int = 3;
pub const VK_COVERAGE_MODULATION_MODE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkCoverageModulationModeNV = c_uint;
pub const VkCoverageModulationModeNV = enum_VkCoverageModulationModeNV;
pub const VkPipelineCoverageModulationStateCreateFlagsNV = VkFlags;
pub const struct_VkPipelineCoverageModulationStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineCoverageModulationStateCreateFlagsNV,
    coverageModulationMode: VkCoverageModulationModeNV,
    coverageModulationTableEnable: VkBool32,
    coverageModulationTableCount: u32,
    pCoverageModulationTable: [*c]const f32,
};
pub const VkPipelineCoverageModulationStateCreateInfoNV = struct_VkPipelineCoverageModulationStateCreateInfoNV;
pub const struct_vk.PhysicalDeviceShaderSMBuiltinsPropertiesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderSMCount: u32,
    shaderWarpsPerSM: u32,
};
pub const vk.PhysicalDeviceShaderSMBuiltinsPropertiesNV = struct_vk.PhysicalDeviceShaderSMBuiltinsPropertiesNV;
pub const struct_vk.PhysicalDeviceShaderSMBuiltinsFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderSMBuiltins: VkBool32,
};
pub const vk.PhysicalDeviceShaderSMBuiltinsFeaturesNV = struct_vk.PhysicalDeviceShaderSMBuiltinsFeaturesNV;
pub const struct_VkDrmFormatModifierPropertiesEXT = extern struct {
    drmFormatModifier: u64,
    drmFormatModifierPlaneCount: u32,
    drmFormatModifierTilingFeatures: VkFormatFeatureFlags,
};
pub const VkDrmFormatModifierPropertiesEXT = struct_VkDrmFormatModifierPropertiesEXT;
pub const struct_VkDrmFormatModifierPropertiesListEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    drmFormatModifierCount: u32,
    pDrmFormatModifierProperties: [*c]VkDrmFormatModifierPropertiesEXT,
};
pub const VkDrmFormatModifierPropertiesListEXT = struct_VkDrmFormatModifierPropertiesListEXT;
pub const struct_vk.PhysicalDeviceImageDrmFormatModifierInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    drmFormatModifier: u64,
    sharingMode: VkSharingMode,
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: [*c]const u32,
};
pub const vk.PhysicalDeviceImageDrmFormatModifierInfoEXT = struct_vk.PhysicalDeviceImageDrmFormatModifierInfoEXT;
pub const struct_VkImageDrmFormatModifierListCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    drmFormatModifierCount: u32,
    pDrmFormatModifiers: [*c]const u64,
};
pub const VkImageDrmFormatModifierListCreateInfoEXT = struct_VkImageDrmFormatModifierListCreateInfoEXT;
pub const struct_VkImageDrmFormatModifierExplicitCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    drmFormatModifier: u64,
    drmFormatModifierPlaneCount: u32,
    pPlaneLayouts: [*c]const VkSubresourceLayout,
};
pub const VkImageDrmFormatModifierExplicitCreateInfoEXT = struct_VkImageDrmFormatModifierExplicitCreateInfoEXT;
pub const struct_VkImageDrmFormatModifierPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    drmFormatModifier: u64,
};
pub const VkImageDrmFormatModifierPropertiesEXT = struct_VkImageDrmFormatModifierPropertiesEXT;
pub const struct_VkDrmFormatModifierProperties2EXT = extern struct {
    drmFormatModifier: u64,
    drmFormatModifierPlaneCount: u32,
    drmFormatModifierTilingFeatures: VkFormatFeatureFlags2KHR,
};
pub const VkDrmFormatModifierProperties2EXT = struct_VkDrmFormatModifierProperties2EXT;
pub const struct_VkDrmFormatModifierPropertiesList2EXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    drmFormatModifierCount: u32,
    pDrmFormatModifierProperties: [*c]VkDrmFormatModifierProperties2EXT,
};
pub const VkDrmFormatModifierPropertiesList2EXT = struct_VkDrmFormatModifierPropertiesList2EXT;
pub const PFN_vkGetImageDrmFormatModifierPropertiesEXT = ?fn (vk.Device, VkImage, [*c]VkImageDrmFormatModifierPropertiesEXT) callconv(.C) VkResult;
pub extern fn vkGetImageDrmFormatModifierPropertiesEXT(device: vk.Device, image: VkImage, pProperties: [*c]VkImageDrmFormatModifierPropertiesEXT) VkResult;
pub const struct_VkValidationCacheEXT_T = opaque {};
pub const VkValidationCacheEXT = ?*struct_VkValidationCacheEXT_T;
pub const VK_VALIDATION_CACHE_HEADER_VERSION_ONE_EXT: c_int = 1;
pub const VK_VALIDATION_CACHE_HEADER_VERSION_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkValidationCacheHeaderVersionEXT = c_uint;
pub const VkValidationCacheHeaderVersionEXT = enum_VkValidationCacheHeaderVersionEXT;
pub const VkValidationCacheCreateFlagsEXT = VkFlags;
pub const struct_VkValidationCacheCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkValidationCacheCreateFlagsEXT,
    initialDataSize: usize,
    pInitialData: ?*const anyopaque,
};
pub const VkValidationCacheCreateInfoEXT = struct_VkValidationCacheCreateInfoEXT;
pub const struct_VkShaderModuleValidationCacheCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    validationCache: VkValidationCacheEXT,
};
pub const VkShaderModuleValidationCacheCreateInfoEXT = struct_VkShaderModuleValidationCacheCreateInfoEXT;
pub const PFN_vkCreateValidationCacheEXT = ?fn (vk.Device, [*c]const VkValidationCacheCreateInfoEXT, [*c]const VkAllocationCallbacks, [*c]VkValidationCacheEXT) callconv(.C) VkResult;
pub const PFN_vkDestroyValidationCacheEXT = ?fn (vk.Device, VkValidationCacheEXT, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkMergeValidationCachesEXT = ?fn (vk.Device, VkValidationCacheEXT, u32, [*c]const VkValidationCacheEXT) callconv(.C) VkResult;
pub const PFN_vkGetValidationCacheDataEXT = ?fn (vk.Device, VkValidationCacheEXT, [*c]usize, ?*anyopaque) callconv(.C) VkResult;
pub extern fn vkCreateValidationCacheEXT(device: vk.Device, pCreateInfo: [*c]const VkValidationCacheCreateInfoEXT, pAllocator: [*c]const VkAllocationCallbacks, pValidationCache: [*c]VkValidationCacheEXT) VkResult;
pub extern fn vkDestroyValidationCacheEXT(device: vk.Device, validationCache: VkValidationCacheEXT, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkMergeValidationCachesEXT(device: vk.Device, dstCache: VkValidationCacheEXT, srcCacheCount: u32, pSrcCaches: [*c]const VkValidationCacheEXT) VkResult;
pub extern fn vkGetValidationCacheDataEXT(device: vk.Device, validationCache: VkValidationCacheEXT, pDataSize: [*c]usize, pData: ?*anyopaque) VkResult;
pub const VkDescriptorBindingFlagBitsEXT = VkDescriptorBindingFlagBits;
pub const VkDescriptorBindingFlagsEXT = VkDescriptorBindingFlags;
pub const VkDescriptorSetLayoutBindingFlagsCreateInfoEXT = VkDescriptorSetLayoutBindingFlagsCreateInfo;
pub const vk.PhysicalDeviceDescriptorIndexingFeaturesEXT = vk.PhysicalDeviceDescriptorIndexingFeatures;
pub const vk.PhysicalDeviceDescriptorIndexingPropertiesEXT = vk.PhysicalDeviceDescriptorIndexingProperties;
pub const VkDescriptorSetVariableDescriptorCountAllocateInfoEXT = VkDescriptorSetVariableDescriptorCountAllocateInfo;
pub const VkDescriptorSetVariableDescriptorCountLayoutSupportEXT = VkDescriptorSetVariableDescriptorCountLayoutSupport;
pub const VK_SHADING_RATE_PALETTE_ENTRY_NO_INVOCATIONS_NV: c_int = 0;
pub const VK_SHADING_RATE_PALETTE_ENTRY_16_INVOCATIONS_PER_PIXEL_NV: c_int = 1;
pub const VK_SHADING_RATE_PALETTE_ENTRY_8_INVOCATIONS_PER_PIXEL_NV: c_int = 2;
pub const VK_SHADING_RATE_PALETTE_ENTRY_4_INVOCATIONS_PER_PIXEL_NV: c_int = 3;
pub const VK_SHADING_RATE_PALETTE_ENTRY_2_INVOCATIONS_PER_PIXEL_NV: c_int = 4;
pub const VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_PIXEL_NV: c_int = 5;
pub const VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_2X1_PIXELS_NV: c_int = 6;
pub const VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_1X2_PIXELS_NV: c_int = 7;
pub const VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_2X2_PIXELS_NV: c_int = 8;
pub const VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_4X2_PIXELS_NV: c_int = 9;
pub const VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_2X4_PIXELS_NV: c_int = 10;
pub const VK_SHADING_RATE_PALETTE_ENTRY_1_INVOCATION_PER_4X4_PIXELS_NV: c_int = 11;
pub const VK_SHADING_RATE_PALETTE_ENTRY_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkShadingRatePaletteEntryNV = c_uint;
pub const VkShadingRatePaletteEntryNV = enum_VkShadingRatePaletteEntryNV;
pub const VK_COARSE_SAMPLE_ORDER_TYPE_DEFAULT_NV: c_int = 0;
pub const VK_COARSE_SAMPLE_ORDER_TYPE_CUSTOM_NV: c_int = 1;
pub const VK_COARSE_SAMPLE_ORDER_TYPE_PIXEL_MAJOR_NV: c_int = 2;
pub const VK_COARSE_SAMPLE_ORDER_TYPE_SAMPLE_MAJOR_NV: c_int = 3;
pub const VK_COARSE_SAMPLE_ORDER_TYPE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkCoarseSampleOrderTypeNV = c_uint;
pub const VkCoarseSampleOrderTypeNV = enum_VkCoarseSampleOrderTypeNV;
pub const struct_VkShadingRatePaletteNV = extern struct {
    shadingRatePaletteEntryCount: u32,
    pShadingRatePaletteEntries: [*c]const VkShadingRatePaletteEntryNV,
};
pub const VkShadingRatePaletteNV = struct_VkShadingRatePaletteNV;
pub const struct_VkPipelineViewportShadingRateImageStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    shadingRateImageEnable: VkBool32,
    viewportCount: u32,
    pShadingRatePalettes: [*c]const VkShadingRatePaletteNV,
};
pub const VkPipelineViewportShadingRateImageStateCreateInfoNV = struct_VkPipelineViewportShadingRateImageStateCreateInfoNV;
pub const struct_vk.PhysicalDeviceShadingRateImageFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shadingRateImage: VkBool32,
    shadingRateCoarseSampleOrder: VkBool32,
};
pub const vk.PhysicalDeviceShadingRateImageFeaturesNV = struct_vk.PhysicalDeviceShadingRateImageFeaturesNV;
pub const struct_vk.PhysicalDeviceShadingRateImagePropertiesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shadingRateTexelSize: VkExtent2D,
    shadingRatePaletteSize: u32,
    shadingRateMaxCoarseSamples: u32,
};
pub const vk.PhysicalDeviceShadingRateImagePropertiesNV = struct_vk.PhysicalDeviceShadingRateImagePropertiesNV;
pub const struct_VkCoarseSampleLocationNV = extern struct {
    pixelX: u32,
    pixelY: u32,
    sample: u32,
};
pub const VkCoarseSampleLocationNV = struct_VkCoarseSampleLocationNV;
pub const struct_VkCoarseSampleOrderCustomNV = extern struct {
    shadingRate: VkShadingRatePaletteEntryNV,
    sampleCount: u32,
    sampleLocationCount: u32,
    pSampleLocations: [*c]const VkCoarseSampleLocationNV,
};
pub const VkCoarseSampleOrderCustomNV = struct_VkCoarseSampleOrderCustomNV;
pub const struct_VkPipelineViewportCoarseSampleOrderStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    sampleOrderType: VkCoarseSampleOrderTypeNV,
    customSampleOrderCount: u32,
    pCustomSampleOrders: [*c]const VkCoarseSampleOrderCustomNV,
};
pub const VkPipelineViewportCoarseSampleOrderStateCreateInfoNV = struct_VkPipelineViewportCoarseSampleOrderStateCreateInfoNV;
pub const PFN_vkCmdBindShadingRateImageNV = ?fn (VkCommandBuffer, VkImageView, VkImageLayout) callconv(.C) void;
pub const PFN_vkCmdSetViewportShadingRatePaletteNV = ?fn (VkCommandBuffer, u32, u32, [*c]const VkShadingRatePaletteNV) callconv(.C) void;
pub const PFN_vkCmdSetCoarseSampleOrderNV = ?fn (VkCommandBuffer, VkCoarseSampleOrderTypeNV, u32, [*c]const VkCoarseSampleOrderCustomNV) callconv(.C) void;
pub extern fn vkCmdBindShadingRateImageNV(commandBuffer: VkCommandBuffer, imageView: VkImageView, imageLayout: VkImageLayout) void;
pub extern fn vkCmdSetViewportShadingRatePaletteNV(commandBuffer: VkCommandBuffer, firstViewport: u32, viewportCount: u32, pShadingRatePalettes: [*c]const VkShadingRatePaletteNV) void;
pub extern fn vkCmdSetCoarseSampleOrderNV(commandBuffer: VkCommandBuffer, sampleOrderType: VkCoarseSampleOrderTypeNV, customSampleOrderCount: u32, pCustomSampleOrders: [*c]const VkCoarseSampleOrderCustomNV) void;
pub const struct_VkAccelerationStructureNV_T = opaque {};
pub const VkAccelerationStructureNV = ?*struct_VkAccelerationStructureNV_T;
pub const VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_KHR: c_int = 0;
pub const VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_KHR: c_int = 1;
pub const VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_KHR: c_int = 2;
pub const VK_RAY_TRACING_SHADER_GROUP_TYPE_GENERAL_NV: c_int = 0;
pub const VK_RAY_TRACING_SHADER_GROUP_TYPE_TRIANGLES_HIT_GROUP_NV: c_int = 1;
pub const VK_RAY_TRACING_SHADER_GROUP_TYPE_PROCEDURAL_HIT_GROUP_NV: c_int = 2;
pub const VK_RAY_TRACING_SHADER_GROUP_TYPE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkRayTracingShaderGroupTypeKHR = c_uint;
pub const VkRayTracingShaderGroupTypeKHR = enum_VkRayTracingShaderGroupTypeKHR;
pub const VkRayTracingShaderGroupTypeNV = VkRayTracingShaderGroupTypeKHR;
pub const VK_GEOMETRY_TYPE_TRIANGLES_KHR: c_int = 0;
pub const VK_GEOMETRY_TYPE_AABBS_KHR: c_int = 1;
pub const VK_GEOMETRY_TYPE_INSTANCES_KHR: c_int = 2;
pub const VK_GEOMETRY_TYPE_TRIANGLES_NV: c_int = 0;
pub const VK_GEOMETRY_TYPE_AABBS_NV: c_int = 1;
pub const VK_GEOMETRY_TYPE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkGeometryTypeKHR = c_uint;
pub const VkGeometryTypeKHR = enum_VkGeometryTypeKHR;
pub const VkGeometryTypeNV = VkGeometryTypeKHR;
pub const VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_KHR: c_int = 0;
pub const VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_KHR: c_int = 1;
pub const VK_ACCELERATION_STRUCTURE_TYPE_GENERIC_KHR: c_int = 2;
pub const VK_ACCELERATION_STRUCTURE_TYPE_TOP_LEVEL_NV: c_int = 0;
pub const VK_ACCELERATION_STRUCTURE_TYPE_BOTTOM_LEVEL_NV: c_int = 1;
pub const VK_ACCELERATION_STRUCTURE_TYPE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkAccelerationStructureTypeKHR = c_uint;
pub const VkAccelerationStructureTypeKHR = enum_VkAccelerationStructureTypeKHR;
pub const VkAccelerationStructureTypeNV = VkAccelerationStructureTypeKHR;
pub const VK_COPY_ACCELERATION_STRUCTURE_MODE_CLONE_KHR: c_int = 0;
pub const VK_COPY_ACCELERATION_STRUCTURE_MODE_COMPACT_KHR: c_int = 1;
pub const VK_COPY_ACCELERATION_STRUCTURE_MODE_SERIALIZE_KHR: c_int = 2;
pub const VK_COPY_ACCELERATION_STRUCTURE_MODE_DESERIALIZE_KHR: c_int = 3;
pub const VK_COPY_ACCELERATION_STRUCTURE_MODE_CLONE_NV: c_int = 0;
pub const VK_COPY_ACCELERATION_STRUCTURE_MODE_COMPACT_NV: c_int = 1;
pub const VK_COPY_ACCELERATION_STRUCTURE_MODE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkCopyAccelerationStructureModeKHR = c_uint;
pub const VkCopyAccelerationStructureModeKHR = enum_VkCopyAccelerationStructureModeKHR;
pub const VkCopyAccelerationStructureModeNV = VkCopyAccelerationStructureModeKHR;
pub const VK_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_TYPE_OBJECT_NV: c_int = 0;
pub const VK_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_TYPE_BUILD_SCRATCH_NV: c_int = 1;
pub const VK_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_TYPE_UPDATE_SCRATCH_NV: c_int = 2;
pub const VK_ACCELERATION_STRUCTURE_MEMORY_REQUIREMENTS_TYPE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkAccelerationStructureMemoryRequirementsTypeNV = c_uint;
pub const VkAccelerationStructureMemoryRequirementsTypeNV = enum_VkAccelerationStructureMemoryRequirementsTypeNV;
pub const VK_GEOMETRY_OPAQUE_BIT_KHR: c_int = 1;
pub const VK_GEOMETRY_NO_DUPLICATE_ANY_HIT_INVOCATION_BIT_KHR: c_int = 2;
pub const VK_GEOMETRY_OPAQUE_BIT_NV: c_int = 1;
pub const VK_GEOMETRY_NO_DUPLICATE_ANY_HIT_INVOCATION_BIT_NV: c_int = 2;
pub const VK_GEOMETRY_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkGeometryFlagBitsKHR = c_uint;
pub const VkGeometryFlagBitsKHR = enum_VkGeometryFlagBitsKHR;
pub const VkGeometryFlagsKHR = VkFlags;
pub const VkGeometryFlagsNV = VkGeometryFlagsKHR;
pub const VkGeometryFlagBitsNV = VkGeometryFlagBitsKHR;
pub const VK_GEOMETRY_INSTANCE_TRIANGLE_FACING_CULL_DISABLE_BIT_KHR: c_int = 1;
pub const VK_GEOMETRY_INSTANCE_TRIANGLE_FLIP_FACING_BIT_KHR: c_int = 2;
pub const VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_KHR: c_int = 4;
pub const VK_GEOMETRY_INSTANCE_FORCE_NO_OPAQUE_BIT_KHR: c_int = 8;
pub const VK_GEOMETRY_INSTANCE_TRIANGLE_FRONT_COUNTERCLOCKWISE_BIT_KHR: c_int = 2;
pub const VK_GEOMETRY_INSTANCE_TRIANGLE_CULL_DISABLE_BIT_NV: c_int = 1;
pub const VK_GEOMETRY_INSTANCE_TRIANGLE_FRONT_COUNTERCLOCKWISE_BIT_NV: c_int = 2;
pub const VK_GEOMETRY_INSTANCE_FORCE_OPAQUE_BIT_NV: c_int = 4;
pub const VK_GEOMETRY_INSTANCE_FORCE_NO_OPAQUE_BIT_NV: c_int = 8;
pub const VK_GEOMETRY_INSTANCE_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkGeometryInstanceFlagBitsKHR = c_uint;
pub const VkGeometryInstanceFlagBitsKHR = enum_VkGeometryInstanceFlagBitsKHR;
pub const VkGeometryInstanceFlagsKHR = VkFlags;
pub const VkGeometryInstanceFlagsNV = VkGeometryInstanceFlagsKHR;
pub const VkGeometryInstanceFlagBitsNV = VkGeometryInstanceFlagBitsKHR;
pub const VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_KHR: c_int = 1;
pub const VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_COMPACTION_BIT_KHR: c_int = 2;
pub const VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_KHR: c_int = 4;
pub const VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_BUILD_BIT_KHR: c_int = 8;
pub const VK_BUILD_ACCELERATION_STRUCTURE_LOW_MEMORY_BIT_KHR: c_int = 16;
pub const VK_BUILD_ACCELERATION_STRUCTURE_MOTION_BIT_NV: c_int = 32;
pub const VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_UPDATE_BIT_NV: c_int = 1;
pub const VK_BUILD_ACCELERATION_STRUCTURE_ALLOW_COMPACTION_BIT_NV: c_int = 2;
pub const VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_TRACE_BIT_NV: c_int = 4;
pub const VK_BUILD_ACCELERATION_STRUCTURE_PREFER_FAST_BUILD_BIT_NV: c_int = 8;
pub const VK_BUILD_ACCELERATION_STRUCTURE_LOW_MEMORY_BIT_NV: c_int = 16;
pub const VK_BUILD_ACCELERATION_STRUCTURE_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkBuildAccelerationStructureFlagBitsKHR = c_uint;
pub const VkBuildAccelerationStructureFlagBitsKHR = enum_VkBuildAccelerationStructureFlagBitsKHR;
pub const VkBuildAccelerationStructureFlagsKHR = VkFlags;
pub const VkBuildAccelerationStructureFlagsNV = VkBuildAccelerationStructureFlagsKHR;
pub const VkBuildAccelerationStructureFlagBitsNV = VkBuildAccelerationStructureFlagBitsKHR;
pub const struct_VkRayTracingShaderGroupCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    type: VkRayTracingShaderGroupTypeKHR,
    generalShader: u32,
    closestHitShader: u32,
    anyHitShader: u32,
    intersectionShader: u32,
};
pub const VkRayTracingShaderGroupCreateInfoNV = struct_VkRayTracingShaderGroupCreateInfoNV;
pub const struct_VkRayTracingPipelineCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineCreateFlags,
    stageCount: u32,
    pStages: [*c]const VkPipelineShaderStageCreateInfo,
    groupCount: u32,
    pGroups: [*c]const VkRayTracingShaderGroupCreateInfoNV,
    maxRecursionDepth: u32,
    layout: VkPipelineLayout,
    basePipelineHandle: VkPipeline,
    basePipelineIndex: i32,
};
pub const VkRayTracingPipelineCreateInfoNV = struct_VkRayTracingPipelineCreateInfoNV;
pub const struct_VkGeometryTrianglesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    vertexData: VkBuffer,
    vertexOffset: vk.DeviceSize,
    vertexCount: u32,
    vertexStride: vk.DeviceSize,
    vertexFormat: VkFormat,
    indexData: VkBuffer,
    indexOffset: vk.DeviceSize,
    indexCount: u32,
    indexType: VkIndexType,
    transformData: VkBuffer,
    transformOffset: vk.DeviceSize,
};
pub const VkGeometryTrianglesNV = struct_VkGeometryTrianglesNV;
pub const struct_VkGeometryAABBNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    aabbData: VkBuffer,
    numAABBs: u32,
    stride: u32,
    offset: vk.DeviceSize,
};
pub const VkGeometryAABBNV = struct_VkGeometryAABBNV;
pub const struct_VkGeometryDataNV = extern struct {
    triangles: VkGeometryTrianglesNV,
    aabbs: VkGeometryAABBNV,
};
pub const VkGeometryDataNV = struct_VkGeometryDataNV;
pub const struct_VkGeometryNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    geometryType: VkGeometryTypeKHR,
    geometry: VkGeometryDataNV,
    flags: VkGeometryFlagsKHR,
};
pub const VkGeometryNV = struct_VkGeometryNV;
pub const struct_VkAccelerationStructureInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    type: VkAccelerationStructureTypeNV,
    flags: VkBuildAccelerationStructureFlagsNV,
    instanceCount: u32,
    geometryCount: u32,
    pGeometries: [*c]const VkGeometryNV,
};
pub const VkAccelerationStructureInfoNV = struct_VkAccelerationStructureInfoNV;
pub const struct_VkAccelerationStructureCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    compactedSize: vk.DeviceSize,
    info: VkAccelerationStructureInfoNV,
};
pub const VkAccelerationStructureCreateInfoNV = struct_VkAccelerationStructureCreateInfoNV;
pub const struct_VkBindAccelerationStructureMemoryInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    accelerationStructure: VkAccelerationStructureNV,
    memory: vk.DeviceMemory,
    memoryOffset: vk.DeviceSize,
    deviceIndexCount: u32,
    pDeviceIndices: [*c]const u32,
};
pub const VkBindAccelerationStructureMemoryInfoNV = struct_VkBindAccelerationStructureMemoryInfoNV;
pub const struct_VkWriteDescriptorSetAccelerationStructureNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    accelerationStructureCount: u32,
    pAccelerationStructures: [*c]const VkAccelerationStructureNV,
};
pub const VkWriteDescriptorSetAccelerationStructureNV = struct_VkWriteDescriptorSetAccelerationStructureNV;
pub const struct_VkAccelerationStructureMemoryRequirementsInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    type: VkAccelerationStructureMemoryRequirementsTypeNV,
    accelerationStructure: VkAccelerationStructureNV,
};
pub const VkAccelerationStructureMemoryRequirementsInfoNV = struct_VkAccelerationStructureMemoryRequirementsInfoNV;
pub const struct_vk.PhysicalDeviceRayTracingPropertiesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderGroupHandleSize: u32,
    maxRecursionDepth: u32,
    maxShaderGroupStride: u32,
    shaderGroupBaseAlignment: u32,
    maxGeometryCount: u64,
    maxInstanceCount: u64,
    maxTriangleCount: u64,
    maxDescriptorSetAccelerationStructures: u32,
};
pub const vk.PhysicalDeviceRayTracingPropertiesNV = struct_vk.PhysicalDeviceRayTracingPropertiesNV;
pub const struct_VkTransformMatrixKHR = extern struct {
    matrix: [3][4]f32,
};
pub const VkTransformMatrixKHR = struct_VkTransformMatrixKHR;
pub const VkTransformMatrixNV = VkTransformMatrixKHR;
pub const struct_VkAabbPositionsKHR = extern struct {
    minX: f32,
    minY: f32,
    minZ: f32,
    maxX: f32,
    maxY: f32,
    maxZ: f32,
};
pub const VkAabbPositionsKHR = struct_VkAabbPositionsKHR;
pub const VkAabbPositionsNV = VkAabbPositionsKHR; // /Users/desaro/zig-vulkan/libs/mach-glfw/upstream/vulkan_headers/include/vulkan/vulkan_core.h:10712:35: warning: struct demoted to opaque type - has bitfield
pub const struct_VkAccelerationStructureInstanceKHR = opaque {};
pub const VkAccelerationStructureInstanceKHR = struct_VkAccelerationStructureInstanceKHR;
pub const VkAccelerationStructureInstanceNV = VkAccelerationStructureInstanceKHR;
pub const PFN_vkCreateAccelerationStructureNV = ?fn (vk.Device, [*c]const VkAccelerationStructureCreateInfoNV, [*c]const VkAllocationCallbacks, [*c]VkAccelerationStructureNV) callconv(.C) VkResult;
pub const PFN_vkDestroyAccelerationStructureNV = ?fn (vk.Device, VkAccelerationStructureNV, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkGetAccelerationStructureMemoryRequirementsNV = ?fn (vk.Device, [*c]const VkAccelerationStructureMemoryRequirementsInfoNV, [*c]VkMemoryRequirements2KHR) callconv(.C) void;
pub const PFN_vkBindAccelerationStructureMemoryNV = ?fn (vk.Device, u32, [*c]const VkBindAccelerationStructureMemoryInfoNV) callconv(.C) VkResult;
pub const PFN_vkCmdBuildAccelerationStructureNV = ?fn (VkCommandBuffer, [*c]const VkAccelerationStructureInfoNV, VkBuffer, vk.DeviceSize, VkBool32, VkAccelerationStructureNV, VkAccelerationStructureNV, VkBuffer, vk.DeviceSize) callconv(.C) void;
pub const PFN_vkCmdCopyAccelerationStructureNV = ?fn (VkCommandBuffer, VkAccelerationStructureNV, VkAccelerationStructureNV, VkCopyAccelerationStructureModeKHR) callconv(.C) void;
pub const PFN_vkCmdTraceRaysNV = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, VkBuffer, vk.DeviceSize, vk.DeviceSize, VkBuffer, vk.DeviceSize, vk.DeviceSize, VkBuffer, vk.DeviceSize, vk.DeviceSize, u32, u32, u32) callconv(.C) void;
pub const PFN_vkCreateRayTracingPipelinesNV = ?fn (vk.Device, VkPipelineCache, u32, [*c]const VkRayTracingPipelineCreateInfoNV, [*c]const VkAllocationCallbacks, [*c]VkPipeline) callconv(.C) VkResult;
pub const PFN_vkGetRayTracingShaderGroupHandlesKHR = ?fn (vk.Device, VkPipeline, u32, u32, usize, ?*anyopaque) callconv(.C) VkResult;
pub const PFN_vkGetRayTracingShaderGroupHandlesNV = ?fn (vk.Device, VkPipeline, u32, u32, usize, ?*anyopaque) callconv(.C) VkResult;
pub const PFN_vkGetAccelerationStructureHandleNV = ?fn (vk.Device, VkAccelerationStructureNV, usize, ?*anyopaque) callconv(.C) VkResult;
pub const PFN_vkCmdWriteAccelerationStructuresPropertiesNV = ?fn (VkCommandBuffer, u32, [*c]const VkAccelerationStructureNV, VkQueryType, VkQueryPool, u32) callconv(.C) void;
pub const PFN_vkCompileDeferredNV = ?fn (vk.Device, VkPipeline, u32) callconv(.C) VkResult;
pub extern fn vkCreateAccelerationStructureNV(device: vk.Device, pCreateInfo: [*c]const VkAccelerationStructureCreateInfoNV, pAllocator: [*c]const VkAllocationCallbacks, pAccelerationStructure: [*c]VkAccelerationStructureNV) VkResult;
pub extern fn vkDestroyAccelerationStructureNV(device: vk.Device, accelerationStructure: VkAccelerationStructureNV, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkGetAccelerationStructureMemoryRequirementsNV(device: vk.Device, pInfo: [*c]const VkAccelerationStructureMemoryRequirementsInfoNV, pMemoryRequirements: [*c]VkMemoryRequirements2KHR) void;
pub extern fn vkBindAccelerationStructureMemoryNV(device: vk.Device, bindInfoCount: u32, pBindInfos: [*c]const VkBindAccelerationStructureMemoryInfoNV) VkResult;
pub extern fn vkCmdBuildAccelerationStructureNV(commandBuffer: VkCommandBuffer, pInfo: [*c]const VkAccelerationStructureInfoNV, instanceData: VkBuffer, instanceOffset: vk.DeviceSize, update: VkBool32, dst: VkAccelerationStructureNV, src: VkAccelerationStructureNV, scratch: VkBuffer, scratchOffset: vk.DeviceSize) void;
pub extern fn vkCmdCopyAccelerationStructureNV(commandBuffer: VkCommandBuffer, dst: VkAccelerationStructureNV, src: VkAccelerationStructureNV, mode: VkCopyAccelerationStructureModeKHR) void;
pub extern fn vkCmdTraceRaysNV(commandBuffer: VkCommandBuffer, raygenShaderBindingTableBuffer: VkBuffer, raygenShaderBindingOffset: vk.DeviceSize, missShaderBindingTableBuffer: VkBuffer, missShaderBindingOffset: vk.DeviceSize, missShaderBindingStride: vk.DeviceSize, hitShaderBindingTableBuffer: VkBuffer, hitShaderBindingOffset: vk.DeviceSize, hitShaderBindingStride: vk.DeviceSize, callableShaderBindingTableBuffer: VkBuffer, callableShaderBindingOffset: vk.DeviceSize, callableShaderBindingStride: vk.DeviceSize, width: u32, height: u32, depth: u32) void;
pub extern fn vkCreateRayTracingPipelinesNV(device: vk.Device, pipelineCache: VkPipelineCache, createInfoCount: u32, pCreateInfos: [*c]const VkRayTracingPipelineCreateInfoNV, pAllocator: [*c]const VkAllocationCallbacks, pPipelines: [*c]VkPipeline) VkResult;
pub extern fn vkGetRayTracingShaderGroupHandlesKHR(device: vk.Device, pipeline: VkPipeline, firstGroup: u32, groupCount: u32, dataSize: usize, pData: ?*anyopaque) VkResult;
pub extern fn vkGetRayTracingShaderGroupHandlesNV(device: vk.Device, pipeline: VkPipeline, firstGroup: u32, groupCount: u32, dataSize: usize, pData: ?*anyopaque) VkResult;
pub extern fn vkGetAccelerationStructureHandleNV(device: vk.Device, accelerationStructure: VkAccelerationStructureNV, dataSize: usize, pData: ?*anyopaque) VkResult;
pub extern fn vkCmdWriteAccelerationStructuresPropertiesNV(commandBuffer: VkCommandBuffer, accelerationStructureCount: u32, pAccelerationStructures: [*c]const VkAccelerationStructureNV, queryType: VkQueryType, queryPool: VkQueryPool, firstQuery: u32) void;
pub extern fn vkCompileDeferredNV(device: vk.Device, pipeline: VkPipeline, shader: u32) VkResult;
pub const struct_vk.PhysicalDeviceRepresentativeFragmentTestFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    representativeFragmentTest: VkBool32,
};
pub const vk.PhysicalDeviceRepresentativeFragmentTestFeaturesNV = struct_vk.PhysicalDeviceRepresentativeFragmentTestFeaturesNV;
pub const struct_VkPipelineRepresentativeFragmentTestStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    representativeFragmentTestEnable: VkBool32,
};
pub const VkPipelineRepresentativeFragmentTestStateCreateInfoNV = struct_VkPipelineRepresentativeFragmentTestStateCreateInfoNV;
pub const struct_vk.PhysicalDeviceImageViewImageFormatInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    imageViewType: VkImageViewType,
};
pub const vk.PhysicalDeviceImageViewImageFormatInfoEXT = struct_vk.PhysicalDeviceImageViewImageFormatInfoEXT;
pub const struct_VkFilterCubicImageViewImageFormatPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    filterCubic: VkBool32,
    filterCubicMinmax: VkBool32,
};
pub const VkFilterCubicImageViewImageFormatPropertiesEXT = struct_VkFilterCubicImageViewImageFormatPropertiesEXT;
pub const VK_QUEUE_GLOBAL_PRIORITY_LOW_EXT: c_int = 128;
pub const VK_QUEUE_GLOBAL_PRIORITY_MEDIUM_EXT: c_int = 256;
pub const VK_QUEUE_GLOBAL_PRIORITY_HIGH_EXT: c_int = 512;
pub const VK_QUEUE_GLOBAL_PRIORITY_REALTIME_EXT: c_int = 1024;
pub const VK_QUEUE_GLOBAL_PRIORITY_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkQueueGlobalPriorityEXT = c_uint;
pub const VkQueueGlobalPriorityEXT = enum_VkQueueGlobalPriorityEXT;
pub const struct_vk.DeviceQueueGlobalPriorityCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    globalPriority: VkQueueGlobalPriorityEXT,
};
pub const vk.DeviceQueueGlobalPriorityCreateInfoEXT = struct_vk.DeviceQueueGlobalPriorityCreateInfoEXT;
pub const struct_VkImportMemoryHostPointerInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    handleType: VkExternalMemoryHandleTypeFlagBits,
    pHostPointer: ?*anyopaque,
};
pub const VkImportMemoryHostPointerInfoEXT = struct_VkImportMemoryHostPointerInfoEXT;
pub const struct_VkMemoryHostPointerPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    memoryTypeBits: u32,
};
pub const VkMemoryHostPointerPropertiesEXT = struct_VkMemoryHostPointerPropertiesEXT;
pub const struct_vk.PhysicalDeviceExternalMemoryHostPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    minImportedHostPointerAlignment: vk.DeviceSize,
};
pub const vk.PhysicalDeviceExternalMemoryHostPropertiesEXT = struct_vk.PhysicalDeviceExternalMemoryHostPropertiesEXT;
pub const PFN_vkGetMemoryHostPointerPropertiesEXT = ?fn (vk.Device, VkExternalMemoryHandleTypeFlagBits, ?*const anyopaque, [*c]VkMemoryHostPointerPropertiesEXT) callconv(.C) VkResult;
pub extern fn vkGetMemoryHostPointerPropertiesEXT(device: vk.Device, handleType: VkExternalMemoryHandleTypeFlagBits, pHostPointer: ?*const anyopaque, pMemoryHostPointerProperties: [*c]VkMemoryHostPointerPropertiesEXT) VkResult;
pub const PFN_vkCmdWriteBufferMarkerAMD = ?fn (VkCommandBuffer, VkPipelineStageFlagBits, VkBuffer, vk.DeviceSize, u32) callconv(.C) void;
pub extern fn vkCmdWriteBufferMarkerAMD(commandBuffer: VkCommandBuffer, pipelineStage: VkPipelineStageFlagBits, dstBuffer: VkBuffer, dstOffset: vk.DeviceSize, marker: u32) void;
pub const VK_PIPELINE_COMPILER_CONTROL_FLAG_BITS_MAX_ENUM_AMD: c_int = 2147483647;
pub const enum_VkPipelineCompilerControlFlagBitsAMD = c_uint;
pub const VkPipelineCompilerControlFlagBitsAMD = enum_VkPipelineCompilerControlFlagBitsAMD;
pub const VkPipelineCompilerControlFlagsAMD = VkFlags;
pub const struct_VkPipelineCompilerControlCreateInfoAMD = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    compilerControlFlags: VkPipelineCompilerControlFlagsAMD,
};
pub const VkPipelineCompilerControlCreateInfoAMD = struct_VkPipelineCompilerControlCreateInfoAMD;
pub const VK_TIME_DOMAIN_DEVICE_EXT: c_int = 0;
pub const VK_TIME_DOMAIN_CLOCK_MONOTONIC_EXT: c_int = 1;
pub const VK_TIME_DOMAIN_CLOCK_MONOTONIC_RAW_EXT: c_int = 2;
pub const VK_TIME_DOMAIN_QUERY_PERFORMANCE_COUNTER_EXT: c_int = 3;
pub const VK_TIME_DOMAIN_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkTimeDomainEXT = c_uint;
pub const VkTimeDomainEXT = enum_VkTimeDomainEXT;
pub const struct_VkCalibratedTimestampInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    timeDomain: VkTimeDomainEXT,
};
pub const VkCalibratedTimestampInfoEXT = struct_VkCalibratedTimestampInfoEXT;
pub const PFN_vkGetPhysicalDeviceCalibrateableTimeDomainsEXT = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkTimeDomainEXT) callconv(.C) VkResult;
pub const PFN_vkGetCalibratedTimestampsEXT = ?fn (vk.Device, u32, [*c]const VkCalibratedTimestampInfoEXT, [*c]u64, [*c]u64) callconv(.C) VkResult;
pub extern fn vkGetPhysicalDeviceCalibrateableTimeDomainsEXT(physicalDevice: vk.PhysicalDevice, pTimeDomainCount: [*c]u32, pTimeDomains: [*c]VkTimeDomainEXT) VkResult;
pub extern fn vkGetCalibratedTimestampsEXT(device: vk.Device, timestampCount: u32, pTimestampInfos: [*c]const VkCalibratedTimestampInfoEXT, pTimestamps: [*c]u64, pMaxDeviation: [*c]u64) VkResult;
pub const struct_vk.PhysicalDeviceShaderCorePropertiesAMD = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderEngineCount: u32,
    shaderArraysPerEngineCount: u32,
    computeUnitsPerShaderArray: u32,
    simdPerComputeUnit: u32,
    wavefrontsPerSimd: u32,
    wavefrontSize: u32,
    sgprsPerSimd: u32,
    minSgprAllocation: u32,
    maxSgprAllocation: u32,
    sgprAllocationGranularity: u32,
    vgprsPerSimd: u32,
    minVgprAllocation: u32,
    maxVgprAllocation: u32,
    vgprAllocationGranularity: u32,
};
pub const vk.PhysicalDeviceShaderCorePropertiesAMD = struct_vk.PhysicalDeviceShaderCorePropertiesAMD;
pub const VK_MEMORY_OVERALLOCATION_BEHAVIOR_DEFAULT_AMD: c_int = 0;
pub const VK_MEMORY_OVERALLOCATION_BEHAVIOR_ALLOWED_AMD: c_int = 1;
pub const VK_MEMORY_OVERALLOCATION_BEHAVIOR_DISALLOWED_AMD: c_int = 2;
pub const VK_MEMORY_OVERALLOCATION_BEHAVIOR_MAX_ENUM_AMD: c_int = 2147483647;
pub const enum_VkMemoryOverallocationBehaviorAMD = c_uint;
pub const VkMemoryOverallocationBehaviorAMD = enum_VkMemoryOverallocationBehaviorAMD;
pub const struct_vk.DeviceMemoryOverallocationCreateInfoAMD = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    overallocationBehavior: VkMemoryOverallocationBehaviorAMD,
};
pub const vk.DeviceMemoryOverallocationCreateInfoAMD = struct_vk.DeviceMemoryOverallocationCreateInfoAMD;
pub const struct_vk.PhysicalDeviceVertexAttributeDivisorPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxVertexAttribDivisor: u32,
};
pub const vk.PhysicalDeviceVertexAttributeDivisorPropertiesEXT = struct_vk.PhysicalDeviceVertexAttributeDivisorPropertiesEXT;
pub const struct_VkVertexInputBindingDivisorDescriptionEXT = extern struct {
    binding: u32,
    divisor: u32,
};
pub const VkVertexInputBindingDivisorDescriptionEXT = struct_VkVertexInputBindingDivisorDescriptionEXT;
pub const struct_VkPipelineVertexInputDivisorStateCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    vertexBindingDivisorCount: u32,
    pVertexBindingDivisors: [*c]const VkVertexInputBindingDivisorDescriptionEXT,
};
pub const VkPipelineVertexInputDivisorStateCreateInfoEXT = struct_VkPipelineVertexInputDivisorStateCreateInfoEXT;
pub const struct_vk.PhysicalDeviceVertexAttributeDivisorFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    vertexAttributeInstanceRateDivisor: VkBool32,
    vertexAttributeInstanceRateZeroDivisor: VkBool32,
};
pub const vk.PhysicalDeviceVertexAttributeDivisorFeaturesEXT = struct_vk.PhysicalDeviceVertexAttributeDivisorFeaturesEXT;
pub const VK_PIPELINE_CREATION_FEEDBACK_VALID_BIT_EXT: c_int = 1;
pub const VK_PIPELINE_CREATION_FEEDBACK_APPLICATION_PIPELINE_CACHE_HIT_BIT_EXT: c_int = 2;
pub const VK_PIPELINE_CREATION_FEEDBACK_BASE_PIPELINE_ACCELERATION_BIT_EXT: c_int = 4;
pub const VK_PIPELINE_CREATION_FEEDBACK_FLAG_BITS_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkPipelineCreationFeedbackFlagBitsEXT = c_uint;
pub const VkPipelineCreationFeedbackFlagBitsEXT = enum_VkPipelineCreationFeedbackFlagBitsEXT;
pub const VkPipelineCreationFeedbackFlagsEXT = VkFlags;
pub const struct_VkPipelineCreationFeedbackEXT = extern struct {
    flags: VkPipelineCreationFeedbackFlagsEXT,
    duration: u64,
};
pub const VkPipelineCreationFeedbackEXT = struct_VkPipelineCreationFeedbackEXT;
pub const struct_VkPipelineCreationFeedbackCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pPipelineCreationFeedback: [*c]VkPipelineCreationFeedbackEXT,
    pipelineStageCreationFeedbackCount: u32,
    pPipelineStageCreationFeedbacks: [*c]VkPipelineCreationFeedbackEXT,
};
pub const VkPipelineCreationFeedbackCreateInfoEXT = struct_VkPipelineCreationFeedbackCreateInfoEXT;
pub const struct_vk.PhysicalDeviceComputeShaderDerivativesFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    computeDerivativeGroupQuads: VkBool32,
    computeDerivativeGroupLinear: VkBool32,
};
pub const vk.PhysicalDeviceComputeShaderDerivativesFeaturesNV = struct_vk.PhysicalDeviceComputeShaderDerivativesFeaturesNV;
pub const struct_vk.PhysicalDeviceMeshShaderFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    taskShader: VkBool32,
    meshShader: VkBool32,
};
pub const vk.PhysicalDeviceMeshShaderFeaturesNV = struct_vk.PhysicalDeviceMeshShaderFeaturesNV;
pub const struct_vk.PhysicalDeviceMeshShaderPropertiesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxDrawMeshTasksCount: u32,
    maxTaskWorkGroupInvocations: u32,
    maxTaskWorkGroupSize: [3]u32,
    maxTaskTotalMemorySize: u32,
    maxTaskOutputCount: u32,
    maxMeshWorkGroupInvocations: u32,
    maxMeshWorkGroupSize: [3]u32,
    maxMeshTotalMemorySize: u32,
    maxMeshOutputVertices: u32,
    maxMeshOutputPrimitives: u32,
    maxMeshMultiviewViewCount: u32,
    meshOutputPerVertexGranularity: u32,
    meshOutputPerPrimitiveGranularity: u32,
};
pub const vk.PhysicalDeviceMeshShaderPropertiesNV = struct_vk.PhysicalDeviceMeshShaderPropertiesNV;
pub const struct_VkDrawMeshTasksIndirectCommandNV = extern struct {
    taskCount: u32,
    firstTask: u32,
};
pub const VkDrawMeshTasksIndirectCommandNV = struct_VkDrawMeshTasksIndirectCommandNV;
pub const PFN_vkCmdDrawMeshTasksNV = ?fn (VkCommandBuffer, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawMeshTasksIndirectNV = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawMeshTasksIndirectCountNV = ?fn (VkCommandBuffer, VkBuffer, vk.DeviceSize, VkBuffer, vk.DeviceSize, u32, u32) callconv(.C) void;
pub extern fn vkCmdDrawMeshTasksNV(commandBuffer: VkCommandBuffer, taskCount: u32, firstTask: u32) void;
pub extern fn vkCmdDrawMeshTasksIndirectNV(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, drawCount: u32, stride: u32) void;
pub extern fn vkCmdDrawMeshTasksIndirectCountNV(commandBuffer: VkCommandBuffer, buffer: VkBuffer, offset: vk.DeviceSize, countBuffer: VkBuffer, countBufferOffset: vk.DeviceSize, maxDrawCount: u32, stride: u32) void;
pub const struct_vk.PhysicalDeviceFragmentShaderBarycentricFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    fragmentShaderBarycentric: VkBool32,
};
pub const vk.PhysicalDeviceFragmentShaderBarycentricFeaturesNV = struct_vk.PhysicalDeviceFragmentShaderBarycentricFeaturesNV;
pub const struct_vk.PhysicalDeviceShaderImageFootprintFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    imageFootprint: VkBool32,
};
pub const vk.PhysicalDeviceShaderImageFootprintFeaturesNV = struct_vk.PhysicalDeviceShaderImageFootprintFeaturesNV;
pub const struct_VkPipelineViewportExclusiveScissorStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    exclusiveScissorCount: u32,
    pExclusiveScissors: [*c]const VkRect2D,
};
pub const VkPipelineViewportExclusiveScissorStateCreateInfoNV = struct_VkPipelineViewportExclusiveScissorStateCreateInfoNV;
pub const struct_vk.PhysicalDeviceExclusiveScissorFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    exclusiveScissor: VkBool32,
};
pub const vk.PhysicalDeviceExclusiveScissorFeaturesNV = struct_vk.PhysicalDeviceExclusiveScissorFeaturesNV;
pub const PFN_vkCmdSetExclusiveScissorNV = ?fn (VkCommandBuffer, u32, u32, [*c]const VkRect2D) callconv(.C) void;
pub extern fn vkCmdSetExclusiveScissorNV(commandBuffer: VkCommandBuffer, firstExclusiveScissor: u32, exclusiveScissorCount: u32, pExclusiveScissors: [*c]const VkRect2D) void;
pub const struct_VkQueueFamilyCheckpointPropertiesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    checkpointExecutionStageMask: VkPipelineStageFlags,
};
pub const VkQueueFamilyCheckpointPropertiesNV = struct_VkQueueFamilyCheckpointPropertiesNV;
pub const struct_VkCheckpointDataNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    stage: VkPipelineStageFlagBits,
    pCheckpointMarker: ?*anyopaque,
};
pub const VkCheckpointDataNV = struct_VkCheckpointDataNV;
pub const PFN_vkCmdSetCheckpointNV = ?fn (VkCommandBuffer, ?*const anyopaque) callconv(.C) void;
pub const PFN_vkGetQueueCheckpointDataNV = ?fn (VkQueue, [*c]u32, [*c]VkCheckpointDataNV) callconv(.C) void;
pub extern fn vkCmdSetCheckpointNV(commandBuffer: VkCommandBuffer, pCheckpointMarker: ?*const anyopaque) void;
pub extern fn vkGetQueueCheckpointDataNV(queue: VkQueue, pCheckpointDataCount: [*c]u32, pCheckpointData: [*c]VkCheckpointDataNV) void;
pub const struct_vk.PhysicalDeviceShaderIntegerFunctions2FeaturesINTEL = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderIntegerFunctions2: VkBool32,
};
pub const vk.PhysicalDeviceShaderIntegerFunctions2FeaturesINTEL = struct_vk.PhysicalDeviceShaderIntegerFunctions2FeaturesINTEL;
pub const struct_VkPerformanceConfigurationINTEL_T = opaque {};
pub const VkPerformanceConfigurationINTEL = ?*struct_VkPerformanceConfigurationINTEL_T;
pub const VK_PERFORMANCE_CONFIGURATION_TYPE_COMMAND_QUEUE_METRICS_DISCOVERY_ACTIVATED_INTEL: c_int = 0;
pub const VK_PERFORMANCE_CONFIGURATION_TYPE_MAX_ENUM_INTEL: c_int = 2147483647;
pub const enum_VkPerformanceConfigurationTypeINTEL = c_uint;
pub const VkPerformanceConfigurationTypeINTEL = enum_VkPerformanceConfigurationTypeINTEL;
pub const VK_QUERY_POOL_SAMPLING_MODE_MANUAL_INTEL: c_int = 0;
pub const VK_QUERY_POOL_SAMPLING_MODE_MAX_ENUM_INTEL: c_int = 2147483647;
pub const enum_VkQueryPoolSamplingModeINTEL = c_uint;
pub const VkQueryPoolSamplingModeINTEL = enum_VkQueryPoolSamplingModeINTEL;
pub const VK_PERFORMANCE_OVERRIDE_TYPE_NULL_HARDWARE_INTEL: c_int = 0;
pub const VK_PERFORMANCE_OVERRIDE_TYPE_FLUSH_GPU_CACHES_INTEL: c_int = 1;
pub const VK_PERFORMANCE_OVERRIDE_TYPE_MAX_ENUM_INTEL: c_int = 2147483647;
pub const enum_VkPerformanceOverrideTypeINTEL = c_uint;
pub const VkPerformanceOverrideTypeINTEL = enum_VkPerformanceOverrideTypeINTEL;
pub const VK_PERFORMANCE_PARAMETER_TYPE_HW_COUNTERS_SUPPORTED_INTEL: c_int = 0;
pub const VK_PERFORMANCE_PARAMETER_TYPE_STREAM_MARKER_VALID_BITS_INTEL: c_int = 1;
pub const VK_PERFORMANCE_PARAMETER_TYPE_MAX_ENUM_INTEL: c_int = 2147483647;
pub const enum_VkPerformanceParameterTypeINTEL = c_uint;
pub const VkPerformanceParameterTypeINTEL = enum_VkPerformanceParameterTypeINTEL;
pub const VK_PERFORMANCE_VALUE_TYPE_UINT32_INTEL: c_int = 0;
pub const VK_PERFORMANCE_VALUE_TYPE_UINT64_INTEL: c_int = 1;
pub const VK_PERFORMANCE_VALUE_TYPE_FLOAT_INTEL: c_int = 2;
pub const VK_PERFORMANCE_VALUE_TYPE_BOOL_INTEL: c_int = 3;
pub const VK_PERFORMANCE_VALUE_TYPE_STRING_INTEL: c_int = 4;
pub const VK_PERFORMANCE_VALUE_TYPE_MAX_ENUM_INTEL: c_int = 2147483647;
pub const enum_VkPerformanceValueTypeINTEL = c_uint;
pub const VkPerformanceValueTypeINTEL = enum_VkPerformanceValueTypeINTEL;
pub const union_VkPerformanceValueDataINTEL = extern union {
    value32: u32,
    value64: u64,
    valueFloat: f32,
    valueBool: VkBool32,
    valueString: [*c]const u8,
};
pub const VkPerformanceValueDataINTEL = union_VkPerformanceValueDataINTEL;
pub const struct_VkPerformanceValueINTEL = extern struct {
    type: VkPerformanceValueTypeINTEL,
    data: VkPerformanceValueDataINTEL,
};
pub const VkPerformanceValueINTEL = struct_VkPerformanceValueINTEL;
pub const struct_VkInitializePerformanceApiInfoINTEL = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pUserData: ?*anyopaque,
};
pub const VkInitializePerformanceApiInfoINTEL = struct_VkInitializePerformanceApiInfoINTEL;
pub const struct_VkQueryPoolPerformanceQueryCreateInfoINTEL = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    performanceCountersSampling: VkQueryPoolSamplingModeINTEL,
};
pub const VkQueryPoolPerformanceQueryCreateInfoINTEL = struct_VkQueryPoolPerformanceQueryCreateInfoINTEL;
pub const VkQueryPoolCreateInfoINTEL = VkQueryPoolPerformanceQueryCreateInfoINTEL;
pub const struct_VkPerformanceMarkerInfoINTEL = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    marker: u64,
};
pub const VkPerformanceMarkerInfoINTEL = struct_VkPerformanceMarkerInfoINTEL;
pub const struct_VkPerformanceStreamMarkerInfoINTEL = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    marker: u32,
};
pub const VkPerformanceStreamMarkerInfoINTEL = struct_VkPerformanceStreamMarkerInfoINTEL;
pub const struct_VkPerformanceOverrideInfoINTEL = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    type: VkPerformanceOverrideTypeINTEL,
    enable: VkBool32,
    parameter: u64,
};
pub const VkPerformanceOverrideInfoINTEL = struct_VkPerformanceOverrideInfoINTEL;
pub const struct_VkPerformanceConfigurationAcquireInfoINTEL = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    type: VkPerformanceConfigurationTypeINTEL,
};
pub const VkPerformanceConfigurationAcquireInfoINTEL = struct_VkPerformanceConfigurationAcquireInfoINTEL;
pub const PFN_vkInitializePerformanceApiINTEL = ?fn (vk.Device, [*c]const VkInitializePerformanceApiInfoINTEL) callconv(.C) VkResult;
pub const PFN_vkUninitializePerformanceApiINTEL = ?fn (vk.Device) callconv(.C) void;
pub const PFN_vkCmdSetPerformanceMarkerINTEL = ?fn (VkCommandBuffer, [*c]const VkPerformanceMarkerInfoINTEL) callconv(.C) VkResult;
pub const PFN_vkCmdSetPerformanceStreamMarkerINTEL = ?fn (VkCommandBuffer, [*c]const VkPerformanceStreamMarkerInfoINTEL) callconv(.C) VkResult;
pub const PFN_vkCmdSetPerformanceOverrideINTEL = ?fn (VkCommandBuffer, [*c]const VkPerformanceOverrideInfoINTEL) callconv(.C) VkResult;
pub const PFN_vkAcquirePerformanceConfigurationINTEL = ?fn (vk.Device, [*c]const VkPerformanceConfigurationAcquireInfoINTEL, [*c]VkPerformanceConfigurationINTEL) callconv(.C) VkResult;
pub const PFN_vkReleasePerformanceConfigurationINTEL = ?fn (vk.Device, VkPerformanceConfigurationINTEL) callconv(.C) VkResult;
pub const PFN_vkQueueSetPerformanceConfigurationINTEL = ?fn (VkQueue, VkPerformanceConfigurationINTEL) callconv(.C) VkResult;
pub const PFN_vkGetPerformanceParameterINTEL = ?fn (vk.Device, VkPerformanceParameterTypeINTEL, [*c]VkPerformanceValueINTEL) callconv(.C) VkResult;
pub extern fn vkInitializePerformanceApiINTEL(device: vk.Device, pInitializeInfo: [*c]const VkInitializePerformanceApiInfoINTEL) VkResult;
pub extern fn vkUninitializePerformanceApiINTEL(device: vk.Device) void;
pub extern fn vkCmdSetPerformanceMarkerINTEL(commandBuffer: VkCommandBuffer, pMarkerInfo: [*c]const VkPerformanceMarkerInfoINTEL) VkResult;
pub extern fn vkCmdSetPerformanceStreamMarkerINTEL(commandBuffer: VkCommandBuffer, pMarkerInfo: [*c]const VkPerformanceStreamMarkerInfoINTEL) VkResult;
pub extern fn vkCmdSetPerformanceOverrideINTEL(commandBuffer: VkCommandBuffer, pOverrideInfo: [*c]const VkPerformanceOverrideInfoINTEL) VkResult;
pub extern fn vkAcquirePerformanceConfigurationINTEL(device: vk.Device, pAcquireInfo: [*c]const VkPerformanceConfigurationAcquireInfoINTEL, pConfiguration: [*c]VkPerformanceConfigurationINTEL) VkResult;
pub extern fn vkReleasePerformanceConfigurationINTEL(device: vk.Device, configuration: VkPerformanceConfigurationINTEL) VkResult;
pub extern fn vkQueueSetPerformanceConfigurationINTEL(queue: VkQueue, configuration: VkPerformanceConfigurationINTEL) VkResult;
pub extern fn vkGetPerformanceParameterINTEL(device: vk.Device, parameter: VkPerformanceParameterTypeINTEL, pValue: [*c]VkPerformanceValueINTEL) VkResult;
pub const struct_vk.PhysicalDevicePCIBusInfoPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    pciDomain: u32,
    pciBus: u32,
    pciDevice: u32,
    pciFunction: u32,
};
pub const vk.PhysicalDevicePCIBusInfoPropertiesEXT = struct_vk.PhysicalDevicePCIBusInfoPropertiesEXT;
pub const struct_VkDisplayNativeHdrSurfaceCapabilitiesAMD = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    localDimmingSupport: VkBool32,
};
pub const VkDisplayNativeHdrSurfaceCapabilitiesAMD = struct_VkDisplayNativeHdrSurfaceCapabilitiesAMD;
pub const struct_VkSwapchainDisplayNativeHdrCreateInfoAMD = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    localDimmingEnable: VkBool32,
};
pub const VkSwapchainDisplayNativeHdrCreateInfoAMD = struct_VkSwapchainDisplayNativeHdrCreateInfoAMD;
pub const PFN_vkSetLocalDimmingAMD = ?fn (vk.Device, VkSwapchainKHR, VkBool32) callconv(.C) void;
pub extern fn vkSetLocalDimmingAMD(device: vk.Device, swapChain: VkSwapchainKHR, localDimmingEnable: VkBool32) void;
pub const struct_vk.PhysicalDeviceFragmentDensityMapFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    fragmentDensityMap: VkBool32,
    fragmentDensityMapDynamic: VkBool32,
    fragmentDensityMapNonSubsampledImages: VkBool32,
};
pub const vk.PhysicalDeviceFragmentDensityMapFeaturesEXT = struct_vk.PhysicalDeviceFragmentDensityMapFeaturesEXT;
pub const struct_vk.PhysicalDeviceFragmentDensityMapPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    minFragmentDensityTexelSize: VkExtent2D,
    maxFragmentDensityTexelSize: VkExtent2D,
    fragmentDensityInvocations: VkBool32,
};
pub const vk.PhysicalDeviceFragmentDensityMapPropertiesEXT = struct_vk.PhysicalDeviceFragmentDensityMapPropertiesEXT;
pub const struct_VkRenderPassFragmentDensityMapCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    fragmentDensityMapAttachment: VkAttachmentReference,
};
pub const VkRenderPassFragmentDensityMapCreateInfoEXT = struct_VkRenderPassFragmentDensityMapCreateInfoEXT;
pub const vk.PhysicalDeviceScalarBlockLayoutFeaturesEXT = vk.PhysicalDeviceScalarBlockLayoutFeatures;
pub const struct_vk.PhysicalDeviceSubgroupSizeControlFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    subgroupSizeControl: VkBool32,
    computeFullSubgroups: VkBool32,
};
pub const vk.PhysicalDeviceSubgroupSizeControlFeaturesEXT = struct_vk.PhysicalDeviceSubgroupSizeControlFeaturesEXT;
pub const struct_vk.PhysicalDeviceSubgroupSizeControlPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    minSubgroupSize: u32,
    maxSubgroupSize: u32,
    maxComputeWorkgroupSubgroups: u32,
    requiredSubgroupSizeStages: VkShaderStageFlags,
};
pub const vk.PhysicalDeviceSubgroupSizeControlPropertiesEXT = struct_vk.PhysicalDeviceSubgroupSizeControlPropertiesEXT;
pub const struct_VkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    requiredSubgroupSize: u32,
};
pub const VkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT = struct_VkPipelineShaderStageRequiredSubgroupSizeCreateInfoEXT;
pub const VK_SHADER_CORE_PROPERTIES_FLAG_BITS_MAX_ENUM_AMD: c_int = 2147483647;
pub const enum_VkShaderCorePropertiesFlagBitsAMD = c_uint;
pub const VkShaderCorePropertiesFlagBitsAMD = enum_VkShaderCorePropertiesFlagBitsAMD;
pub const VkShaderCorePropertiesFlagsAMD = VkFlags;
pub const struct_vk.PhysicalDeviceShaderCoreProperties2AMD = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderCoreFeatures: VkShaderCorePropertiesFlagsAMD,
    activeComputeUnitCount: u32,
};
pub const vk.PhysicalDeviceShaderCoreProperties2AMD = struct_vk.PhysicalDeviceShaderCoreProperties2AMD;
pub const struct_vk.PhysicalDeviceCoherentMemoryFeaturesAMD = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    deviceCoherentMemory: VkBool32,
};
pub const vk.PhysicalDeviceCoherentMemoryFeaturesAMD = struct_vk.PhysicalDeviceCoherentMemoryFeaturesAMD;
pub const struct_vk.PhysicalDeviceShaderImageAtomicInt64FeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderImageInt64Atomics: VkBool32,
    sparseImageInt64Atomics: VkBool32,
};
pub const vk.PhysicalDeviceShaderImageAtomicInt64FeaturesEXT = struct_vk.PhysicalDeviceShaderImageAtomicInt64FeaturesEXT;
pub const struct_vk.PhysicalDeviceMemoryBudgetPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    heapBudget: [16]vk.DeviceSize,
    heapUsage: [16]vk.DeviceSize,
};
pub const vk.PhysicalDeviceMemoryBudgetPropertiesEXT = struct_vk.PhysicalDeviceMemoryBudgetPropertiesEXT;
pub const struct_vk.PhysicalDeviceMemoryPriorityFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    memoryPriority: VkBool32,
};
pub const vk.PhysicalDeviceMemoryPriorityFeaturesEXT = struct_vk.PhysicalDeviceMemoryPriorityFeaturesEXT;
pub const struct_VkMemoryPriorityAllocateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    priority: f32,
};
pub const VkMemoryPriorityAllocateInfoEXT = struct_VkMemoryPriorityAllocateInfoEXT;
pub const struct_vk.PhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    dedicatedAllocationImageAliasing: VkBool32,
};
pub const vk.PhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV = struct_vk.PhysicalDeviceDedicatedAllocationImageAliasingFeaturesNV;
pub const struct_vk.PhysicalDeviceBufferDeviceAddressFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    bufferDeviceAddress: VkBool32,
    bufferDeviceAddressCaptureReplay: VkBool32,
    bufferDeviceAddressMultiDevice: VkBool32,
};
pub const vk.PhysicalDeviceBufferDeviceAddressFeaturesEXT = struct_vk.PhysicalDeviceBufferDeviceAddressFeaturesEXT;
pub const vk.PhysicalDeviceBufferAddressFeaturesEXT = vk.PhysicalDeviceBufferDeviceAddressFeaturesEXT;
pub const VkBufferDeviceAddressInfoEXT = VkBufferDeviceAddressInfo;
pub const struct_VkBufferDeviceAddressCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    deviceAddress: vk.DeviceAddress,
};
pub const VkBufferDeviceAddressCreateInfoEXT = struct_VkBufferDeviceAddressCreateInfoEXT;
pub const PFN_vkGetBufferDeviceAddressEXT = ?fn (vk.Device, [*c]const VkBufferDeviceAddressInfo) callconv(.C) vk.DeviceAddress;
pub extern fn vkGetBufferDeviceAddressEXT(device: vk.Device, pInfo: [*c]const VkBufferDeviceAddressInfo) vk.DeviceAddress;
pub const VK_TOOL_PURPOSE_VALIDATION_BIT_EXT: c_int = 1;
pub const VK_TOOL_PURPOSE_PROFILING_BIT_EXT: c_int = 2;
pub const VK_TOOL_PURPOSE_TRACING_BIT_EXT: c_int = 4;
pub const VK_TOOL_PURPOSE_ADDITIONAL_FEATURES_BIT_EXT: c_int = 8;
pub const VK_TOOL_PURPOSE_MODIFYING_FEATURES_BIT_EXT: c_int = 16;
pub const VK_TOOL_PURPOSE_DEBUG_REPORTING_BIT_EXT: c_int = 32;
pub const VK_TOOL_PURPOSE_DEBUG_MARKERS_BIT_EXT: c_int = 64;
pub const VK_TOOL_PURPOSE_FLAG_BITS_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkToolPurposeFlagBitsEXT = c_uint;
pub const VkToolPurposeFlagBitsEXT = enum_VkToolPurposeFlagBitsEXT;
pub const VkToolPurposeFlagsEXT = VkFlags;
pub const struct_vk.PhysicalDeviceToolPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    name: [256]u8,
    version: [256]u8,
    purposes: VkToolPurposeFlagsEXT,
    description: [256]u8,
    layer: [256]u8,
};
pub const vk.PhysicalDeviceToolPropertiesEXT = struct_vk.PhysicalDeviceToolPropertiesEXT;
pub const PFN_vkGetPhysicalDeviceToolPropertiesEXT = ?fn (vk.PhysicalDevice, [*c]u32, [*c]vk.PhysicalDeviceToolPropertiesEXT) callconv(.C) VkResult;
pub extern fn vkGetPhysicalDeviceToolPropertiesEXT(physicalDevice: vk.PhysicalDevice, pToolCount: [*c]u32, pToolProperties: [*c]vk.PhysicalDeviceToolPropertiesEXT) VkResult;
pub const VkImageStencilUsageCreateInfoEXT = VkImageStencilUsageCreateInfo;
pub const VK_VALIDATION_FEATURE_ENABLE_GPU_ASSISTED_EXT: c_int = 0;
pub const VK_VALIDATION_FEATURE_ENABLE_GPU_ASSISTED_RESERVE_BINDING_SLOT_EXT: c_int = 1;
pub const VK_VALIDATION_FEATURE_ENABLE_BEST_PRACTICES_EXT: c_int = 2;
pub const VK_VALIDATION_FEATURE_ENABLE_DEBUG_PRINTF_EXT: c_int = 3;
pub const VK_VALIDATION_FEATURE_ENABLE_SYNCHRONIZATION_VALIDATION_EXT: c_int = 4;
pub const VK_VALIDATION_FEATURE_ENABLE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkValidationFeatureEnableEXT = c_uint;
pub const VkValidationFeatureEnableEXT = enum_VkValidationFeatureEnableEXT;
pub const VK_VALIDATION_FEATURE_DISABLE_ALL_EXT: c_int = 0;
pub const VK_VALIDATION_FEATURE_DISABLE_SHADERS_EXT: c_int = 1;
pub const VK_VALIDATION_FEATURE_DISABLE_THREAD_SAFETY_EXT: c_int = 2;
pub const VK_VALIDATION_FEATURE_DISABLE_API_PARAMETERS_EXT: c_int = 3;
pub const VK_VALIDATION_FEATURE_DISABLE_OBJECT_LIFETIMES_EXT: c_int = 4;
pub const VK_VALIDATION_FEATURE_DISABLE_CORE_CHECKS_EXT: c_int = 5;
pub const VK_VALIDATION_FEATURE_DISABLE_UNIQUE_HANDLES_EXT: c_int = 6;
pub const VK_VALIDATION_FEATURE_DISABLE_SHADER_VALIDATION_CACHE_EXT: c_int = 7;
pub const VK_VALIDATION_FEATURE_DISABLE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkValidationFeatureDisableEXT = c_uint;
pub const VkValidationFeatureDisableEXT = enum_VkValidationFeatureDisableEXT;
pub const struct_VkValidationFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    enabledValidationFeatureCount: u32,
    pEnabledValidationFeatures: [*c]const VkValidationFeatureEnableEXT,
    disabledValidationFeatureCount: u32,
    pDisabledValidationFeatures: [*c]const VkValidationFeatureDisableEXT,
};
pub const VkValidationFeaturesEXT = struct_VkValidationFeaturesEXT;
pub const VK_COMPONENT_TYPE_FLOAT16_NV: c_int = 0;
pub const VK_COMPONENT_TYPE_FLOAT32_NV: c_int = 1;
pub const VK_COMPONENT_TYPE_FLOAT64_NV: c_int = 2;
pub const VK_COMPONENT_TYPE_SINT8_NV: c_int = 3;
pub const VK_COMPONENT_TYPE_SINT16_NV: c_int = 4;
pub const VK_COMPONENT_TYPE_SINT32_NV: c_int = 5;
pub const VK_COMPONENT_TYPE_SINT64_NV: c_int = 6;
pub const VK_COMPONENT_TYPE_UINT8_NV: c_int = 7;
pub const VK_COMPONENT_TYPE_UINT16_NV: c_int = 8;
pub const VK_COMPONENT_TYPE_UINT32_NV: c_int = 9;
pub const VK_COMPONENT_TYPE_UINT64_NV: c_int = 10;
pub const VK_COMPONENT_TYPE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkComponentTypeNV = c_uint;
pub const VkComponentTypeNV = enum_VkComponentTypeNV;
pub const VK_SCOPE_DEVICE_NV: c_int = 1;
pub const VK_SCOPE_WORKGROUP_NV: c_int = 2;
pub const VK_SCOPE_SUBGROUP_NV: c_int = 3;
pub const VK_SCOPE_QUEUE_FAMILY_NV: c_int = 5;
pub const VK_SCOPE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkScopeNV = c_uint;
pub const VkScopeNV = enum_VkScopeNV;
pub const struct_VkCooperativeMatrixPropertiesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    MSize: u32,
    NSize: u32,
    KSize: u32,
    AType: VkComponentTypeNV,
    BType: VkComponentTypeNV,
    CType: VkComponentTypeNV,
    DType: VkComponentTypeNV,
    scope: VkScopeNV,
};
pub const VkCooperativeMatrixPropertiesNV = struct_VkCooperativeMatrixPropertiesNV;
pub const struct_vk.PhysicalDeviceCooperativeMatrixFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    cooperativeMatrix: VkBool32,
    cooperativeMatrixRobustBufferAccess: VkBool32,
};
pub const vk.PhysicalDeviceCooperativeMatrixFeaturesNV = struct_vk.PhysicalDeviceCooperativeMatrixFeaturesNV;
pub const struct_vk.PhysicalDeviceCooperativeMatrixPropertiesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    cooperativeMatrixSupportedStages: VkShaderStageFlags,
};
pub const vk.PhysicalDeviceCooperativeMatrixPropertiesNV = struct_vk.PhysicalDeviceCooperativeMatrixPropertiesNV;
pub const PFN_vkGetPhysicalDeviceCooperativeMatrixPropertiesNV = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkCooperativeMatrixPropertiesNV) callconv(.C) VkResult;
pub extern fn vkGetPhysicalDeviceCooperativeMatrixPropertiesNV(physicalDevice: vk.PhysicalDevice, pPropertyCount: [*c]u32, pProperties: [*c]VkCooperativeMatrixPropertiesNV) VkResult;
pub const VK_COVERAGE_REDUCTION_MODE_MERGE_NV: c_int = 0;
pub const VK_COVERAGE_REDUCTION_MODE_TRUNCATE_NV: c_int = 1;
pub const VK_COVERAGE_REDUCTION_MODE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkCoverageReductionModeNV = c_uint;
pub const VkCoverageReductionModeNV = enum_VkCoverageReductionModeNV;
pub const VkPipelineCoverageReductionStateCreateFlagsNV = VkFlags;
pub const struct_vk.PhysicalDeviceCoverageReductionModeFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    coverageReductionMode: VkBool32,
};
pub const vk.PhysicalDeviceCoverageReductionModeFeaturesNV = struct_vk.PhysicalDeviceCoverageReductionModeFeaturesNV;
pub const struct_VkPipelineCoverageReductionStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineCoverageReductionStateCreateFlagsNV,
    coverageReductionMode: VkCoverageReductionModeNV,
};
pub const VkPipelineCoverageReductionStateCreateInfoNV = struct_VkPipelineCoverageReductionStateCreateInfoNV;
pub const struct_VkFramebufferMixedSamplesCombinationNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    coverageReductionMode: VkCoverageReductionModeNV,
    rasterizationSamples: VkSampleCountFlagBits,
    depthStencilSamples: VkSampleCountFlags,
    colorSamples: VkSampleCountFlags,
};
pub const VkFramebufferMixedSamplesCombinationNV = struct_VkFramebufferMixedSamplesCombinationNV;
pub const PFN_vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV = ?fn (vk.PhysicalDevice, [*c]u32, [*c]VkFramebufferMixedSamplesCombinationNV) callconv(.C) VkResult;
pub extern fn vkGetPhysicalDeviceSupportedFramebufferMixedSamplesCombinationsNV(physicalDevice: vk.PhysicalDevice, pCombinationCount: [*c]u32, pCombinations: [*c]VkFramebufferMixedSamplesCombinationNV) VkResult;
pub const struct_vk.PhysicalDeviceFragmentShaderInterlockFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    fragmentShaderSampleInterlock: VkBool32,
    fragmentShaderPixelInterlock: VkBool32,
    fragmentShaderShadingRateInterlock: VkBool32,
};
pub const vk.PhysicalDeviceFragmentShaderInterlockFeaturesEXT = struct_vk.PhysicalDeviceFragmentShaderInterlockFeaturesEXT;
pub const struct_vk.PhysicalDeviceYcbcrImageArraysFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    ycbcrImageArrays: VkBool32,
};
pub const vk.PhysicalDeviceYcbcrImageArraysFeaturesEXT = struct_vk.PhysicalDeviceYcbcrImageArraysFeaturesEXT;
pub const VK_PROVOKING_VERTEX_MODE_FIRST_VERTEX_EXT: c_int = 0;
pub const VK_PROVOKING_VERTEX_MODE_LAST_VERTEX_EXT: c_int = 1;
pub const VK_PROVOKING_VERTEX_MODE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkProvokingVertexModeEXT = c_uint;
pub const VkProvokingVertexModeEXT = enum_VkProvokingVertexModeEXT;
pub const struct_vk.PhysicalDeviceProvokingVertexFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    provokingVertexLast: VkBool32,
    transformFeedbackPreservesProvokingVertex: VkBool32,
};
pub const vk.PhysicalDeviceProvokingVertexFeaturesEXT = struct_vk.PhysicalDeviceProvokingVertexFeaturesEXT;
pub const struct_vk.PhysicalDeviceProvokingVertexPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    provokingVertexModePerPipeline: VkBool32,
    transformFeedbackPreservesTriangleFanProvokingVertex: VkBool32,
};
pub const vk.PhysicalDeviceProvokingVertexPropertiesEXT = struct_vk.PhysicalDeviceProvokingVertexPropertiesEXT;
pub const struct_VkPipelineRasterizationProvokingVertexStateCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    provokingVertexMode: VkProvokingVertexModeEXT,
};
pub const VkPipelineRasterizationProvokingVertexStateCreateInfoEXT = struct_VkPipelineRasterizationProvokingVertexStateCreateInfoEXT;
pub const VkHeadlessSurfaceCreateFlagsEXT = VkFlags;
pub const struct_VkHeadlessSurfaceCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkHeadlessSurfaceCreateFlagsEXT,
};
pub const VkHeadlessSurfaceCreateInfoEXT = struct_VkHeadlessSurfaceCreateInfoEXT;
pub const PFN_vkCreateHeadlessSurfaceEXT = ?fn (vk.Instance, [*c]const VkHeadlessSurfaceCreateInfoEXT, [*c]const VkAllocationCallbacks, [*c]VkSurfaceKHR) callconv(.C) VkResult;
pub extern fn vkCreateHeadlessSurfaceEXT(instance: vk.Instance, pCreateInfo: [*c]const VkHeadlessSurfaceCreateInfoEXT, pAllocator: [*c]const VkAllocationCallbacks, pSurface: [*c]VkSurfaceKHR) VkResult;
pub const VK_LINE_RASTERIZATION_MODE_DEFAULT_EXT: c_int = 0;
pub const VK_LINE_RASTERIZATION_MODE_RECTANGULAR_EXT: c_int = 1;
pub const VK_LINE_RASTERIZATION_MODE_BRESENHAM_EXT: c_int = 2;
pub const VK_LINE_RASTERIZATION_MODE_RECTANGULAR_SMOOTH_EXT: c_int = 3;
pub const VK_LINE_RASTERIZATION_MODE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkLineRasterizationModeEXT = c_uint;
pub const VkLineRasterizationModeEXT = enum_VkLineRasterizationModeEXT;
pub const struct_vk.PhysicalDeviceLineRasterizationFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    rectangularLines: VkBool32,
    bresenhamLines: VkBool32,
    smoothLines: VkBool32,
    stippledRectangularLines: VkBool32,
    stippledBresenhamLines: VkBool32,
    stippledSmoothLines: VkBool32,
};
pub const vk.PhysicalDeviceLineRasterizationFeaturesEXT = struct_vk.PhysicalDeviceLineRasterizationFeaturesEXT;
pub const struct_vk.PhysicalDeviceLineRasterizationPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    lineSubPixelPrecisionBits: u32,
};
pub const vk.PhysicalDeviceLineRasterizationPropertiesEXT = struct_vk.PhysicalDeviceLineRasterizationPropertiesEXT;
pub const struct_VkPipelineRasterizationLineStateCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    lineRasterizationMode: VkLineRasterizationModeEXT,
    stippledLineEnable: VkBool32,
    lineStippleFactor: u32,
    lineStipplePattern: u16,
};
pub const VkPipelineRasterizationLineStateCreateInfoEXT = struct_VkPipelineRasterizationLineStateCreateInfoEXT;
pub const PFN_vkCmdSetLineStippleEXT = ?fn (VkCommandBuffer, u32, u16) callconv(.C) void;
pub extern fn vkCmdSetLineStippleEXT(commandBuffer: VkCommandBuffer, lineStippleFactor: u32, lineStipplePattern: u16) void;
pub const struct_vk.PhysicalDeviceShaderAtomicFloatFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderBufferFloat32Atomics: VkBool32,
    shaderBufferFloat32AtomicAdd: VkBool32,
    shaderBufferFloat64Atomics: VkBool32,
    shaderBufferFloat64AtomicAdd: VkBool32,
    shaderSharedFloat32Atomics: VkBool32,
    shaderSharedFloat32AtomicAdd: VkBool32,
    shaderSharedFloat64Atomics: VkBool32,
    shaderSharedFloat64AtomicAdd: VkBool32,
    shaderImageFloat32Atomics: VkBool32,
    shaderImageFloat32AtomicAdd: VkBool32,
    sparseImageFloat32Atomics: VkBool32,
    sparseImageFloat32AtomicAdd: VkBool32,
};
pub const vk.PhysicalDeviceShaderAtomicFloatFeaturesEXT = struct_vk.PhysicalDeviceShaderAtomicFloatFeaturesEXT;
pub const vk.PhysicalDeviceHostQueryResetFeaturesEXT = vk.PhysicalDeviceHostQueryResetFeatures;
pub const PFN_vkResetQueryPoolEXT = ?fn (vk.Device, VkQueryPool, u32, u32) callconv(.C) void;
pub extern fn vkResetQueryPoolEXT(device: vk.Device, queryPool: VkQueryPool, firstQuery: u32, queryCount: u32) void;
pub const struct_vk.PhysicalDeviceIndexTypeUint8FeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    indexTypeUint8: VkBool32,
};
pub const vk.PhysicalDeviceIndexTypeUint8FeaturesEXT = struct_vk.PhysicalDeviceIndexTypeUint8FeaturesEXT;
pub const struct_vk.PhysicalDeviceExtendedDynamicStateFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    extendedDynamicState: VkBool32,
};
pub const vk.PhysicalDeviceExtendedDynamicStateFeaturesEXT = struct_vk.PhysicalDeviceExtendedDynamicStateFeaturesEXT;
pub const PFN_vkCmdSetCullModeEXT = ?fn (VkCommandBuffer, VkCullModeFlags) callconv(.C) void;
pub const PFN_vkCmdSetFrontFaceEXT = ?fn (VkCommandBuffer, VkFrontFace) callconv(.C) void;
pub const PFN_vkCmdSetPrimitiveTopologyEXT = ?fn (VkCommandBuffer, VkPrimitiveTopology) callconv(.C) void;
pub const PFN_vkCmdSetViewportWithCountEXT = ?fn (VkCommandBuffer, u32, [*c]const VkViewport) callconv(.C) void;
pub const PFN_vkCmdSetScissorWithCountEXT = ?fn (VkCommandBuffer, u32, [*c]const VkRect2D) callconv(.C) void;
pub const PFN_vkCmdBindVertexBuffers2EXT = ?fn (VkCommandBuffer, u32, u32, [*c]const VkBuffer, [*c]const vk.DeviceSize, [*c]const vk.DeviceSize, [*c]const vk.DeviceSize) callconv(.C) void;
pub const PFN_vkCmdSetDepthTestEnableEXT = ?fn (VkCommandBuffer, VkBool32) callconv(.C) void;
pub const PFN_vkCmdSetDepthWriteEnableEXT = ?fn (VkCommandBuffer, VkBool32) callconv(.C) void;
pub const PFN_vkCmdSetDepthCompareOpEXT = ?fn (VkCommandBuffer, VkCompareOp) callconv(.C) void;
pub const PFN_vkCmdSetDepthBoundsTestEnableEXT = ?fn (VkCommandBuffer, VkBool32) callconv(.C) void;
pub const PFN_vkCmdSetStencilTestEnableEXT = ?fn (VkCommandBuffer, VkBool32) callconv(.C) void;
pub const PFN_vkCmdSetStencilOpEXT = ?fn (VkCommandBuffer, VkStencilFaceFlags, VkStencilOp, VkStencilOp, VkStencilOp, VkCompareOp) callconv(.C) void;
pub extern fn vkCmdSetCullModeEXT(commandBuffer: VkCommandBuffer, cullMode: VkCullModeFlags) void;
pub extern fn vkCmdSetFrontFaceEXT(commandBuffer: VkCommandBuffer, frontFace: VkFrontFace) void;
pub extern fn vkCmdSetPrimitiveTopologyEXT(commandBuffer: VkCommandBuffer, primitiveTopology: VkPrimitiveTopology) void;
pub extern fn vkCmdSetViewportWithCountEXT(commandBuffer: VkCommandBuffer, viewportCount: u32, pViewports: [*c]const VkViewport) void;
pub extern fn vkCmdSetScissorWithCountEXT(commandBuffer: VkCommandBuffer, scissorCount: u32, pScissors: [*c]const VkRect2D) void;
pub extern fn vkCmdBindVertexBuffers2EXT(commandBuffer: VkCommandBuffer, firstBinding: u32, bindingCount: u32, pBuffers: [*c]const VkBuffer, pOffsets: [*c]const vk.DeviceSize, pSizes: [*c]const vk.DeviceSize, pStrides: [*c]const vk.DeviceSize) void;
pub extern fn vkCmdSetDepthTestEnableEXT(commandBuffer: VkCommandBuffer, depthTestEnable: VkBool32) void;
pub extern fn vkCmdSetDepthWriteEnableEXT(commandBuffer: VkCommandBuffer, depthWriteEnable: VkBool32) void;
pub extern fn vkCmdSetDepthCompareOpEXT(commandBuffer: VkCommandBuffer, depthCompareOp: VkCompareOp) void;
pub extern fn vkCmdSetDepthBoundsTestEnableEXT(commandBuffer: VkCommandBuffer, depthBoundsTestEnable: VkBool32) void;
pub extern fn vkCmdSetStencilTestEnableEXT(commandBuffer: VkCommandBuffer, stencilTestEnable: VkBool32) void;
pub extern fn vkCmdSetStencilOpEXT(commandBuffer: VkCommandBuffer, faceMask: VkStencilFaceFlags, failOp: VkStencilOp, passOp: VkStencilOp, depthFailOp: VkStencilOp, compareOp: VkCompareOp) void;
pub const struct_vk.PhysicalDeviceShaderAtomicFloat2FeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderBufferFloat16Atomics: VkBool32,
    shaderBufferFloat16AtomicAdd: VkBool32,
    shaderBufferFloat16AtomicMinMax: VkBool32,
    shaderBufferFloat32AtomicMinMax: VkBool32,
    shaderBufferFloat64AtomicMinMax: VkBool32,
    shaderSharedFloat16Atomics: VkBool32,
    shaderSharedFloat16AtomicAdd: VkBool32,
    shaderSharedFloat16AtomicMinMax: VkBool32,
    shaderSharedFloat32AtomicMinMax: VkBool32,
    shaderSharedFloat64AtomicMinMax: VkBool32,
    shaderImageFloat32AtomicMinMax: VkBool32,
    sparseImageFloat32AtomicMinMax: VkBool32,
};
pub const vk.PhysicalDeviceShaderAtomicFloat2FeaturesEXT = struct_vk.PhysicalDeviceShaderAtomicFloat2FeaturesEXT;
pub const struct_vk.PhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderDemoteToHelperInvocation: VkBool32,
};
pub const vk.PhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT = struct_vk.PhysicalDeviceShaderDemoteToHelperInvocationFeaturesEXT;
pub const struct_VkIndirectCommandsLayoutNV_T = opaque {};
pub const VkIndirectCommandsLayoutNV = ?*struct_VkIndirectCommandsLayoutNV_T;
pub const VK_INDIRECT_COMMANDS_TOKEN_TYPE_SHADER_GROUP_NV: c_int = 0;
pub const VK_INDIRECT_COMMANDS_TOKEN_TYPE_STATE_FLAGS_NV: c_int = 1;
pub const VK_INDIRECT_COMMANDS_TOKEN_TYPE_INDEX_BUFFER_NV: c_int = 2;
pub const VK_INDIRECT_COMMANDS_TOKEN_TYPE_VERTEX_BUFFER_NV: c_int = 3;
pub const VK_INDIRECT_COMMANDS_TOKEN_TYPE_PUSH_CONSTANT_NV: c_int = 4;
pub const VK_INDIRECT_COMMANDS_TOKEN_TYPE_DRAW_INDEXED_NV: c_int = 5;
pub const VK_INDIRECT_COMMANDS_TOKEN_TYPE_DRAW_NV: c_int = 6;
pub const VK_INDIRECT_COMMANDS_TOKEN_TYPE_DRAW_TASKS_NV: c_int = 7;
pub const VK_INDIRECT_COMMANDS_TOKEN_TYPE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkIndirectCommandsTokenTypeNV = c_uint;
pub const VkIndirectCommandsTokenTypeNV = enum_VkIndirectCommandsTokenTypeNV;
pub const VK_INDIRECT_STATE_FLAG_FRONTFACE_BIT_NV: c_int = 1;
pub const VK_INDIRECT_STATE_FLAG_BITS_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkIndirectStateFlagBitsNV = c_uint;
pub const VkIndirectStateFlagBitsNV = enum_VkIndirectStateFlagBitsNV;
pub const VkIndirectStateFlagsNV = VkFlags;
pub const VK_INDIRECT_COMMANDS_LAYOUT_USAGE_EXPLICIT_PREPROCESS_BIT_NV: c_int = 1;
pub const VK_INDIRECT_COMMANDS_LAYOUT_USAGE_INDEXED_SEQUENCES_BIT_NV: c_int = 2;
pub const VK_INDIRECT_COMMANDS_LAYOUT_USAGE_UNORDERED_SEQUENCES_BIT_NV: c_int = 4;
pub const VK_INDIRECT_COMMANDS_LAYOUT_USAGE_FLAG_BITS_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkIndirectCommandsLayoutUsageFlagBitsNV = c_uint;
pub const VkIndirectCommandsLayoutUsageFlagBitsNV = enum_VkIndirectCommandsLayoutUsageFlagBitsNV;
pub const VkIndirectCommandsLayoutUsageFlagsNV = VkFlags;
pub const struct_vk.PhysicalDeviceDeviceGeneratedCommandsPropertiesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxGraphicsShaderGroupCount: u32,
    maxIndirectSequenceCount: u32,
    maxIndirectCommandsTokenCount: u32,
    maxIndirectCommandsStreamCount: u32,
    maxIndirectCommandsTokenOffset: u32,
    maxIndirectCommandsStreamStride: u32,
    minSequencesCountBufferOffsetAlignment: u32,
    minSequencesIndexBufferOffsetAlignment: u32,
    minIndirectCommandsBufferOffsetAlignment: u32,
};
pub const vk.PhysicalDeviceDeviceGeneratedCommandsPropertiesNV = struct_vk.PhysicalDeviceDeviceGeneratedCommandsPropertiesNV;
pub const struct_vk.PhysicalDeviceDeviceGeneratedCommandsFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    deviceGeneratedCommands: VkBool32,
};
pub const vk.PhysicalDeviceDeviceGeneratedCommandsFeaturesNV = struct_vk.PhysicalDeviceDeviceGeneratedCommandsFeaturesNV;
pub const struct_VkGraphicsShaderGroupCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    stageCount: u32,
    pStages: [*c]const VkPipelineShaderStageCreateInfo,
    pVertexInputState: [*c]const VkPipelineVertexInputStateCreateInfo,
    pTessellationState: [*c]const VkPipelineTessellationStateCreateInfo,
};
pub const VkGraphicsShaderGroupCreateInfoNV = struct_VkGraphicsShaderGroupCreateInfoNV;
pub const struct_VkGraphicsPipelineShaderGroupsCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    groupCount: u32,
    pGroups: [*c]const VkGraphicsShaderGroupCreateInfoNV,
    pipelineCount: u32,
    pPipelines: [*c]const VkPipeline,
};
pub const VkGraphicsPipelineShaderGroupsCreateInfoNV = struct_VkGraphicsPipelineShaderGroupsCreateInfoNV;
pub const struct_VkBindShaderGroupIndirectCommandNV = extern struct {
    groupIndex: u32,
};
pub const VkBindShaderGroupIndirectCommandNV = struct_VkBindShaderGroupIndirectCommandNV;
pub const struct_VkBindIndexBufferIndirectCommandNV = extern struct {
    bufferAddress: vk.DeviceAddress,
    size: u32,
    indexType: VkIndexType,
};
pub const VkBindIndexBufferIndirectCommandNV = struct_VkBindIndexBufferIndirectCommandNV;
pub const struct_VkBindVertexBufferIndirectCommandNV = extern struct {
    bufferAddress: vk.DeviceAddress,
    size: u32,
    stride: u32,
};
pub const VkBindVertexBufferIndirectCommandNV = struct_VkBindVertexBufferIndirectCommandNV;
pub const struct_VkSetStateFlagsIndirectCommandNV = extern struct {
    data: u32,
};
pub const VkSetStateFlagsIndirectCommandNV = struct_VkSetStateFlagsIndirectCommandNV;
pub const struct_VkIndirectCommandsStreamNV = extern struct {
    buffer: VkBuffer,
    offset: vk.DeviceSize,
};
pub const VkIndirectCommandsStreamNV = struct_VkIndirectCommandsStreamNV;
pub const struct_VkIndirectCommandsLayoutTokenNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    tokenType: VkIndirectCommandsTokenTypeNV,
    stream: u32,
    offset: u32,
    vertexBindingUnit: u32,
    vertexDynamicStride: VkBool32,
    pushconstantPipelineLayout: VkPipelineLayout,
    pushconstantShaderStageFlags: VkShaderStageFlags,
    pushconstantOffset: u32,
    pushconstantSize: u32,
    indirectStateFlags: VkIndirectStateFlagsNV,
    indexTypeCount: u32,
    pIndexTypes: [*c]const VkIndexType,
    pIndexTypeValues: [*c]const u32,
};
pub const VkIndirectCommandsLayoutTokenNV = struct_VkIndirectCommandsLayoutTokenNV;
pub const struct_VkIndirectCommandsLayoutCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkIndirectCommandsLayoutUsageFlagsNV,
    pipelineBindPoint: VkPipelineBindPoint,
    tokenCount: u32,
    pTokens: [*c]const VkIndirectCommandsLayoutTokenNV,
    streamCount: u32,
    pStreamStrides: [*c]const u32,
};
pub const VkIndirectCommandsLayoutCreateInfoNV = struct_VkIndirectCommandsLayoutCreateInfoNV;
pub const struct_VkGeneratedCommandsInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pipelineBindPoint: VkPipelineBindPoint,
    pipeline: VkPipeline,
    indirectCommandsLayout: VkIndirectCommandsLayoutNV,
    streamCount: u32,
    pStreams: [*c]const VkIndirectCommandsStreamNV,
    sequencesCount: u32,
    preprocessBuffer: VkBuffer,
    preprocessOffset: vk.DeviceSize,
    preprocessSize: vk.DeviceSize,
    sequencesCountBuffer: VkBuffer,
    sequencesCountOffset: vk.DeviceSize,
    sequencesIndexBuffer: VkBuffer,
    sequencesIndexOffset: vk.DeviceSize,
};
pub const VkGeneratedCommandsInfoNV = struct_VkGeneratedCommandsInfoNV;
pub const struct_VkGeneratedCommandsMemoryRequirementsInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pipelineBindPoint: VkPipelineBindPoint,
    pipeline: VkPipeline,
    indirectCommandsLayout: VkIndirectCommandsLayoutNV,
    maxSequencesCount: u32,
};
pub const VkGeneratedCommandsMemoryRequirementsInfoNV = struct_VkGeneratedCommandsMemoryRequirementsInfoNV;
pub const PFN_vkGetGeneratedCommandsMemoryRequirementsNV = ?fn (vk.Device, [*c]const VkGeneratedCommandsMemoryRequirementsInfoNV, [*c]VkMemoryRequirements2) callconv(.C) void;
pub const PFN_vkCmdPreprocessGeneratedCommandsNV = ?fn (VkCommandBuffer, [*c]const VkGeneratedCommandsInfoNV) callconv(.C) void;
pub const PFN_vkCmdExecuteGeneratedCommandsNV = ?fn (VkCommandBuffer, VkBool32, [*c]const VkGeneratedCommandsInfoNV) callconv(.C) void;
pub const PFN_vkCmdBindPipelineShaderGroupNV = ?fn (VkCommandBuffer, VkPipelineBindPoint, VkPipeline, u32) callconv(.C) void;
pub const PFN_vkCreateIndirectCommandsLayoutNV = ?fn (vk.Device, [*c]const VkIndirectCommandsLayoutCreateInfoNV, [*c]const VkAllocationCallbacks, [*c]VkIndirectCommandsLayoutNV) callconv(.C) VkResult;
pub const PFN_vkDestroyIndirectCommandsLayoutNV = ?fn (vk.Device, VkIndirectCommandsLayoutNV, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub extern fn vkGetGeneratedCommandsMemoryRequirementsNV(device: vk.Device, pInfo: [*c]const VkGeneratedCommandsMemoryRequirementsInfoNV, pMemoryRequirements: [*c]VkMemoryRequirements2) void;
pub extern fn vkCmdPreprocessGeneratedCommandsNV(commandBuffer: VkCommandBuffer, pGeneratedCommandsInfo: [*c]const VkGeneratedCommandsInfoNV) void;
pub extern fn vkCmdExecuteGeneratedCommandsNV(commandBuffer: VkCommandBuffer, isPreprocessed: VkBool32, pGeneratedCommandsInfo: [*c]const VkGeneratedCommandsInfoNV) void;
pub extern fn vkCmdBindPipelineShaderGroupNV(commandBuffer: VkCommandBuffer, pipelineBindPoint: VkPipelineBindPoint, pipeline: VkPipeline, groupIndex: u32) void;
pub extern fn vkCreateIndirectCommandsLayoutNV(device: vk.Device, pCreateInfo: [*c]const VkIndirectCommandsLayoutCreateInfoNV, pAllocator: [*c]const VkAllocationCallbacks, pIndirectCommandsLayout: [*c]VkIndirectCommandsLayoutNV) VkResult;
pub extern fn vkDestroyIndirectCommandsLayoutNV(device: vk.Device, indirectCommandsLayout: VkIndirectCommandsLayoutNV, pAllocator: [*c]const VkAllocationCallbacks) void;
pub const struct_vk.PhysicalDeviceInheritedViewportScissorFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    inheritedViewportScissor2D: VkBool32,
};
pub const vk.PhysicalDeviceInheritedViewportScissorFeaturesNV = struct_vk.PhysicalDeviceInheritedViewportScissorFeaturesNV;
pub const struct_VkCommandBufferInheritanceViewportScissorInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    viewportScissor2D: VkBool32,
    viewportDepthCount: u32,
    pViewportDepths: [*c]const VkViewport,
};
pub const VkCommandBufferInheritanceViewportScissorInfoNV = struct_VkCommandBufferInheritanceViewportScissorInfoNV;
pub const struct_vk.PhysicalDeviceTexelBufferAlignmentFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    texelBufferAlignment: VkBool32,
};
pub const vk.PhysicalDeviceTexelBufferAlignmentFeaturesEXT = struct_vk.PhysicalDeviceTexelBufferAlignmentFeaturesEXT;
pub const struct_vk.PhysicalDeviceTexelBufferAlignmentPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    storageTexelBufferOffsetAlignmentBytes: vk.DeviceSize,
    storageTexelBufferOffsetSingleTexelAlignment: VkBool32,
    uniformTexelBufferOffsetAlignmentBytes: vk.DeviceSize,
    uniformTexelBufferOffsetSingleTexelAlignment: VkBool32,
};
pub const vk.PhysicalDeviceTexelBufferAlignmentPropertiesEXT = struct_vk.PhysicalDeviceTexelBufferAlignmentPropertiesEXT;
pub const struct_VkRenderPassTransformBeginInfoQCOM = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    transform: VkSurfaceTransformFlagBitsKHR,
};
pub const VkRenderPassTransformBeginInfoQCOM = struct_VkRenderPassTransformBeginInfoQCOM;
pub const struct_VkCommandBufferInheritanceRenderPassTransformInfoQCOM = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    transform: VkSurfaceTransformFlagBitsKHR,
    renderArea: VkRect2D,
};
pub const VkCommandBufferInheritanceRenderPassTransformInfoQCOM = struct_VkCommandBufferInheritanceRenderPassTransformInfoQCOM;
pub const VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_ALLOCATE_EXT: c_int = 0;
pub const VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_FREE_EXT: c_int = 1;
pub const VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_IMPORT_EXT: c_int = 2;
pub const VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_UNIMPORT_EXT: c_int = 3;
pub const VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_ALLOCATION_FAILED_EXT: c_int = 4;
pub const VK_DEVICE_MEMORY_REPORT_EVENT_TYPE_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_vk.DeviceMemoryReportEventTypeEXT = c_uint;
pub const vk.DeviceMemoryReportEventTypeEXT = enum_vk.DeviceMemoryReportEventTypeEXT;
pub const vk.DeviceMemoryReportFlagsEXT = VkFlags;
pub const struct_vk.PhysicalDeviceDeviceMemoryReportFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    deviceMemoryReport: VkBool32,
};
pub const vk.PhysicalDeviceDeviceMemoryReportFeaturesEXT = struct_vk.PhysicalDeviceDeviceMemoryReportFeaturesEXT;
pub const struct_vk.DeviceMemoryReportCallbackDataEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    flags: vk.DeviceMemoryReportFlagsEXT,
    type: vk.DeviceMemoryReportEventTypeEXT,
    memoryObjectId: u64,
    size: vk.DeviceSize,
    objectType: VkObjectType,
    objectHandle: u64,
    heapIndex: u32,
};
pub const vk.DeviceMemoryReportCallbackDataEXT = struct_vk.DeviceMemoryReportCallbackDataEXT;
pub const PFN_vk.DeviceMemoryReportCallbackEXT = ?fn ([*c]const vk.DeviceMemoryReportCallbackDataEXT, ?*anyopaque) callconv(.C) void;
pub const struct_vk.DeviceDeviceMemoryReportCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: vk.DeviceMemoryReportFlagsEXT,
    pfnUserCallback: PFN_vk.DeviceMemoryReportCallbackEXT,
    pUserData: ?*anyopaque,
};
pub const vk.DeviceDeviceMemoryReportCreateInfoEXT = struct_vk.DeviceDeviceMemoryReportCreateInfoEXT;
pub const PFN_vkAcquireDrmDisplayEXT = ?fn (vk.PhysicalDevice, i32, VkDisplayKHR) callconv(.C) VkResult;
pub const PFN_vkGetDrmDisplayEXT = ?fn (vk.PhysicalDevice, i32, u32, [*c]VkDisplayKHR) callconv(.C) VkResult;
pub extern fn vkAcquireDrmDisplayEXT(physicalDevice: vk.PhysicalDevice, drmFd: i32, display: VkDisplayKHR) VkResult;
pub extern fn vkGetDrmDisplayEXT(physicalDevice: vk.PhysicalDevice, drmFd: i32, connectorId: u32, display: [*c]VkDisplayKHR) VkResult;
pub const struct_vk.PhysicalDeviceRobustness2FeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    robustBufferAccess2: VkBool32,
    robustImageAccess2: VkBool32,
    nullDescriptor: VkBool32,
};
pub const vk.PhysicalDeviceRobustness2FeaturesEXT = struct_vk.PhysicalDeviceRobustness2FeaturesEXT;
pub const struct_vk.PhysicalDeviceRobustness2PropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    robustStorageBufferAccessSizeAlignment: vk.DeviceSize,
    robustUniformBufferAccessSizeAlignment: vk.DeviceSize,
};
pub const vk.PhysicalDeviceRobustness2PropertiesEXT = struct_vk.PhysicalDeviceRobustness2PropertiesEXT;
pub const struct_VkSamplerCustomBorderColorCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    customBorderColor: VkClearColorValue,
    format: VkFormat,
};
pub const VkSamplerCustomBorderColorCreateInfoEXT = struct_VkSamplerCustomBorderColorCreateInfoEXT;
pub const struct_vk.PhysicalDeviceCustomBorderColorPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxCustomBorderColorSamplers: u32,
};
pub const vk.PhysicalDeviceCustomBorderColorPropertiesEXT = struct_vk.PhysicalDeviceCustomBorderColorPropertiesEXT;
pub const struct_vk.PhysicalDeviceCustomBorderColorFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    customBorderColors: VkBool32,
    customBorderColorWithoutFormat: VkBool32,
};
pub const vk.PhysicalDeviceCustomBorderColorFeaturesEXT = struct_vk.PhysicalDeviceCustomBorderColorFeaturesEXT;
pub const struct_VkPrivateDataSlotEXT_T = opaque {};
pub const VkPrivateDataSlotEXT = ?*struct_VkPrivateDataSlotEXT_T;
pub const VK_PRIVATE_DATA_SLOT_CREATE_FLAG_BITS_MAX_ENUM_EXT: c_int = 2147483647;
pub const enum_VkPrivateDataSlotCreateFlagBitsEXT = c_uint;
pub const VkPrivateDataSlotCreateFlagBitsEXT = enum_VkPrivateDataSlotCreateFlagBitsEXT;
pub const VkPrivateDataSlotCreateFlagsEXT = VkFlags;
pub const struct_vk.PhysicalDevicePrivateDataFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    privateData: VkBool32,
};
pub const vk.PhysicalDevicePrivateDataFeaturesEXT = struct_vk.PhysicalDevicePrivateDataFeaturesEXT;
pub const struct_vk.DevicePrivateDataCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    privateDataSlotRequestCount: u32,
};
pub const vk.DevicePrivateDataCreateInfoEXT = struct_vk.DevicePrivateDataCreateInfoEXT;
pub const struct_VkPrivateDataSlotCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPrivateDataSlotCreateFlagsEXT,
};
pub const VkPrivateDataSlotCreateInfoEXT = struct_VkPrivateDataSlotCreateInfoEXT;
pub const PFN_vkCreatePrivateDataSlotEXT = ?fn (vk.Device, [*c]const VkPrivateDataSlotCreateInfoEXT, [*c]const VkAllocationCallbacks, [*c]VkPrivateDataSlotEXT) callconv(.C) VkResult;
pub const PFN_vkDestroyPrivateDataSlotEXT = ?fn (vk.Device, VkPrivateDataSlotEXT, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkSetPrivateDataEXT = ?fn (vk.Device, VkObjectType, u64, VkPrivateDataSlotEXT, u64) callconv(.C) VkResult;
pub const PFN_vkGetPrivateDataEXT = ?fn (vk.Device, VkObjectType, u64, VkPrivateDataSlotEXT, [*c]u64) callconv(.C) void;
pub extern fn vkCreatePrivateDataSlotEXT(device: vk.Device, pCreateInfo: [*c]const VkPrivateDataSlotCreateInfoEXT, pAllocator: [*c]const VkAllocationCallbacks, pPrivateDataSlot: [*c]VkPrivateDataSlotEXT) VkResult;
pub extern fn vkDestroyPrivateDataSlotEXT(device: vk.Device, privateDataSlot: VkPrivateDataSlotEXT, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkSetPrivateDataEXT(device: vk.Device, objectType: VkObjectType, objectHandle: u64, privateDataSlot: VkPrivateDataSlotEXT, data: u64) VkResult;
pub extern fn vkGetPrivateDataEXT(device: vk.Device, objectType: VkObjectType, objectHandle: u64, privateDataSlot: VkPrivateDataSlotEXT, pData: [*c]u64) void;
pub const struct_vk.PhysicalDevicePipelineCreationCacheControlFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    pipelineCreationCacheControl: VkBool32,
};
pub const vk.PhysicalDevicePipelineCreationCacheControlFeaturesEXT = struct_vk.PhysicalDevicePipelineCreationCacheControlFeaturesEXT;
pub const VK_DEVICE_DIAGNOSTICS_CONFIG_ENABLE_SHADER_DEBUG_INFO_BIT_NV: c_int = 1;
pub const VK_DEVICE_DIAGNOSTICS_CONFIG_ENABLE_RESOURCE_TRACKING_BIT_NV: c_int = 2;
pub const VK_DEVICE_DIAGNOSTICS_CONFIG_ENABLE_AUTOMATIC_CHECKPOINTS_BIT_NV: c_int = 4;
pub const VK_DEVICE_DIAGNOSTICS_CONFIG_FLAG_BITS_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_vk.DeviceDiagnosticsConfigFlagBitsNV = c_uint;
pub const vk.DeviceDiagnosticsConfigFlagBitsNV = enum_vk.DeviceDiagnosticsConfigFlagBitsNV;
pub const vk.DeviceDiagnosticsConfigFlagsNV = VkFlags;
pub const struct_vk.PhysicalDeviceDiagnosticsConfigFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    diagnosticsConfig: VkBool32,
};
pub const vk.PhysicalDeviceDiagnosticsConfigFeaturesNV = struct_vk.PhysicalDeviceDiagnosticsConfigFeaturesNV;
pub const struct_vk.DeviceDiagnosticsConfigCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: vk.DeviceDiagnosticsConfigFlagsNV,
};
pub const vk.DeviceDiagnosticsConfigCreateInfoNV = struct_vk.DeviceDiagnosticsConfigCreateInfoNV;
pub const VK_FRAGMENT_SHADING_RATE_TYPE_FRAGMENT_SIZE_NV: c_int = 0;
pub const VK_FRAGMENT_SHADING_RATE_TYPE_ENUMS_NV: c_int = 1;
pub const VK_FRAGMENT_SHADING_RATE_TYPE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkFragmentShadingRateTypeNV = c_uint;
pub const VkFragmentShadingRateTypeNV = enum_VkFragmentShadingRateTypeNV;
pub const VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_PIXEL_NV: c_int = 0;
pub const VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_1X2_PIXELS_NV: c_int = 1;
pub const VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_2X1_PIXELS_NV: c_int = 4;
pub const VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_2X2_PIXELS_NV: c_int = 5;
pub const VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_2X4_PIXELS_NV: c_int = 6;
pub const VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_4X2_PIXELS_NV: c_int = 9;
pub const VK_FRAGMENT_SHADING_RATE_1_INVOCATION_PER_4X4_PIXELS_NV: c_int = 10;
pub const VK_FRAGMENT_SHADING_RATE_2_INVOCATIONS_PER_PIXEL_NV: c_int = 11;
pub const VK_FRAGMENT_SHADING_RATE_4_INVOCATIONS_PER_PIXEL_NV: c_int = 12;
pub const VK_FRAGMENT_SHADING_RATE_8_INVOCATIONS_PER_PIXEL_NV: c_int = 13;
pub const VK_FRAGMENT_SHADING_RATE_16_INVOCATIONS_PER_PIXEL_NV: c_int = 14;
pub const VK_FRAGMENT_SHADING_RATE_NO_INVOCATIONS_NV: c_int = 15;
pub const VK_FRAGMENT_SHADING_RATE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkFragmentShadingRateNV = c_uint;
pub const VkFragmentShadingRateNV = enum_VkFragmentShadingRateNV;
pub const struct_vk.PhysicalDeviceFragmentShadingRateEnumsFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    fragmentShadingRateEnums: VkBool32,
    supersampleFragmentShadingRates: VkBool32,
    noInvocationFragmentShadingRates: VkBool32,
};
pub const vk.PhysicalDeviceFragmentShadingRateEnumsFeaturesNV = struct_vk.PhysicalDeviceFragmentShadingRateEnumsFeaturesNV;
pub const struct_vk.PhysicalDeviceFragmentShadingRateEnumsPropertiesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxFragmentShadingRateInvocationCount: VkSampleCountFlagBits,
};
pub const vk.PhysicalDeviceFragmentShadingRateEnumsPropertiesNV = struct_vk.PhysicalDeviceFragmentShadingRateEnumsPropertiesNV;
pub const struct_VkPipelineFragmentShadingRateEnumStateCreateInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    shadingRateType: VkFragmentShadingRateTypeNV,
    shadingRate: VkFragmentShadingRateNV,
    combinerOps: [2]VkFragmentShadingRateCombinerOpKHR,
};
pub const VkPipelineFragmentShadingRateEnumStateCreateInfoNV = struct_VkPipelineFragmentShadingRateEnumStateCreateInfoNV;
pub const PFN_vkCmdSetFragmentShadingRateEnumNV = ?fn (VkCommandBuffer, VkFragmentShadingRateNV, [*c]const VkFragmentShadingRateCombinerOpKHR) callconv(.C) void;
pub extern fn vkCmdSetFragmentShadingRateEnumNV(commandBuffer: VkCommandBuffer, shadingRate: VkFragmentShadingRateNV, combinerOps: [*c]const VkFragmentShadingRateCombinerOpKHR) void;
pub const VK_ACCELERATION_STRUCTURE_MOTION_INSTANCE_TYPE_STATIC_NV: c_int = 0;
pub const VK_ACCELERATION_STRUCTURE_MOTION_INSTANCE_TYPE_MATRIX_MOTION_NV: c_int = 1;
pub const VK_ACCELERATION_STRUCTURE_MOTION_INSTANCE_TYPE_SRT_MOTION_NV: c_int = 2;
pub const VK_ACCELERATION_STRUCTURE_MOTION_INSTANCE_TYPE_MAX_ENUM_NV: c_int = 2147483647;
pub const enum_VkAccelerationStructureMotionInstanceTypeNV = c_uint;
pub const VkAccelerationStructureMotionInstanceTypeNV = enum_VkAccelerationStructureMotionInstanceTypeNV;
pub const VkAccelerationStructureMotionInfoFlagsNV = VkFlags;
pub const VkAccelerationStructureMotionInstanceFlagsNV = VkFlags;
pub const union_vk.DeviceOrHostAddressConstKHR = extern union {
    deviceAddress: vk.DeviceAddress,
    hostAddress: ?*const anyopaque,
};
pub const vk.DeviceOrHostAddressConstKHR = union_vk.DeviceOrHostAddressConstKHR;
pub const struct_VkAccelerationStructureGeometryMotionTrianglesDataNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    vertexData: vk.DeviceOrHostAddressConstKHR,
};
pub const VkAccelerationStructureGeometryMotionTrianglesDataNV = struct_VkAccelerationStructureGeometryMotionTrianglesDataNV;
pub const struct_VkAccelerationStructureMotionInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    maxInstances: u32,
    flags: VkAccelerationStructureMotionInfoFlagsNV,
};
pub const VkAccelerationStructureMotionInfoNV = struct_VkAccelerationStructureMotionInfoNV; // /Users/desaro/zig-vulkan/libs/mach-glfw/upstream/vulkan_headers/include/vulkan/vulkan_core.h:12644:35: warning: struct demoted to opaque type - has bitfield
pub const struct_VkAccelerationStructureMatrixMotionInstanceNV = opaque {};
pub const VkAccelerationStructureMatrixMotionInstanceNV = struct_VkAccelerationStructureMatrixMotionInstanceNV;
pub const struct_VkSRTDataNV = extern struct {
    sx: f32,
    a: f32,
    b: f32,
    pvx: f32,
    sy: f32,
    c: f32,
    pvy: f32,
    sz: f32,
    pvz: f32,
    qx: f32,
    qy: f32,
    qz: f32,
    qw: f32,
    tx: f32,
    ty: f32,
    tz: f32,
};
pub const VkSRTDataNV = struct_VkSRTDataNV; // /Users/desaro/zig-vulkan/libs/mach-glfw/upstream/vulkan_headers/include/vulkan/vulkan_core.h:12673:35: warning: struct demoted to opaque type - has bitfield
pub const struct_VkAccelerationStructureSRTMotionInstanceNV = opaque {};
pub const VkAccelerationStructureSRTMotionInstanceNV = struct_VkAccelerationStructureSRTMotionInstanceNV;
pub const union_VkAccelerationStructureMotionInstanceDataNV = extern union {
    staticInstance: VkAccelerationStructureInstanceKHR,
    matrixMotionInstance: VkAccelerationStructureMatrixMotionInstanceNV,
    srtMotionInstance: VkAccelerationStructureSRTMotionInstanceNV,
};
pub const VkAccelerationStructureMotionInstanceDataNV = union_VkAccelerationStructureMotionInstanceDataNV;
pub const struct_VkAccelerationStructureMotionInstanceNV = extern struct {
    type: VkAccelerationStructureMotionInstanceTypeNV,
    flags: VkAccelerationStructureMotionInstanceFlagsNV,
    data: VkAccelerationStructureMotionInstanceDataNV,
};
pub const VkAccelerationStructureMotionInstanceNV = struct_VkAccelerationStructureMotionInstanceNV;
pub const struct_vk.PhysicalDeviceRayTracingMotionBlurFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    rayTracingMotionBlur: VkBool32,
    rayTracingMotionBlurPipelineTraceRaysIndirect: VkBool32,
};
pub const vk.PhysicalDeviceRayTracingMotionBlurFeaturesNV = struct_vk.PhysicalDeviceRayTracingMotionBlurFeaturesNV;
pub const struct_vk.PhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    ycbcr2plane444Formats: VkBool32,
};
pub const vk.PhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT = struct_vk.PhysicalDeviceYcbcr2Plane444FormatsFeaturesEXT;
pub const struct_vk.PhysicalDeviceFragmentDensityMap2FeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    fragmentDensityMapDeferred: VkBool32,
};
pub const vk.PhysicalDeviceFragmentDensityMap2FeaturesEXT = struct_vk.PhysicalDeviceFragmentDensityMap2FeaturesEXT;
pub const struct_vk.PhysicalDeviceFragmentDensityMap2PropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    subsampledLoads: VkBool32,
    subsampledCoarseReconstructionEarlyAccess: VkBool32,
    maxSubsampledArrayLayers: u32,
    maxDescriptorSetSubsampledSamplers: u32,
};
pub const vk.PhysicalDeviceFragmentDensityMap2PropertiesEXT = struct_vk.PhysicalDeviceFragmentDensityMap2PropertiesEXT;
pub const struct_VkCopyCommandTransformInfoQCOM = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    transform: VkSurfaceTransformFlagBitsKHR,
};
pub const VkCopyCommandTransformInfoQCOM = struct_VkCopyCommandTransformInfoQCOM;
pub const struct_vk.PhysicalDeviceImageRobustnessFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    robustImageAccess: VkBool32,
};
pub const vk.PhysicalDeviceImageRobustnessFeaturesEXT = struct_vk.PhysicalDeviceImageRobustnessFeaturesEXT;
pub const struct_vk.PhysicalDevice4444FormatsFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    formatA4R4G4B4: VkBool32,
    formatA4B4G4R4: VkBool32,
};
pub const vk.PhysicalDevice4444FormatsFeaturesEXT = struct_vk.PhysicalDevice4444FormatsFeaturesEXT;
pub const struct_vk.PhysicalDeviceRasterizationOrderAttachmentAccessFeaturesARM = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    rasterizationOrderColorAttachmentAccess: VkBool32,
    rasterizationOrderDepthAttachmentAccess: VkBool32,
    rasterizationOrderStencilAttachmentAccess: VkBool32,
};
pub const vk.PhysicalDeviceRasterizationOrderAttachmentAccessFeaturesARM = struct_vk.PhysicalDeviceRasterizationOrderAttachmentAccessFeaturesARM;
pub const struct_vk.PhysicalDeviceRGBA10X6FormatsFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    formatRgba10x6WithoutYCbCrSampler: VkBool32,
};
pub const vk.PhysicalDeviceRGBA10X6FormatsFeaturesEXT = struct_vk.PhysicalDeviceRGBA10X6FormatsFeaturesEXT;
pub const PFN_vkAcquireWinrtDisplayNV = ?fn (vk.PhysicalDevice, VkDisplayKHR) callconv(.C) VkResult;
pub const PFN_vkGetWinrtDisplayNV = ?fn (vk.PhysicalDevice, u32, [*c]VkDisplayKHR) callconv(.C) VkResult;
pub extern fn vkAcquireWinrtDisplayNV(physicalDevice: vk.PhysicalDevice, display: VkDisplayKHR) VkResult;
pub extern fn vkGetWinrtDisplayNV(physicalDevice: vk.PhysicalDevice, deviceRelativeId: u32, pDisplay: [*c]VkDisplayKHR) VkResult;
pub const struct_vk.PhysicalDeviceMutableDescriptorTypeFeaturesVALVE = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    mutableDescriptorType: VkBool32,
};
pub const vk.PhysicalDeviceMutableDescriptorTypeFeaturesVALVE = struct_vk.PhysicalDeviceMutableDescriptorTypeFeaturesVALVE;
pub const struct_VkMutableDescriptorTypeListVALVE = extern struct {
    descriptorTypeCount: u32,
    pDescriptorTypes: [*c]const VkDescriptorType,
};
pub const VkMutableDescriptorTypeListVALVE = struct_VkMutableDescriptorTypeListVALVE;
pub const struct_VkMutableDescriptorTypeCreateInfoVALVE = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    mutableDescriptorTypeListCount: u32,
    pMutableDescriptorTypeLists: [*c]const VkMutableDescriptorTypeListVALVE,
};
pub const VkMutableDescriptorTypeCreateInfoVALVE = struct_VkMutableDescriptorTypeCreateInfoVALVE;
pub const struct_vk.PhysicalDeviceVertexInputDynamicStateFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    vertexInputDynamicState: VkBool32,
};
pub const vk.PhysicalDeviceVertexInputDynamicStateFeaturesEXT = struct_vk.PhysicalDeviceVertexInputDynamicStateFeaturesEXT;
pub const struct_VkVertexInputBindingDescription2EXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    binding: u32,
    stride: u32,
    inputRate: VkVertexInputRate,
    divisor: u32,
};
pub const VkVertexInputBindingDescription2EXT = struct_VkVertexInputBindingDescription2EXT;
pub const struct_VkVertexInputAttributeDescription2EXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    location: u32,
    binding: u32,
    format: VkFormat,
    offset: u32,
};
pub const VkVertexInputAttributeDescription2EXT = struct_VkVertexInputAttributeDescription2EXT;
pub const PFN_vkCmdSetVertexInputEXT = ?fn (VkCommandBuffer, u32, [*c]const VkVertexInputBindingDescription2EXT, u32, [*c]const VkVertexInputAttributeDescription2EXT) callconv(.C) void;
pub extern fn vkCmdSetVertexInputEXT(commandBuffer: VkCommandBuffer, vertexBindingDescriptionCount: u32, pVertexBindingDescriptions: [*c]const VkVertexInputBindingDescription2EXT, vertexAttributeDescriptionCount: u32, pVertexAttributeDescriptions: [*c]const VkVertexInputAttributeDescription2EXT) void;
pub const struct_vk.PhysicalDeviceDrmPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    hasPrimary: VkBool32,
    hasRender: VkBool32,
    primaryMajor: i64,
    primaryMinor: i64,
    renderMajor: i64,
    renderMinor: i64,
};
pub const vk.PhysicalDeviceDrmPropertiesEXT = struct_vk.PhysicalDeviceDrmPropertiesEXT;
pub const struct_vk.PhysicalDeviceDepthClipControlFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    depthClipControl: VkBool32,
};
pub const vk.PhysicalDeviceDepthClipControlFeaturesEXT = struct_vk.PhysicalDeviceDepthClipControlFeaturesEXT;
pub const struct_VkPipelineViewportDepthClipControlCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    negativeOneToOne: VkBool32,
};
pub const VkPipelineViewportDepthClipControlCreateInfoEXT = struct_VkPipelineViewportDepthClipControlCreateInfoEXT;
pub const struct_vk.PhysicalDevicePrimitiveTopologyListRestartFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    primitiveTopologyListRestart: VkBool32,
    primitiveTopologyPatchListRestart: VkBool32,
};
pub const vk.PhysicalDevicePrimitiveTopologyListRestartFeaturesEXT = struct_vk.PhysicalDevicePrimitiveTopologyListRestartFeaturesEXT;
pub const struct_VkSubpassShadingPipelineCreateInfoHUAWEI = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    renderPass: VkRenderPass,
    subpass: u32,
};
pub const VkSubpassShadingPipelineCreateInfoHUAWEI = struct_VkSubpassShadingPipelineCreateInfoHUAWEI;
pub const struct_vk.PhysicalDeviceSubpassShadingFeaturesHUAWEI = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    subpassShading: VkBool32,
};
pub const vk.PhysicalDeviceSubpassShadingFeaturesHUAWEI = struct_vk.PhysicalDeviceSubpassShadingFeaturesHUAWEI;
pub const struct_vk.PhysicalDeviceSubpassShadingPropertiesHUAWEI = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxSubpassShadingWorkgroupSizeAspectRatio: u32,
};
pub const vk.PhysicalDeviceSubpassShadingPropertiesHUAWEI = struct_vk.PhysicalDeviceSubpassShadingPropertiesHUAWEI;
pub const PFN_vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI = ?fn (vk.Device, VkRenderPass, [*c]VkExtent2D) callconv(.C) VkResult;
pub const PFN_vkCmdSubpassShadingHUAWEI = ?fn (VkCommandBuffer) callconv(.C) void;
pub extern fn vkGetDeviceSubpassShadingMaxWorkgroupSizeHUAWEI(device: vk.Device, renderpass: VkRenderPass, pMaxWorkgroupSize: [*c]VkExtent2D) VkResult;
pub extern fn vkCmdSubpassShadingHUAWEI(commandBuffer: VkCommandBuffer) void;
pub const struct_vk.PhysicalDeviceInvocationMaskFeaturesHUAWEI = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    invocationMask: VkBool32,
};
pub const vk.PhysicalDeviceInvocationMaskFeaturesHUAWEI = struct_vk.PhysicalDeviceInvocationMaskFeaturesHUAWEI;
pub const PFN_vkCmdBindInvocationMaskHUAWEI = ?fn (VkCommandBuffer, VkImageView, VkImageLayout) callconv(.C) void;
pub extern fn vkCmdBindInvocationMaskHUAWEI(commandBuffer: VkCommandBuffer, imageView: VkImageView, imageLayout: VkImageLayout) void;
pub const VkRemoteAddressNV = ?*anyopaque;
pub const struct_VkMemoryGetRemoteAddressInfoNV = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    memory: vk.DeviceMemory,
    handleType: VkExternalMemoryHandleTypeFlagBits,
};
pub const VkMemoryGetRemoteAddressInfoNV = struct_VkMemoryGetRemoteAddressInfoNV;
pub const struct_vk.PhysicalDeviceExternalMemoryRDMAFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    externalMemoryRDMA: VkBool32,
};
pub const vk.PhysicalDeviceExternalMemoryRDMAFeaturesNV = struct_vk.PhysicalDeviceExternalMemoryRDMAFeaturesNV;
pub const PFN_vkGetMemoryRemoteAddressNV = ?fn (vk.Device, [*c]const VkMemoryGetRemoteAddressInfoNV, [*c]VkRemoteAddressNV) callconv(.C) VkResult;
pub extern fn vkGetMemoryRemoteAddressNV(device: vk.Device, pMemoryGetRemoteAddressInfo: [*c]const VkMemoryGetRemoteAddressInfoNV, pAddress: [*c]VkRemoteAddressNV) VkResult;
pub const struct_vk.PhysicalDeviceExtendedDynamicState2FeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    extendedDynamicState2: VkBool32,
    extendedDynamicState2LogicOp: VkBool32,
    extendedDynamicState2PatchControlPoints: VkBool32,
};
pub const vk.PhysicalDeviceExtendedDynamicState2FeaturesEXT = struct_vk.PhysicalDeviceExtendedDynamicState2FeaturesEXT;
pub const PFN_vkCmdSetPatchControlPointsEXT = ?fn (VkCommandBuffer, u32) callconv(.C) void;
pub const PFN_vkCmdSetRasterizerDiscardEnableEXT = ?fn (VkCommandBuffer, VkBool32) callconv(.C) void;
pub const PFN_vkCmdSetDepthBiasEnableEXT = ?fn (VkCommandBuffer, VkBool32) callconv(.C) void;
pub const PFN_vkCmdSetLogicOpEXT = ?fn (VkCommandBuffer, VkLogicOp) callconv(.C) void;
pub const PFN_vkCmdSetPrimitiveRestartEnableEXT = ?fn (VkCommandBuffer, VkBool32) callconv(.C) void;
pub extern fn vkCmdSetPatchControlPointsEXT(commandBuffer: VkCommandBuffer, patchControlPoints: u32) void;
pub extern fn vkCmdSetRasterizerDiscardEnableEXT(commandBuffer: VkCommandBuffer, rasterizerDiscardEnable: VkBool32) void;
pub extern fn vkCmdSetDepthBiasEnableEXT(commandBuffer: VkCommandBuffer, depthBiasEnable: VkBool32) void;
pub extern fn vkCmdSetLogicOpEXT(commandBuffer: VkCommandBuffer, logicOp: VkLogicOp) void;
pub extern fn vkCmdSetPrimitiveRestartEnableEXT(commandBuffer: VkCommandBuffer, primitiveRestartEnable: VkBool32) void;
pub const struct_vk.PhysicalDeviceColorWriteEnableFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    colorWriteEnable: VkBool32,
};
pub const vk.PhysicalDeviceColorWriteEnableFeaturesEXT = struct_vk.PhysicalDeviceColorWriteEnableFeaturesEXT;
pub const struct_VkPipelineColorWriteCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    attachmentCount: u32,
    pColorWriteEnables: [*c]const VkBool32,
};
pub const VkPipelineColorWriteCreateInfoEXT = struct_VkPipelineColorWriteCreateInfoEXT;
pub const PFN_vkCmdSetColorWriteEnableEXT = ?fn (VkCommandBuffer, u32, [*c]const VkBool32) callconv(.C) void;
pub extern fn vkCmdSetColorWriteEnableEXT(commandBuffer: VkCommandBuffer, attachmentCount: u32, pColorWriteEnables: [*c]const VkBool32) void;
pub const struct_vk.PhysicalDeviceGlobalPriorityQueryFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    globalPriorityQuery: VkBool32,
};
pub const vk.PhysicalDeviceGlobalPriorityQueryFeaturesEXT = struct_vk.PhysicalDeviceGlobalPriorityQueryFeaturesEXT;
pub const struct_VkQueueFamilyGlobalPriorityPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    priorityCount: u32,
    priorities: [16]VkQueueGlobalPriorityEXT,
};
pub const VkQueueFamilyGlobalPriorityPropertiesEXT = struct_VkQueueFamilyGlobalPriorityPropertiesEXT;
pub const struct_vk.PhysicalDeviceImageViewMinLodFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    minLod: VkBool32,
};
pub const vk.PhysicalDeviceImageViewMinLodFeaturesEXT = struct_vk.PhysicalDeviceImageViewMinLodFeaturesEXT;
pub const struct_VkImageViewMinLodCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    minLod: f32,
};
pub const VkImageViewMinLodCreateInfoEXT = struct_VkImageViewMinLodCreateInfoEXT;
pub const struct_vk.PhysicalDeviceMultiDrawFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    multiDraw: VkBool32,
};
pub const vk.PhysicalDeviceMultiDrawFeaturesEXT = struct_vk.PhysicalDeviceMultiDrawFeaturesEXT;
pub const struct_vk.PhysicalDeviceMultiDrawPropertiesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxMultiDrawCount: u32,
};
pub const vk.PhysicalDeviceMultiDrawPropertiesEXT = struct_vk.PhysicalDeviceMultiDrawPropertiesEXT;
pub const struct_VkMultiDrawInfoEXT = extern struct {
    firstVertex: u32,
    vertexCount: u32,
};
pub const VkMultiDrawInfoEXT = struct_VkMultiDrawInfoEXT;
pub const struct_VkMultiDrawIndexedInfoEXT = extern struct {
    firstIndex: u32,
    indexCount: u32,
    vertexOffset: i32,
};
pub const VkMultiDrawIndexedInfoEXT = struct_VkMultiDrawIndexedInfoEXT;
pub const PFN_vkCmdDrawMultiEXT = ?fn (VkCommandBuffer, u32, [*c]const VkMultiDrawInfoEXT, u32, u32, u32) callconv(.C) void;
pub const PFN_vkCmdDrawMultiIndexedEXT = ?fn (VkCommandBuffer, u32, [*c]const VkMultiDrawIndexedInfoEXT, u32, u32, u32, [*c]const i32) callconv(.C) void;
pub extern fn vkCmdDrawMultiEXT(commandBuffer: VkCommandBuffer, drawCount: u32, pVertexInfo: [*c]const VkMultiDrawInfoEXT, instanceCount: u32, firstInstance: u32, stride: u32) void;
pub extern fn vkCmdDrawMultiIndexedEXT(commandBuffer: VkCommandBuffer, drawCount: u32, pIndexInfo: [*c]const VkMultiDrawIndexedInfoEXT, instanceCount: u32, firstInstance: u32, stride: u32, pVertexOffset: [*c]const i32) void;
pub const struct_vk.PhysicalDeviceBorderColorSwizzleFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    borderColorSwizzle: VkBool32,
    borderColorSwizzleFromImage: VkBool32,
};
pub const vk.PhysicalDeviceBorderColorSwizzleFeaturesEXT = struct_vk.PhysicalDeviceBorderColorSwizzleFeaturesEXT;
pub const struct_VkSamplerBorderColorComponentMappingCreateInfoEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    components: VkComponentMapping,
    srgb: VkBool32,
};
pub const VkSamplerBorderColorComponentMappingCreateInfoEXT = struct_VkSamplerBorderColorComponentMappingCreateInfoEXT;
pub const struct_vk.PhysicalDevicePageableDeviceLocalMemoryFeaturesEXT = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    pageableDeviceLocalMemory: VkBool32,
};
pub const vk.PhysicalDevicePageableDeviceLocalMemoryFeaturesEXT = struct_vk.PhysicalDevicePageableDeviceLocalMemoryFeaturesEXT;
pub const PFN_vkSetDeviceMemoryPriorityEXT = ?fn (vk.Device, vk.DeviceMemory, f32) callconv(.C) void;
pub extern fn vkSetDeviceMemoryPriorityEXT(device: vk.Device, memory: vk.DeviceMemory, priority: f32) void;
pub const struct_vk.PhysicalDeviceFragmentDensityMapOffsetFeaturesQCOM = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    fragmentDensityMapOffset: VkBool32,
};
pub const vk.PhysicalDeviceFragmentDensityMapOffsetFeaturesQCOM = struct_vk.PhysicalDeviceFragmentDensityMapOffsetFeaturesQCOM;
pub const struct_vk.PhysicalDeviceFragmentDensityMapOffsetPropertiesQCOM = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    fragmentDensityOffsetGranularity: VkExtent2D,
};
pub const vk.PhysicalDeviceFragmentDensityMapOffsetPropertiesQCOM = struct_vk.PhysicalDeviceFragmentDensityMapOffsetPropertiesQCOM;
pub const struct_VkSubpassFragmentDensityMapOffsetEndInfoQCOM = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    fragmentDensityOffsetCount: u32,
    pFragmentDensityOffsets: [*c]const VkOffset2D,
};
pub const VkSubpassFragmentDensityMapOffsetEndInfoQCOM = struct_VkSubpassFragmentDensityMapOffsetEndInfoQCOM;
pub const struct_vk.PhysicalDeviceLinearColorAttachmentFeaturesNV = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    linearColorAttachment: VkBool32,
};
pub const vk.PhysicalDeviceLinearColorAttachmentFeaturesNV = struct_vk.PhysicalDeviceLinearColorAttachmentFeaturesNV;
pub const struct_VkAccelerationStructureKHR_T = opaque {};
pub const VkAccelerationStructureKHR = ?*struct_VkAccelerationStructureKHR_T;
pub const VK_BUILD_ACCELERATION_STRUCTURE_MODE_BUILD_KHR: c_int = 0;
pub const VK_BUILD_ACCELERATION_STRUCTURE_MODE_UPDATE_KHR: c_int = 1;
pub const VK_BUILD_ACCELERATION_STRUCTURE_MODE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkBuildAccelerationStructureModeKHR = c_uint;
pub const VkBuildAccelerationStructureModeKHR = enum_VkBuildAccelerationStructureModeKHR;
pub const VK_ACCELERATION_STRUCTURE_BUILD_TYPE_HOST_KHR: c_int = 0;
pub const VK_ACCELERATION_STRUCTURE_BUILD_TYPE_DEVICE_KHR: c_int = 1;
pub const VK_ACCELERATION_STRUCTURE_BUILD_TYPE_HOST_OR_DEVICE_KHR: c_int = 2;
pub const VK_ACCELERATION_STRUCTURE_BUILD_TYPE_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkAccelerationStructureBuildTypeKHR = c_uint;
pub const VkAccelerationStructureBuildTypeKHR = enum_VkAccelerationStructureBuildTypeKHR;
pub const VK_ACCELERATION_STRUCTURE_COMPATIBILITY_COMPATIBLE_KHR: c_int = 0;
pub const VK_ACCELERATION_STRUCTURE_COMPATIBILITY_INCOMPATIBLE_KHR: c_int = 1;
pub const VK_ACCELERATION_STRUCTURE_COMPATIBILITY_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkAccelerationStructureCompatibilityKHR = c_uint;
pub const VkAccelerationStructureCompatibilityKHR = enum_VkAccelerationStructureCompatibilityKHR;
pub const VK_ACCELERATION_STRUCTURE_CREATE_DEVICE_ADDRESS_CAPTURE_REPLAY_BIT_KHR: c_int = 1;
pub const VK_ACCELERATION_STRUCTURE_CREATE_MOTION_BIT_NV: c_int = 4;
pub const VK_ACCELERATION_STRUCTURE_CREATE_FLAG_BITS_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkAccelerationStructureCreateFlagBitsKHR = c_uint;
pub const VkAccelerationStructureCreateFlagBitsKHR = enum_VkAccelerationStructureCreateFlagBitsKHR;
pub const VkAccelerationStructureCreateFlagsKHR = VkFlags;
pub const union_vk.DeviceOrHostAddressKHR = extern union {
    deviceAddress: vk.DeviceAddress,
    hostAddress: ?*anyopaque,
};
pub const vk.DeviceOrHostAddressKHR = union_vk.DeviceOrHostAddressKHR;
pub const struct_VkAccelerationStructureBuildRangeInfoKHR = extern struct {
    primitiveCount: u32,
    primitiveOffset: u32,
    firstVertex: u32,
    transformOffset: u32,
};
pub const VkAccelerationStructureBuildRangeInfoKHR = struct_VkAccelerationStructureBuildRangeInfoKHR;
pub const struct_VkAccelerationStructureGeometryTrianglesDataKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    vertexFormat: VkFormat,
    vertexData: vk.DeviceOrHostAddressConstKHR,
    vertexStride: vk.DeviceSize,
    maxVertex: u32,
    indexType: VkIndexType,
    indexData: vk.DeviceOrHostAddressConstKHR,
    transformData: vk.DeviceOrHostAddressConstKHR,
};
pub const VkAccelerationStructureGeometryTrianglesDataKHR = struct_VkAccelerationStructureGeometryTrianglesDataKHR;
pub const struct_VkAccelerationStructureGeometryAabbsDataKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    data: vk.DeviceOrHostAddressConstKHR,
    stride: vk.DeviceSize,
};
pub const VkAccelerationStructureGeometryAabbsDataKHR = struct_VkAccelerationStructureGeometryAabbsDataKHR;
pub const struct_VkAccelerationStructureGeometryInstancesDataKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    arrayOfPointers: VkBool32,
    data: vk.DeviceOrHostAddressConstKHR,
};
pub const VkAccelerationStructureGeometryInstancesDataKHR = struct_VkAccelerationStructureGeometryInstancesDataKHR;
pub const union_VkAccelerationStructureGeometryDataKHR = extern union {
    triangles: VkAccelerationStructureGeometryTrianglesDataKHR,
    aabbs: VkAccelerationStructureGeometryAabbsDataKHR,
    instances: VkAccelerationStructureGeometryInstancesDataKHR,
};
pub const VkAccelerationStructureGeometryDataKHR = union_VkAccelerationStructureGeometryDataKHR;
pub const struct_VkAccelerationStructureGeometryKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    geometryType: VkGeometryTypeKHR,
    geometry: VkAccelerationStructureGeometryDataKHR,
    flags: VkGeometryFlagsKHR,
};
pub const VkAccelerationStructureGeometryKHR = struct_VkAccelerationStructureGeometryKHR;
pub const struct_VkAccelerationStructureBuildGeometryInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    type: VkAccelerationStructureTypeKHR,
    flags: VkBuildAccelerationStructureFlagsKHR,
    mode: VkBuildAccelerationStructureModeKHR,
    srcAccelerationStructure: VkAccelerationStructureKHR,
    dstAccelerationStructure: VkAccelerationStructureKHR,
    geometryCount: u32,
    pGeometries: [*c]const VkAccelerationStructureGeometryKHR,
    ppGeometries: [*c]const [*c]const VkAccelerationStructureGeometryKHR,
    scratchData: vk.DeviceOrHostAddressKHR,
};
pub const VkAccelerationStructureBuildGeometryInfoKHR = struct_VkAccelerationStructureBuildGeometryInfoKHR;
pub const struct_VkAccelerationStructureCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    createFlags: VkAccelerationStructureCreateFlagsKHR,
    buffer: VkBuffer,
    offset: vk.DeviceSize,
    size: vk.DeviceSize,
    type: VkAccelerationStructureTypeKHR,
    deviceAddress: vk.DeviceAddress,
};
pub const VkAccelerationStructureCreateInfoKHR = struct_VkAccelerationStructureCreateInfoKHR;
pub const struct_VkWriteDescriptorSetAccelerationStructureKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    accelerationStructureCount: u32,
    pAccelerationStructures: [*c]const VkAccelerationStructureKHR,
};
pub const VkWriteDescriptorSetAccelerationStructureKHR = struct_VkWriteDescriptorSetAccelerationStructureKHR;
pub const struct_vk.PhysicalDeviceAccelerationStructureFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    accelerationStructure: VkBool32,
    accelerationStructureCaptureReplay: VkBool32,
    accelerationStructureIndirectBuild: VkBool32,
    accelerationStructureHostCommands: VkBool32,
    descriptorBindingAccelerationStructureUpdateAfterBind: VkBool32,
};
pub const vk.PhysicalDeviceAccelerationStructureFeaturesKHR = struct_vk.PhysicalDeviceAccelerationStructureFeaturesKHR;
pub const struct_vk.PhysicalDeviceAccelerationStructurePropertiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    maxGeometryCount: u64,
    maxInstanceCount: u64,
    maxPrimitiveCount: u64,
    maxPerStageDescriptorAccelerationStructures: u32,
    maxPerStageDescriptorUpdateAfterBindAccelerationStructures: u32,
    maxDescriptorSetAccelerationStructures: u32,
    maxDescriptorSetUpdateAfterBindAccelerationStructures: u32,
    minAccelerationStructureScratchOffsetAlignment: u32,
};
pub const vk.PhysicalDeviceAccelerationStructurePropertiesKHR = struct_vk.PhysicalDeviceAccelerationStructurePropertiesKHR;
pub const struct_VkAccelerationStructureDeviceAddressInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    accelerationStructure: VkAccelerationStructureKHR,
};
pub const VkAccelerationStructureDeviceAddressInfoKHR = struct_VkAccelerationStructureDeviceAddressInfoKHR;
pub const struct_VkAccelerationStructureVersionInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    pVersionData: [*c]const u8,
};
pub const VkAccelerationStructureVersionInfoKHR = struct_VkAccelerationStructureVersionInfoKHR;
pub const struct_VkCopyAccelerationStructureToMemoryInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    src: VkAccelerationStructureKHR,
    dst: vk.DeviceOrHostAddressKHR,
    mode: VkCopyAccelerationStructureModeKHR,
};
pub const VkCopyAccelerationStructureToMemoryInfoKHR = struct_VkCopyAccelerationStructureToMemoryInfoKHR;
pub const struct_VkCopyMemoryToAccelerationStructureInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    src: vk.DeviceOrHostAddressConstKHR,
    dst: VkAccelerationStructureKHR,
    mode: VkCopyAccelerationStructureModeKHR,
};
pub const VkCopyMemoryToAccelerationStructureInfoKHR = struct_VkCopyMemoryToAccelerationStructureInfoKHR;
pub const struct_VkCopyAccelerationStructureInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    src: VkAccelerationStructureKHR,
    dst: VkAccelerationStructureKHR,
    mode: VkCopyAccelerationStructureModeKHR,
};
pub const VkCopyAccelerationStructureInfoKHR = struct_VkCopyAccelerationStructureInfoKHR;
pub const struct_VkAccelerationStructureBuildSizesInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    accelerationStructureSize: vk.DeviceSize,
    updateScratchSize: vk.DeviceSize,
    buildScratchSize: vk.DeviceSize,
};
pub const VkAccelerationStructureBuildSizesInfoKHR = struct_VkAccelerationStructureBuildSizesInfoKHR;
pub const PFN_vkCreateAccelerationStructureKHR = ?fn (vk.Device, [*c]const VkAccelerationStructureCreateInfoKHR, [*c]const VkAllocationCallbacks, [*c]VkAccelerationStructureKHR) callconv(.C) VkResult;
pub const PFN_vkDestroyAccelerationStructureKHR = ?fn (vk.Device, VkAccelerationStructureKHR, [*c]const VkAllocationCallbacks) callconv(.C) void;
pub const PFN_vkCmdBuildAccelerationStructuresKHR = ?fn (VkCommandBuffer, u32, [*c]const VkAccelerationStructureBuildGeometryInfoKHR, [*c]const [*c]const VkAccelerationStructureBuildRangeInfoKHR) callconv(.C) void;
pub const PFN_vkCmdBuildAccelerationStructuresIndirectKHR = ?fn (VkCommandBuffer, u32, [*c]const VkAccelerationStructureBuildGeometryInfoKHR, [*c]const vk.DeviceAddress, [*c]const u32, [*c]const [*c]const u32) callconv(.C) void;
pub const PFN_vkBuildAccelerationStructuresKHR = ?fn (vk.Device, VkDeferredOperationKHR, u32, [*c]const VkAccelerationStructureBuildGeometryInfoKHR, [*c]const [*c]const VkAccelerationStructureBuildRangeInfoKHR) callconv(.C) VkResult;
pub const PFN_vkCopyAccelerationStructureKHR = ?fn (vk.Device, VkDeferredOperationKHR, [*c]const VkCopyAccelerationStructureInfoKHR) callconv(.C) VkResult;
pub const PFN_vkCopyAccelerationStructureToMemoryKHR = ?fn (vk.Device, VkDeferredOperationKHR, [*c]const VkCopyAccelerationStructureToMemoryInfoKHR) callconv(.C) VkResult;
pub const PFN_vkCopyMemoryToAccelerationStructureKHR = ?fn (vk.Device, VkDeferredOperationKHR, [*c]const VkCopyMemoryToAccelerationStructureInfoKHR) callconv(.C) VkResult;
pub const PFN_vkWriteAccelerationStructuresPropertiesKHR = ?fn (vk.Device, u32, [*c]const VkAccelerationStructureKHR, VkQueryType, usize, ?*anyopaque, usize) callconv(.C) VkResult;
pub const PFN_vkCmdCopyAccelerationStructureKHR = ?fn (VkCommandBuffer, [*c]const VkCopyAccelerationStructureInfoKHR) callconv(.C) void;
pub const PFN_vkCmdCopyAccelerationStructureToMemoryKHR = ?fn (VkCommandBuffer, [*c]const VkCopyAccelerationStructureToMemoryInfoKHR) callconv(.C) void;
pub const PFN_vkCmdCopyMemoryToAccelerationStructureKHR = ?fn (VkCommandBuffer, [*c]const VkCopyMemoryToAccelerationStructureInfoKHR) callconv(.C) void;
pub const PFN_vkGetAccelerationStructureDeviceAddressKHR = ?fn (vk.Device, [*c]const VkAccelerationStructureDeviceAddressInfoKHR) callconv(.C) vk.DeviceAddress;
pub const PFN_vkCmdWriteAccelerationStructuresPropertiesKHR = ?fn (VkCommandBuffer, u32, [*c]const VkAccelerationStructureKHR, VkQueryType, VkQueryPool, u32) callconv(.C) void;
pub const PFN_vkGetDeviceAccelerationStructureCompatibilityKHR = ?fn (vk.Device, [*c]const VkAccelerationStructureVersionInfoKHR, [*c]VkAccelerationStructureCompatibilityKHR) callconv(.C) void;
pub const PFN_vkGetAccelerationStructureBuildSizesKHR = ?fn (vk.Device, VkAccelerationStructureBuildTypeKHR, [*c]const VkAccelerationStructureBuildGeometryInfoKHR, [*c]const u32, [*c]VkAccelerationStructureBuildSizesInfoKHR) callconv(.C) void;
pub extern fn vkCreateAccelerationStructureKHR(device: vk.Device, pCreateInfo: [*c]const VkAccelerationStructureCreateInfoKHR, pAllocator: [*c]const VkAllocationCallbacks, pAccelerationStructure: [*c]VkAccelerationStructureKHR) VkResult;
pub extern fn vkDestroyAccelerationStructureKHR(device: vk.Device, accelerationStructure: VkAccelerationStructureKHR, pAllocator: [*c]const VkAllocationCallbacks) void;
pub extern fn vkCmdBuildAccelerationStructuresKHR(commandBuffer: VkCommandBuffer, infoCount: u32, pInfos: [*c]const VkAccelerationStructureBuildGeometryInfoKHR, ppBuildRangeInfos: [*c]const [*c]const VkAccelerationStructureBuildRangeInfoKHR) void;
pub extern fn vkCmdBuildAccelerationStructuresIndirectKHR(commandBuffer: VkCommandBuffer, infoCount: u32, pInfos: [*c]const VkAccelerationStructureBuildGeometryInfoKHR, pIndirectDeviceAddresses: [*c]const vk.DeviceAddress, pIndirectStrides: [*c]const u32, ppMaxPrimitiveCounts: [*c]const [*c]const u32) void;
pub extern fn vkBuildAccelerationStructuresKHR(device: vk.Device, deferredOperation: VkDeferredOperationKHR, infoCount: u32, pInfos: [*c]const VkAccelerationStructureBuildGeometryInfoKHR, ppBuildRangeInfos: [*c]const [*c]const VkAccelerationStructureBuildRangeInfoKHR) VkResult;
pub extern fn vkCopyAccelerationStructureKHR(device: vk.Device, deferredOperation: VkDeferredOperationKHR, pInfo: [*c]const VkCopyAccelerationStructureInfoKHR) VkResult;
pub extern fn vkCopyAccelerationStructureToMemoryKHR(device: vk.Device, deferredOperation: VkDeferredOperationKHR, pInfo: [*c]const VkCopyAccelerationStructureToMemoryInfoKHR) VkResult;
pub extern fn vkCopyMemoryToAccelerationStructureKHR(device: vk.Device, deferredOperation: VkDeferredOperationKHR, pInfo: [*c]const VkCopyMemoryToAccelerationStructureInfoKHR) VkResult;
pub extern fn vkWriteAccelerationStructuresPropertiesKHR(device: vk.Device, accelerationStructureCount: u32, pAccelerationStructures: [*c]const VkAccelerationStructureKHR, queryType: VkQueryType, dataSize: usize, pData: ?*anyopaque, stride: usize) VkResult;
pub extern fn vkCmdCopyAccelerationStructureKHR(commandBuffer: VkCommandBuffer, pInfo: [*c]const VkCopyAccelerationStructureInfoKHR) void;
pub extern fn vkCmdCopyAccelerationStructureToMemoryKHR(commandBuffer: VkCommandBuffer, pInfo: [*c]const VkCopyAccelerationStructureToMemoryInfoKHR) void;
pub extern fn vkCmdCopyMemoryToAccelerationStructureKHR(commandBuffer: VkCommandBuffer, pInfo: [*c]const VkCopyMemoryToAccelerationStructureInfoKHR) void;
pub extern fn vkGetAccelerationStructureDeviceAddressKHR(device: vk.Device, pInfo: [*c]const VkAccelerationStructureDeviceAddressInfoKHR) vk.DeviceAddress;
pub extern fn vkCmdWriteAccelerationStructuresPropertiesKHR(commandBuffer: VkCommandBuffer, accelerationStructureCount: u32, pAccelerationStructures: [*c]const VkAccelerationStructureKHR, queryType: VkQueryType, queryPool: VkQueryPool, firstQuery: u32) void;
pub extern fn vkGetDeviceAccelerationStructureCompatibilityKHR(device: vk.Device, pVersionInfo: [*c]const VkAccelerationStructureVersionInfoKHR, pCompatibility: [*c]VkAccelerationStructureCompatibilityKHR) void;
pub extern fn vkGetAccelerationStructureBuildSizesKHR(device: vk.Device, buildType: VkAccelerationStructureBuildTypeKHR, pBuildInfo: [*c]const VkAccelerationStructureBuildGeometryInfoKHR, pMaxPrimitiveCounts: [*c]const u32, pSizeInfo: [*c]VkAccelerationStructureBuildSizesInfoKHR) void;
pub const VK_SHADER_GROUP_SHADER_GENERAL_KHR: c_int = 0;
pub const VK_SHADER_GROUP_SHADER_CLOSEST_HIT_KHR: c_int = 1;
pub const VK_SHADER_GROUP_SHADER_ANY_HIT_KHR: c_int = 2;
pub const VK_SHADER_GROUP_SHADER_INTERSECTION_KHR: c_int = 3;
pub const VK_SHADER_GROUP_SHADER_MAX_ENUM_KHR: c_int = 2147483647;
pub const enum_VkShaderGroupShaderKHR = c_uint;
pub const VkShaderGroupShaderKHR = enum_VkShaderGroupShaderKHR;
pub const struct_VkRayTracingShaderGroupCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    type: VkRayTracingShaderGroupTypeKHR,
    generalShader: u32,
    closestHitShader: u32,
    anyHitShader: u32,
    intersectionShader: u32,
    pShaderGroupCaptureReplayHandle: ?*const anyopaque,
};
pub const VkRayTracingShaderGroupCreateInfoKHR = struct_VkRayTracingShaderGroupCreateInfoKHR;
pub const struct_VkRayTracingPipelineInterfaceCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    maxPipelineRayPayloadSize: u32,
    maxPipelineRayHitAttributeSize: u32,
};
pub const VkRayTracingPipelineInterfaceCreateInfoKHR = struct_VkRayTracingPipelineInterfaceCreateInfoKHR;
pub const struct_VkRayTracingPipelineCreateInfoKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*const anyopaque,
    flags: VkPipelineCreateFlags,
    stageCount: u32,
    pStages: [*c]const VkPipelineShaderStageCreateInfo,
    groupCount: u32,
    pGroups: [*c]const VkRayTracingShaderGroupCreateInfoKHR,
    maxPipelineRayRecursionDepth: u32,
    pLibraryInfo: [*c]const VkPipelineLibraryCreateInfoKHR,
    pLibraryInterface: [*c]const VkRayTracingPipelineInterfaceCreateInfoKHR,
    pDynamicState: [*c]const VkPipelineDynamicStateCreateInfo,
    layout: VkPipelineLayout,
    basePipelineHandle: VkPipeline,
    basePipelineIndex: i32,
};
pub const VkRayTracingPipelineCreateInfoKHR = struct_VkRayTracingPipelineCreateInfoKHR;
pub const struct_vk.PhysicalDeviceRayTracingPipelineFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    rayTracingPipeline: VkBool32,
    rayTracingPipelineShaderGroupHandleCaptureReplay: VkBool32,
    rayTracingPipelineShaderGroupHandleCaptureReplayMixed: VkBool32,
    rayTracingPipelineTraceRaysIndirect: VkBool32,
    rayTraversalPrimitiveCulling: VkBool32,
};
pub const vk.PhysicalDeviceRayTracingPipelineFeaturesKHR = struct_vk.PhysicalDeviceRayTracingPipelineFeaturesKHR;
pub const struct_vk.PhysicalDeviceRayTracingPipelinePropertiesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    shaderGroupHandleSize: u32,
    maxRayRecursionDepth: u32,
    maxShaderGroupStride: u32,
    shaderGroupBaseAlignment: u32,
    shaderGroupHandleCaptureReplaySize: u32,
    maxRayDispatchInvocationCount: u32,
    shaderGroupHandleAlignment: u32,
    maxRayHitAttributeSize: u32,
};
pub const vk.PhysicalDeviceRayTracingPipelinePropertiesKHR = struct_vk.PhysicalDeviceRayTracingPipelinePropertiesKHR;
pub const struct_VkStridedDeviceAddressRegionKHR = extern struct {
    deviceAddress: vk.DeviceAddress,
    stride: vk.DeviceSize,
    size: vk.DeviceSize,
};
pub const VkStridedDeviceAddressRegionKHR = struct_VkStridedDeviceAddressRegionKHR;
pub const struct_VkTraceRaysIndirectCommandKHR = extern struct {
    width: u32,
    height: u32,
    depth: u32,
};
pub const VkTraceRaysIndirectCommandKHR = struct_VkTraceRaysIndirectCommandKHR;
pub const PFN_vkCmdTraceRaysKHR = ?fn (VkCommandBuffer, [*c]const VkStridedDeviceAddressRegionKHR, [*c]const VkStridedDeviceAddressRegionKHR, [*c]const VkStridedDeviceAddressRegionKHR, [*c]const VkStridedDeviceAddressRegionKHR, u32, u32, u32) callconv(.C) void;
pub const PFN_vkCreateRayTracingPipelinesKHR = ?fn (vk.Device, VkDeferredOperationKHR, VkPipelineCache, u32, [*c]const VkRayTracingPipelineCreateInfoKHR, [*c]const VkAllocationCallbacks, [*c]VkPipeline) callconv(.C) VkResult;
pub const PFN_vkGetRayTracingCaptureReplayShaderGroupHandlesKHR = ?fn (vk.Device, VkPipeline, u32, u32, usize, ?*anyopaque) callconv(.C) VkResult;
pub const PFN_vkCmdTraceRaysIndirectKHR = ?fn (VkCommandBuffer, [*c]const VkStridedDeviceAddressRegionKHR, [*c]const VkStridedDeviceAddressRegionKHR, [*c]const VkStridedDeviceAddressRegionKHR, [*c]const VkStridedDeviceAddressRegionKHR, vk.DeviceAddress) callconv(.C) void;
pub const PFN_vkGetRayTracingShaderGroupStackSizeKHR = ?fn (vk.Device, VkPipeline, u32, VkShaderGroupShaderKHR) callconv(.C) vk.DeviceSize;
pub const PFN_vkCmdSetRayTracingPipelineStackSizeKHR = ?fn (VkCommandBuffer, u32) callconv(.C) void;
pub extern fn vkCmdTraceRaysKHR(commandBuffer: VkCommandBuffer, pRaygenShaderBindingTable: [*c]const VkStridedDeviceAddressRegionKHR, pMissShaderBindingTable: [*c]const VkStridedDeviceAddressRegionKHR, pHitShaderBindingTable: [*c]const VkStridedDeviceAddressRegionKHR, pCallableShaderBindingTable: [*c]const VkStridedDeviceAddressRegionKHR, width: u32, height: u32, depth: u32) void;
pub extern fn vkCreateRayTracingPipelinesKHR(device: vk.Device, deferredOperation: VkDeferredOperationKHR, pipelineCache: VkPipelineCache, createInfoCount: u32, pCreateInfos: [*c]const VkRayTracingPipelineCreateInfoKHR, pAllocator: [*c]const VkAllocationCallbacks, pPipelines: [*c]VkPipeline) VkResult;
pub extern fn vkGetRayTracingCaptureReplayShaderGroupHandlesKHR(device: vk.Device, pipeline: VkPipeline, firstGroup: u32, groupCount: u32, dataSize: usize, pData: ?*anyopaque) VkResult;
pub extern fn vkCmdTraceRaysIndirectKHR(commandBuffer: VkCommandBuffer, pRaygenShaderBindingTable: [*c]const VkStridedDeviceAddressRegionKHR, pMissShaderBindingTable: [*c]const VkStridedDeviceAddressRegionKHR, pHitShaderBindingTable: [*c]const VkStridedDeviceAddressRegionKHR, pCallableShaderBindingTable: [*c]const VkStridedDeviceAddressRegionKHR, indirectDeviceAddress: vk.DeviceAddress) void;
pub extern fn vkGetRayTracingShaderGroupStackSizeKHR(device: vk.Device, pipeline: VkPipeline, group: u32, groupShader: VkShaderGroupShaderKHR) vk.DeviceSize;
pub extern fn vkCmdSetRayTracingPipelineStackSizeKHR(commandBuffer: VkCommandBuffer, pipelineStackSize: u32) void;
pub const struct_vk.PhysicalDeviceRayQueryFeaturesKHR = extern struct {
    sType: VkStructureType,
    pNext: ?*anyopaque,
    rayQuery: VkBool32,
};
pub const vk.PhysicalDeviceRayQueryFeaturesKHR = struct_vk.PhysicalDeviceRayQueryFeaturesKHR;
