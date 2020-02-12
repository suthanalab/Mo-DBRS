//
//  ViewController.swift
//  rns-ipad
//
//  Created by Uros Topalovic on 5/26/19.
//  Copyright © 2019 Uros Topalovic. All rights reserved.
//

import UIKit
import SwiftSocket

class ViewController: UIViewController {
    var isConnected = false
    
    let host = "192.168.1.177";
    let port = 50000
    var client: TCPClient?
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var connectionLabel: UILabel!
    
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var markButton: UIButton!
    @IBOutlet weak var stimButton: UIButton!
    @IBOutlet weak var magnetButton: UIButton!
    @IBOutlet weak var connectionButton: UIButton!
    
    @IBAction func connectionClick(_ sender: Any) {
        if isConnected == false {
            
            guard let client = client else { return }
            
            switch client.connect(timeout: 2){
            case .success:
                appendToTextField(string: "Connected to host \(client.address)")
                storeButton.isEnabled = true
                markButton.isEnabled = true
                stimButton.isEnabled = true
                magnetButton.isEnabled = true
                connectionLabel.text = "Connected"
                isConnected = true
                connectionButton.setTitle("    Disconnect", for: .normal)
            case .failure(let error):
                appendToTextField(string: String(describing: error))
            }
        } else {
            client?.close();
            storeButton.isEnabled = false
            markButton.isEnabled = false
            stimButton.isEnabled = false
            magnetButton.isEnabled = false
            connectionLabel.text = "Disconnected"
            isConnected = false
            connectionButton.setTitle("    Connect", for: .normal)
        }
    }


    @IBAction func storeClick(_ sender: Any) {
        guard let client = client else { return }
        let cmd: [Byte] = [([Byte](("r").utf8))[0]]
        sendRequest(msg: cmd, using: client)
        
    }
    
    @IBAction func markClick(_ sender: Any) {
        guard let client = client else { return }
        let cmd: [Byte] = [([Byte](("t").utf8))[0]]
        sendRequest(msg: cmd, using: client)
    }
    
    @IBAction func stimClick(_ sender: Any) {
        guard let client = client else { return }
        let cmd: [Byte] = [([Byte](("s").utf8))[0]]
        sendRequest(msg: cmd, using: client)
    }
    
    @IBAction func magnetClick(_ sender: Any) {
        guard let client = client else { return }
        let cmd: [Byte] = [([Byte](("m").utf8))[0]]
        sendRequest(msg: cmd, using: client)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeButton.isEnabled = false
        markButton.isEnabled = false
        stimButton.isEnabled = false
        magnetButton.isEnabled = false
        
        client = TCPClient(address: host, port: Int32(port))
        
        
        // Do any additional setup after loading the view.
    }
    
    private func sendRequest(msg: [Byte], using client: TCPClient) -> String?{
        guard let temp = String(bytes: msg, encoding: .utf8) else { return nil}
        var cmd = ""
        if temp == "r"
        {
            cmd = "Store command"
        }
        else if temp == "t"
        {
            cmd = "Mark command"
        }
        else if temp == "s"
        {
            cmd = "Stimulation command"
        }
        else
        {
            cmd = "Magnet command"
        }
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = String(format: "%02d", calendar.component(.second, from: date))
        let timeOfDay = "\(hour):\(minutes):\(seconds)"
        appendToTextField(string: timeOfDay + "\t -> \t" + cmd)
        scrollTextViewToBottom(tv: textView)
        client.send(data: msg)
        return nil
        
    }
    func scrollTextViewToBottom(tv: UITextView) {
        if textView.text.count > 0 {
            let location = textView.text.count - 1
            let bottom = NSMakeRange(location, 1)
            textView.scrollRangeToVisible(bottom)
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        return String(bytes: response, encoding: .utf8)
    }
    
    private func appendToTextField(string: String) {
        print(string)
        textView.text = textView.text.appending("\n\(string)")
    }

}

