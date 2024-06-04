using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer), typeof(MeshFilter))]
public class ShellTexture : MonoBehaviour
{
    [SerializeField] private Shader _shellShader;

    [Header("Settings")]
    [SerializeField] private int _nrShells = 2;
    [SerializeField] private int _density = 256;
    [SerializeField] private float _fullHeight = 1f;

    private MeshRenderer _meshRenderer;
    private MeshFilter _meshFilter;

    private GameObject[] _shells;

    private void Awake()
    {
        _meshRenderer = GetComponent<MeshRenderer>();
        _meshRenderer.material = new Material(_shellShader);
        SetShaderSettings(_meshRenderer.material, 0);

        _meshFilter = GetComponent<MeshFilter>();
    }

    private void Start()
    {
        _shells = new GameObject[_nrShells];

        GameObject createdShell;
        MeshRenderer createdRenderer;
        MeshFilter createdFilter;

        // Create layers
        for (int idx = 1; idx < _nrShells; ++idx)
        {
            // GameObject
            createdShell = new GameObject($"Shell_{idx}");
            createdShell.transform.SetParent(transform);
            _shells[idx] = createdShell;

            // Renderer
            createdRenderer = createdShell.AddComponent<MeshRenderer>();
            createdRenderer.material = _meshRenderer.material;

            // Mesh
            createdFilter = createdShell.AddComponent<MeshFilter>();
            createdFilter.mesh = _meshFilter.sharedMesh;

            // Material
            SetShaderSettings(createdRenderer.material, idx);
        }
    }

    private void SetShaderSettings(Material material, int idx)
    {
        material.SetInt("_NrShells", _nrShells);
        material.SetInt("_ShellIdx", idx);

        material.SetInt("_Density", _density);
        material.SetFloat("_FullHeight", _fullHeight);
    }
}
