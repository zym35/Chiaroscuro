using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Cuttable : MonoBehaviour
{
    public GameObject debug;
    public PhysicMaterial physicMaterial;

    private Mesh _mesh;
    private MeshFilter _meshFilter;

    private void Awake()
    {
        _meshFilter = GetComponent<MeshFilter>();
        _mesh = _meshFilter.mesh;
    }

    public void Cut(Plane plane, float force)
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

        var intersects = new List<Vector3>();

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

                //add intersects to list for filling later
                if (!ListHasVector3(intersects, v4))
                    intersects.Add(v4);
                if (!ListHasVector3(intersects, v5))
                    intersects.Add(v5);

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

        //Fill the hole

        //StartCoroutine(StartDebug(intersects));
        //Fill();
        void Fill()
        {
            Vector3 center = intersects.Aggregate(Vector3.zero, (a, b) => a + b) / intersects.Count;
            intersects.Sort(new PointClockwiseComparer(plane.normal, center));

            for (int i = 0; i < intersects.Count - 1; i++)
            {
                int x1 = AddVertexAndNormal(ref vertices1, intersects[i], ref normals1, -plane.normal);
                int y1 = AddVertexAndNormal(ref vertices1, intersects[i + 1], ref normals1, -plane.normal);
                int z1 = AddVertexAndNormal(ref vertices1, center, ref normals1, -plane.normal);
                AddTriangle(ref triangles1, y1, x1, z1);

                int x2 = AddVertexAndNormal(ref vertices2, intersects[i], ref normals2, plane.normal);
                int y2 = AddVertexAndNormal(ref vertices2, intersects[i + 1], ref normals2, plane.normal);
                int z2 = AddVertexAndNormal(ref vertices2, center, ref normals2, plane.normal);
                AddTriangle(ref triangles2, x2, y2, z2);
            }

            int x1f = AddVertexAndNormal(ref vertices1, intersects[intersects.Count - 1], ref normals1, -plane.normal);
            int y1f = AddVertexAndNormal(ref vertices1, intersects[0], ref normals1, -plane.normal);
            int z1f = AddVertexAndNormal(ref vertices1, center, ref normals1, -plane.normal);
            AddTriangle(ref triangles1, y1f, x1f, z1f);

            int x2f = AddVertexAndNormal(ref vertices2, intersects[intersects.Count - 1], ref normals2, plane.normal);
            int y2f = AddVertexAndNormal(ref vertices2, intersects[0], ref normals2, plane.normal);
            int z2f = AddVertexAndNormal(ref vertices2, center, ref normals2, plane.normal);
            AddTriangle(ref triangles2, x2f, y2f, z2f);

            // while (intersects.Count > 3)
            // {
            //     int i = 1;
            //     for (; i < intersects.Count - 1; i++)
            //     {
            //         Vector3 v = intersects[i];
            //         Vector3 vLeft = intersects[i - 1];
            //         Vector3 vRight = intersects[i + 1];
            //
            //         bool isEar = true;
            //
            //         //is v convex
            //         if (Vector3.SignedAngle(vLeft - v, vRight - v, plane.normal) > 0)
            //             continue;
            //
            //         //no other point inside triangle
            //          for (var j = 0; j < intersects.Count && j < i - 1 && j > i + 1; j++)
            //          {
            //              if (!IsPointInsideTriangle(intersects[j], v, vLeft, vRight))
            //                  continue;
            //              isEar = false;
            //              break;
            //          }
            //
            //          if (!isEar)
            //              continue;
            //
            //          int x1 = AddVertexAndNormal(ref vertices1, vRight, ref normals1, -plane.normal);
            //          int y1 = AddVertexAndNormal(ref vertices1, v, ref normals1, -plane.normal);
            //          int z1 = AddVertexAndNormal(ref vertices1, vLeft, ref normals1, -plane.normal);
            //          AddTriangle(ref triangles1, x1, y1, z1);
            //
            //         int x2 = AddVertexAndNormal(ref vertices2, vLeft, ref normals2, plane.normal);
            //         int y2 = AddVertexAndNormal(ref vertices2, v, ref normals2, plane.normal);
            //         int z2 = AddVertexAndNormal(ref vertices2, vRight, ref normals2, plane.normal);
            //         AddTriangle(ref triangles2, x2, y2, z2);
            //
            //         intersects.RemoveAt(i);
            //         break;
            //     }
            //
            //     if (i == intersects.Count - 1)
            //         intersects.RemoveAt(0);
            // }
            //
            // //final three vertices
            // int x1f = AddVertexAndNormal(ref vertices1, intersects[2], ref normals1, -plane.normal);
            // int y1f = AddVertexAndNormal(ref vertices1, intersects[0], ref normals1, -plane.normal);
            // int z1f = AddVertexAndNormal(ref vertices1, intersects[1], ref normals1, -plane.normal);
            // AddTriangle(ref triangles1, x1f, y1f, z1f);
            //
            // int x2f = AddVertexAndNormal(ref vertices2, intersects[1], ref normals2, plane.normal);
            // int y2f = AddVertexAndNormal(ref vertices2, intersects[0], ref normals2, plane.normal);
            // int z2f = AddVertexAndNormal(ref vertices2, intersects[2], ref normals2, plane.normal);
            // AddTriangle(ref triangles2, z2f, y2f, x2f);
        }

        //spawn
        Rigidbody rb1 = SpawnObject(vertices1, triangles1, normals1);
        Rigidbody rb2 = SpawnObject(vertices2, triangles2, normals2);

        if (rb1 != null && rb2 != null)
        {
            //rb1.AddForce(plane.normal * force, ForceMode.Impulse);
            //rb2.AddForce(-plane.normal * force, ForceMode.Impulse);
        }

        Destroy(gameObject);
    }

    private IEnumerator StartDebug(List<Vector3> list)
    {
        foreach (Vector3 vector3 in list)
        {
            Instantiate(debug, transform.TransformPoint(vector3), Quaternion.identity);
            yield return new WaitForSeconds(1f);
        }
    }

    private Rigidbody SpawnObject(List<Vector3> vertices, List<int> triangles, List<Vector3> normals)
    {
        if (vertices.Count == 0)
            return null;

        Mesh mesh = new()
        {
            name = "MeshCut",
            vertices = vertices.ToArray(),
            triangles = triangles.ToArray(),
            normals = normals.ToArray()
        };
        //mesh.RecalculateNormals();

        GameObject obj = new();
        obj.transform.SetPositionAndRotation(transform.position, transform.rotation);
        obj.transform.localScale = transform.localScale;
        obj.AddComponent<MeshFilter>().mesh = mesh;
        obj.AddComponent<MeshRenderer>().material = GetComponent<MeshRenderer>().sharedMaterial;
        obj.AddComponent<Cuttable>();

        MeshCollider collider = obj.AddComponent<MeshCollider>();
        collider.convex = true;
        collider.material = physicMaterial;

        Rigidbody rb = obj.AddComponent<Rigidbody>();
        rb.constraints = RigidbodyConstraints.FreezeRotationX | RigidbodyConstraints.FreezeRotationY | RigidbodyConstraints.FreezePositionZ;

        return rb;
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
        int iVert = vertices.IndexOf(v);
        if (iVert != -1 && normals[iVert] == n)
            return iVert;

        vertices.Add(v);
        normals.Add(n);
        return vertices.Count - 1;
    }

    private class PointClockwiseComparer : Comparer<Vector3>
    {
        private Vector3 _normal, _center;

        public PointClockwiseComparer(Vector3 normal, Vector3 center)
        {
            _normal = normal;
            _center = center;
        }

        public override int Compare(Vector3 a, Vector3 b)
        {
            float angle = Vector3.SignedAngle(a - _center, b - _center, _normal);

            if (angle == 0)
            {
                float dist = Vector3.Distance(a, _center) - Vector3.Distance(b, _center);
                if (dist == 0)
                    return 0;

                return dist > 0 ? -1 : 1;
            }

            return angle > 0 ? -1 : 1;
        }
    }

    private static bool IsPointInsideTriangle(Vector3 p, Vector3 a, Vector3 b, Vector3 c)
    {
        bool SameDirection(Vector3 x, Vector3 y)
        {
            return Vector3.Dot(x, y) >= 0;
        }

        if (!SameDirection(Vector3.Cross(b - a, p - a), Vector3.Cross(b - a, c - a)))
            return false;
        if (!SameDirection(Vector3.Cross(c - b, p - b), Vector3.Cross(c - b, a - b)))
            return false;
        if (!SameDirection(Vector3.Cross(a - c, p - c), Vector3.Cross(a - c, b - c)))
            return false;

        return true;
    }

    private bool ListHasVector3(List<Vector3> list, Vector3 v)
    {
        foreach (Vector3 vector3 in list)
        {
            if (Vector3.Distance(v, vector3) < 0.001f)
                return true;
        }

        return false;
    }
}