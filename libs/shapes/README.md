# Zig bindings for [par shapes](https://github.com/prideout/par/blob/master/par_shapes.h)

## Getting started

Then in your `build.zig` add:

```zig
const std = @import("std");
const zmesh = @import("libs/zmesh/build.zig");

pub fn build(b: *std.build.Builder) void {
    ...
    exe.addPackage(zmesh.pkg);
    zmesh.link(exe);
}
```

Now in your code you may import and use zmesh:

```zig
const zmesh = @import("shapes");

pub fn main() !void {
    ...
    zmesh.init(allocator);
    defer zmesh.deinit();

    var disk = zmesh.initParametricDisk(10, 2);
    defer disk.deinit();
    disk.invert(0, 0);

    var cylinder = zmesh.initCylinder(10, 4);
    defer cylinder.deinit();

    cylinder.merge(disk);
    cylinder.translate(0, 0, -1);
    disk.invert(0, 0);
    cylinder.merge(disk);

    cylinder.scale(0.5, 0.5, 2);
    cylinder.rotate(math.pi * 0.5, 1.0, 0.0, 0.0);

    cylinder.unweld();
    cylinder.computeNormals();
    ...
}
```
