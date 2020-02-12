using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Diagnostics;
using System.Collections.Generic;
using System.Net;
using System.Threading;
using System.IO;
using System;
using NetMQ;
using NetMQ.Sockets;

public class TestPupil : MonoBehaviour
{
    public RequestSocket requestSocket = null;
    // Use this for initialization
    IEnumerator Start()
    {
        pupil = new Pupil("127.0.0.1", "63704");
        pupil.SetTimestamp(Time.time);
       // yield return new WaitForSeconds(1);
        UnityEngine.Debug.Log("Start >: " + Time.time.ToString());
        pupil.StartRecording();
        UnityEngine.Debug.Log("Start <: " + Time.time.ToString());
        //yield return new WaitForSeconds(1);
        int numberOfMarks = 4;
        while (numberOfMarks > 0)
        {
            pupil.SendMark();

            UnityEngine.Debug.Log(Time.time.ToString());
            numberOfMarks--;
            yield return new WaitForSeconds(1);
        }
        yield return new WaitForSeconds(1);

        pupil.StopRecording();


    }

    // Update is called once per frame
    void Update()
    {
    }

    public Pupil pupil;


}