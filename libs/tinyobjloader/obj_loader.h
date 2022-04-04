#ifndef obj_loader_h
#define obj_loader_h

extern "C" {
    typedef struct {
        float x;
        float y;
        float z;
    } obj_vec3_t;

    typedef struct {
        float u;
        float v;
    } obj_uv_t;

    typedef struct {
        const char *name;
        unsigned long long num_vertices;
        unsigned long long num_normals;
        unsigned long long num_uvs;
        unsigned long long num_colors;
        
        obj_vec3_t *vertices;
        obj_vec3_t *normals;
        obj_uv_t *uvs;
        obj_vec3_t *colors;
    } obj_shape_t;

    typedef struct {
        unsigned long long num_shapes;
        obj_shape_t* shapes;
    } obj_mesh_t;

    typedef struct {
        unsigned long long num_vertices;
        unsigned long long num_indices;

        obj_vec3_t *vertices;
        obj_vec3_t *normals;
        obj_uv_t *uvs;
        obj_vec3_t *colors;
        unsigned int *indices;
    } obj_indexed_mesh_t;

    void obj_free(obj_mesh_t mesh);
    obj_mesh_t obj_load(const char* file);

    void obj_free_indexed(obj_indexed_mesh_t mesh);
    obj_indexed_mesh_t obj_load_indexed(const char* file);
}

#endif
