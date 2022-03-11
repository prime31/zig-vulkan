# Vulkan + GLFW

<img width="1071" alt="image" src="https://cdn.wccftech.com/wp-content/uploads/2019/05/DX-mmbxWkAAGbA4.jpg">

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

### Run the example
```sh
zig build clear
```

### Cross compilation
```sh
zig build -Dtarget=x86_64-linux-gnu
zig build -Dtarget=x86_64-windows-gnu
```
