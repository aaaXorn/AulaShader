using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move4 : MonoBehaviour
{
    bool _x_gotoR;

    Vector3 _initPos;

    [SerializeField]
    Vector3 _targetPos;

    [SerializeField]
    float spd;

    void Start()
    {
        _initPos = transform.position;
    }
    
    void Update()
    {
        if(_x_gotoR)
        {
            transform.position = Vector3.MoveTowards(transform.position, _initPos + _targetPos, Time.deltaTime * spd);
            if(Vector3.Distance(transform.position, _initPos + _targetPos) < 0.1f) _x_gotoR = false;
        }
        else
        {
            transform.position = Vector3.MoveTowards(transform.position, _initPos - _targetPos, Time.deltaTime * spd);
            if(Vector3.Distance(transform.position, _initPos - _targetPos) < 0.1f) _x_gotoR = true;
        }
    }
}
