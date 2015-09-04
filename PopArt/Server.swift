//
//  Server.swift
//  PopArt
//
//  Created by Ricardo Franco on 17/08/15.
//  Copyright (c) 2015 Ricardo Franco. All rights reserved.
//

//        https://github.com/swiftsocket/SwiftSocket
//        var client:TCPClient = TCPClient(addr: "192.168.0.175", port: 5100)
//        var (success,errmsg)=client.connect(timeout: 10)
//        var (success,errmsg)=client.send(str:"GET / HTTP/1.0\n\n" )
//        socket.send(data:[Int8])
//        var data=client.read(1024*10) //return optional [Int8]
//        var (success,errormsg)=client.close()

import Foundation
import CoreLocation

let SERVER_ADDRESS = "popart-app.com"
//let SERVER_ADDRESS = "192.168.0.175"
let SERVER_PORT = 5100

class Server {
    let client: TCPClient = TCPClient(addr: SERVER_ADDRESS, port: SERVER_PORT)
    var shouldSend = false
    
    var location: CLLocation?
    var placemark: CLPlacemark?
    
    init() {}
    
    func connect() {
        client.connect(timeout: 10)
    }
    
    func disconnect() {
        client.close()
    }
    
    func send(message: NSData) {
        println("Send \(message)")
        client.send(data: message)
    }
    
    func send(message: String) {
        let array_message = Array(message)[0..<100]
        let print_message = String(array_message)
        println("Send \(print_message) ...")
        
        client.send(str: message)
    }
    
    func read() -> NSString? {
        println("Read")
        let data = client.read(1024*10)
        if let d=data{
            if let str=NSString(bytes: d, length: d.count, encoding: NSUTF8StringEncoding){
                println(str)                
                return str
            }
        }
        
        return nil
    }
}

let server = Server()