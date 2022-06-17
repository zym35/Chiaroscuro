using System;
using UnityEngine;

[ExecuteInEditMode]
public class MTOImageEffect : MonoBehaviour
{
    public Material material;

    [ImageEffectOpaque]
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
        Graphics.Blit(src, dest, material);
    }
}