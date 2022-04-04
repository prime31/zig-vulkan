#include "obj_loader.h"
#define TINYOBJLOADER_IMPLEMENTATION
#define TINYOBJLOADER_USE_MAPBOX_EARCUT
#include "tiny_obj_loader.h"
#include <map>

void obj_free(obj_mesh_t mesh) {
    for (int i = 0; i < mesh.num_shapes; i++) {
        obj_shape_t shape = mesh.shapes[i];
        free(shape.vertices);
        if (shape.num_normals > 0) free(shape.normals);
        if (shape.num_uvs > 0) free(shape.uvs);
        free(shape.colors);
    }
    free(mesh.shapes);
}

obj_mesh_t obj_load(const char* file) {
    tinyobj::ObjReaderConfig reader_config;
    reader_config.triangulate = true;
    
    tinyobj::ObjReader reader;
    
    if (!reader.ParseFromFile(std::string(file), reader_config)) {
        if (!reader.Error().empty()) printf("Error parsing file: %s", reader.Error().c_str());
        exit(1);
    }
    
    if (!reader.Warning().empty()) printf("Warning parsing file: %s" ,reader.Warning().c_str());
    
    auto& attrib = reader.GetAttrib();
    auto& shapes = reader.GetShapes();
    // auto& materials = reader.GetMaterials();
    
    obj_mesh_t mesh;
    mesh.num_shapes = shapes.size();
    mesh.shapes = (obj_shape_t*)malloc(sizeof(obj_shape_t) * mesh.num_shapes);
        
    // Loop over shapes
    for (size_t s = 0; s < shapes.size(); s++) {
        obj_shape_t* shape = &mesh.shapes[s];
        shape->name = shapes[s].name.c_str();
        
        // peek ahead to see if we have normals/uvs
        tinyobj::index_t peak_idx = shapes[s].mesh.indices[0];
        unsigned long long total_verts = shapes[s].mesh.num_face_vertices.size() * 3;
        
        shape->num_vertices = total_verts;
        shape->num_normals = peak_idx.normal_index >= 0 ? total_verts : 0;
        shape->num_uvs = peak_idx.texcoord_index >= 0 ? total_verts : 0;
        shape->num_colors = total_verts;
        
        shape->vertices = (obj_vec3_t*)malloc(sizeof(obj_vec3_t) * shape->num_vertices);
        shape->normals = (obj_vec3_t*)malloc(sizeof(obj_vec3_t) * shape->num_normals);
        shape->uvs = (obj_uv_t*)malloc(sizeof(obj_uv_t) * shape->num_uvs);
        shape->colors = (obj_vec3_t*)malloc(sizeof(obj_vec3_t) * shape->num_colors);
        
        // Loop over faces(polygon)
        size_t index_offset = 0;
        for (size_t f = 0; f < shapes[s].mesh.num_face_vertices.size(); f++) {            
            // Loop over vertices in the face. hardcode loading to triangles
            for (size_t v = 0; v < 3; v++) {
                // access to vertex
                tinyobj::index_t idx = shapes[s].mesh.indices[index_offset + v];
                tinyobj::real_t vx = attrib.vertices[3 * size_t(idx.vertex_index) + 0];
                tinyobj::real_t vy = attrib.vertices[3 * size_t(idx.vertex_index) + 1];
                tinyobj::real_t vz = attrib.vertices[3 * size_t(idx.vertex_index) + 2];
                shape->vertices[index_offset + v].x = vx;
                shape->vertices[index_offset + v].y = vy;
                shape->vertices[index_offset + v].z = vz;
                
                // Check if `normal_index` is zero or positive. negative = no normal data
                if (idx.normal_index >= 0) {
                    tinyobj::real_t nx = attrib.normals[3 * size_t(idx.normal_index) + 0];
                    tinyobj::real_t ny = attrib.normals[3 * size_t(idx.normal_index) + 1];
                    tinyobj::real_t nz = attrib.normals[3 * size_t(idx.normal_index) + 2];
                    shape->normals[index_offset + v].x = nx;
                    shape->normals[index_offset + v].y = ny;
                    shape->normals[index_offset + v].z = nz;
                }
                
                // Check if `texcoord_index` is zero or positive. negative = no texcoord data
                if (idx.texcoord_index >= 0) {
                    tinyobj::real_t tx = attrib.texcoords[2 * size_t(idx.texcoord_index) + 0];
                    tinyobj::real_t ty = 1 - attrib.texcoords[2 * size_t(idx.texcoord_index) + 1];
                    shape->uvs[index_offset + v].u = tx;
                    shape->uvs[index_offset + v].v = ty;
                }
                
                // Optional: vertex colors
                tinyobj::real_t red   = attrib.colors[3 * size_t(idx.vertex_index) + 0];
                tinyobj::real_t green = attrib.colors[3 * size_t(idx.vertex_index) + 1];
                tinyobj::real_t blue  = attrib.colors[3 * size_t(idx.vertex_index) + 2];
                shape->colors[index_offset + v].x = red;
                shape->colors[index_offset + v].y = green;
                shape->colors[index_offset + v].z = blue;
            }
            index_offset += 3;
        }
    }
    
    return mesh;
}

