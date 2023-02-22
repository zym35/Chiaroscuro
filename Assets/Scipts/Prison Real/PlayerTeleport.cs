using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerTeleport : MonoBehaviour
{
    public float tpDistance;
    public float tpDetect;
    void Update()
    {
        if (Mathf.Abs(transform.position.z) > tpDetect)
        {
            transform.position += (transform.position.z > 0 ? -1 : 1) * tpDistance * Vector3.forward;
        }
        if (Mathf.Abs(transform.position.x) > tpDetect)
        {
            transform.position += (transform.position.x > 0 ? -1 : 1) * tpDistance * Vector3.right;
        }
    }
}
