using System;
using UnityEngine;

public class PlayerSpawnCut : MonoBehaviour
{
    public GameObject paperPrefab;
    private bool _isMouseDown;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            GameObject paper = Instantiate(paperPrefab, transform.position, transform.rotation);
        }
    }
}