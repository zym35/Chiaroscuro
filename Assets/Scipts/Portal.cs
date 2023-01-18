using UnityEngine;

public class Portal : MonoBehaviour
{
    [SerializeField] private Portal linkedPortal;
    private Camera _playerCam;
    private Camera _portalCam;
    private RenderTexture _viewTexture;
}
