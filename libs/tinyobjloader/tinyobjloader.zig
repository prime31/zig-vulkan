pub const tinyobj_material_t = extern struct {
    name: [*c]u8,
    ambient: [3]f32,
    diffuse: [3]f32,
    specular: [3]f32,
    transmittance: [3]f32,
    emission: [3]f32,
    shininess: f32,
    ior: f32,
    dissolve: f32,
    illum: c_int,
    pad0: c_int,
    ambient_texname: [*c]u8,
    diffuse_texname: [*c]u8,
    specular_texname: [*c]u8,
    specular_highlight_texname: [*c]u8,
    bump_texname: [*c]u8,
    displacement_texname: [*c]u8,
    alpha_texname: [*c]u8,
};
pub const tinyobj_shape_t = extern struct {
    name: [*c]u8,
    face_offset: c_uint,
    length: c_uint,
};
pub const tinyobj_vertex_index_t = extern struct {
    v_idx: c_int,
    vt_idx: c_int,
    vn_idx: c_int,
};
pub const tinyobj_attrib_t = extern struct {
    num_vertices: c_uint,
    num_normals: c_uint,
    num_texcoords: c_uint,
    num_faces: c_uint,
    num_face_num_verts: c_uint,
    pad0: c_int,
    vertices: [*c]f32,
    normals: [*c]f32,
    texcoords: [*c]f32,
    faces: [*c]tinyobj_vertex_index_t,
    face_num_verts: [*c]c_int,
    material_ids: [*c]c_int,
};
pub const file_reader_callback = ?fn (?*anyopaque, [*c]const u8, c_int, [*c]const u8, [*c][*c]u8, [*c]usize) callconv(.C) void;
pub extern fn tinyobj_parse_obj(attrib: [*c]tinyobj_attrib_t, shapes: [*c][*c]tinyobj_shape_t, num_shapes: [*c]usize, materials: [*c][*c]tinyobj_material_t, num_materials: [*c]usize, file_name: [*c]const u8, file_reader: file_reader_callback, ctx: ?*anyopaque, flags: c_uint) c_int;
pub extern fn tinyobj_parse_mtl_file(materials_out: [*c][*c]tinyobj_material_t, num_materials_out: [*c]usize, filename: [*c]const u8, obj_filename: [*c]const u8, file_reader: file_reader_callback, ctx: ?*anyopaque) c_int;
pub extern fn tinyobj_attrib_init(attrib: [*c]tinyobj_attrib_t) void;
pub extern fn tinyobj_attrib_free(attrib: [*c]tinyobj_attrib_t) void;
pub extern fn tinyobj_shapes_free(shapes: [*c]tinyobj_shape_t, num_shapes: usize) void;
pub extern fn tinyobj_materials_free(materials: [*c]tinyobj_material_t, num_materials: usize) void;

pub const TINYOBJ_FLAG_TRIANGULATE = @as(c_int, 1) << @as(c_int, 0);
pub const TINYOBJ_INVALID_INDEX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x80000000, .hexadecimal);
pub const TINYOBJ_SUCCESS = @as(c_int, 0);
pub const TINYOBJ_ERROR_EMPTY = -@as(c_int, 1);
pub const TINYOBJ_ERROR_INVALID_PARAMETER = -@as(c_int, 2);
pub const TINYOBJ_ERROR_FILE_OPERATION = -@as(c_int, 3);