void obj_free_indexed(obj_indexed_mesh_t mesh) {
    free(mesh.vertices);
    free(mesh.normals);
    free(mesh.uvs);
    free(mesh.colors);
    free(mesh.indices);
}

obj_indexed_mesh_t obj_load_indexed(const char* file) {
    tinyobj::ObjReaderConfig reader_config;
    reader_config.triangulate = true;
    
    tinyobj::ObjReader reader;
    
    if (!reader.ParseFromFile(std::string(file), reader_config)) {
        if (!reader.Error().empty()) printf("Error parsing file: %s", reader.Error().c_str());
        exit(1);
    }
    
    if (!reader.Warning().empty()) printf("Warning parsing file: %s" ,reader.Warning().c_str());
    
    auto& attrib = reader.GetAttrib();
    auto& shapes = reader.GetShapes();

    int iCounter = 0;
    std::map<int, tinyobj::index_t> unique_indices;
    std::map<int, tinyobj::index_t>::iterator iter;

    std::vector<obj_vec3_t> verts;
    std::vector<obj_vec3_t> colors;
    std::vector<obj_vec3_t> normals;
    std::vector<obj_uv_t> uvs;
    std::vector<unsigned int> indices;

    for (size_t s = 0; s < shapes.size(); s++) {
        for (size_t i = 0; i < shapes[s].mesh.indices.size(); i++) {
            int f = (int)floor(i / 3);

            tinyobj::index_t index = shapes[s].mesh.indices[i];
            int vi = index.vertex_index;
            int ni = index.normal_index;
            int ti = index.texcoord_index;

            bool reuse = false;
            iter = unique_indices.find(vi);

            if (iter != unique_indices.end())
                if ((iter->second.normal_index == ni) && (iter->second.texcoord_index == ti) )
                    reuse = true;

            if (reuse) {
                indices.push_back(iter->second.vertex_index);
            } else {
                unique_indices[vi].vertex_index = (int)iCounter;
                unique_indices[vi].normal_index = ni;
                unique_indices[vi].texcoord_index = ti;

                verts.push_back({ attrib.vertices[3 * vi + 0], attrib.vertices[3 * vi + 1], attrib.vertices[3 * vi + 2] });
                colors.push_back({ attrib.colors[3 * vi + 0], attrib.colors[3 * vi + 1], attrib.colors[3 * vi + 2] });
                normals.push_back({ attrib.normals[3 * ni + 0], attrib.normals[3 * ni + 1], attrib.normals[3 * ni + 2] });
                uvs.push_back({ attrib.texcoords[2 * ti + 0], 1 - attrib.texcoords[2 * ti + 1] });

                indices.push_back(iCounter++);
            }
        }
    }

    obj_indexed_mesh_t mesh;
    mesh.num_vertices = verts.size();
    mesh.num_indices = indices.size();
    
    mesh.vertices = (obj_vec3_t*)malloc(sizeof(obj_vec3_t) * mesh.num_vertices);
    mesh.normals = (obj_vec3_t*)malloc(sizeof(obj_vec3_t) * mesh.num_vertices);
    mesh.uvs = (obj_uv_t*)malloc(sizeof(obj_uv_t) * mesh.num_vertices);
    mesh.colors = (obj_vec3_t*)malloc(sizeof(obj_vec3_t) * mesh.num_vertices);
    mesh.indices = (unsigned int*)malloc(sizeof(unsigned int) * mesh.num_indices);

    memcpy(mesh.vertices, verts.data(), sizeof(obj_vec3_t) * mesh.num_vertices);
    memcpy(mesh.normals, normals.data(), sizeof(obj_vec3_t) * mesh.num_vertices);
    memcpy(mesh.uvs, uvs.data(), sizeof(obj_uv_t) * uvs.size());
    memcpy(mesh.colors, colors.data(), sizeof(obj_vec3_t) * mesh.num_vertices);
    memcpy(mesh.indices, indices.data(), sizeof(unsigned int) * mesh.num_indices);

    return mesh;
}
