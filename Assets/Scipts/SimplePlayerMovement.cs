using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimplePlayerMovement : MonoBehaviour
{
    public float speed = 1;
    public float rotateSpeed = 1;
    public Transform cameraTracking;

    void Update()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        Vector3 movement = vertical * speed * Time.deltaTime * Vector3.forward;
        transform.Translate(movement);
        transform.Rotate(Vector3.up, horizontal * rotateSpeed * Time.deltaTime);

        //cameraTracking.position = new Vector3(transform.position.x, transform.position.y, 0);
    }
}