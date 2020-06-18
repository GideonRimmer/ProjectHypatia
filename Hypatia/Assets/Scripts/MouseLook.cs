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
    public Text QuestText;
    string steal = "Steal a gate Key from the next patrol";
    string open = "Open the gate";
    public LadyController[] ladyControllers;
    public CanvasGroup StealthStateCanvasGroup;

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
        StealthStateController();
    }
    void GetKey()
    {
        for (int i = 0; i < Key.Count; i++)
        {
            Vector3 KeyDirection = (Key[i].transform.position - transform.position).normalized;
            float playerKeyAngle = Vector3.Angle(KeyDirection, transform.forward);
            if (Key[i].activeInHierarchy) {
                if (Vector3.Distance(Key[i].transform.position, transform.position) < 2 && playerKeyAngle < 20 && !hasKey)
                {
                    Debug.Log("Key number " + i + " visible");

                    if (Input.GetKeyDown(KeyCode.F))
                    {
                        Key[i].SetActive(false);
                        hasKey = true;
                        KeyImage.SetActive(true);
                        crosshair.SetActive(false);
                        QuestText.text = open;
                    }
                    crosshair.SetActive(true);
                    break;
                }
            }
            else
            {
                crosshair.SetActive(false);
            }
        }
    }

    void StealthStateController()
    {
        int spottedCount = 0;
        foreach (LadyController lc in ladyControllers)
        {
            if (lc.FoundPlayer == true)
                spottedCount++;
        }
        if (spottedCount<=0)
        {
            Mathf.Clamp(StealthStateCanvasGroup.alpha -= Time.deltaTime, 0, 1);
        }
        if (spottedCount>0)
        {
            StealthStateCanvasGroup.alpha = Mathf.PingPong(Time.time, 1);
        }
    }
}
