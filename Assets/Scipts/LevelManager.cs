using System;
using System.Collections.Generic;
using UnityEngine;

public class LevelManager : MonoBehaviour
{
    public static LevelManager Instance;

    private List<Light> _lights;

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        _lights = new List<Light>(FindObjectsOfType<Light>());
    }

    public List<Light> GetAllLights()
    {
        return _lights;
    }

    public bool PositionInAnyShadow(Vector3 pos, out List<GameObject> shadowSource)
    {
        shadowSource = new List<GameObject>();
        bool result = false;
        
        foreach (Light l in _lights)
        {
            if (Physics.Raycast(pos, l.transform.position - pos, out RaycastHit hit, l.range - 0.01f))
            {
                result = true;
                shadowSource.Add(hit.transform.gameObject);
            }
        }
        
        return result;
    }
}
