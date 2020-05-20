using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KeyController : MonoBehaviour
{
    public ParticleSystem keyEffect;
    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player")
        {
            Debug.Log("Key picked up");
            Instantiate(keyEffect, this.transform.position, Quaternion.identity);

            Destroy(this.gameObject);
        }
    }
}
