using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Disable : MonoBehaviour
{
    public GameObject target;

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Disable"))
        {
            target.SetActive(false);
        }
    }
}