//
//  NetManager.swift
//  Service
//
//  Created by 陈旭珂 on 2016/8/14.
//  Copyright © 2016年 陈旭珂. All rights reserved.
//

import Foundation

class ConnectHandler: NSObject ,StreamDelegate{
    
    typealias dataResolveClouser = (data:Data , handler : ConnectHandler) -> ()
    
    var name = ""
    
    override init() {
        super.init()
    }
    
    convenience init( inputStream : InputStream ,outputStream:NSOutputStream,dataReceiveClouser:dataResolveClouser) {
        self.init()
        self.input = inputStream
        self.output = outputStream
        self.dataReceiveClouser = dataReceiveClouser
    }
    
    var input:InputStream?{
        didSet{
            input?.delegate = self
            input?.schedule(in: .current, forMode: .commonModes)
            if input?.streamStatus == .notOpen{
                input?.open()
            }
        }
    }
    var output:NSOutputStream?{
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
            self.output?.write(bytes, maxLength: data.count)
        }
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
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
                    self.dataReceiveClouser(data: Data(bytes: self.data) , handler: self)
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
    
    typealias connectClouser = (handler : ConnectHandler) -> ()
    
    static let defaultManager  = ServerManager()
    
    private let service = NetService(domain: "local.", type: serviceType, name: "cxk_service")
    
    override init() {
        super.init()
        service.delegate = self
    }
    
    func publishService(connectClouser : connectClouser){
        service.publish(options: .listenForConnections)
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
    public func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: NSOutputStream){
        print(#function)
    }
}




