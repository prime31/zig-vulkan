## Notes
- translate-c output is no bueno by default because we have to manually replace all `Vk*` objects with the `vk.*` equivalent from vulkan-zig's `vk.zig` file
- `VMA_EXTERNAL_MEMORY 0` is required for it to function due to some off Metal error or something
- `VMA_DYNAMIC_VULKAN_FUNCTIONS` is required since we dont static link vulkan


## TODO
- regenerate with translate-c and fix the `vk_mem_alloc.zig` file
- clean up `vk_mem_alloc.zig` flags and other bits to match vulkan-zig
