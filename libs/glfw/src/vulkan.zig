const std = @import("std");

const c = @import("c.zig");
const vk = @import("vulkan");
const Error = @import("errors.zig").Error;
const getError = @import("errors.zig").getError;
const Window = @import("Window.zig");

const internal_debug = @import("internal_debug.zig");

/// Returns whether the Vulkan loader and an ICD have been found.
///
/// This function returns whether the Vulkan loader and any minimally functional ICD have been
/// found.
///
/// The availability of a Vulkan loader and even an ICD does not by itself guarantee that surface
/// creation or even instance creation is possible. Call glfw.getRequiredInstanceExtensions
/// to check whether the extensions necessary for Vulkan surface creation are available and
/// glfw.getPhysicalDevicePresentationSupport to check whether a queue family of a physical device
/// supports image presentation.
///
/// @return `true` if Vulkan is minimally available, or `false` otherwise.
///
/// Possible errors include glfw.Error.NotInitialized.
///
/// @thread_safety This function may be called from any thread.
pub inline fn vulkanSupported() bool {
    internal_debug.assertInitialized();
    const supported = c.glfwVulkanSupported();
    getError() catch unreachable; // Only error 'GLFW_NOT_INITIALIZED' is impossible
    return supported == c.GLFW_TRUE;
}

/// Returns the Vulkan instance extensions required by GLFW.
///
/// This function returns an array of names of Vulkan instance extensions required by GLFW for
/// creating Vulkan surfaces for GLFW windows. If successful, the list will always contain
/// `VK_KHR_surface`, so if you don't require any additional extensions you can pass this list
/// directly to the `VkInstanceCreateInfo` struct.
///
/// If Vulkan is not available on the machine, this function returns null and generates a
/// glfw.Error.APIUnavailable error. Call glfw.vulkanSupported to check whether Vulkan is at least
/// minimally available.
///
/// If Vulkan is available but no set of extensions allowing window surface creation was found,
/// this function returns null. You may still use Vulkan for off-screen rendering and compute work.
///
/// Possible errors include glfw.Error.NotInitialized and glfw.Error.APIUnavailable.
///
/// Additional extensions may be required by future versions of GLFW. You should check if any
/// extensions you wish to enable are already in the returned array, as it is an error to specify
/// an extension more than once in the `VkInstanceCreateInfo` struct.
///
/// macos: GLFW currently supports both the `VK_MVK_macos_surface` and the newer
/// `VK_EXT_metal_surface` extensions.
///
/// @pointer_lifetime The returned array is allocated and freed by GLFW. You should not free it
/// yourself. It is guaranteed to be valid only until the library is terminated.
///
/// @thread_safety This function may be called from any thread.
///
/// see also: vulkan_ext, glfwCreateWindowSurface
pub inline fn getRequiredInstanceExtensions() error{APIUnavailable}![][*:0]const u8 {
    internal_debug.assertInitialized();
    var count: u32 = 0;
    if (c.glfwGetRequiredInstanceExtensions(&count)) |extensions| return @ptrCast([*][*:0]const u8, extensions)[0..count];
    getError() catch |err| return switch (err) {
        Error.NotInitialized => unreachable,
        Error.APIUnavailable => |e| e,
        else => unreachable,
    };
    // `glfwGetRequiredInstanceExtensions` returns `null` only for errors
    unreachable;
}

/// Vulkan API function pointer type.
///
/// Generic function pointer used for returning Vulkan API function pointers.
///
/// see also: vulkan_proc, glfw.getInstanceProcAddress
pub const VKProc = fn () callconv(.C) void;

/// Returns the address of the specified Vulkan instance function.
///
/// This function returns the address of the specified Vulkan core or extension function for the
/// specified instance. If instance is set to null it can return any function exported from the
/// Vulkan loader, including at least the following functions:
///
/// - `vkEnumerateInstanceExtensionProperties`
/// - `vkEnumerateInstanceLayerProperties`
/// - `vkCreateInstance`
/// - `vkGetInstanceProcAddr`
///
/// If Vulkan is not available on the machine, this function returns null and generates a
/// glfw.Error.APIUnavailable error. Call glfw.vulkanSupported to check whether Vulkan is at least
/// minimally available.
///
/// This function is equivalent to calling `vkGetInstanceProcAddr` with a platform-specific query
/// of the Vulkan loader as a fallback.
///
/// @param[in] instance The Vulkan instance to query, or null to retrieve functions related to
///            instance creation.
/// @param[in] procname The ASCII encoded name of the function.
/// @return The address of the function, or null if an error occurred.
///
/// To maintain ABI compatability with the C glfwGetInstanceProcAddress, as it is commonly passed
/// into libraries expecting that exact ABI, this function does not return an error. Instead, if
/// glfw.Error.NotInitialized or glfw.Error.APIUnavailable would occur this function will panic.
/// You may check glfw.vulkanSupported prior to invoking this function.
///
/// @pointer_lifetime The returned function pointer is valid until the library is terminated.
///
/// @thread_safety This function may be called from any thread.

