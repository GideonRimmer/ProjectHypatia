using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class LadyController : MonoBehaviour
{
    NavMeshAgent navMeshAgent;
    public Transform target;
    public Transform CurrentPatrolPath;
    public Transform[] currentWaypoints;
    public int targetWaypointIndex;
    public bool FoundPlayer = false;

    Animator anim;
    Vector2 smoothDeltaPosition = Vector2.zero;
    Vector2 velocity = Vector2.zero;

    // Start is called before the first frame update
    void Start()
    {
        anim = GetComponent<Animator>();
        currentWaypoints = new Transform[CurrentPatrolPath.childCount];

        if (currentWaypoints.Length != 0)
        {
            for (int i = 0; i < currentWaypoints.Length; i++)
            {
                currentWaypoints[i] = CurrentPatrolPath.GetChild(i);
            }
        }
        navMeshAgent = GetComponent<NavMeshAgent>();
        navMeshAgent.updatePosition = false;
        FindClosestWaypoint(currentWaypoints);
    }

    private void Update()
    {
        Patrol();
        trackPositionAndVelocity();
    }



    void FindClosestWaypoint(Transform[] waypoints)
    {
        int closestWaypoint = 0;
        for (int i = 0; i < waypoints.Length; i++)
        {
            if (Vector3.Distance(waypoints[i].position, transform.position) < Vector3.Distance(waypoints[closestWaypoint].position, transform.position))
            {
                closestWaypoint = i;
            }
        }
        targetWaypointIndex = closestWaypoint;

        target = waypoints[targetWaypointIndex];
    }

    void Patrol()
    {
        if (!FoundPlayer)
        {
            if (!navMeshAgent.pathPending && navMeshAgent.remainingDistance < 0.5f)
            {
                targetWaypointIndex++;
                if (targetWaypointIndex >= currentWaypoints.Length)
                    targetWaypointIndex = 0;

                target = currentWaypoints[targetWaypointIndex];
                HeadToTarget(target);
            }
        }
    }

    public void HeadToTarget(Transform _target)
    {
        navMeshAgent.destination = _target.position;
    }

    void trackPositionAndVelocity()
    {
        Vector3 worldDeltaPosition = navMeshAgent.nextPosition - transform.position;

        // Map 'worldDeltaPosition' to local space
        float dx = Vector3.Dot(transform.right, worldDeltaPosition);
        float dy = Vector3.Dot(transform.forward, worldDeltaPosition);
        Vector2 deltaPosition = new Vector2(dx, dy);

        // Low-pass filter the deltaMove
        float smooth = Mathf.Min(1.0f, Time.deltaTime / 0.15f);
        smoothDeltaPosition = Vector2.Lerp(smoothDeltaPosition, deltaPosition, smooth);

        // Update velocity if delta time is safe
        if (Time.deltaTime > 1e-5f)
            velocity = smoothDeltaPosition / Time.deltaTime;
        velocity = velocity.normalized;

        bool shouldMove = velocity.magnitude > 0.5f && navMeshAgent.remainingDistance > navMeshAgent.radius;

        // Update animation parameters
        anim.SetBool("move", shouldMove);
        anim.SetFloat("xvel", velocity.x);
        anim.SetFloat("yvel", velocity.y);

        /*// Pull character towards agent
		if (worldDeltaPosition.magnitude > navMeshAgent.radius)
		transform.position = navMeshAgent.nextPosition - 0.9f*worldDeltaPosition;*/

        /*if (worldDeltaPosition.magnitude > navMeshAgent.radius)
        navMeshAgent.nextPosition = transform.position + 0.9f*worldDeltaPosition;*/
    }

    void OnAnimatorMove()
    {
        // Update postion to agent position
        //		transform.position = agent.nextPosition;

        // Update position based on animation movement using navigation surface height
        Vector3 position = anim.rootPosition;
        position.y = navMeshAgent.nextPosition.y;
        transform.position = position;
    }

    private void OnDrawGizmos()
    {
        if (currentWaypoints.Length != 0)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawLine(transform.position, target.position);
        }
    }
}
