using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChasePlayer : MonoBehaviour
{
    private Rigidbody rigidbody;
    private Animator animator;
    public float rotateSpeed;

    // Move towards parameters.
    public float moveTowardsSpeed;
    [SerializeField] bool isMovingTowards;
    [SerializeField] float distanceToClosestLeader;
    private List<string> leaderTag = new List<string>()
    {
        "Player"
    };
    public int searchLeaderRadius;
    public int minDistanceFromLeader;

    void Start()
    {
        rigidbody = GetComponent<Rigidbody>();
        animator = GetComponent<Animator>();
        isMovingTowards = false;
    }

    void Update()
    {
        FindLeaderInRadius();
    }

    protected void LateUpdate()
    {
        transform.localEulerAngles = new Vector3(0, transform.localEulerAngles.y, 0);
    }

    void FindLeaderInRadius()
    {
        // Set the default distance to infinity, so we can revert to a value.
        distanceToClosestLeader = Mathf.Infinity;
        // Set the default closest target to null.
        GameObject closestTarget = null;
        // Create an array of all GameObjects with the the tag "target" in the scene.
        foreach (string tag in leaderTag)
        {
            GameObject[] allTargets = GameObject.FindGameObjectsWithTag(tag);

            foreach (GameObject currentTarget in allTargets)
            {
                // Find the distance between this GameObject and each target's position.
                float distanceToTarget = (currentTarget.transform.position - this.transform.position).sqrMagnitude;
                // If the distance to the target is less than the distance to other targets, set currentTarget to be closestTarget.
                if (distanceToTarget < distanceToClosestLeader)
                {
                    distanceToClosestLeader = distanceToTarget;
                    closestTarget = currentTarget;
                }
            }

            if (closestTarget != null && distanceToClosestLeader > minDistanceFromLeader && distanceToClosestLeader <= searchLeaderRadius)
            {
                //animator.speed = moveAnimatorSpeed;
                Debug.DrawLine(this.transform.position, closestTarget.transform.position);

                isMovingTowards = true;
                animator.SetBool("IsWalking", true);

                // Automatically move towards the target.
                transform.position = Vector3.MoveTowards(transform.position, closestTarget.transform.position, moveTowardsSpeed * Time.deltaTime);

                // Auto rotate towards the target.
                Vector3 targetDirection = closestTarget.transform.position - transform.position;

                Vector3 newDirection = Vector3.RotateTowards(transform.forward, targetDirection, rotateSpeed * Time.deltaTime, 0.0f);
                Debug.DrawRay(transform.position, newDirection, Color.red);

                // Move position a step towards to the target.
                transform.rotation = Quaternion.LookRotation(newDirection);
            }
            else if (closestTarget != null && (distanceToClosestLeader <= minDistanceFromLeader || distanceToClosestLeader > searchLeaderRadius))
            {
                isMovingTowards = false;
                animator.SetBool("IsWalking", false);
                rigidbody.freezeRotation = true;
            }
        }
    }
}
