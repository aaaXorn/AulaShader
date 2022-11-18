using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaguetteWavy : MonoBehaviour
{
    [Tooltip("Amplitude of the movement.")]
    [SerializeField] float _moveAmp = 1;
    [Tooltip("Speed of the movement.")]
    [SerializeField] float _moveSpd = 1;

    Vector3 _startPos;

    void Start()
    {
        _startPos = transform.position;
    }

    void Update()
    {
        float _sin = Time.time * _moveSpd;
        print(Mathf.Sin(_sin));
        transform.position += Vector3.up * Mathf.Sin(_sin) * _moveAmp;
    }
}
