using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class PrisonSpawner : MonoBehaviour
{
    public GameObject picturePrefab;
    public Camera cam;
    public GameObject fakeWall;
    public LayerMask everything, screen;

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            ToggleFakeWall(true);
        }
    }

    public void ToggleFakeWall(bool active)
    {
        fakeWall.SetActive(active);
        cam.cullingMask = active ? screen : everything;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Prison"))
        {
            if (Vector3.Dot(transform.forward, Vector3.zero - transform.position) > 0)
            {
                collision.collider.isTrigger = true;
            }
            else
            {
                StartCoroutine(RecordFrame());
            }
        }
    }

    IEnumerator RecordFrame()
    {
        yield return new WaitForEndOfFrame();
        var texture = ScreenCapture.CaptureScreenshotAsTexture();

        Transform transform1 = cam.transform;
        var pic = Instantiate(picturePrefab, transform1);
        pic.transform.SetParent(null, true);

        pic.GetComponent<MeshRenderer>().material.SetTexture("_MainTex", texture);
    }
}