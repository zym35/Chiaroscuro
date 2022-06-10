using System.Collections.Generic;
using UnityEngine;

public class Cuttable : MonoBehaviour
{
    private Mesh _mesh;
    private MeshFilter _meshFilter;

    private void Awake()
    {
        _meshFilter = GetComponent<MeshFilter>();
        _mesh = _meshFilter.mesh;
    }

    public void Cut(Plane plane)
    {
        //initialize for new meshes
        var vertices = new List<Vector3>(_mesh.vertices);
        var triangles = new List<int>(_mesh.triangles);
        var normals = new List<Vector3>(_mesh.normals);

        var vertices1 = new List<Vector3>();
        var triangles1 = new List<int>();
        var normals1 = new List<Vector3>();

        var vertices2 = new List<Vector3>();
        var triangles2 = new List<int>();
        var normals2 = new List<Vector3>();

        //for each triangle
        int triangleCount = triangles.Count;
        for (var i = 0; i < triangleCount; i += 3)
        {
            int i1 = triangles[i];
            int i2 = triangles[i+1];
            int i3 = triangles[i+2];

            Vector3 v1 = transform.TransformPoint(vertices[i1]);
            Vector3 v2 = transform.TransformPoint(vertices[i2]);
            Vector3 v3 = transform.TransformPoint(vertices[i3]);

            bool side1 = plane.GetSide(v1);
            bool side2 = plane.GetSide(v2);
            bool side3 = plane.GetSide(v3);

            //all three vertices in same side
            if (side1 && side2 && side3)
            {
                Vector3 v1Local = transform.InverseTransformPoint(v1);
                Vector3 v2Local = transform.InverseTransformPoint(v2);
                Vector3 v3Local = transform.InverseTransformPoint(v3);

                int i1New = AddVertexAndNormal(ref vertices1, v1Local, ref normals1, normals[i1]);
                int i2New = AddVertexAndNormal(ref vertices1, v2Local, ref normals1, normals[i2]);
                int i3New = AddVertexAndNormal(ref vertices1, v3Local, ref normals1, normals[i3]);
                AddTriangle(ref triangles1, i1New, i2New, i3New);
            }
            else if (!side1 && !side2 && !side3)
            {
                Vector3 v1Local = transform.InverseTransformPoint(v1);
                Vector3 v2Local = transform.InverseTransformPoint(v2);
                Vector3 v3Local = transform.InverseTransformPoint(v3);

                int i1New = AddVertexAndNormal(ref vertices2, v1Local, ref normals2, normals[i1]);
                int i2New = AddVertexAndNormal(ref vertices2, v2Local, ref normals2, normals[i2]);
                int i3New = AddVertexAndNormal(ref vertices2, v3Local, ref normals2, normals[i3]);
                AddTriangle(ref triangles2, i1New, i2New, i3New);
            }
            else if (side1 && !side2 && !side3)
            {
                Intersect(v1, v2, v3, i1, i2, i3, true);
            }
            else if (!side1 && side2 && !side3)
            {
                Intersect(v2, v3, v1, i2, i3, i1, true);
            }
            else if (!side1 && !side2 && side3)
            {
                Intersect(v3, v1, v2, i3, i1, i2, true);
            }
            else if (!side1 && side2 && side3)
            {
                Intersect(v1, v2, v3, i1, i2, i3, false);
            }
            else if (side1 && !side2 && side3)
            {
                Intersect(v2, v3, v1, i2, i3, i1, false);
            }
            else if (side1 && side2 && !side3)
            {
                Intersect(v3, v1, v2, i3, i1, i2, false);
            }

            void Intersect(Vector3 v0World, Vector3 v1World, Vector3 v2World, int i0Old, int i1Old, int i2Old, bool v0IsPos)
            {
                //get v4 and v5
                plane.Raycast(new Ray(v0World, v1World - v0World), out float enter4);
                plane.Raycast(new Ray(v0World, v2World - v0World), out float enter5);

                float t4 = enter4 / (v1World - v0World).magnitude;
                float t5 = enter5 / (v2World - v0World).magnitude;

                Vector3 v4 = Vector3.Lerp(v0World, v1World, t4);
                Vector3 v5 = Vector3.Lerp(v0World, v2World, t5);

                v4 = transform.InverseTransformPoint(v4);
                v5 = transform.InverseTransformPoint(v5);
                Vector3 v0Local = transform.InverseTransformPoint(v0World);
                Vector3 v1Local = transform.InverseTransformPoint(v1World);
                Vector3 v2Local = transform.InverseTransformPoint(v2World);

                //add vertices and normals
                Vector3 v4n = Vector3.Lerp(normals[i0Old], normals[i1Old], t4);
                Vector3 v5n = Vector3.Lerp(normals[i0Old], normals[i2Old], t5);

                int i4_1 = AddVertexAndNormal(ref vertices1, v4, ref normals1, v4n);
                int i5_1 = AddVertexAndNormal(ref vertices1, v5, ref normals1, v5n);
                int i4_2 = AddVertexAndNormal(ref vertices2, v4, ref normals2, v4n);
                int i5_2 = AddVertexAndNormal(ref vertices2, v5, ref normals2, v5n);

                if (v0IsPos)
                {
                    int i0New = AddVertexAndNormal(ref vertices1, v0Local, ref normals1, normals[i0Old]);
                    int i1New = AddVertexAndNormal(ref vertices2, v1Local, ref normals2, normals[i1Old]);
                    int i2New = AddVertexAndNormal(ref vertices2, v2Local, ref normals2, normals[i2Old]);

                    AddTriangle(ref triangles1, i0New, i4_1, i5_1);
                    AddTriangle(ref triangles2, i5_2, i4_2, i1New);
                    AddTriangle(ref triangles2, i5_2, i1New, i2New);
                }
                else
                {
                    int i0New = AddVertexAndNormal(ref vertices2, v0Local, ref normals2, normals[i0Old]);
                    int i1New = AddVertexAndNormal(ref vertices1, v1Local, ref normals1, normals[i1Old]);
                    int i2New = AddVertexAndNormal(ref vertices1, v2Local, ref normals1, normals[i2Old]);

                    AddTriangle(ref triangles1, i1New, i2New, i4_1);
                    AddTriangle(ref triangles1, i2New, i5_1, i4_1);
                    AddTriangle(ref triangles2, i0New, i4_2, i5_2);
                }
            }
        }

        //spawn and destroy
        SpawnObject(vertices1, triangles1, normals1);
        SpawnObject(vertices2, triangles2, normals2);
        //Destroy(gameObject);
    }

