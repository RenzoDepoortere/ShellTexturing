using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class NoiseGenerator : MonoBehaviour
{
    const int _textureResolution = 1024;
    const string _computeShaderString = "Assets/ShellTexturing/NoiseGenerator/NoiseComputeShader.compute";
    const string _texturePathString = "Assets/ShellTexturing/NoiseGenerator/NoiseTexture.asset";

    [MenuItem("Tools/Generate Noise Texture")]
    public static void GenerateTexture()
    {
        // Create renderTexture
        RenderTexture noiseRenderTexture = new RenderTexture(_textureResolution, _textureResolution, 0);
        noiseRenderTexture.enableRandomWrite = true;
        noiseRenderTexture.Create();

        // Initialize shader
        ComputeShader noiseShader = AssetDatabase.LoadAssetAtPath<ComputeShader>(_computeShaderString);
        int kernelID = noiseShader.FindKernel("CSMain");
        noiseShader.SetTexture(kernelID, "NoiseTexture", noiseRenderTexture);

        // Dispatch shader
        uint threadCount_X;
        uint threadCount_Y;
        uint threadCount_Z;
        noiseShader.GetKernelThreadGroupSizes(kernelID, out threadCount_X, out threadCount_Y, out threadCount_Z);
        noiseShader.Dispatch(kernelID, Mathf.CeilToInt(_textureResolution / threadCount_X), Mathf.CeilToInt(_textureResolution / threadCount_Y), 1);

        // Create noise texture
        Texture2D noiseTexture = new Texture2D(_textureResolution, _textureResolution, TextureFormat.RGB24, false);
        RenderTexture.active = noiseRenderTexture;
        noiseTexture.ReadPixels(new Rect(0, 0, noiseRenderTexture.width, noiseRenderTexture.height), 0, 0);
        noiseTexture.Apply();

        // "Spawn" texture
        string texturePath = AssetDatabase.GenerateUniqueAssetPath(_texturePathString);
        AssetDatabase.CreateAsset(noiseTexture, texturePath);
    }
}
