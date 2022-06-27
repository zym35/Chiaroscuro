using UnityEngine;

public static class Util
{
    public static void DrawPlaneAtPoint(Plane plane, Vector3 center, float size, Color color, float duration)
    {
        var basis = Quaternion.LookRotation(plane.normal);
        var scale = Vector3.one * size / 10f;

        var right = Vector3.Scale(basis * Vector3.right, scale);
        var up = Vector3.Scale(basis * Vector3.up, scale);

        for (int i = -5; i <= 5; i++)
        {
            Debug.DrawLine(center + right * i - up * 5, center + right * i + up * 5, color, duration, true);
            Debug.DrawLine(center + up * i - right * 5, center + up * i + right * 5, color, duration, true);
        }
    }
}