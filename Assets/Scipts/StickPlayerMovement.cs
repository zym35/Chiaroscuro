using System;
using UnityEngine;

[ExecuteInEditMode]
public class StickPlayerMovement : MonoBehaviour
{
    private const float PlayerHeight = 3;

    public float stepLengthMultiplier = 0.06f;
    public float speed;
    public Transform leftFootIK, rightFootIK;

    public bool _lastFootLeft = true;

    private Rigidbody _rigidbody;

    private void Awake()
    {
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void Update()
    {
        Vector3 playerPos = transform.position;
        Vector3 footCenter = (leftFootIK.position + rightFootIK.position) / 2;
        Debug.DrawLine(playerPos, footCenter, Color.yellow);
        if (Vector3.Distance(playerPos, footCenter) > Vector3.Distance(leftFootIK.position, footCenter))
        {
            StepPolar(leftFootIK.position, rightFootIK.position, playerPos,
                out Vector3 leftPos, out Vector3 rightPos);
            if (!_lastFootLeft)
            {
                leftFootIK.position = leftPos;
            }
            else
            {
                rightFootIK.position = rightPos;
            }

            _lastFootLeft = !_lastFootLeft;
            Debug.Break();
        }
    }

    private void FixedUpdate()
    {
        Move();
    }

    private void LogDegree(float radius, string n)
    {
        Debug.Log(n + ": " + radius * Mathf.Rad2Deg);
    }

    private void StepPolar(Vector3 leftFootPos, Vector3 rightFootPos, Vector3 playerPos, out Vector3 newLeftPos, out Vector3 newRightPos)
    {
        Vector3 upAxis = Vector3.up;
        float r0 = Vector3.Distance(leftFootPos, rightFootPos) / 2;
        float r1 = 2 * r0;
        Vector3 axisOrigin = (leftFootPos + rightFootPos) / 2;
        Vector3 axisFront = Vector3.Cross(upAxis, leftFootPos - axisOrigin);
        float playerAngle = Vector3.SignedAngle(axisFront, playerPos - axisOrigin, upAxis) * Mathf.Deg2Rad;
        float triangleCornerAngle = Mathf.Acos(r0 / r1);

        LogDegree(playerAngle, "playerAngle");
        LogDegree(triangleCornerAngle, "triangleCornerAngle");

        float newLeftIKAngle = Mathf.PI / 2 - triangleCornerAngle - playerAngle;

        LogDegree(newLeftIKAngle, "newLeftIKAngle");

        Vector3 newLeftPosLocal = new(-r1 * Mathf.Sin(newLeftIKAngle), 0, r1 * Mathf.Cos(newLeftIKAngle));
        Vector3 newRightPosLocal = new(r1 * Mathf.Sin(newLeftIKAngle), 0, r1 * Mathf.Cos(newLeftIKAngle));

        Debug.DrawLine(newLeftPosLocal, newRightPosLocal, Color.yellow);

        //newLeftPos = Quaternion.AngleAxis(-playerAngle, upAxis) * newLeftPosLocal + axisOrigin;
        newLeftPos = newLeftPosLocal + axisOrigin;
        newRightPos = newRightPosLocal + axisOrigin;
    }

    private void CreateStepBox()
    {
        Vector3 velocity = _rigidbody.velocity;
        float dot = Vector3.Dot(transform.forward, velocity);
        float stepLength = velocity.magnitude * stepLengthMultiplier;
        if (dot == 0)
            stepLength = 0;
        else if (dot < 0)
            stepLength *= -1;

        Vector3 lowLeft = leftFootIK.position;
        Vector3 upLeft = leftFootIK.TransformPoint(0, 0, stepLength);
        Vector3 upRight = rightFootIK.TransformPoint(0, 0, stepLength);
        Vector3 lowRight = rightFootIK.position;

        DebugStepBox(lowLeft, upLeft, upRight, lowRight);
    }

    private void Move()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");
        Vector3 input = speed * Time.deltaTime * new Vector3(horizontal, 0, vertical);

        Vector3 movement = transform.TransformPoint(input);
        _rigidbody.MovePosition(movement);
    }

    private void TiltBody(float length)
    {
        float angle = Mathf.Rad2Deg * Mathf.Asin(length / PlayerHeight);

        transform.rotation = Quaternion.Euler(angle, 0, 0);
    }

    private void DebugStepBox(Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4)
    {
        Debug.DrawLine(p1, p2, Color.green);
        Debug.DrawLine(p2, p3, Color.green);
        Debug.DrawLine(p3, p4, Color.green);
        Debug.DrawLine(p4, p1, Color.green);
    }
}