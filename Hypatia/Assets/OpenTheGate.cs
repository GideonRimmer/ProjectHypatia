using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class OpenTheGate : MonoBehaviour
{
    MouseLook mouseLook;
    Vector3 currentGateVector;
    Vector3 GateOpenVector = new Vector3(0, -4, 0);
    public Transform GateTransform;
    float GateLoweringSpeed = .01f;
    public AudioClip GateClip;
    public AudioSource GateSound;
    bool runOnce = false;
    public Text QuestText;
    string steal = "Steal a gate Key from the next patrol";

    private void Start()
    {
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.name == "CharacterController" && !runOnce)
        {
            mouseLook = other.GetComponentInChildren<MouseLook>();
            if (mouseLook.hasKey == true && !runOnce)
            {
                runOnce = true;
                mouseLook.hasKey = false;
                mouseLook.KeyImage.SetActive(false);
                QuestText.text = steal;
                Debug.Log("PlayerInside");
                if(GateSound.clip == null)
                {
                    GateSound.clip = GateClip;
                }
                if(!GateSound.isPlaying)
                    GateSound.Play();
                StartCoroutine(LowerTheGate());
            }
        }
    }

    IEnumerator LowerTheGate()
    {
        
        currentGateVector = GateTransform.localPosition;
        currentGateVector += GateOpenVector;
        Debug.Log(GateTransform.localPosition.y +" " + GateOpenVector.y);
            yield return new WaitForSeconds(.1f);
        while (GateTransform.position.y>GateOpenVector.y)
        {
            GateTransform.localPosition = Vector3.Lerp(GateTransform.localPosition, currentGateVector, Time.deltaTime * GateLoweringSpeed);
            yield return null;
        }
    }
}
