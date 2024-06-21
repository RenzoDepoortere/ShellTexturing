using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(MeshRenderer))]
public class Shell_Physics : MonoBehaviour
{
    private Material _material;
    const string _MoveDirectionString = "_MovementDirection";

    private void Awake()
    {
        _material = GetComponent<MeshRenderer>().material;
    }

    private void FixedUpdate()
    {
        _material.SetVector(_MoveDirectionString, transform.InverseTransformVector(Vector3.down));
    }
}
