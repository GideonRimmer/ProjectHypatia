using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class OpenTheGate : MonoBehaviour
{
    MouseLook mouseLook;
    Vector3 currentGateVector;
    Vector3 GateOpenVector = new Vector3(0, -4, 0 );
    public Transform GateTransform;
    float GateLoweringSpeed = 1f;
    public AudioClip GateClip;
    public AudioSource GateSound;
    bool runOnce = false;
    public Text QuestText;
    bool endGameGate = false;
    string steal = "Steal a gate Key from the next patrol";
    string exit = "Exit the City";

    private void Start()
    {
        mouseLook = Camera.main.GetComponentInChildren<MouseLook>();
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if(other.name == "CharacterController" && !runOnce)
        {
            if (mouseLook.hasKey == true && !runOnce)
            {
                runOnce = true;
                mouseLook.hasKey = false;
                mouseLook.KeyImage.SetActive(false);
                QuestText.text = steal;
                if (endGameGate)
                {
                    QuestText.text = exit;
                }
                Debug.Log("PlayerInside");
                /*if(GateSound.clip == null)
                {
                    GateSound.clip = GateClip;
                }
                if(!GateSound.isPlaying)
                    GateSound.Play();*/
                StartCoroutine(LowerTheGate());
            }
        }
    }

    IEnumerator LowerTheGate()
    {
        
        currentGateVector = GateTransform.position;
        currentGateVector += GateOpenVector;
            yield return new WaitForSeconds(.1f);
        while (GateTransform.localPosition.y>0)
        {
            GateTransform.localPosition = Vector3.Lerp(GateTransform.localPosition, currentGateVector, Time.deltaTime * GateLoweringSpeed);
            yield return null;
        }
    }
}
