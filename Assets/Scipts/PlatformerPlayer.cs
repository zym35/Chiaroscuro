using UnityEngine;
using UnityEngine.Serialization;

public class PlatformerPlayer : MonoBehaviour
{
    public float acceleration;
    public float maxSpeed;
    public float jumpPower;
    public float gravity;
    public float distance = 0.1f;
    public float drag;
    public float frontThreshold;

    private Transform _camTransform;
    private Vector3 _posOnSurface, _surfaceNormal;
    private Vector3 _vel;

    private void Start()
    {
        _camTransform = Camera.main.transform;
        _posOnSurface = transform.position;
        _surfaceNormal = Vector3.zero;
        _vel = Vector3.zero;
    }

    void Update()
    {
        if (GetInput().magnitude > 0.1f && PlayerInSight())
        {
            var destOnSurface = _posOnSurface + _vel * Time.deltaTime;
            if (Physics.Raycast(_camTransform.position, destOnSurface - _camTransform.position, out RaycastHit hit, 1000))
            {
                _posOnSurface = hit.point;
                _surfaceNormal = hit.normal;
            }

            MoveAndRotate();
            UpdateVelocity(GetInput());
        }
    }

    private bool PlayerInSight()
    {
        bool blocked = Physics.Linecast(_camTransform.position, transform.position, out RaycastHit info);
        if (blocked)
            Debug.Log("blocked: " + info.transform.name);
        bool front = Vector3.Dot(_camTransform.forward, _posOnSurface - _camTransform.position)< frontThreshold ;
        return !blocked && front;
    }

    private Vector2 GetInput()
    {
        return new Vector2(Input.GetAxis("ArrowX"), Input.GetAxis("ArrowY"));
    }

    private void UpdateVelocity(Vector2 input)
    {
        // var horizontalAcc = input * acceleration;
        // if (Mathf.Abs(_vel.x) > drag)
        // {
        //     if (_vel.x > 0)
        //         horizontalAcc -= drag;
        //     else
        //         horizontalAcc += drag;
        // }
        
        // var verticalAcc = -gravity;
        // if (Input.GetKeyDown(KeyCode.W))
        //     verticalAcc += jumpPower;
        // var verticalAcc = input * acceleration;
        // if (Mathf.Abs(_vel.y) > drag)
        // {
        //     if (_vel.y > 0)
        //         verticalAcc -= drag;
        //     else
        //         verticalAcc += drag;
        // }

        _vel += acceleration * Time.deltaTime * new Vector3(input.x, input.y, 0);
        _vel *= drag;
        if (_vel.magnitude> maxSpeed)
            _vel = _vel.normalized * maxSpeed;
    }
    
    private void MoveAndRotate()
    {
        var dest = _posOnSurface + _surfaceNormal * distance;
        transform.Translate(dest - transform.position);
        transform.LookAt(_posOnSurface);
    }
    
    private bool IsBlockedByShadow(Vector3 pos, Vector3 dirToLight, float maxDistance = 1000f)
    {
        return Physics.Raycast(pos, dirToLight, maxDistance);
    }
}