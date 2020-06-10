using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathHolder : MonoBehaviour
{
    Transform pathHolder;
    public Transform[] childrenTransforms;
    public float GizmoSize = 0.3f;

    private void OnDrawGizmos()
    {
        pathHolder = transform;
        if (pathHolder.childCount != 0)
        {
            childrenTransforms = pathHolder.GetComponentsInChildren<Transform>();
            Vector3 startPosition = pathHolder.GetChild(0).position;
            Vector3 previousPosition = startPosition;

            for (int i = 1; i < childrenTransforms.Length; i++)
            {
                Gizmos.DrawSphere(childrenTransforms[i].position, GizmoSize);
                Gizmos.DrawLine(previousPosition, childrenTransforms[i].position);
                previousPosition = childrenTransforms[i].position;
            }
            Gizmos.DrawLine(previousPosition, startPosition);
        }
    }
}
