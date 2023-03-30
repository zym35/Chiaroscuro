using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CameraImageEffect : MonoBehaviour
{
    public Material edgeDetection, lightingMaterial;
    public RenderTexture outlineRT, lightingRT;
    public CommandBuffer cb;

    private void Update()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

    // [ImageEffectOpaque]
    // void OnRenderImage(RenderTexture src, RenderTexture dest)
    // {
    //     Graphics.Blit(src, dest, edgeDetection);
    //     //Graphics.Blit(src, null, edgeDetection);
    // }
    
    
    // public void OnWillRenderObject()
    // {
    //     var cam = GetComponent<Camera>();
    //     //cam.RemoveCommandBuffer(CameraEvent.BeforeLighting);
    //     // create new command buffer
    //     cb = new CommandBuffer();
    //     cb.name = "face cb";
    //     
    //     // create render texture for glow map
    //     int tempID = Shader.PropertyToID("_Temp1");
    //     cb.GetTemporaryRT(tempID, -1, -1, 24, FilterMode.Bilinear);
    //     cb.SetRenderTarget(tempID);
    //     cb.ClearRenderTarget(true, true, Color.black); // clear before drawing to it each frame!!
    //
    //     // draw all glow objects to it
    //     foreach(OutlinedObj o in FindObjectsOfType<OutlinedObj>())
    //     {
    //         Renderer r = o.GetComponent<Renderer>();
    //         Material outlineMat = o.outlineMat;
    //         cb.DrawRenderer(r, outlineMat);
    //     }
    //
    //     // set render texture as globally accessable 'glow map' texture
    //     cb.SetGlobalTexture("_OutlineFaceTex", tempID);
    //
    //     // add this command buffer to the pipeline
    //     cam.AddCommandBuffer(CameraEvent.BeforeLighting, cb);
    // }
}