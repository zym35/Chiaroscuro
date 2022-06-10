using System;
using UnityEngine;

public class CutPlaneSpawner : MonoBehaviour
{
    [SerializeField] private Camera _cam;
    private Vector3 _mouseStartPos, _mouseEndPos;
    private bool _isMouseDown;

    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            _mouseStartPos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 5);
        }

        if (Input.GetMouseButtonUp(0))
        {
            _mouseEndPos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 5);
            BeginCut();
        }
    }

    private Plane SpawnPlane()
    {
        Vector3 startPos = _cam.ScreenToWorldPoint(_mouseStartPos);
        Vector3 endPos = _cam.ScreenToWorldPoint(_mouseEndPos);
        Vector3 camPos = _cam.transform.position;

        Plane plane = new(startPos, endPos, camPos);
        DrawPlane(startPos, endPos, camPos, 3, Color.green, 10);

        return plane;
    }

    private void OnDrawGizmos()
    {
        Vector3 mousePos = new Vector3(Input.mousePosition.x, Input.mousePosition.y, 5);
        Gizmos.color = Color.blue;
    }

    private void BeginCut()
    {
        Cuttable[] cuttables = FindObjectsOfType<Cuttable>();
        if (cuttables.Length == 0)
            return;

        Plane plane = SpawnPlane();
        foreach (Cuttable cuttable in cuttables)
        {
            cuttable.Cut(plane);
        }

        foreach (Cuttable cuttable in cuttables)
        {
            Destroy(cuttable.gameObject);
        }
    }

    /// Mimics Debug.DrawLine, drawing a plane containing the 3 provided worldspace points,
    /// with the visualization centered on the centroid of the triangle they form.
    public static void DrawPlane(Vector3 a, Vector3 b, Vector3 c, float size, Color color, float duration = 0f, bool depthTest = true)
    {
        var plane = new Plane(a, b, c);
        var centroid = (a + b + c) / 3f;

        DrawPlaneAtPoint(plane, centroid, size, color, duration, depthTest);
    }

    /// Draws the portion of the plane closest to the provided point, with an altitude line colour-coding whether the point
    /// is in front (cyan) or behind (red) the provided plane.
    public static void DrawPlaneNearPoint(Plane plane, Vector3 point, float size, Color color, float duration = 0f, bool depthTest = true)
    {
        var closest = plane.ClosestPointOnPlane(point);
        Color side = plane.GetSide(point) ? Color.cyan : Color.red;
        Debug.DrawLine(point, closest, side, duration, depthTest);

        DrawPlaneAtPoint(plane, closest, size, color, duration, depthTest);
    }

    /// Non-public method to do the heavy lifting of drawing the grid of a given plane segment.
    static void DrawPlaneAtPoint(Plane plane, Vector3 center, float size, Color color, float duration, bool depthTest)
    {
        var basis = Quaternion.LookRotation(plane.normal);
        var scale = Vector3.one * size / 10f;

        var right = Vector3.Scale(basis * Vector3.right, scale);
        var up = Vector3.Scale(basis * Vector3.up, scale);

        for (int i = -5; i <= 5; i++)
        {
            Debug.DrawLine(center + right * i - up * 5, center + right * i + up * 5, color, duration, depthTest);
            Debug.DrawLine(center + up * i - right * 5, center + up * i + right * 5, color, duration, depthTest);
        }
    }
}