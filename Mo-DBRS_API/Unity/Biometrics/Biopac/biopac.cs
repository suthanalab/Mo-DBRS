using System.Collectioins;
using System.Collections.Generic;
using UnityEngine;
using System.Net.Sockets;
using System.IO.Ports;

public class Biopac 
{
    private string biopacPort;
    private SerialPort biopacSerialPort;
    public Biopac(string port)
    {
        biopacPort = port;
        biopacSerialPort = new SerialPort(biopacPort);
        biopacSerialPort.BaudRate = 115200;
        biopacSerialPort.Parity = Parity.None;
        biopacSerialPort.StopBits = StopBits.One;
        biopacSerialPort.DataBits = 8;
        biopacSerialPort.Open();

    }

    public void biopacStartPulse()
    {
        biopacSerialPort.WriteLine("01");
    }
    
    public void biopacStopPulse()
    {
        biopacSerialPort.WriteLine("00");
    }

    public void biopacClose()
    {
        biopacSerialPort.Close();
    }
}
