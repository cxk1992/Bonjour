//
//  NetManager.swift
//  Service
//
//  Created by 陈旭珂 on 2016/8/14.
//  Copyright © 2016年 陈旭珂. All rights reserved.
//

import Foundation

enum BonjourType : String {
    case bonjour,service ,client
}

enum MessageFrom {
    case fromMe , fromOther
}

class Message{
    var type : MessageFrom = .fromMe
    var message:String?
    var data : Data?
    var dataType:String?
    
}

class ConnectHandler: NSObject ,StreamDelegate{
    
    var type : BonjourType = .bonjour
    
    var service : NetService?
    
    typealias dataResolveClouser = (_ data:Data , _ handler : ConnectHandler) -> ()
    
    var name = ""
    
    var hasNewMessage : Bool = false
    
    var messages : [Message] = []
    
    override init() {
        super.init()
    }
    
    internal
    func cennect(){
        self.type = .client
        
        var input : InputStream?
        var output : OutputStream?
        self.service?.getInputStream(&input, outputStream: &output)
        
        self.input = input
        self.output = output
    }
    
    convenience init( inputStream : InputStream ,outputStream:OutputStream,dataReceiveClouser:dataResolveClouser) {
        self.init()
        self.type = .service
        self.input = inputStream
        self.output = outputStream
        self.dataReceiveClouser = dataReceiveClouser
    }
    
    var input:InputStream?{
        didSet{
            input?.delegate = self
            input?.schedule(in: .current, forMode: .commonModes)
            print("\(type) will open")
            if input?.streamStatus == .notOpen{
                print("\(type) begin open")
                
                input?.open()
            }
        }
    }
    var output:OutputStream?{
        didSet{
            output?.delegate = self
            output?.schedule(in: .current, forMode: .commonModes)
            if output?.streamStatus == .notOpen{
                output?.open()
            }
        }
    }
    
    var data : [UInt8] = []
    var dataReceiveClouser:dataResolveClouser = { (data:Data , handler : ConnectHandler) in
        
    }
    
    func send(data:Data){
        if self.output!.hasSpaceAvailable{
            var bytes : [UInt8] = Array(repeating: 0, count: data.count)
            data.copyBytes(to: &bytes, count: data.count)
            let message = Message()
            message.type = .fromMe
            message.message = String(data: data, encoding: .utf8)!
            messages.append(message)
            
            self.output?.write(bytes, maxLength: data.count)
        }
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print(type)
        switch eventCode {
        case Stream.Event.openCompleted:
            print("Stream.Event.openCompleted")
            
        case Stream.Event.errorOccurred:
                print("Stream.Event.errorOccurred")
            
        case Stream.Event.endEncountered:
            print("Stream.Event.endEncountered")
            
        case Stream.Event.hasBytesAvailable:
            print("Stream.Event.hasBytesAvailable")
            var tmpData = [UInt8](repeating:0 ,count:1024)
            if let inStream = aStream as? InputStream{
                let count = inStream.read(&tmpData, maxLength: 1024)
                self.data.append(contentsOf: tmpData[0..<count])
                if !inStream.hasBytesAvailable{
                    self.dataReceiveClouser(Data(bytes: self.data) , self)
                    let message = Message()
                    message.type = .fromOther
                    message.message = String(bytes: self.data, encoding: .utf8)!
                    self.messages.append(message)
                    self.data.removeAll()
                }
            }
            
            break
        case Stream.Event.hasSpaceAvailable:
            print("Stream.Event.hasSpaceAvailable")
        default:
            break
        }
    }
}

public let serviceType = "_serviceType._tcp"

class ServerManager:NSObject{
    
    typealias connectClouser = (_ handler : ConnectHandler) -> ()
    
    static let defaultManager  = ServerManager()
    
    private let service = NetService(domain: "local.", type: serviceType, name: "cxk_service")
    
    var connectCloser : connectClouser?
    
    override init() {
        super.init()
        service.delegate = self
    }
    
    func publishService(connectClouser : connectClouser){
        service.publish(options: .listenForConnections)
        self.connectCloser = connectClouser;
        
        self.service.resolve(withTimeout: 5)
    }
    
    func closeService(){
        service.stop()
    }
    
}

extension ServerManager : NetServiceDelegate{
    public func netServiceWillPublish(_ sender: NetService){
        print(#function)
    }
    
    
    public func netServiceDidPublish(_ sender: NetService){
        print(#function)
    }
    
    
    public func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]){
        print(#function)
    }
    
    
    public func netServiceWillResolve(_ sender: NetService){
        print(#function)
    }
    
    
    public func netServiceDidResolveAddress(_ sender: NetService){
        print(#function)
    }
    
    
    public func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]){
        print(#function)
    }
    
    
    public func netServiceDidStop(_ sender: NetService){
        print(#function)
    }
    
    
    public func netService(_ sender: NetService, didUpdateTXTRecord data: Data){
        print(#function)
    }
    
    
    @available(OSX 10.9, *)
    public func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream){
        print(#function)
        
        let handler = ConnectHandler()
        handler.input = inputStream
        handler.output = outputStream
        if let clouser = self.connectCloser{
            clouser(handler)
        }
    }
}




