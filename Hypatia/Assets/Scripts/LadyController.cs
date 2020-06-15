using Gamekit3D;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.Design;
using UnityEditorInternal;
using UnityEngine;
using UnityEngine.AI;

public class LadyController : MonoBehaviour
{
    NavMeshAgent navMeshAgent;
    public Transform target;
    public Transform CurrentPatrolPath;
    public Transform[] currentWaypoints;
    public int targetWaypointIndex;
    public Transform LastSeenPosition;

    public GameObject Player;
    public NPCStateMachine NPCState;
    public float attackDistance = 1f;
    public float attackTimeout = 1f;
    public float SpotPlayerDistance = 8f;
    public float SpotPlayerAngle = 90f;
    public float InvestigationTime = 6f;
    public LayerMask layerMask;
    public Transform Head;
    public bool attacking = false;
    public bool investigating = false;

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
        LastSeenPosition = Instantiate(LastSeenPosition, transform.position, transform.rotation, null);
    }

    private void Update()
    {
        CheckIfPlayerVisible();
        switch (NPCState)
        {
            case NPCStateMachine.Patrol:
                HeadToTarget(target);
                if (!navMeshAgent.pathPending && navMeshAgent.remainingDistance < navMeshAgent.stoppingDistance && !FoundPlayer)
                {
                    targetWaypointIndex++;
                    if (targetWaypointIndex >= currentWaypoints.Length)
                        targetWaypointIndex = 0;

                    target = currentWaypoints[targetWaypointIndex];
                    //HeadToTarget(target);
                }

                if (FoundPlayer)
                {
                    NPCState = NPCStateMachine.Chase;
                }
                break;

            case NPCStateMachine.Chase:
                HeadToTarget(target);

                if (Vector3.Distance(transform.position, Player.transform.position) <= navMeshAgent.stoppingDistance + .5f && FoundPlayer)
                {
                    NPCState = NPCStateMachine.Attack;
                }

                if (!navMeshAgent.pathPending && navMeshAgent.remainingDistance < navMeshAgent.stoppingDistance && !FoundPlayer)
                {
                    NPCState = NPCStateMachine.Investigate;
                }
                break;

            case NPCStateMachine.Attack:
                if (attacking == false)
                    StartCoroutine(Attack());
                break;

            case NPCStateMachine.Investigate:

                if (!investigating)
                {
                    StartCoroutine("Investigate");
                }

                if (FoundPlayer)
                {
                    StopCoroutine("Investigate");
                    investigating = false;
                    anim.SetBool("investigate", investigating);
                    NPCState = NPCStateMachine.Chase;
                }
                break;

            case NPCStateMachine.GoBackToPatrol:
                    FindClosestWaypoint(currentWaypoints);
                    NPCState = NPCStateMachine.Patrol;
                break;

            default:
                break;
        }

        trackPositionAndVelocity();
    }

    IEnumerator Attack()
    {
        attacking = true;
            yield return new WaitForSeconds(1f);
        NPCState = NPCStateMachine.Chase;
        attacking = false;
    }

    IEnumerator Investigate()
    {
        investigating = true;
        anim.SetBool("investigate", investigating);
        yield return new WaitForSeconds(InvestigationTime);
        NPCState = NPCStateMachine.GoBackToPatrol;
        investigating = false;
    }
    

    public void CheckIfPlayerVisible()
    {
        float distanceFromPlayer = Vector3.Distance(Head.position, Player.transform.position);
        if (distanceFromPlayer < SpotPlayerDistance)
        {
            Vector3 PlayerDirection = (Player.transform.position - Head.position).normalized;
            float playerNPCAngle = Vector3.Angle(PlayerDirection, Head.forward);
            if (playerNPCAngle < SpotPlayerAngle / 2f)
            {
                if (!Physics.Linecast(Head.position, Player.transform.position, layerMask))
                {
                    LastSeenPosition.position = Player.transform.position;
                    target = LastSeenPosition;
                    FoundPlayer = true;
                }
            }
            if (!Physics.Linecast(Head.position, Player.transform.position, layerMask) && distanceFromPlayer<3f)
            {
                LastSeenPosition.position = Player.transform.position;
                target = LastSeenPosition;
                FoundPlayer = true;
            }
        }
        else
            FoundPlayer = false;

    }

    void FindClosestWaypoint(Transform[] waypoints)
    {
        int closestWaypoint = 0;
        float closestDistance = Vector3.Distance(waypoints[0].position, transform.position);
        for (int i = 0; i < waypoints.Length; i++)
        {
            float tempDistance = Vector3.Distance(waypoints[i].position, transform.position);
            if(tempDistance < closestDistance)
            {
                closestWaypoint = i;
                closestDistance = tempDistance;
            }
        }
        targetWaypointIndex = closestWaypoint;
        target = waypoints[targetWaypointIndex];
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

        bool shouldMove = velocity.magnitude > 0.5f && navMeshAgent.remainingDistance > navMeshAgent.stoppingDistance;

        anim.SetBool("move", shouldMove);
        anim.SetBool("attack", attacking);
        anim.SetFloat("xvel", velocity.x);
        anim.SetFloat("yvel", velocity.y);

        /*// Pull character towards agent
		if (worldDeltaPosition.magnitude > navMeshAgent.radius)
		transform.position = navMeshAgent.nextPosition - 0.9f*worldDeltaPosition;*/

        if (worldDeltaPosition.magnitude > navMeshAgent.radius)
        navMeshAgent.nextPosition = transform.position + 0.9f*worldDeltaPosition;
    }

    void OnAnimatorMove()
    {
        // Update position based on animation movement using navigation surface height
        Vector3 position = anim.rootPosition;
        position.y = navMeshAgent.nextPosition.y;
        transform.position = position;
    }

    //Draw target direction
    private void OnDrawGizmos()
    {
        if (currentWaypoints.Length != 0)
        {
            Gizmos.color = Color.red;
            Gizmos.DrawLine(transform.position, target.position);
        }
    }
}

public enum NPCStateMachine{
    Patrol,
    Chase,
    Attack,
    Investigate,
    GoBackToPatrol
}
