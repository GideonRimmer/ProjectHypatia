using System.Collections;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.UI;

public class LadyController : MonoBehaviour
{
    NavMeshAgent navMeshAgent;
    public Transform target;
    public Transform CurrentPatrolPath;
    public Transform[] currentWaypoints;
    public int targetWaypointIndex;
    public Transform LastSeenPosition;
    public Vector3 adjustNPCLookHeight;
    float GeneralIKWeight = .7f;
    float BodyIKWeight = .3f;
    float HeadIKWeight = .6f;
    
    public GameObject Player;
    PlayerMovement playerMovement;
    public NPCStateMachine NPCState;
    public float SpotPlayerDistance = 8f;
    public float SpotPlayerAngle = 90f;
    public float InvestigationTime = 6f;
    public LayerMask layerMask;
    public Transform Head;
    public bool attacking = false;
    public bool investigating = false;
    public SphereCollider punchHand;
    bool hit = false;

    public bool FoundPlayer = false;
    public bool playerDead = false;

    float playerVisibleTimer;
    float timeToSpotPlayer = 1.5f;
    float timeToSpotCrouch = 7f;
    float timeToSpotWalk = 1.5f;
    public Slider spottedSlider;
    public CanvasGroup spottedCanvasGroup;

    Animator anim;
    Vector2 smoothDeltaPosition = Vector2.zero;
    Vector2 velocity = Vector2.zero;

    // Start is called before the first frame update
    void Start()
    {
        anim = GetComponent<Animator>();
        playerMovement = Player.GetComponent<PlayerMovement>();
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
        if (Health.health > 0)
        {
            FoundPlayer = lookedLongEnough();
        }
        else if(Health.health<=0 && !playerDead)
        {
            FoundPlayer = false;
            NPCState = NPCStateMachine.GoBackToPatrol;
            playerDead = true;
        }
        
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

                if (Vector3.Distance(transform.position, Player.transform.position) <= navMeshAgent.stoppingDistance + 1f && FoundPlayer && !attacking)
                {
                        StartCoroutine(Attack());
                }

                if (!FoundPlayer && navMeshAgent.remainingDistance > navMeshAgent.stoppingDistance)
                {
                    NPCState = NPCStateMachine.CheckLastLocation;
                }
                break;

            case NPCStateMachine.CheckLastLocation:
                HeadToTarget(target);
                if (!navMeshAgent.pathPending && navMeshAgent.remainingDistance < navMeshAgent.stoppingDistance && !FoundPlayer)
                {
                    NPCState = NPCStateMachine.Investigate;
                }
                if (FoundPlayer)
                {
                    NPCState = NPCStateMachine.Chase;
                }
                break;

            case NPCStateMachine.Investigate:
                if (!investigating)
                {
                    GeneralIKWeight = 0;
                    StartCoroutine("Investigate");
                }

                if (FoundPlayer)
                {
                    investigating = false;
                    GeneralIKWeight = .7f;
                    anim.SetBool("investigate", investigating);
                    StopCoroutine("Investigate");
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

    void adjustSpotedTime()
    {
        if (playerMovement.isCrouching)
        {
            timeToSpotPlayer = timeToSpotCrouch;
        }
        else
            timeToSpotPlayer = timeToSpotWalk;

        float scaledValue = Mathf.Clamp(playerVisibleTimer / timeToSpotPlayer, 0, 1);

        spottedSlider.value = scaledValue;
        spottedCanvasGroup.alpha = scaledValue;
        if (scaledValue >= 1)
        {
            spottedCanvasGroup.alpha = 0; 
        }
    }

    bool lookedLongEnough()
    {
        if(NPCState== NPCStateMachine.Patrol)
        {
            if (CheckIfPlayerVisible())
            {
                playerVisibleTimer += Time.deltaTime;
            }
            else
            {
                playerVisibleTimer -= Time.deltaTime;
            }
            playerVisibleTimer = Mathf.Clamp(playerVisibleTimer, 0, timeToSpotPlayer);
            adjustSpotedTime();
            if (playerVisibleTimer >= timeToSpotPlayer)
            {
                LastSeenPosition.position = Player.transform.position;
                target = LastSeenPosition;
                return true;
            }
            return false;
        }
        else if(CheckIfPlayerVisible())
        {
            LastSeenPosition.position = Player.transform.position;
            target = LastSeenPosition;
            return true;
        }
        else
        {
            return false;
        }
    }


    IEnumerator Attack()
    {
        attacking = true;
        float duration = Time.time + 1.1f;
        while (Time.time < duration && !hit)
        {
            Collider[] colliders = Physics.OverlapSphere(punchHand.transform.position, punchHand.radius, 1<<9, QueryTriggerInteraction.Ignore);
            if (colliders.Length > 0)
            {
                hit = true;
                Health.health--;
            }
            yield return null;
        }
        if(Time.time < duration)
        {
            float newWaitTime = duration - Time.time;
            yield return new WaitForSeconds(newWaitTime);
        }
        hit = false;
        attacking = false;
    }

    public void LadyPunch()
    {
        //Debug.Log("Punch Sound");
    }

    IEnumerator Investigate()
    {
        investigating = true;
        anim.SetBool("investigate", investigating);
        yield return new WaitForSeconds(InvestigationTime);
        NPCState = NPCStateMachine.GoBackToPatrol;
        investigating = false;
    }


    bool CheckIfPlayerVisible()
    {
        float distanceFromPlayer = Vector3.Distance(Head.position, Player.transform.position);
        if (distanceFromPlayer < SpotPlayerDistance)
        {
            Vector3 PlayerDirection = (Player.transform.position - Head.position).normalized;
            float playerNPCAngle = Vector3.Angle(PlayerDirection, Head.forward);

             if (!Physics.Linecast(Head.position, Player.transform.position, layerMask) && distanceFromPlayer < 2.5f)
            {
                return true;
            }
            if (playerNPCAngle < SpotPlayerAngle / 2f)
            {
                if (!Physics.Linecast(Head.position, Player.transform.position, layerMask))
                {
                    return true;
                }
            }
        }
        return false;
    }

    void FindClosestWaypoint(Transform[] waypoints)
    {
        int closestWaypoint = 0;
        float closestDistance = Vector3.Distance(waypoints[0].position, transform.position);
        for (int i = 0; i < waypoints.Length; i++)
        {
            float tempDistance = Vector3.Distance(waypoints[i].position, transform.position);
            if (tempDistance < closestDistance)
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

        if (worldDeltaPosition.magnitude > navMeshAgent.radius)
            navMeshAgent.nextPosition = transform.position + 0.9f * worldDeltaPosition;
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

    void OnAnimatorIK()
    {
        anim.SetLookAtWeight(GeneralIKWeight, BodyIKWeight, HeadIKWeight);
        anim.SetLookAtPosition(target.position + adjustNPCLookHeight);
        
    }
}

public enum NPCStateMachine{
    Patrol,
    Chase,
    CheckLastLocation,
    Investigate,
    GoBackToPatrol
}
