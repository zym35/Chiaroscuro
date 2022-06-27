using System;
using System.Collections;
using UnityEngine;

public class CutPaper : MonoBehaviour
{
    public float speed = 20;
    public float duration = 5;

    private IEnumerator Start()
    {
        BeginCut();

        yield return new WaitForSeconds(duration);
        Destroy(gameObject);
    }

    private void Update()
    {
        transform.Translate(Time.deltaTime * speed * Vector3.forward);
    }

    private void BeginCut()
    {
        Cuttable[] cuttables = FindObjectsOfType<Cuttable>();
        if (cuttables.Length == 0)
            return;

        Transform l = GameObject.Find("Directional Light").transform;
        Vector3 lightDir = l.forward;

        Plane plane = new Plane(Vector3.Cross(transform.forward, lightDir), transform.position);
        Util.DrawPlaneAtPoint(plane, transform.position, 3, Color.green, 1);

        foreach (Cuttable cuttable in cuttables)
        {
            cuttable.Cut(plane, 0);
        }
    }
}