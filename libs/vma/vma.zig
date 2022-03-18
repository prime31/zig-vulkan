const vk = @import("vulkan");

// zigified API
pub const VukanMemoryAllocator = struct {
    const Self = @This();

    allocator: VmaAllocator,

    pub fn init(alloc_create_info: *VmaAllocatorCreateInfo) !Self {
        var allocator: VmaAllocator = undefined;
        const res = vmaCreateAllocator(alloc_create_info, &allocator);
        if (res != vk.Result.success) return error.Unknown;

        return .{ .allocator = allocator };
    }

    pub fn deinit(self: Self) void {
        vmaDestroyAllocator(self.allocator);
    }

    // TODO: return an AllocatedBuffer replacing the `buffer` and `allocation` ref params
    pub fn createBuffer(self: Self, buffer_create_info: *const vk.BufferCreateInfo, alloc_info: *const VmaAllocationCreateInfo, buffer: *vk.Buffer, allocation: *VmaAllocation, allocation_info: ?*VmaAllocationInfo) !void {
        const a_info = if (allocation_info) |ai| ai else null;
        const res = vmaCreateBuffer(
            self.allocator,
            buffer_create_info,
            alloc_info,
            &buffer,
            &allocation,
            a_info,
        );
        if (res != vk.Result.success) return error.Unknown;
    }

    pub fn destroyBuffer(self: Self, buffer: vk.Buffer, allocation: VmaAllocation) void {
        vmaDestroyBuffer(self.allocator, buffer, allocation);
    }

    // TODO: return an AllocatedImage replacing the `image` and `allocation` ref params
    pub fn createImage(self: Self, img_create_info: *const vk.ImageCreateInfo, vma_malloc_info: *const VmaAllocationCreateInfo, image: *vk.Image, allocation: *VmaAllocation, allocation_info: ?*VmaAllocationInfo) !void {
        const a_info = if (allocation_info) |ai| ai else null;
        const res = vmaCreateImage(self.allocator, img_create_info, vma_malloc_info, image, allocation, a_info);
        if (res != vk.Result.success) return error.Unknown;
    }

    pub fn destroyImage(self: Self, image: vk.Image, allocation: VmaAllocation) void {
        vmaDestroyImage(self.allocator, image, allocation);
    }

    pub fn mapMemory(self: Self, comptime T: type, allocation: VmaAllocation) ![*]T {
        var pp_data: ?*anyopaque = undefined;
        const res = vmaMapMemory(self.allocator, allocation, @ptrCast([*c]?*anyopaque, &pp_data));
        if (res != vk.Result.success) return error.Unknown;

        return @ptrCast([*]T, @alignCast(@alignOf(T), pp_data));
    }

    pub fn unmapMemory(self: Self, allocation: VmaAllocation) void {
        vmaUnmapMemory(self.allocator, allocation);
    }

    pub fn flushAllocation(self: Self, allocation: VmaAllocation, offset: vk.DeviceSize, size: vk.DeviceSize) !void {
        const res = vmaFlushAllocation(self.allocator, allocation, offset, size);
        if (res != vk.Result.success) return error.Unknown;
    }
};


// manually added translation layer
const VkFlags = vk.Flags;
const VkResult = vk.Result;
const VkDeviceMemory = vk.DeviceMemory;
const VkPhysicalDevice = vk.PhysicalDevice;
const VkInstance = vk.Instance;
const VkDeviceSize = vk.DeviceSize;
const VkMemoryPropertyFlags = vk.MemoryPropertyFlags;
const VkDevice = vk.Device;
const VkAllocationCallbacks = vk.AllocationCallbacks;
const VkPhysicalDeviceProperties = vk.PhysicalDeviceProperties;
const VkPhysicalDeviceMemoryProperties = vk.PhysicalDeviceMemoryProperties;
const VkBufferCreateInfo = vk.BufferCreateInfo;
const VkMemoryRequirements = vk.MemoryRequirements;
const VkImageCreateInfo = vk.ImageCreateInfo;
const VkBuffer = vk.Buffer;
const VkImage = vk.Image;
const VkBool32 = vk.Bool32;

