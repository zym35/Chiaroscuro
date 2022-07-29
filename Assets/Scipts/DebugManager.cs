using UnityEngine;

public class DebugManager : MonoBehaviour
{
    public static DebugManager Instance;

    [SerializeField] private GameObject debugPoint;

    private void Awake()
    {
        Instance = this;
    }

    public void SpawnDebugPoint(Vector3 position)
    {
        Instantiate(debugPoint, position, Quaternion.identity);
    }
}