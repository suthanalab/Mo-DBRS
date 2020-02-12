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
using MessagePack;

public class Pupil
{
    public Pupil(string IP = "127.0.0.1", string PORT = "50020")
    {
        NetMQConfig.ContextCreate(true);
        requestSocket = new RequestSocket(">tcp://" + IP + ":" + PORT);

        float t = Time.time;
        requestSocket.SendFrame("t");
        string response = requestSocket.ReceiveFrameString();

        requestSocket.SendFrame("T 0.0");

        response = requestSocket.ReceiveFrameString();
        SetTimestamp(Time.time);
        }

    public void StartRecording()
    {
        if (requestSocket != null)
        {
            requestSocket.SendFrame("R");
            requestSocket.ReceiveFrameString();
        }
    }

    public void StopRecording()
    {
        if (requestSocket != null)
        {
            requestSocket.SendFrame("r");
            requestSocket.ReceiveFrameString();
        }
    }

    public void StartCalibration()
    {
        if (requestSocket != null)
        {
            requestSocket.SendFrame("C");
            requestSocket.ReceiveFrameString();
        }
    }

    public void StopCalibration()
    {
        if (requestSocket != null)
        {
            requestSocket.SendFrame("c");
            requestSocket.ReceiveFrameString();
        }
    }

    public void SendMark()
    {
        string label = "Custom Mark";
        float duration = 0f;

        SendTrigger(new Dictionary<string, object> { { "topic", "annotation" }, { "label", label }, { "timestamp", Time.time }, { "duration", duration } });
        requestSocket.ReceiveFrameString();
    }

    public void SetTimestamp(float time)
    {
        if (requestSocket != null)
        {
            requestSocket.SendFrame("T " + time.ToString("0.00000000"));
            requestSocket.ReceiveFrameString();
        }
    }

    private void Send(Dictionary<string, object> data)
    {
        if (requestSocket != null)
        {
            NetMQMessage m = new NetMQMessage();

            m.Append("notify." + data["subject"]);
            m.Append(MessagePackSerializer.Serialize<Dictionary<string, object>>(data));

            requestSocket.SendMultipartMessage(m);
        }

    }

    private void SendTrigger(Dictionary<string, object> data)
    {
        if (requestSocket != null)
        {
            NetMQMessage m = new NetMQMessage();

            m.Append(data["topic"].ToString());
            m.Append(MessagePackSerializer.Serialize<Dictionary<string, object>>(data));

            requestSocket.SendMultipartMessage(m);
        }
    }

    private void StartAnnotationPlugin()
    {
        Send(new Dictionary<string, object> { { "subject", "start_plugin" }, { "name", "Annotation_Capture" } });
        requestSocket.ReceiveFrameString();
    }


    private RequestSocket requestSocket = null;
}
