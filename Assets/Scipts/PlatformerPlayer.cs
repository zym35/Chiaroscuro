using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformerPlayer : MonoBehaviour
{
    public float speed = 2;
    public float jumpSpeed = 1;
    public float size = .5f;
    public float gravity = 9;
    public float distance = 0.1f;

    private Transform _camTransform;

    private void OnEnable()
    {
        _camTransform = Camera.main.transform;
    }

    void Update()
    {
        float horizontal = Input.GetAxis("Horizontal");
        Vector3 movement = new Vector3(horizontal * speed, -gravity, 0) * Time.deltaTime;
        if (Input.GetKeyDown(KeyCode.W))
        {
            movement += Vector3.up * jumpSpeed;
        }

        Vector3 dest = transform.position + movement.normalized * size + movement;
        if (TestDestination(dest))
        {
            if (Physics.Raycast(_camTransform.position, dest - _camTransform.position, out RaycastHit hit, 1000))
            {
                transform.Translate(hit.point + hit.normal * distance - transform.position);
                transform.LookAt(transform.position - hit.normal);
            }
        }
    }

    private bool TestDestination(Vector3 pos)
    {
        if (Physics.Raycast(pos, Vector3.back, 1000))
        {
            return false;
        }
        else
        {
            return true;
        }
    }
}