using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    [SerializeField] private float rotationspeed;

    // Update is called once per frame
    void Update()
    {
        //transform.RotateAroundLocal(transform.position, rotationspeed);
        transform.Rotate(0, rotationspeed, 0);
    }
}
