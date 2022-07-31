using DG.Tweening;
using UnityEngine;

public class StickPlayerMovement : MonoBehaviour
{
    private const float PlayerHeight = 3;

    public float stepLengthMultiplier = 0.06f;
    public float stepThreshold = 0.5f;
    public float bumpHeightMultiplier = 0.1f;
    public float bodyTiltMultiplier = 0.3f;
    public float speed, rotateSpeed;
    public Transform leftFootIK, rightFootIK;
    public Transform leftKnee, rightKnee;
    public Transform body;

    private Rigidbody _rigidbody;
    private bool _isFootMoving;
    private Vector3 _leftDest, _rightDest;
    private float _stepLength;
    private Vector3 _targetPosition = Vector3.zero;
    private Quaternion _targetRotation = Quaternion.identity;

    private void Awake()
    {
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void Update()
    {
        CreateStepBox();
        TiltBody(_stepLength * bodyTiltMultiplier);
        RaycastGround();
        DebugStepBox(_leftDest, _rightDest, transform.TransformPoint(0.5f, 0, 0), transform.TransformPoint(-0.5f, 0, 0));
        MoveFeetIKs();
        CheckKnee();
    }

    private void FixedUpdate()
    {
        MovePosition();
        MoveRotation();

        _rigidbody.MovePosition(_targetPosition);
        _rigidbody.MoveRotation(_targetRotation);
    }

    private void RaycastGround()
    {
        Vector3 leftDest = transform.TransformPoint(-0.5f, 1, _stepLength);
        Vector3 rightDest = transform.TransformPoint(0.5f, 1, _stepLength);

        if (Physics.Raycast(new Ray(leftDest, Vector3.down), out RaycastHit hitLeft, 5))
        {
            leftDest = hitLeft.point;
        }
        else
        {
            leftDest = transform.TransformPoint(-0.5f, 0, _stepLength);
        }

        if (Physics.Raycast(new Ray(rightDest, Vector3.down), out RaycastHit hitRight, 5))
        {
            rightDest = hitRight.point;
        }
        else
        {
            rightDest = transform.TransformPoint(0.5f, 0, _stepLength);
        }

        _leftDest = leftDest;
        _rightDest = rightDest;
    }

    private void CheckKnee()
    {
        if (Physics.Raycast(leftKnee.position + Vector3.up, Vector3.down, 1.1f) ||
            Physics.Raycast(rightKnee.position + Vector3.up, Vector3.down, 1.1f))
        {
            if (_isFootMoving) return;

            float leftDist = Vector3.Distance(_leftDest, leftFootIK.position);
            float rightDist = Vector3.Distance(_rightDest, rightFootIK.position);
            if (leftDist > rightDist)
            {
                MoveFoot(leftFootIK, _leftDest);
            }
            else
            {
                MoveFoot(rightFootIK, _rightDest);
            }
        }
    }

    private void CreateStepBox()
    {
        Vector3 velocity = _rigidbody.velocity;

        float dot = Vector3.Dot(transform.forward, velocity);
        _stepLength = velocity.magnitude * stepLengthMultiplier;
        if (dot == 0)
            _stepLength = 0;
        else if (dot < 0)
            _stepLength *= -1;
    }

    private void MoveFeetIKs()
    {
        float stepSpeedThreshold = stepThreshold * (1 + _rigidbody.velocity.magnitude);
        float leftDist = Vector3.Distance(_leftDest, leftFootIK.position);
        float rightDist = Vector3.Distance(_rightDest, rightFootIK.position);

        if (leftDist > stepSpeedThreshold && rightDist > stepSpeedThreshold)
        {
            if (_isFootMoving) return;

            if (leftDist > rightDist)
            {
                MoveFoot(leftFootIK, _leftDest);
            }
            else
            {
                MoveFoot(rightFootIK, _rightDest);
            }
        }
    }

    private async void MoveFoot(Transform ik, Vector3 dest)
    {
        _isFootMoving = true;
        float duration = _rigidbody.velocity.magnitude < 0.5f ? 0.15f : 0.5f / _rigidbody.velocity.magnitude;
        await ik.DOJump(dest, 0.2f, 1, duration).AsyncWaitForCompletion();
        _isFootMoving = false;
    }

    private void MovePosition()
    {
        float vertical = Input.GetAxis("Vertical");
        if (Input.GetKey(KeyCode.LeftShift))
            vertical *= 2;
        Vector3 input = speed * Time.deltaTime * new Vector3(0, 0, vertical);

        _targetPosition = transform.TransformPoint(input);

        float targetY = Mathf.Min(leftFootIK.position.y, rightFootIK.position.y);
        _targetPosition.y = Mathf.Lerp(transform.position.y, targetY, 0.1f);
    }

    private void MoveRotation()
    {
        float horizontal = Input.GetAxis("Horizontal") * Time.deltaTime * rotateSpeed;
        _targetRotation = Quaternion.AngleAxis(transform.rotation.eulerAngles.y + horizontal, Vector3.up);
    }

    private void TiltBody(float length)
    {
        float angle = Mathf.Rad2Deg * Mathf.Asin(length / PlayerHeight);
        body.transform.localRotation = Quaternion.Euler(angle, 0, 0);
    }

    private void DebugStepBox(Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4)
    {
        Debug.DrawLine(p1, p2, Color.yellow);
        Debug.DrawLine(p2, p3, Color.yellow);
        Debug.DrawLine(p3, p4, Color.yellow);
        Debug.DrawLine(p4, p1, Color.yellow);
    }
}