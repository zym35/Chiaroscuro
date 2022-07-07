using UnityEngine;

public class StickPlayerMovement : MonoBehaviour
{
    public Transform leftWheelCenter, rightWheelCenter;
    public Transform leftFootTarget, rightFootTarget;
    public float rotateSpeed = 1;
    public float radius = 1;

    private void FixedUpdate()
    {
        leftWheelCenter.Rotate(transform.right, rotateSpeed);
        rightWheelCenter.Rotate(transform.right, rotateSpeed);

        Vector3 leftFoot = WheelRayCast(leftWheelCenter);
        Vector3 rightFoot = WheelRayCast(rightWheelCenter);
        leftFootTarget.position = leftFoot;
        rightFootTarget.position = rightFoot;
    }

    private Vector3 WheelRayCast(Transform wheelCenter)
    {
        Ray ray = new Ray(wheelCenter.position, wheelCenter.forward);

        Vector3 dest;
        if (Physics.Raycast(ray, out RaycastHit hit, radius))
        {
            dest = hit.point;
            Debug.DrawLine(wheelCenter.position, dest, Color.green);
        }
        else
        {
            dest = wheelCenter.TransformPoint(Vector3.forward * radius);
            dest = new Vector3(dest.x, dest.y / 2, dest.z);
            Debug.DrawLine(wheelCenter.position, dest, Color.green);
        }

        return dest;
    }
}