pub const getInstanceProcAddress = glfwGetInstanceProcAddress;
pub extern fn glfwGetInstanceProcAddress(instance: vk.Instance, procname: [*:0]const u8) vk.PfnVoidFunction;


/// Creates a Vulkan surface for the specified window.
///
/// This function creates a Vulkan surface for the specified window.
///
/// If the Vulkan loader or at least one minimally functional ICD were not found, this function
/// returns `VK_ERROR_INITIALIZATION_FAILED` and generates a glfw.Error.APIUnavailable error. Call
/// glfw.vulkanSupported to check whether Vulkan is at least minimally available.
///
/// If the required window surface creation instance extensions are not available or if the
/// specified instance was not created with these extensions enabled, this function returns `VK_ERROR_EXTENSION_NOT_PRESENT`
/// and generates a glfw.Error.APIUnavailable error. Call glfw.getRequiredInstanceExtensions to
/// check what instance extensions are required.
///
/// The window surface cannot be shared with another API so the window must have been created with
/// the client api hint set to `GLFW_NO_API` otherwise it generates a glfw.Error.InvalidValue error
/// and returns `VK_ERROR_NATIVE_WINDOW_IN_USE_KHR`.
///
/// The window surface must be destroyed before the specified Vulkan instance. It is the
/// responsibility of the caller to destroy the window surface. GLFW does not destroy it for you.
/// Call `vkDestroySurfaceKHR` to destroy the surface.
///
/// @param[in] vk_instance The Vulkan instance to create the surface in.
/// @param[in] window The window to create the surface for.
/// @param[in] vk_allocation_callbacks The allocator to use, or null to use the default
/// allocator.
/// @param[out] surface Where to store the handle of the surface. This is set
/// to `VK_NULL_HANDLE` if an error occurred.
/// @return `VkResult` type, `VK_SUCCESS` if successful, or a Vulkan error code if an
/// error occurred.
///
/// Possible errors include glfw.Error.NotInitialized, glfw.Error.APIUnavailable, glfw.Error.PlatformError and glfw.Error.InvalidValue
///
/// If an error occurs before the creation call is made, GLFW returns the Vulkan error code most
/// appropriate for the error. Appropriate use of glfw.vulkanSupported and glfw.getRequiredInstanceExtensions
/// should eliminate almost all occurrences of these errors.
///
/// macos: This function currently only supports the `VK_MVK_macos_surface` extension from MoltenVK.
///
/// macos: This function creates and sets a `CAMetalLayer` instance for the window content view,
/// which is required for MoltenVK to function.
///
/// @thread_safety This function may be called from any thread. For synchronization details of
/// Vulkan objects, see the Vulkan specification.
///
/// see also: vulkan_surface, glfw.getRequiredInstanceExtensions

// pub const createWindowSurface = glfwCreateWindowSurface;
extern fn glfwCreateWindowSurface(instance: vk.Instance, window: *c.GLFWwindow, allocation_callbacks: ?*const vk.AllocationCallbacks, surface: *vk.SurfaceKHR) vk.Result;

pub inline fn createWindowSurface(instance: vk.Instance, window: Window, allocation_callbacks: ?*const vk.AllocationCallbacks, surface: *vk.SurfaceKHR) error{ APIUnavailable, PlatformError }!vk.Result {
    internal_debug.assertInitialized();
    const v = glfwCreateWindowSurface(
        instance,
        window.handle,
        if (allocation_callbacks == null) null else @ptrCast(*const vk.AllocationCallbacks, @alignCast(@alignOf(vk.AllocationCallbacks), allocation_callbacks)),
        @ptrCast(*vk.SurfaceKHR, @alignCast(@alignOf(vk.SurfaceKHR), surface)),
    );

    if (v == vk.Result.success) return v;
    getError() catch |err| return switch (err) {
        Error.NotInitialized => unreachable,
        Error.InvalidValue => @panic("Attempted to use window with client api to create vulkan surface."),
        Error.APIUnavailable, Error.PlatformError => |e| e,
        else => unreachable,
    };
    // `glfwCreateWindowSurface` returns `!VK_SUCCESS` only for errors
    unreachable;
}

test "vulkanSupported" {
    const glfw = @import("main.zig");
    try glfw.init(.{});
    defer glfw.terminate();

    _ = glfw.vulkanSupported();
}

test "getRequiredInstanceExtensions" {
    const glfw = @import("main.zig");
    try glfw.init(.{});
    defer glfw.terminate();

    _ = glfw.getRequiredInstanceExtensions() catch |err| std.debug.print("failed to get vulkan instance extensions, error={}\n", .{err});
}

test "getInstanceProcAddress" {
    const glfw = @import("main.zig");
    try glfw.init(.{});
    defer glfw.terminate();

    // syntax check only, we don't have a real vulkan instance and so this function would panic.
    _ = glfw.getInstanceProcAddress;
}
