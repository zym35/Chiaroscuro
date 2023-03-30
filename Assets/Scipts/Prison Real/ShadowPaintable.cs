using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowPaintable : MonoBehaviour
{
    const int TEXTURE_SIZE = 1024;
    
    public RenderTexture maskRenderTexture;
    public RenderTexture supportTexture;
    
    Renderer rend;

    int maskTextureID = Shader.PropertyToID("_MaskTexture");

    public RenderTexture getMask() => maskRenderTexture;
    public RenderTexture getSupport() => supportTexture;
    public Renderer getRenderer() => rend;

    void Start() {
        maskRenderTexture = new RenderTexture(TEXTURE_SIZE, TEXTURE_SIZE, 0);
        maskRenderTexture.filterMode = FilterMode.Bilinear;

        supportTexture = new RenderTexture(TEXTURE_SIZE, TEXTURE_SIZE, 0);
        supportTexture.filterMode =  FilterMode.Bilinear;

        rend = GetComponent<Renderer>();
        rend.material.SetTexture(maskTextureID, maskRenderTexture);

        ShadowPaintManager.instance.InitTextures(this);
    }

    void OnDisable(){
        maskRenderTexture.Release();
        supportTexture.Release();
    }
}
