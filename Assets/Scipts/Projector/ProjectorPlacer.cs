using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectorPlacer : MonoBehaviour
{
    public float distance = 0.1f;

    private Camera _cam;

    private void OnEnable()
    {
        _cam = Camera.current;
    }

    void Update()
    {

    }
}