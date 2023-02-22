using DG.Tweening;
using UnityEngine;

public class MonocularController : MonoBehaviour
{
    public Transform playerTransform;
    public Transform camTransform;
    public Transform monocularTransform;
    public float sensitivity;

    private bool _equipped;
    private static readonly Vector3 OriginalMonocularPos = new Vector3(-0.13f,-0.11f,0.24f);
    private static readonly Vector3 OriginalMonocularRot = new Vector3(90,0,0);

    private void Start()
    {
        _equipped = false;
        monocularTransform.localPosition = OriginalMonocularPos;
        monocularTransform.localEulerAngles = OriginalMonocularRot;
    }

    private void Update()
    {
        if (Input.GetMouseButtonDown(0) && !_equipped)
        {
            camTransform.localPosition = Vector3.zero;
            _equipped = true;
            monocularTransform.DOLocalMove(Vector3.zero, .5f);
            monocularTransform.DOLocalRotate(Vector3.zero, .5f);
        }
        if (Input.GetMouseButton(0))
        {
            camTransform.Translate(0, 0, sensitivity * Input.mouseScrollDelta.y, Space.Self);
            if (camTransform.localPosition.z < 0)
                camTransform.localPosition = Vector3.zero;
        }

        if (Input.GetMouseButtonUp(0) && _equipped)
        {
            playerTransform.Translate(camTransform.localPosition, Space.Self);
            monocularTransform.DOLocalMove(OriginalMonocularPos, .5f);
            monocularTransform.DOLocalRotate(OriginalMonocularRot, .5f);
            _equipped = false;
        }
    }
}
