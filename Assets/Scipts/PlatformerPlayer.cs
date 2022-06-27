using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlatformerPlayer : MonoBehaviour
{
    public float speed = 1;
    public float jumpSpeed = 1;

    private Rigidbody _rigidbody;

    private void Awake()
    {
        _rigidbody = GetComponent<Rigidbody>();
    }

    void Update()
    {
        float horizontal = Input.GetAxis("Horizontal");
        //float vertical = Input.GetAxis("Vertical");

        Vector3 movement = horizontal * speed * Time.deltaTime * Vector3.right;

        if (Input.GetKeyDown(KeyCode.W))
        {
            _rigidbody.AddForce(Vector3.up * jumpSpeed, ForceMode.Impulse);
        }

        transform.Translate(movement, Space.World);
    }
}