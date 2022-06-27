using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Teleportation : MonoBehaviour
{
    public Transform title;

    private void Update()
    {
        if (title != null && Vector3.Dot(transform.forward, title.position - transform.position) < 0)
            title.gameObject.SetActive(false);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("TeleStart"))
        {
            Vector3 delta = transform.position - other.transform.position;
            Vector3 dest = other.GetComponent<TeleZone>().dest.position;
            transform.position = dest + delta;
        }

        else if (other.CompareTag("TeleDirect"))
        {
            if (Vector3.Dot(transform.forward, other.transform.forward) < 0)
            {
                Vector3 delta = transform.position - other.transform.position;
                Vector3 dest = other.GetComponent<TeleZone>().dest.position;
                transform.position = dest + delta;
            }
        }

        else if (other.CompareTag("SceneTrasition1"))
        {
            FindObjectOfType<Transition>().Transit(1);
        }

        else if (other.CompareTag("SceneTrasition2"))
        {
            FindObjectOfType<Transition>().Transit(2);
        }

        else if (other.CompareTag("SceneTransition3"))
        {
            FindObjectOfType<Transition>().Transit(3);
        }
    }
}