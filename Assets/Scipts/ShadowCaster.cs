using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowCaster : MonoBehaviour
{
    public Light light;

    private Vector3 _lightDir;
    private MeshFilter _meshFilter;
    private List<Vector3> _vertexList;

    private void Awake()
    {
        _meshFilter = GetComponent<MeshFilter>();
        _vertexList = new List<Vector3>();
    }

    private void Start()
    {
        _lightDir = light.transform.forward;
    }

    private void CreateShadowObject()
    {
        _meshFilter.mesh.GetVertices(_vertexList);
        
        
    }
}
