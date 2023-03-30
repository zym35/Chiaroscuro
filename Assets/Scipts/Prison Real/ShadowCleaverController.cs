using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using UnityEngine.Serialization;

public class ShadowCleaverController : MonoBehaviour
{
    public Transform knifeTransform;
    public Camera mainCam;
    public TrailRenderer knifeTrail;
    public bool equipped;
    
    private Vector3 _originalKnifePos;
    private Vector3 _knifeStartPos, _knifeEndPos;
    private bool _canCut;
    
    private void Start()
    {
        knifeTrail.emitting = false;
        equipped = true;
    }

    private void Update()
    {
        // shadow cut
        if (Input.GetMouseButtonDown(0) && equipped)
        {
            equipped = false;
            if (RayCastFromCrosshair(out Vector3 point))
            {
                _originalKnifePos = transform.InverseTransformPoint(knifeTransform.position);
                _knifeStartPos = point;
                _canCut = true;
            }
            else
            {
                _canCut = false;
            }
        }
        if (Input.GetMouseButton(0) && _canCut)
        {
            if (RayCastFromCrosshair(out Vector3 point))
            {
                knifeTransform.position = Vector3.Lerp(knifeTransform.position, point, Time.deltaTime * 6);
                if (Vector3.Distance(knifeTransform.position, point) < 0.1f && !knifeTrail.emitting)
                {
                    knifeTrail.emitting = true;
                }
            }
        }
        if (Input.GetMouseButtonUp(0) && !equipped)
        {
            equipped = true;
            knifeTrail.emitting = false;
            knifeTransform.DOLocalMove(_originalKnifePos, .5f);
            if (RayCastFromCrosshair(out Vector3 point))
            {
                _knifeEndPos = point;
                if (_canCut)
                {
                    Cut();
                }
            }
        }
        
        
        // shadow substantiation
        if (Input.GetMouseButtonDown(1))
        {
            if (equipped)
            {
                if (RayCastFromCrosshair(out Vector3 point))
                {
                    _originalKnifePos = transform.InverseTransformPoint(knifeTransform.position);
                    knifeTransform.SetParent(null);
                    knifeTransform.DOMove(point, .5f);
                    equipped = false;
                    StartCoroutine(StartKnifeTouch(0.5f));
                }
            }
            else
            {
                knifeTransform.SetParent(transform);
                knifeTransform.DOLocalMove(_originalKnifePos, .5f);
                equipped = true;
                OnKnifeTouchCancel();
            }
        }
    }

    IEnumerator StartKnifeTouch(float delay)
    {
        yield return new WaitForSeconds(delay);
        OnKnifeTouch();
    }

    private void OnKnifeTouch()
    {
        if (LevelManager.Instance.PositionInAnyShadow(knifeTransform.position, out List<GameObject> objs))
        {
            foreach (GameObject o in objs)
            {
                if (o.TryGetComponent(out Rigidbody r))
                {
                    r.isKinematic = true;
                }
            }
        }
    }

    private void OnKnifeTouchCancel()
    {
        if (LevelManager.Instance.PositionInAnyShadow(knifeTransform.position, out List<GameObject> objs))
        {
            foreach (GameObject o in objs)
            {
                if (o.TryGetComponent(out Rigidbody r))
                {
                    r.isKinematic = false;
                }
            }
        }
    }

    private void Cut()
    {
        Vector3 middle = (_knifeStartPos + _knifeEndPos) / 2.0f;
        if (LevelManager.Instance.PositionInAnyShadow(middle, out List<GameObject> objs))
        {
            foreach (GameObject o in objs)
            {
                if (o.TryGetComponent(out Cuttable c))
                {
                    Debug.Log("find cuttable");
                    Plane plane = new Plane(_knifeStartPos, _knifeEndPos, o.transform.position);
                    c.Cut(plane, 0.3f);
                }
            }
        }
    }

    private bool RayCastFromCrosshair(out Vector3 point)
    {
        if (Physics.Raycast(mainCam.ScreenPointToRay(new Vector3(Screen.width / 2.0f, Screen.height / 2.0f, 0)),
                out RaycastHit hit))
        {
            point = hit.point;
            return true;
        }

        point = Vector3.zero;
        return false;
    }
}