    private void SpawnObject(List<Vector3> vertices, List<int> triangles, List<Vector3> normals)
    {
        if (vertices.Count == 0)
            return;

        Mesh mesh = new()
        {
            name = "MeshCut",
            vertices = vertices.ToArray(),
            triangles = triangles.ToArray(),
            normals = normals.ToArray()
        };
        mesh.RecalculateNormals();

        GameObject obj = new();
        obj.transform.SetPositionAndRotation(transform.position, transform.rotation);
        obj.transform.localScale = transform.localScale;
        obj.AddComponent<MeshFilter>().mesh = mesh;
        obj.AddComponent<MeshRenderer>().material = GetComponent<MeshRenderer>().sharedMaterial;
        obj.AddComponent<Rigidbody>();
        obj.AddComponent<MeshCollider>().convex = true;
        obj.AddComponent<Cuttable>();
    }

    private void AddTriangle(ref List<int> triangles, int i1, int i2, int i3)
    {
        triangles.Add(i1);
        triangles.Add(i2);
        triangles.Add(i3);
    }

    /// <returns>the index of vertex in the new list</returns>
    private static int AddVertexAndNormal(ref List<Vector3> vertices, Vector3 v, ref List<Vector3> normals, Vector3 n)
    {
        //int i = vertices.IndexOf(v);
        //if (i != -1) return i;

        vertices.Add(v);
        normals.Add(n);
        return vertices.Count - 1;
    }
}