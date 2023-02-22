using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using Random = UnityEngine.Random;

public class PillarSpawner : MonoBehaviour
{
    public GameObject pillarPrefab;
    public int pillarNumSqrt;
    public float paddingDistance;
    public float centerClearDistance;
    public bool randomRotation;

    private List<GameObject> _pool = new List<GameObject>();

    private void Start()
    {
        float startX = -pillarNumSqrt * paddingDistance * 0.5f;
        float startZ = -pillarNumSqrt * paddingDistance * 0.5f;
        float endX = pillarNumSqrt * paddingDistance * 0.5f;
        float endZ = pillarNumSqrt * paddingDistance * 0.5f;
        for (float x = startX; x < endX; x += paddingDistance)
        {
            for (float z = startZ; z < endZ; z += paddingDistance)
            {
                Vector3 pos = new Vector3(x, 50, z);
                Quaternion rot = randomRotation ? Quaternion.Euler(0, Random.Range(0f, 360f), 0) : Quaternion.identity;
                if (Mathf.Abs(pos.x) > centerClearDistance || Mathf.Abs(pos.z) > centerClearDistance)
                {
                    _pool.Add(Instantiate(pillarPrefab, pos, rot));
                }
            }
        }
    }
}
