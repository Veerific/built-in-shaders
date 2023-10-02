using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class AttachToCamera : MonoBehaviour
{
    

    public Material material;
    //public void Start()
    //{
    //    GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
    //}

    //This adds the shader to the camera
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }

}
