using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerDamage : MonoBehaviour
{
    public int maxHitPoints = 5;
    [SerializeField] private int currentHitPoints;
    
    //private Rigidbody rigidbody;
    //public float pushForce = 10.0f;
    void Start()
    {
        //rigidbody = GetComponent<Rigidbody>();
        currentHitPoints = maxHitPoints;
    }

    // Update is called once per frame
    void Update()
    {
        if (currentHitPoints <= 0)
        {
            Debug.Log("GAME OVER!");
            // TODO: GameOver();
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Enemy" && currentHitPoints >= 0)
        {
            // Reduce the player's hit points.
            currentHitPoints -= 1;
            Debug.Log("Player hit! Current HP: " + currentHitPoints);

            // TODO: play hit effect

            /*
            // Push the player back.
            // Calculate the angle between the collision point and the player.
            Vector3 pushDirection = collision.contacts[0].point - transform.position;
            // Get the opposite direction and normalize it.
            pushDirection = -pushDirection.normalized;
            // Add the force in the direction
            rigidbody.AddForce(pushDirection * pushForce);
            */
        }
    }
}
