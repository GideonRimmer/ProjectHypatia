using Aura2API;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MouseLook : MonoBehaviour
{

    public float sensitivity = 1f;
    public Transform PlayerBody;
    float xRotation = 0f;

    public List<GameObject> Key;
    public GameObject crosshair;
    public bool hasKey = false;
    public GameObject KeyImage;

    // Start is called before the first frame update
    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }

    // Update is called once per frame
    void Update()
    {
        float mouseX = Input.GetAxis("Mouse X") * sensitivity * 100 * Time.deltaTime;
        float mouseY = Input.GetAxis("Mouse Y") * sensitivity * 100 * Time.deltaTime;

        xRotation -= mouseY;
        xRotation = Mathf.Clamp(xRotation, -90f, 90f);

        transform.localRotation = Quaternion.Euler(xRotation, 0f, 0f);

        PlayerBody.Rotate(Vector3.up * mouseX);
        GetKey();
    }
    void GetKey()
    {
        if (Key.Count > 0) {
            for (int i = 0; i < Key.Count; i++)
            {
                Vector3 KeyDirection = (Key[i].transform.position - transform.position).normalized;
                float playerKeyAngle = Vector3.Angle(KeyDirection, transform.forward);
                if (Vector3.Distance(Key[i].transform.position, transform.position) < 2 && playerKeyAngle < 20 && !hasKey)
                {
                    Debug.Log("Key number " + i + " visible");
                    crosshair.SetActive(true);
                    if (Input.GetKeyDown(KeyCode.F))
                    {
                        Key[i].Destroy();
                        Key.RemoveAt(i);
                        i--;
                        hasKey = true;
                        KeyImage.SetActive(true);
                        crosshair.SetActive(false);
                    }
                }
                else
                {
                    crosshair.SetActive(false);
                }
            }
        }
    }
}
