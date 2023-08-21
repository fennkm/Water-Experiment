using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class EnvironmentManager : MonoBehaviour
{
    [SerializeField] private Vector2 sunPos;
    [SerializeField] private Color sunCol;
    [SerializeField] private Material waterMat;
    [SerializeField] private Cubemap skybox;

    void Update()
    {
        waterMat.SetVector("_SunDir", GetSunDir());
        waterMat.SetColor("_SunColour", sunCol);
        waterMat.SetTexture("_Skybox", GetSkybox());
    }

    public Cubemap GetSkybox() { return skybox; }

    public Color GetSunColour() { return sunCol; }

    public Vector3 GetSunDir() 
    {
        return new Vector3
        (
            Mathf.Cos(sunPos.y) * Mathf.Sin(sunPos.x),
            Mathf.Sin(sunPos.y),
            Mathf.Cos(sunPos.y) * Mathf.Cos(sunPos.x)
        );
    }
}