const PFN_vkGetPhysicalDeviceMemoryProperties2KHR = vk.PfnGetPhysicalDeviceMemoryProperties2;
const PFN_vkBindImageMemory2KHR = vk.PfnBindImageMemory2;
const PFN_vkBindBufferMemory2KHR = vk.PfnBindBufferMemory2;
const PFN_vkGetImageMemoryRequirements2KHR = vk.PfnGetImageMemoryRequirements2;
const PFN_vkGetBufferMemoryRequirements2KHR = vk.PfnGetBufferMemoryRequirements2;
const PFN_vkGetPhysicalDeviceMemoryProperties = vk.PfnGetPhysicalDeviceMemoryProperties;
const PFN_vkGetPhysicalDeviceProperties = vk.PfnGetPhysicalDeviceProperties;
const PFN_vkGetDeviceProcAddr = vk.PfnGetDeviceProcAddr;
const PFN_vkGetInstanceProcAddr = vk.PfnGetInstanceProcAddr;
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


pub const VMA_ALLOCATOR_CREATE_EXTERNALLY_SYNCHRONIZED_BIT: c_int = 1;
pub const VMA_ALLOCATOR_CREATE_KHR_DEDICATED_ALLOCATION_BIT: c_int = 2;
pub const VMA_ALLOCATOR_CREATE_KHR_BIND_MEMORY2_BIT: c_int = 4;
pub const VMA_ALLOCATOR_CREATE_EXT_MEMORY_BUDGET_BIT: c_int = 8;
pub const VMA_ALLOCATOR_CREATE_AMD_DEVICE_COHERENT_MEMORY_BIT: c_int = 16;
pub const VMA_ALLOCATOR_CREATE_BUFFER_DEVICE_ADDRESS_BIT: c_int = 32;
pub const VMA_ALLOCATOR_CREATE_EXT_MEMORY_PRIORITY_BIT: c_int = 64;
pub const VMA_ALLOCATOR_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaAllocatorCreateFlagBits = c_uint;
pub const VmaAllocatorCreateFlagBits = enum_VmaAllocatorCreateFlagBits;
pub const VmaAllocatorCreateFlags = VkFlags;
pub const VMA_MEMORY_USAGE_UNKNOWN: c_int = 0;
pub const VMA_MEMORY_USAGE_GPU_ONLY: c_int = 1;
pub const VMA_MEMORY_USAGE_CPU_ONLY: c_int = 2;
pub const VMA_MEMORY_USAGE_CPU_TO_GPU: c_int = 3;
pub const VMA_MEMORY_USAGE_GPU_TO_CPU: c_int = 4;
pub const VMA_MEMORY_USAGE_CPU_COPY: c_int = 5;
pub const VMA_MEMORY_USAGE_GPU_LAZILY_ALLOCATED: c_int = 6;
pub const VMA_MEMORY_USAGE_AUTO: c_int = 7;
pub const VMA_MEMORY_USAGE_AUTO_PREFER_DEVICE: c_int = 8;
pub const VMA_MEMORY_USAGE_AUTO_PREFER_HOST: c_int = 9;
pub const VMA_MEMORY_USAGE_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaMemoryUsage = c_uint;
pub const VmaMemoryUsage = enum_VmaMemoryUsage;
pub const VMA_ALLOCATION_CREATE_DEDICATED_MEMORY_BIT: c_int = 1;
pub const VMA_ALLOCATION_CREATE_NEVER_ALLOCATE_BIT: c_int = 2;
pub const VMA_ALLOCATION_CREATE_MAPPED_BIT: c_int = 4;
pub const VMA_ALLOCATION_CREATE_USER_DATA_COPY_STRING_BIT: c_int = 32;
pub const VMA_ALLOCATION_CREATE_UPPER_ADDRESS_BIT: c_int = 64;
pub const VMA_ALLOCATION_CREATE_DONT_BIND_BIT: c_int = 128;
pub const VMA_ALLOCATION_CREATE_WITHIN_BUDGET_BIT: c_int = 256;
pub const VMA_ALLOCATION_CREATE_CAN_ALIAS_BIT: c_int = 512;
pub const VMA_ALLOCATION_CREATE_HOST_ACCESS_SEQUENTIAL_WRITE_BIT: c_int = 1024;
pub const VMA_ALLOCATION_CREATE_HOST_ACCESS_RANDOM_BIT: c_int = 2048;
pub const VMA_ALLOCATION_CREATE_HOST_ACCESS_ALLOW_TRANSFER_INSTEAD_BIT: c_int = 4096;
pub const VMA_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT: c_int = 65536;
pub const VMA_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT: c_int = 131072;
pub const VMA_ALLOCATION_CREATE_STRATEGY_MIN_OFFSET_BIT: c_int = 262144;
pub const VMA_ALLOCATION_CREATE_STRATEGY_BEST_FIT_BIT: c_int = 65536;
pub const VMA_ALLOCATION_CREATE_STRATEGY_FIRST_FIT_BIT: c_int = 131072;
pub const VMA_ALLOCATION_CREATE_STRATEGY_MASK: c_int = 458752;
pub const VMA_ALLOCATION_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaAllocationCreateFlagBits = c_uint;
pub const VmaAllocationCreateFlagBits = enum_VmaAllocationCreateFlagBits;
pub const VmaAllocationCreateFlags = VkFlags;
pub const VMA_POOL_CREATE_IGNORE_BUFFER_IMAGE_GRANULARITY_BIT: c_int = 2;
pub const VMA_POOL_CREATE_LINEAR_ALGORITHM_BIT: c_int = 4;
pub const VMA_POOL_CREATE_ALGORITHM_MASK: c_int = 4;
pub const VMA_POOL_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaPoolCreateFlagBits = c_uint;
pub const VmaPoolCreateFlagBits = enum_VmaPoolCreateFlagBits;
pub const VmaPoolCreateFlags = VkFlags;
pub const VMA_DEFRAGMENTATION_FLAG_ALGORITHM_FAST_BIT: c_int = 1;
pub const VMA_DEFRAGMENTATION_FLAG_ALGORITHM_BALANCED_BIT: c_int = 2;
pub const VMA_DEFRAGMENTATION_FLAG_ALGORITHM_FULL_BIT: c_int = 4;
pub const VMA_DEFRAGMENTATION_FLAG_ALGORITHM_EXTENSIVE_BIT: c_int = 8;
pub const VMA_DEFRAGMENTATION_FLAG_ALGORITHM_MASK: c_int = 15;
pub const VMA_DEFRAGMENTATION_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaDefragmentationFlagBits = c_uint;
pub const VmaDefragmentationFlagBits = enum_VmaDefragmentationFlagBits;
pub const VmaDefragmentationFlags = VkFlags;
pub const VMA_DEFRAGMENTATION_MOVE_OPERATION_COPY: c_int = 0;
pub const VMA_DEFRAGMENTATION_MOVE_OPERATION_IGNORE: c_int = 1;
pub const VMA_DEFRAGMENTATION_MOVE_OPERATION_DESTROY: c_int = 2;
pub const enum_VmaDefragmentationMoveOperation = c_uint;
pub const VmaDefragmentationMoveOperation = enum_VmaDefragmentationMoveOperation;
pub const VMA_VIRTUAL_BLOCK_CREATE_LINEAR_ALGORITHM_BIT: c_int = 1;
pub const VMA_VIRTUAL_BLOCK_CREATE_ALGORITHM_MASK: c_int = 1;
pub const VMA_VIRTUAL_BLOCK_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaVirtualBlockCreateFlagBits = c_uint;
pub const VmaVirtualBlockCreateFlagBits = enum_VmaVirtualBlockCreateFlagBits;
pub const VmaVirtualBlockCreateFlags = VkFlags;
pub const VMA_VIRTUAL_ALLOCATION_CREATE_UPPER_ADDRESS_BIT: c_int = 64;
pub const VMA_VIRTUAL_ALLOCATION_CREATE_STRATEGY_MIN_MEMORY_BIT: c_int = 65536;
pub const VMA_VIRTUAL_ALLOCATION_CREATE_STRATEGY_MIN_TIME_BIT: c_int = 131072;
pub const VMA_VIRTUAL_ALLOCATION_CREATE_STRATEGY_MIN_OFFSET_BIT: c_int = 262144;
pub const VMA_VIRTUAL_ALLOCATION_CREATE_STRATEGY_MASK: c_int = 458752;
pub const VMA_VIRTUAL_ALLOCATION_CREATE_FLAG_BITS_MAX_ENUM: c_int = 2147483647;
pub const enum_VmaVirtualAllocationCreateFlagBits = c_uint;
pub const VmaVirtualAllocationCreateFlagBits = enum_VmaVirtualAllocationCreateFlagBits;
pub const VmaVirtualAllocationCreateFlags = VkFlags;
pub const struct_VmaAllocator_T = opaque {};
pub const VmaAllocator = ?*struct_VmaAllocator_T;
pub const struct_VmaPool_T = opaque {};
pub const VmaPool = ?*struct_VmaPool_T;
pub const struct_VmaAllocation_T = opaque {};
pub const VmaAllocation = ?*struct_VmaAllocation_T;
pub const struct_VmaDefragmentationContext_T = opaque {};
pub const VmaDefragmentationContext = ?*struct_VmaDefragmentationContext_T;
pub const struct_VmaVirtualAllocation_T = opaque {};
pub const VmaVirtualAllocation = ?*struct_VmaVirtualAllocation_T;
pub const struct_VmaVirtualBlock_T = opaque {};
pub const VmaVirtualBlock = ?*struct_VmaVirtualBlock_T;
pub const PFN_vmaAllocateDeviceMemoryFunction = ?fn (VmaAllocator, u32, VkDeviceMemory, VkDeviceSize, ?*anyopaque) callconv(.C) void;
pub const PFN_vmaFreeDeviceMemoryFunction = ?fn (VmaAllocator, u32, VkDeviceMemory, VkDeviceSize, ?*anyopaque) callconv(.C) void;
pub const struct_VmaDeviceMemoryCallbacks = extern struct {
    pfnAllocate: PFN_vmaAllocateDeviceMemoryFunction,
    pfnFree: PFN_vmaFreeDeviceMemoryFunction,
    pUserData: ?*anyopaque,
};
pub const VmaDeviceMemoryCallbacks = struct_VmaDeviceMemoryCallbacks;
pub const struct_VmaVulkanFunctions = extern struct {
    vkGetInstanceProcAddr: PFN_vkGetInstanceProcAddr,
    vkGetDeviceProcAddr: PFN_vkGetDeviceProcAddr,
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
pub const struct_VmaAllocatorCreateInfo = extern struct {
    flags: VmaAllocatorCreateFlags,
    physicalDevice: VkPhysicalDevice,
    device: VkDevice,
    preferredLargeHeapBlockSize: VkDeviceSize,
    pAllocationCallbacks: [*c]const VkAllocationCallbacks,
    pDeviceMemoryCallbacks: [*c]const VmaDeviceMemoryCallbacks,
    pHeapSizeLimit: [*c]const VkDeviceSize,
    pVulkanFunctions: [*c]const VmaVulkanFunctions,
    instance: VkInstance,
    vulkanApiVersion: u32,
};
pub const VmaAllocatorCreateInfo = struct_VmaAllocatorCreateInfo;
pub const struct_VmaAllocatorInfo = extern struct {
    instance: VkInstance,
    physicalDevice: VkPhysicalDevice,
    device: VkDevice,
};
pub const VmaAllocatorInfo = struct_VmaAllocatorInfo;
pub const struct_VmaStatistics = extern struct {
    blockCount: u32,
    allocationCount: u32,
    blockBytes: VkDeviceSize,
    allocationBytes: VkDeviceSize,
};
pub const VmaStatistics = struct_VmaStatistics;
pub const struct_VmaDetailedStatistics = extern struct {
    statistics: VmaStatistics,
    unusedRangeCount: u32,
    allocationSizeMin: VkDeviceSize,
    allocationSizeMax: VkDeviceSize,
    unusedRangeSizeMin: VkDeviceSize,
    unusedRangeSizeMax: VkDeviceSize,
};
pub const VmaDetailedStatistics = struct_VmaDetailedStatistics;
pub const struct_VmaTotalStatistics = extern struct {
    memoryType: [32]VmaDetailedStatistics,
    memoryHeap: [16]VmaDetailedStatistics,
    total: VmaDetailedStatistics,
};
pub const VmaTotalStatistics = struct_VmaTotalStatistics;
pub const struct_VmaBudget = extern struct {
    statistics: VmaStatistics,
    usage: VkDeviceSize,
    budget: VkDeviceSize,
};
pub const VmaBudget = struct_VmaBudget;
pub const struct_VmaAllocationCreateInfo = extern struct {
    flags: VmaAllocationCreateFlags,
    usage: VmaMemoryUsage,
    requiredFlags: VkMemoryPropertyFlags,
    preferredFlags: VkMemoryPropertyFlags,
    memoryTypeBits: u32,
    pool: VmaPool,
    pUserData: ?*anyopaque,
    priority: f32,
};
pub const VmaAllocationCreateInfo = struct_VmaAllocationCreateInfo;
pub const struct_VmaPoolCreateInfo = extern struct {
    memoryTypeIndex: u32,
    flags: VmaPoolCreateFlags,
    blockSize: VkDeviceSize,
    minBlockCount: usize,
    maxBlockCount: usize,
    priority: f32,
    minAllocationAlignment: VkDeviceSize,
    pMemoryAllocateNext: ?*anyopaque,
};
pub const VmaPoolCreateInfo = struct_VmaPoolCreateInfo;
pub const struct_VmaAllocationInfo = extern struct {
    memoryType: u32,
    deviceMemory: VkDeviceMemory,
    offset: VkDeviceSize,
    size: VkDeviceSize,
    pMappedData: ?*anyopaque,
    pUserData: ?*anyopaque,
    pName: [*c]const u8,
};
pub const VmaAllocationInfo = struct_VmaAllocationInfo;
pub const struct_VmaDefragmentationInfo = extern struct {
    flags: VmaDefragmentationFlags,
    pool: VmaPool,
    maxBytesPerPass: VkDeviceSize,
    maxAllocationsPerPass: u32,
};
pub const VmaDefragmentationInfo = struct_VmaDefragmentationInfo;
pub const struct_VmaDefragmentationMove = extern struct {
    operation: VmaDefragmentationMoveOperation,
    srcAllocation: VmaAllocation,
    dstTmpAllocation: VmaAllocation,
};
pub const VmaDefragmentationMove = struct_VmaDefragmentationMove;
pub const struct_VmaDefragmentationPassMoveInfo = extern struct {
    moveCount: u32,
    pMoves: [*c]VmaDefragmentationMove,
};
pub const VmaDefragmentationPassMoveInfo = struct_VmaDefragmentationPassMoveInfo;
pub const struct_VmaDefragmentationStats = extern struct {
    bytesMoved: VkDeviceSize,
    bytesFreed: VkDeviceSize,
    allocationsMoved: u32,
    deviceMemoryBlocksFreed: u32,
};
pub const VmaDefragmentationStats = struct_VmaDefragmentationStats;
pub const struct_VmaVirtualBlockCreateInfo = extern struct {
    size: VkDeviceSize,
    flags: VmaVirtualBlockCreateFlags,
    pAllocationCallbacks: [*c]const VkAllocationCallbacks,
};
pub const VmaVirtualBlockCreateInfo = struct_VmaVirtualBlockCreateInfo;
pub const struct_VmaVirtualAllocationCreateInfo = extern struct {
    size: VkDeviceSize,
    alignment: VkDeviceSize,
    flags: VmaVirtualAllocationCreateFlags,
    pUserData: ?*anyopaque,
};
pub const VmaVirtualAllocationCreateInfo = struct_VmaVirtualAllocationCreateInfo;
pub const struct_VmaVirtualAllocationInfo = extern struct {
    offset: VkDeviceSize,
    size: VkDeviceSize,
    pUserData: ?*anyopaque,
};
pub const VmaVirtualAllocationInfo = struct_VmaVirtualAllocationInfo;
pub extern fn vmaCreateAllocator(pCreateInfo: [*c]const VmaAllocatorCreateInfo, pAllocator: [*c]VmaAllocator) VkResult;
pub extern fn vmaDestroyAllocator(allocator: VmaAllocator) void;
pub extern fn vmaGetAllocatorInfo(allocator: VmaAllocator, pAllocatorInfo: [*c]VmaAllocatorInfo) void;
pub extern fn vmaGetPhysicalDeviceProperties(allocator: VmaAllocator, ppPhysicalDeviceProperties: [*c][*c]const VkPhysicalDeviceProperties) void;
pub extern fn vmaGetMemoryProperties(allocator: VmaAllocator, ppPhysicalDeviceMemoryProperties: [*c][*c]const VkPhysicalDeviceMemoryProperties) void;
pub extern fn vmaGetMemoryTypeProperties(allocator: VmaAllocator, memoryTypeIndex: u32, pFlags: [*c]VkMemoryPropertyFlags) void;
pub extern fn vmaSetCurrentFrameIndex(allocator: VmaAllocator, frameIndex: u32) void;
pub extern fn vmaCalculateStatistics(allocator: VmaAllocator, pStats: [*c]VmaTotalStatistics) void;
pub extern fn vmaGetHeapBudgets(allocator: VmaAllocator, pBudgets: [*c]VmaBudget) void;
pub extern fn vmaFindMemoryTypeIndex(allocator: VmaAllocator, memoryTypeBits: u32, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pMemoryTypeIndex: [*c]u32) VkResult;
pub extern fn vmaFindMemoryTypeIndexForBufferInfo(allocator: VmaAllocator, pBufferCreateInfo: [*c]const VkBufferCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pMemoryTypeIndex: [*c]u32) VkResult;
pub extern fn vmaFindMemoryTypeIndexForImageInfo(allocator: VmaAllocator, pImageCreateInfo: [*c]const VkImageCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pMemoryTypeIndex: [*c]u32) VkResult;
pub extern fn vmaCreatePool(allocator: VmaAllocator, pCreateInfo: [*c]const VmaPoolCreateInfo, pPool: [*c]VmaPool) VkResult;
pub extern fn vmaDestroyPool(allocator: VmaAllocator, pool: VmaPool) void;
pub extern fn vmaGetPoolStatistics(allocator: VmaAllocator, pool: VmaPool, pPoolStats: [*c]VmaStatistics) void;
pub extern fn vmaCalculatePoolStatistics(allocator: VmaAllocator, pool: VmaPool, pPoolStats: [*c]VmaDetailedStatistics) void;
pub extern fn vmaCheckPoolCorruption(allocator: VmaAllocator, pool: VmaPool) VkResult;
pub extern fn vmaGetPoolName(allocator: VmaAllocator, pool: VmaPool, ppName: [*c][*c]const u8) void;
pub extern fn vmaSetPoolName(allocator: VmaAllocator, pool: VmaPool, pName: [*c]const u8) void;
pub extern fn vmaAllocateMemory(allocator: VmaAllocator, pVkMemoryRequirements: [*c]const VkMemoryRequirements, pCreateInfo: [*c]const VmaAllocationCreateInfo, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaAllocateMemoryPages(allocator: VmaAllocator, pVkMemoryRequirements: [*c]const VkMemoryRequirements, pCreateInfo: [*c]const VmaAllocationCreateInfo, allocationCount: usize, pAllocations: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaAllocateMemoryForBuffer(allocator: VmaAllocator, buffer: VkBuffer, pCreateInfo: [*c]const VmaAllocationCreateInfo, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaAllocateMemoryForImage(allocator: VmaAllocator, image: VkImage, pCreateInfo: [*c]const VmaAllocationCreateInfo, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaFreeMemory(allocator: VmaAllocator, allocation: VmaAllocation) void;
pub extern fn vmaFreeMemoryPages(allocator: VmaAllocator, allocationCount: usize, pAllocations: [*c]const VmaAllocation) void;
pub extern fn vmaGetAllocationInfo(allocator: VmaAllocator, allocation: VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) void;
pub extern fn vmaSetAllocationUserData(allocator: VmaAllocator, allocation: VmaAllocation, pUserData: ?*anyopaque) void;
pub extern fn vmaSetAllocationName(allocator: VmaAllocator, allocation: VmaAllocation, pName: [*c]const u8) void;
pub extern fn vmaGetAllocationMemoryProperties(allocator: VmaAllocator, allocation: VmaAllocation, pFlags: [*c]VkMemoryPropertyFlags) void;
pub extern fn vmaMapMemory(allocator: VmaAllocator, allocation: VmaAllocation, ppData: [*c]?*anyopaque) VkResult;
pub extern fn vmaUnmapMemory(allocator: VmaAllocator, allocation: VmaAllocation) void;
pub extern fn vmaFlushAllocation(allocator: VmaAllocator, allocation: VmaAllocation, offset: VkDeviceSize, size: VkDeviceSize) VkResult;
pub extern fn vmaInvalidateAllocation(allocator: VmaAllocator, allocation: VmaAllocation, offset: VkDeviceSize, size: VkDeviceSize) VkResult;
pub extern fn vmaFlushAllocations(allocator: VmaAllocator, allocationCount: u32, allocations: [*c]const VmaAllocation, offsets: [*c]const VkDeviceSize, sizes: [*c]const VkDeviceSize) VkResult;
pub extern fn vmaInvalidateAllocations(allocator: VmaAllocator, allocationCount: u32, allocations: [*c]const VmaAllocation, offsets: [*c]const VkDeviceSize, sizes: [*c]const VkDeviceSize) VkResult;
pub extern fn vmaCheckCorruption(allocator: VmaAllocator, memoryTypeBits: u32) VkResult;
pub extern fn vmaBeginDefragmentation(allocator: VmaAllocator, pInfo: [*c]const VmaDefragmentationInfo, pContext: [*c]VmaDefragmentationContext) VkResult;
pub extern fn vmaEndDefragmentation(allocator: VmaAllocator, context: VmaDefragmentationContext, pStats: [*c]VmaDefragmentationStats) void;
pub extern fn vmaBeginDefragmentationPass(allocator: VmaAllocator, context: VmaDefragmentationContext, pPassInfo: [*c]VmaDefragmentationPassMoveInfo) VkResult;
pub extern fn vmaEndDefragmentationPass(allocator: VmaAllocator, context: VmaDefragmentationContext, pPassInfo: [*c]VmaDefragmentationPassMoveInfo) VkResult;
pub extern fn vmaBindBufferMemory(allocator: VmaAllocator, allocation: VmaAllocation, buffer: VkBuffer) VkResult;
pub extern fn vmaBindBufferMemory2(allocator: VmaAllocator, allocation: VmaAllocation, allocationLocalOffset: VkDeviceSize, buffer: VkBuffer, pNext: ?*const anyopaque) VkResult;
pub extern fn vmaBindImageMemory(allocator: VmaAllocator, allocation: VmaAllocation, image: VkImage) VkResult;
pub extern fn vmaBindImageMemory2(allocator: VmaAllocator, allocation: VmaAllocation, allocationLocalOffset: VkDeviceSize, image: VkImage, pNext: ?*const anyopaque) VkResult;
pub extern fn vmaCreateBuffer(allocator: VmaAllocator, pBufferCreateInfo: [*c]const VkBufferCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pBuffer: [*c]VkBuffer, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaCreateBufferWithAlignment(allocator: VmaAllocator, pBufferCreateInfo: [*c]const VkBufferCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, minAlignment: VkDeviceSize, pBuffer: [*c]VkBuffer, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaCreateAliasingBuffer(allocator: VmaAllocator, allocation: VmaAllocation, pBufferCreateInfo: [*c]const VkBufferCreateInfo, pBuffer: [*c]VkBuffer) VkResult;
pub extern fn vmaDestroyBuffer(allocator: VmaAllocator, buffer: VkBuffer, allocation: VmaAllocation) void;
pub extern fn vmaCreateImage(allocator: VmaAllocator, pImageCreateInfo: [*c]const VkImageCreateInfo, pAllocationCreateInfo: [*c]const VmaAllocationCreateInfo, pImage: [*c]VkImage, pAllocation: [*c]VmaAllocation, pAllocationInfo: [*c]VmaAllocationInfo) VkResult;
pub extern fn vmaCreateAliasingImage(allocator: VmaAllocator, allocation: VmaAllocation, pImageCreateInfo: [*c]const VkImageCreateInfo, pImage: [*c]VkImage) VkResult;
pub extern fn vmaDestroyImage(allocator: VmaAllocator, image: VkImage, allocation: VmaAllocation) void;
pub extern fn vmaCreateVirtualBlock(pCreateInfo: [*c]const VmaVirtualBlockCreateInfo, pVirtualBlock: [*c]VmaVirtualBlock) VkResult;
pub extern fn vmaDestroyVirtualBlock(virtualBlock: VmaVirtualBlock) void;
pub extern fn vmaIsVirtualBlockEmpty(virtualBlock: VmaVirtualBlock) VkBool32;
pub extern fn vmaGetVirtualAllocationInfo(virtualBlock: VmaVirtualBlock, allocation: VmaVirtualAllocation, pVirtualAllocInfo: [*c]VmaVirtualAllocationInfo) void;
pub extern fn vmaVirtualAllocate(virtualBlock: VmaVirtualBlock, pCreateInfo: [*c]const VmaVirtualAllocationCreateInfo, pAllocation: [*c]VmaVirtualAllocation, pOffset: [*c]VkDeviceSize) VkResult;
pub extern fn vmaVirtualFree(virtualBlock: VmaVirtualBlock, allocation: VmaVirtualAllocation) void;
pub extern fn vmaClearVirtualBlock(virtualBlock: VmaVirtualBlock) void;
pub extern fn vmaSetVirtualAllocationUserData(virtualBlock: VmaVirtualBlock, allocation: VmaVirtualAllocation, pUserData: ?*anyopaque) void;
pub extern fn vmaGetVirtualBlockStatistics(virtualBlock: VmaVirtualBlock, pStats: [*c]VmaStatistics) void;
pub extern fn vmaCalculateVirtualBlockStatistics(virtualBlock: VmaVirtualBlock, pStats: [*c]VmaDetailedStatistics) void;
pub extern fn vmaBuildVirtualBlockStatsString(virtualBlock: VmaVirtualBlock, ppStatsString: [*c][*c]u8, detailedMap: VkBool32) void;
pub extern fn vmaFreeVirtualBlockStatsString(virtualBlock: VmaVirtualBlock, pStatsString: [*c]u8) void;
pub extern fn vmaBuildStatsString(allocator: VmaAllocator, ppStatsString: [*c][*c]u8, detailedMap: VkBool32) void;
pub extern fn vmaFreeStatsString(allocator: VmaAllocator, pStatsString: [*c]u8) void;

pub const VMA_DYNAMIC_VULKAN_FUNCTIONS = @as(c_int, 1);
pub const VMA_STATIC_VULKAN_FUNCTIONS = @as(c_int, 0);
pub const VMA_VULKAN_VERSION = @import("std").zig.c_translation.promoteIntLiteral(c_int, 1002000, .decimal);
pub const VMA_EXTERNAL_MEMORY = @as(c_int, 0);
pub const VMA_DEDICATED_ALLOCATION = @as(c_int, 1);
pub const VMA_BIND_MEMORY2 = @as(c_int, 1);
pub const VMA_MEMORY_BUDGET = @as(c_int, 1);
pub const VMA_BUFFER_DEVICE_ADDRESS = @as(c_int, 1);
pub const VMA_MEMORY_PRIORITY = @as(c_int, 1);
pub const VMA_CALL_PRE = "";
pub const VMA_CALL_POST = "";
pub const VMA_STATS_STRING_ENABLED = @as(c_int, 1);
pub const VmaAllocator_T = struct_VmaAllocator_T;
pub const VmaPool_T = struct_VmaPool_T;
pub const VmaAllocation_T = struct_VmaAllocation_T;
pub const VmaDefragmentationContext_T = struct_VmaDefragmentationContext_T;
pub const VmaVirtualAllocation_T = struct_VmaVirtualAllocation_T;
pub const VmaVirtualBlock_T = struct_VmaVirtualBlock_T;