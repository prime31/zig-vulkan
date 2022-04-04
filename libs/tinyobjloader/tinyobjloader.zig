pub const obj_vec3_t = extern struct {
    x: f32,
    y: f32,
    z: f32,
};

pub const obj_uv_t = extern struct {
    u: f32,
    v: f32,
};

pub const obj_shape_t = extern struct {
    name: [*c]const u8,
    num_vertices: c_ulonglong,
    num_normals: c_ulonglong,
    num_uvs: c_ulonglong,
    num_colors: c_ulonglong,
    vertices: [*c]obj_vec3_t,
    normals: [*c]obj_vec3_t,
    uvs: [*c]obj_uv_t,
    colors: [*c]obj_vec3_t,
};

pub const obj_mesh_t = extern struct {
    num_shapes: c_ulonglong,
    shapes: [*c]obj_shape_t,
};

pub const obj_indexed_mesh_t = extern struct {
    num_vertices: c_ulonglong,
    num_indices: c_ulonglong,
    vertices: [*c]obj_vec3_t,
    normals: [*c]obj_vec3_t,
    uvs: [*c]obj_uv_t,
    colors: [*c]obj_vec3_t,
    indices: [*c]u32,
};

pub extern fn obj_free(mesh: obj_mesh_t) void;
pub extern fn obj_load(file: [*c]const u8) obj_mesh_t;

pub extern fn obj_free_indexed(mesh: obj_indexed_mesh_t) void;
pub extern fn obj_load_indexed(file: [*c]const u8) obj_indexed_mesh_t;
