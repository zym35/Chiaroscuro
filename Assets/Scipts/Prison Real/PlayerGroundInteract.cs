using System;
using System.Collections.Generic;
using UnityEngine;

public class PlayerGroundInteract : MonoBehaviour
{
    public bool enableFallThrough;
    public Transform playerFoot;
    public Transform knife;

    private Collider _playerCollider;
    private Rigidbody _playerRigidbody;

    private void Awake()
    {
        _playerCollider = GetComponent<Collider>();
        _playerRigidbody = GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        if (enableFallThrough)
        {
            if (LevelManager.Instance.PositionInAnyShadow(playerFoot.position, out List<GameObject> objs))
            {
                if (!LevelManager.Instance.PositionInAnyShadow(knife.position, out List<GameObject> objs1) ||
                     objs == objs1 || FindObjectOfType<ShadowCleaverController>().equipped)
                {
                    _playerRigidbody.velocity *= 0.3f;
                    _playerCollider.isTrigger = true;
                    enableFallThrough = false;
                }
                
            }
        }
    }
}
