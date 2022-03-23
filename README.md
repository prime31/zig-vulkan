# Vulkan + GLFW

<p align="center"><img height="300" src="https://developer.nvidia.com/sites/default/files/akamai/Vulcan-1-3.png" /></p>

## TODO
- move vk.zig out of cache
- other math lib: [Zalgebra](https://github.com/kooparse/zalgebra)
- other math lib: [vectormath](https://github.com/michal-z/zig-gamedev/blob/main/libs/common/src/vectormath.zig)
- other math lib: [zmath](https://github.com/michal-z/zig-gamedev/tree/main/libs/zmath)

- checkout abstractions here too: [Another Vulkan Zig](https://github.com/maxxnino/another-vulkan-zig)
- and here: [](https://github.com/GPUOpen-LibrariesAndSDKs/V-EZ)
- some API ideas: [Volkano](https://github.com/vulkano-rs/vulkano)
- higher-level api:
    - buffers: CpuAccessibleBuffer, GpuAccessibleBuffer, etc

- higher-level helpers:
    - vertex_input_state: blahGetVertexInputState(VertexT)

- add auto uniform/push/pip_layout generation (`spirv-cross shaer.spv --reflect`)


Future
- add SDL toggle [sdltest](https://github.com/SpexGuy/sdltest)


## Getting started

### Install the Vulkan SDK

You must install the LunarG Vulkan SDK: https://vulkan.lunarg.com/sdk/home

### Clone the repository and dependencies

```sh
git clone --recursive https://github.com/hexops/zig-vulkan
```

### Ensure glslc is on your PATH

On macOS, you may e.g. place the following in your `~/.zprofile` file though the Vulkan SDK installation should handle it for you.
```
export PATH=$PATH:$HOME/VulkanSDK/1.3.xxx/macOS/bin/
```

### Run an example
```sh
zig build --help
```

### Cross compilation
```sh
zig build -Dtarget=x86_64-linux-gnu
zig build -Dtarget=x86_64-windows-gnu
```
