using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class PostProcessing : MonoBehaviour
{
    [SerializeField] private EnvironmentManager environment;
    private Material atmosphereMat;
    private Camera cam;
    private RenderTexture colourTexture, depthTexture; 
    private Vector2 currentResolution = new Vector2(0.0f, 0.0f);

    void OnEnable()
    {
        atmosphereMat = new Material(Shader.Find("Hidden/AtmosphereShader"));
        cam = GetComponent<Camera>();
    }

    void Update()
    {
        if (currentResolution.x != Screen.width || currentResolution.y != Screen.height) {
            if (colourTexture)
                DestroyImmediate(colourTexture);
            if (depthTexture)
                DestroyImmediate(depthTexture);
            
            
            colourTexture = new RenderTexture(Screen.width, Screen.height, 0, RenderTextureFormat.ARGBFloat);
            depthTexture = new RenderTexture(Screen.width, Screen.height, 32, RenderTextureFormat.Depth);
            
            cam.SetTargetBuffers(colourTexture.colorBuffer, depthTexture.depthBuffer);
            currentResolution = new Vector2(Screen.width, Screen.height);
        }
    }

    void OnDisable() 
    {
        DestroyImmediate(atmosphereMat);
    }

    void OnRenderImage(Texture source, RenderTexture dest)
    {
        Matrix4x4 projMatrix = GL.GetGPUProjectionMatrix(cam.projectionMatrix, false);
        Matrix4x4 viewProjMatrix = projMatrix * cam.worldToCameraMatrix;
        atmosphereMat.SetMatrix("_CameraInvViewProjection", viewProjMatrix.inverse);

        atmosphereMat.SetTexture("_DepthTex", depthTexture);
        atmosphereMat.SetTexture("_Skybox", environment.GetSkybox());
        atmosphereMat.SetVector("_SunDir", environment.GetSunDir());
        atmosphereMat.SetVector("_SunColour", environment.GetSunColour());

        Graphics.Blit(colourTexture, dest, atmosphereMat);
        Graphics.Blit(dest, colourTexture);
    }
}
