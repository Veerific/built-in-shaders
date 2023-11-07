using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    private float horizontalInput;
    private float verticalInput;

    private Vector3 movedirection;
    private Rigidbody objRb;
    public float speed;
    public float sensitivity;


    void Start()
    {
        objRb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        horizontalInput = Input.GetAxis("Horizontal");
        verticalInput = Input.GetAxis("Vertical");
        movedirection = new Vector3(horizontalInput, 0, verticalInput);
    }
    void FixedUpdate()
    {
        objRb.velocity = (transform.forward * verticalInput * speed) + (horizontalInput * transform.right * speed);
        objRb.MoveRotation(objRb.rotation * Quaternion.Euler(new Vector3(0, Input.GetAxis("Mouse X") * sensitivity, 0)));
  
    }
}


