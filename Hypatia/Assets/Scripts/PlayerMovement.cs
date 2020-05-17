using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    public CharacterController controller;
    public float characterSpeed;
    public float JumpHeight = 3f;
    float gravity = -9.81f;
    Vector3 velocity;
    public Transform GroundCheck;
    float groundDistance = 0.4f;
    public LayerMask groundMask;
    bool isGrounded;

    private void Start()
    {
        controller = GetComponent<CharacterController>();
    }
    private void Update()
    {
        isGrounded = Physics.CheckSphere(GroundCheck.position, groundDistance, groundMask);
        if(isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
        }
        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");

        Vector3 move = transform.right * x + transform.forward * z;
        controller.Move(move * characterSpeed * Time.deltaTime);

        if(Input.GetButtonDown("Jump") && isGrounded)
        {
            velocity.y = Mathf.Sqrt(JumpHeight * -2f * gravity);
        }

        velocity.y += gravity * Time.deltaTime;
        controller.Move(velocity * Time.deltaTime);
        
    }

}
