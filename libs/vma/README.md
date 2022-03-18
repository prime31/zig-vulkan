## Notes
- `VMA_EXTERNAL_MEMORY 0` is required for it to function due to some Metal error or something
- `VMA_DYNAMIC_VULKAN_FUNCTIONS 1` and `VMA_STATIC_VULKAN_FUNCTIONS 0` are required since we dont static link vulkan

## TODO
- clean up `vma.zig` flags and other bits to match vulkan-zig
- switch vk.Result methods to return zig errors (in progress)