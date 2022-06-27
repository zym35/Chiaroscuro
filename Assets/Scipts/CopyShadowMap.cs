using System;
using UnityEngine;
using UnityEngine.Rendering;

//  [ExecuteInEditMode]
public class CopyShadowMap : MonoBehaviour
{
    private CommandBuffer cb;
    public RenderTexture renderTexture;

    void OnEnable()
    {
        var light = GetComponent<Light>();
        if (light)
        {
            cb = new CommandBuffer();
            cb.name = "CopyShadowMap";
            cb.SetGlobalTexture("_DirectionalShadowMask", new RenderTargetIdentifier(BuiltinRenderTextureType.CurrentActive));
            light.AddCommandBuffer(LightEvent.AfterScreenspaceMask, cb);
        }
    }

    private void Update()
    {
        Graphics.CopyTexture(Shader.GetGlobalTexture("_DirectionalShadowMask"), renderTexture);
        //renderTexture = (RenderTexture) Shader.GetGlobalTexture("_DirectionalShadowMask");
    }

    void OnDisable()
    {
        var light = GetComponent<Light>();
        if (light)
        {
            light.RemoveCommandBuffer(LightEvent.AfterScreenspaceMask, cb);
        }
    }
}