// manually added translation layer
const vk = @import("vulkan");

const PFN_vkAllocateMemory = vk.PfnAllocateMemory;
const PFN_vkFreeMemory = vk.PfnFreeMemory;
const PFN_vkMapMemory = vk.PfnMapMemory;
const PFN_vkUnmapMemory = vk.PfnUnmapMemory;
const PFN_vkFlushMappedMemoryRanges = vk.PfnFlushMappedMemoryRanges;
const PFN_vkInvalidateMappedMemoryRanges = vk.PfnInvalidateMappedMemoryRanges;
const PFN_vkBindBufferMemory = vk.PfnBindBufferMemory;
const PFN_vkBindImageMemory = vk.PfnBindImageMemory;
const PFN_vkGetBufferMemoryRequirements = vk.PfnGetBufferMemoryRequirements;
const PFN_vkGetImageMemoryRequirements = vk.PfnGetImageMemoryRequirements;
const PFN_vkCreateBuffer = vk.PfnCreateBuffer;
const PFN_vkDestroyBuffer = vk.PfnDestroyBuffer;
const PFN_vkCreateImage = vk.PfnCreateImage;
const PFN_vkDestroyImage = vk.PfnDestroyImage;
const PFN_vkCmdCopyBuffer = vk.PfnCmdCopyBuffer;
// end translation layer


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
pub const VmaAllocatorCreateFlags = vk.Flags;
pub const struct_VmaVulkanFunctions = extern struct {
    vkGetInstanceProcAddr: vk.PfnGetInstanceProcAddr,
    vkGetDeviceProcAddr: vk.PfnGetDeviceProcAddr,
    vkGetPhysicalDeviceProperties: vk.PfnGetPhysicalDeviceProperties,
    vkGetPhysicalDeviceMemoryProperties: vk.PfnGetPhysicalDeviceMemoryProperties,
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
    vkGetBufferMemoryRequirements2KHR: vk.PfnGetBufferMemoryRequirements2,
    vkGetImageMemoryRequirements2KHR: vk.PfnGetImageMemoryRequirements2,
    vkBindBufferMemory2KHR: vk.PfnBindBufferMemory2,
    vkBindImageMemory2KHR: vk.PfnBindImageMemory2,
    vkGetPhysicalDeviceMemoryProperties2KHR: vk.PfnGetPhysicalDeviceMemoryProperties2,
    vkGetDeviceBufferMemoryRequirements: vk.PfnGetDeviceBufferMemoryRequirements,
    vkGetDeviceImageMemoryRequirements: vk.PfnGetDeviceImageMemoryRequirements,
};
pub const VmaVulkanFunctions = struct_VmaVulkanFunctions;
pub const VMA_RECORD_FLUSH_AFTER_CALL_BIT: c_int = 1;
pub const VMA_RECORD_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaRecordFlagBits = c_uint;
pub const VmaRecordFlagBits = enum_VmaRecordFlagBits;
pub const VmaRecordFlags = vk.Flags;
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
    pAllocationCallbacks: [*c]const vk.AllocationCallbacks,
    pDeviceMemoryCallbacks: [*c]const VmaDeviceMemoryCallbacks,
    pHeapSizeLimit: [*c]const vk.DeviceSize,
    pVulkanFunctions: [*c]const VmaVulkanFunctions,
    instance: vk.Instance,
    vulkanApiVersion: u32,
    pTypeExternalMemoryHandleTypes: vk.ExternalMemoryHandleTypeFlagsKHR,
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
pub extern fn vmaGetMemoryTypeProperties(allocator: VmaAllocator, memoryTypeIndex: u32, pFlags: [*c]vk.MemoryPropertyFlags) void;
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
pub extern fn vmaBuildStatsString(allocator: VmaAllocator, ppStatsString: [*c][*c]u8, detailedMap: vk.Bool32) void;
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
pub const VmaAllocationCreateFlags = vk.Flags;
pub const struct_VmaAllocationCreateInfo = extern struct {
    flags: VmaAllocationCreateFlags,
    usage: VmaMemoryUsage,
    requiredFlags: vk.MemoryPropertyFlags,
    preferredFlags: vk.MemoryPropertyFlags,
    memoryTypeBits: u32,
    pool: VmaPool,
    pUserData: ?*anyopaque,
};
pub const VmaAllocationCreateInfo = struct_VmaAllocationCreateInfo;
pub extern fn vmaFindMemoryTypeIndex(allocator: VmaAllocator, memoryTypeBits: u32, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pMemoryTypeIndex: [*c]u32) vk.Result;
pub extern fn vmaFindMemoryTypeIndexForBufferInfo(allocator: VmaAllocator, pBufferCreateInfo: [*c]const vk.BufferCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pMemoryTypeIndex: [*c]u32) vk.Result;
pub extern fn vmaFindMemoryTypeIndexForImageInfo(allocator: VmaAllocator, pImageCreateInfo: [*c]const vk.ImageCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pMemoryTypeIndex: [*c]u32) vk.Result;
pub const VMA_POOL_CREATE_IGNORE_BUFFER_IMAGE_GRANULARITY_BIT: c_int = 2;
pub const VMA_POOL_CREATE_LINEAR_ALGORITHM_BIT: c_int = 4;
pub const VMA_POOL_CREATE_BUDDY_ALGORITHM_BIT: c_int = 8;
pub const VMA_POOL_CREATE_ALGORITHM_MASK: c_int = 12;
pub const VMA_POOL_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaPoolCreateFlagBits = c_uint;
pub const VmaPoolCreateFlagBits = enum_VmaPoolCreateFlagBits;
pub const VmaPoolCreateFlags = vk.Flags;
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
pub extern fn vmaCreatePool(allocator: VmaAllocator, pCreateInfo: [*c]const VmaPoolCreateInfo, pPool: [*c]VmaPool) vk.Result;
pub extern fn vmaDestroyPool(allocator: VmaAllocator, pool: VmaPool) void;
pub extern fn vmaGetPoolStats(allocator: VmaAllocator, pool: VmaPool, pPoolStats: [*c]VmaPoolStats) void;
pub extern fn vmaMakePoolAllocationsLost(allocator: VmaAllocator, pool: VmaPool, pLostAllocationCount: [*c]usize) void;
pub extern fn vmaCheckPoolCorruption(allocator: VmaAllocator, pool: VmaPool) vk.Result;
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
pub extern fn vmaAllocateMemory(allocator: VmaAllocator, pVkMemoryRequirements: [*c]const vk.MemoryRequirements, pCreateInfo: [*c]const VmaAllocationCreateInfo, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) vk.Result;
pub extern fn vmaAllocateMemoryPages(allocator: VmaAllocator, pVkMemoryRequirements: [*c]const vk.MemoryRequirements, pCreateInfo: [*c]const VmaAllocationCreateInfo, allocationCount: usize, pAllocations: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) vk.Result;
pub extern fn vmaAllocateMemoryForBuffer(allocator: VmaAllocator, buffer: vk.Buffer, pCreateInfo: [*c]const VmaAllocationCreateInfo, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) vk.Result;
pub extern fn vmaAllocateMemoryForImage(allocator: VmaAllocator, image: vk.Image, pCreateInfo: [*c]const VmaAllocationCreateInfo, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) vk.Result;
pub extern fn vmaFreeMemory(allocator: VmaAllocator, allocation: VmaAllocation) void;
pub extern fn vmaFreeMemoryPages(allocator: VmaAllocator, allocationCount: usize, pAllocations: [*c]const VmaAllocation) void;
pub extern fn vmaResizeAllocation(allocator: VmaAllocator, allocation: VmaAllocation, newSize: vk.DeviceSize) vk.Result;
pub extern fn vmaGetAllocationInfo(allocator: VmaAllocator, allocation: VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) void;
pub extern fn vmaTouchAllocation(allocator: VmaAllocator, allocation: VmaAllocation) vk.Bool32;
pub extern fn vmaSetAllocationUserData(allocator: VmaAllocator, allocation: VmaAllocation, pUserData: ?*anyopaque) void;
pub extern fn vmaCreateLostAllocation(allocator: VmaAllocator, pAllocation: [*c]VmaAllocation) void;
pub extern fn vmaMapMemory(allocator: VmaAllocator, allocation: VmaAllocation, ppData: [*c]?*anyopaque) vk.Result;
pub extern fn vmaUnmapMemory(allocator: VmaAllocator, allocation: VmaAllocation) void;
pub extern fn vmaFlushAllocation(allocator: VmaAllocator, allocation: VmaAllocation, offset: vk.DeviceSize, size: vk.DeviceSize) vk.Result;
pub extern fn vmaInvalidateAllocation(allocator: VmaAllocator, allocation: VmaAllocation, offset: vk.DeviceSize, size: vk.DeviceSize) vk.Result;
pub extern fn vmaFlushAllocations(allocator: VmaAllocator, allocationCount: u32, allocations: [*c]const VmaAllocation, offsets: [*c]const vk.DeviceSize, sizes: [*c]const vk.DeviceSize) vk.Result;
pub extern fn vmaInvalidateAllocations(allocator: VmaAllocator, allocationCount: u32, allocations: [*c]const VmaAllocation, offsets: [*c]const vk.DeviceSize, sizes: [*c]const vk.DeviceSize) vk.Result;
pub extern fn vmaCheckCorruption(allocator: VmaAllocator, memoryTypeBits: u32) vk.Result;
pub const struct_VmaDefragmentationContext_T = opaque {};
pub const VmaDefragmentationContext = ?*struct_VmaDefragmentationContext_T;
pub const VMA_DEFRAGMENTATION_FLAG_INCREMENTAL: c_int = 1;
pub const VMA_DEFRAGMENTATION_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaDefragmentationFlagBits = c_uint;
pub const VmaDefragmentationFlagBits = enum_VmaDefragmentationFlagBits;
pub const VmaDefragmentationFlags = vk.Flags;
pub const struct_VmaDefragmentationInfo2 = extern struct {
    flags: VmaDefragmentationFlags,
    allocationCount: u32,
    pAllocations: [*c]const VmaAllocation,
    pAllocationsChanged: [*c]vk.Bool32,
    poolCount: u32,
    pPools: [*c]const VmaPool,
    maxCpuBytesToMove: vk.DeviceSize,
    maxCpuAllocationsToMove: u32,
    maxGpuBytesToMove: vk.DeviceSize,
    maxGpuAllocationsToMove: u32,
    commandBuffer: vk.CommandBuffer,
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
pub extern fn vmaDefragmentationBegin(allocator: VmaAllocator, pInfo: [*c]const VmaDefragmentationInfo2, pStats: [*c]VmaDefragmentationStats, pContext: [*c]VmaDefragmentationContext) vk.Result;
pub extern fn vmaDefragmentationEnd(allocator: VmaAllocator, context: VmaDefragmentationContext) vk.Result;
pub extern fn vmaBeginDefragmentationPass(allocator: VmaAllocator, context: VmaDefragmentationContext, pInfo: [*c]VmaDefragmentationPassInfo) vk.Result;
pub extern fn vmaEndDefragmentationPass(allocator: VmaAllocator, context: VmaDefragmentationContext) vk.Result;
pub extern fn vmaDefragment(allocator: VmaAllocator, pAllocations: [*c]const VmaAllocation, allocationCount: usize, pAllocationsChanged: [*c]vk.Bool32, pDefragmentationInfo: [*c]const VmaDefragmentationInfo, pDefragmentationStats: [*c]VmaDefragmentationStats) vk.Result;
pub extern fn vmaBindBufferMemory(allocator: VmaAllocator, allocation: VmaAllocation, buffer: vk.Buffer) vk.Result;
pub extern fn vmaBindBufferMemory2(allocator: VmaAllocator, allocation: VmaAllocation, allocationLocalOffset: vk.DeviceSize, buffer: vk.Buffer, pNext: ?*const anyopaque) vk.Result;
pub extern fn vmaBindImageMemory(allocator: VmaAllocator, allocation: VmaAllocation, image: vk.Image) vk.Result;
pub extern fn vmaBindImageMemory2(allocator: VmaAllocator, allocation: VmaAllocation, allocationLocalOffset: vk.DeviceSize, image: vk.Image, pNext: ?*const anyopaque) vk.Result;
pub extern fn vmaCreateBuffer(allocator: VmaAllocator, pBufferCreateInfo: [*c]const vk.BufferCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pBuffer: [*c]vk.Buffer, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) vk.Result;
pub extern fn vmaDestroyBuffer(allocator: VmaAllocator, buffer: vk.Buffer, allocation: VmaAllocation) void;
pub extern fn vmaCreateImage(allocator: VmaAllocator, pImageCreateInfo: [*c]const vk.ImageCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pImage: [*c]vk.Image, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) vk.Result;
pub extern fn vmaDestroyImage(allocator: VmaAllocator, image: vk.Image, allocation: VmaAllocation) void;


pub const VMA_RECORDING_ENABLED = @as(c_int, 0);
pub const VMA_VULKAN_VERSION = @import("std").zig.c_translation.promoteIntLiteral(c_int, 1002000, .decimal);
pub const VMA_DEDICATED_ALLOCATION = @as(c_int, 1);
pub const VMA_BIND_MEMORY2 = @as(c_int, 1);
pub const VMA_MEMORY_BUDGET = @as(c_int, 1);
pub const VMA_BUFFER_DEVICE_ADDRESS = @as(c_int, 1);
pub const VMA_CALL_PRE = "";
pub const VMA_CALL_POST = "";
pub const VMA_STATS_STRING_ENABLED = @as(c_int, 1);


pub const VmaAllocator_T = struct_VmaAllocator_T;
pub const VmaPool_T = struct_VmaPool_T;
pub const VmaAllocation_T = struct_VmaAllocation_T;
pub const VmaDefragmentationContext_T = struct_VmaDefragmentationContext_T;


