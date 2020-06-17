using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public CharacterController controller;
    float characterSpeed;
    float characterWalk = 3f;
    float characterCrouch = 1.7f;
    public float characterHeight;
    public float cameraHeight = 1;
    public bool isCrouching = false;
    Camera mainCamera;
    float gravity = -9.81f;
    Vector3 velocity;
    public Transform GroundCheck;
    float groundDistance = 0.4f;
    public LayerMask groundMask;
    bool isGrounded;

    private void Start()
    {
        Cursor.visible = false;
        controller = GetComponent<CharacterController>();
        mainCamera = Camera.main;
        characterHeight = controller.height;
        characterSpeed = characterWalk;
    }
    private void Update()
    {
        isGrounded = Physics.CheckSphere(GroundCheck.position, groundDistance, groundMask);
        if(isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
        }

        if (Input.GetKeyDown(KeyCode.C))
        {
            isCrouching = !isCrouching;
            if (isCrouching)
            {
                characterSpeed = characterCrouch;
                controller.height = 1.3f;
                mainCamera.transform.localPosition = new Vector3(0,0.5f,0);
            }
            if (!isCrouching)
            {
                characterSpeed = characterWalk;
                controller.height = characterHeight;
                mainCamera.transform.localPosition = new Vector3(0, 1, 0);
            }

        }

        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");

        Vector3 move = transform.right * x + transform.forward * z;
        controller.Move(move * characterSpeed * Time.deltaTime);

        velocity.y += gravity * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);
        
    }
}
