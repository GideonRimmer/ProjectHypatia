using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class canvasLookAt : MonoBehaviour
{
    Camera mainCamera;
    // Start is called before the first frame update
    void Start()
    {
        mainCamera = Camera.main;
    }

    // Update is called once per frame
    void Update()
    {
        var lookPos = mainCamera.transform.position - transform.position;
        lookPos.y = 0;
        var rotation = Quaternion.LookRotation(lookPos);
        transform.rotation = rotation;
    }
}
