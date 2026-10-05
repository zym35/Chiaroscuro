using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeleteCloseFace : MonoBehaviour
{
    public GameObject g1, g2;
    public const float EPSILON = 0.01f;

    void Start()
    {
        Mesh m1 = g1.GetComponent<MeshFilter>().mesh;
        Mesh m2 = g2.GetComponent<MeshFilter>().mesh;

        var newVertices = new List<Vector3>();
        var newTriangles = new List<int>();
        var newNormals = new List<Vector3>();

        var v1 = new List<Vector3>(m1.vertices);
        var t1 = new List<int>(m1.triangles);
        var n1 = new List<Vector3>(m1.normals);

        var v2 = new List<Vector3>(m2.vertices);
        var t2 = new List<int>(m2.triangles);
        var n2 = new List<Vector3>(m2.normals);

        for (var i = 0; i < t1.Count; i += 3)
        {
            int i1 = t1[i];
            int i2 = t1[i + 1];
            int i3 = t1[i + 2];
            
            Vector3 v1w1 = g1.transform.TransformPoint(v1[i1]);
            Vector3 v1w2 = g1.transform.TransformPoint(v1[i2]);
            Vector3 v1w3 = g1.transform.TransformPoint(v1[i3]);

            bool detected = false;
            for (var j = 0; j < t2.Count; j += 3)
            {
                int j1 = t2[j];
                int j2 = t2[j + 1];
                int j3 = t2[j + 2];
                
                Vector3 v2w1 = g2.transform.TransformPoint(v2[j1]);
                Vector3 v2w2 = g2.transform.TransformPoint(v2[j2]);
                Vector3 v2w3 = g2.transform.TransformPoint(v2[j3]);

                List<Vector3> pool = new List<Vector3>() { v1w1, v1w2, v1w3, v2w1, v2w2, v2w3 };

                foreach (Vector3 f in pool)
                {
                    Debug.Log(f);
                }
                
                for (int x = 0; x < pool.Count - 1; x++)
                {
                    for (int y = x + 1; y < pool.Count; y++)
                    {
                        if (Vector3.Distance(pool[x], pool[y]) < EPSILON)
                        {
                            Debug.Log("detected");
                            detected = true;
                            break;
                        }
                    }
                }

                //Vector3 n1 = (normals[i1] + normals[i2] + normals[i3]) / 3f;
                //Vector3 n2 = (normals[j1] + normals[j2] + normals[j3]) / 3f;

                // if (Vector3.Distance(v1w1, v2w1) < EPSILON && 
                //     Vector3.Distance(v1w2, v2w2) < EPSILON &&
                //     Vector3.Distance(v1w1, v2w2) < EPSILON )
                //     //&& Vector3.Dot(n1, n2) + 1 < EPSILON)
                // {
                //     Debug.Log("detected");
                //     detected = true;
                //     break;
                // }
            }

            if (!detected)
            {
                newVertices.Add(v1[i1]);
                newVertices.Add(v1[i2]);
                newVertices.Add(v1[i3]);
                newTriangles.Add(i);
                newTriangles.Add(i+1);
                newTriangles.Add(i+2);
                newNormals.Add(n1[i1]);
                newNormals.Add(n1[i2]);
                newNormals.Add(n1[i3]);
            }
        }
        
        Mesh m = new()
        {
            name = "MeshCut",
            vertices = newVertices.ToArray(),
            triangles = newTriangles.ToArray(),
            normals = newNormals.ToArray()
        };
        g1.GetComponent<MeshFilter>().mesh = m;
        g2.SetActive(false);
    }
}
