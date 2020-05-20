using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpinInPlace : MonoBehaviour
{
    public float rotateSpeed = 5.0f;

    void Update()
    {
        transform.Rotate(0, rotateSpeed, 0);
    }
}
