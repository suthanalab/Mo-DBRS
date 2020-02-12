using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Net.Sockets;
using System.IO;


public class RPi 
{

	bool _socketReady = false;
	private TcpClient _socket;
	private NetworkStream _stream;
	private StreamWriter _writer;
	private string _host = "192.168.1.155";
	private int _port = 50000;

	//Constructor
	public RPi (string host = "192.168.1.155", int port = 50000) 
	{
		_host = host;
		_port = port;
		try
		{
			_socket = new TcpClient (_host, _port);
			_stream = _socket.GetStream ();
			_writer = new StreamWriter (_stream);
			_socketReady = true;
		}
		catch 
		{
			Debug.Log ("Connection failed");
		}
	}

	public void sendSsr()
	{
		_writer.Write("r");
		_writer.Flush();
		Debug.Log("ssr");
	}

	public void sendStim()
	{
		_writer.Write("s");
		_writer.Flush();
		Debug.Log("stim");
	}
	public void sendMark()
	{
		_writer.Write("t");
		_writer.Flush();
		Debug.Log("mark");
	}

	public void sendTest ()
	{
		_writer.Write("q");
		_writer.Flush();
		Debug.Log("Test");
	}

	public void sendMagnet()
	{
		_writer.Write("m");
		_writer.Flush();
		Debug.Log("mark");
	}

	public void wandOn()
	{
		_writer.Write("n");
		_writer.Flush();
		Debug.Log("wandON");
	}

	public void wandOff()
	{
		_writer.Write("f");
		_writer.Flush();
		Debug.Log("wandOFF");
	}

	public void closeClient()
	{
		_writer.Write("u");
		_writer.Flush();
		_socket.Close();
		Debug.Log("Closing the client");
	}

	public void closeRPi(){
		_writer.Write("u");
		_writer.Flush();
		_socket.Close();
	}
}
