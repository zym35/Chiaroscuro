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

    void Update()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        Vector3 movement =  new Vector3(horizontal * speed * Time.deltaTime, 0, 0);
        movement += Vector3.down * gravity * Time.deltaTime;
        if (Input.GetKeyDown(KeyCode.W))
        {
            movement += Vector3.up * jumpSpeed;
        }

        if (TestDestination(transform.position + movement.normalized * size + movement))
        {
            transform.Translate(movement, Space.World);
        }
    }

    private bool TestDestination(Vector3 pos)
    {

        if (Physics.Raycast(pos, Vector3.back, 100))
        {
            return false;
        }
        else
        {
            return true;
        }
    }
}