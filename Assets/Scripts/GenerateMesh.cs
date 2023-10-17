using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

using UnityEditor;

public class GenerateMesh : MonoBehaviour
{

    // Start is called before the first frame update
    void Start()
    {
        Mesh mesh = new Mesh();

        mesh.indexFormat = IndexFormat.UInt32;

        int size = 2000;
        float len = 1000f;

        Vector3[] verts = new Vector3[size * size];

        for (int i = 0; i < size; i ++)
            for (int j = 0; j < size; j++)
                verts[i * size + j] = new Vector3
                (
                    ((i + .5f) / size - .5f) * len,
                    0f,
                    ((j + .5f) / size - .5f) * len
                );

        int[] tris = new int[(size - 1) * (size - 1) * 6];

        for (int i = 0; i < size - 1; i ++)
            for (int j = 0; j < size - 1; j++)
            {
                int cell = (i * (size - 1) + j) * 6;

                tris[cell]     =  i      * size + j;
                tris[cell + 1] =  i      * size + j + 1;
                tris[cell + 2] = (i + 1) * size + j;
                tris[cell + 3] =  i      * size + j + 1;
                tris[cell + 4] = (i + 1) * size + j + 1;
                tris[cell + 5] = (i + 1) * size + j;
            }

        Vector2[] uvs = new Vector2[size * size];

        for (int i = 0; i < size; i ++)
            for (int j = 0; j < size; j++)
                uvs[i * size + j] = new Vector2
                (
                    // (float) i / (size - 1),
                    // (float) j / (size - 1)
                    verts[i * size + j].x,
                    verts[i * size + j].z
                );

        mesh.SetVertices(verts);
        mesh.SetTriangles(tris, 0);
        mesh.SetUVs(0, uvs);
        
        GetComponent<MeshFilter>().sharedMesh = mesh;

        MeshUtility.Optimize(mesh);

        // string path = EditorUtility.SaveFilePanel("Save Separate Mesh Asset", "Assets/", "WaterBase", "asset");
        // path = FileUtil.GetProjectRelativePath(path);
        // AssetDatabase.CreateAsset(mesh, "Assets/Models/WaterBase.asset");
		// AssetDatabase.SaveAssets();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
