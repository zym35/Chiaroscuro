using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class LineBone : MonoBehaviour
{
    public List<Transform> vertexList;

    private LineRenderer _lineRenderer;

    private void Awake()
    {
        _lineRenderer = GetComponent<LineRenderer>();
    }

    private void Start()
    {
        if (vertexList.Count != _lineRenderer.positionCount)
            Debug.LogError("Position number not set correctly!");
    }

    private void Update()
    {
        // assign positions to renderer
        _lineRenderer.SetPositions(TransformsToPositionsArray(vertexList));
    }

    private Vector3[] TransformsToPositionsArray(List<Transform> transforms)
    {
        int count = transforms.Count;
        Vector3[] positions = new Vector3[count];
        for (int i = 0; i < count; i++)
        {
            positions[i] = transforms[i].position;
        }

        return positions;
    }
}