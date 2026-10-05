using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DarkFirePainter : MonoBehaviour
{
    public float radius = 1;
    public float strength = 1;
    public float hardness = 1;

    private ShadowPaintable[] _shadowPaintables;

    private void Start()
    {
        _shadowPaintables = FindObjectsOfType<ShadowPaintable>();
    }

    void Update()
    {
        foreach (var p in _shadowPaintables)
        {
            ShadowPaintManager.instance.Paint(p, transform.position, radius, hardness, strength, Color.yellow);
        }
    }
}
