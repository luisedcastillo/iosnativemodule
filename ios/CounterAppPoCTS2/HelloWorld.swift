//
//  HelloWorld.swift
//  CounterAppPoCTS2
//
//  Created by Luis Castillo on 25/10/21.
//

import Foundation
import UIKit

@objc(HelloWorld)

class HelloWorld: NSObject, RCTBridgeModule, StreamDelegate {
  fileprivate var inputStream: InputStream!
  fileprivate var outputStream: OutputStream!
  fileprivate var command : String!
  fileprivate var connectionCount : Int!
  fileprivate var response : String!
  fileprivate var readStream: Unmanaged<CFReadStream>?
  fileprivate var writeStream: Unmanaged<CFWriteStream>?
  fileprivate var commandSent: Bool = false

  fileprivate var executionGroup : DispatchGroup!

  static func moduleName() -> String!{
    return "HelloWorld";
  }
  
  static func requiresMainQueueSetup() -> Bool {
    return true;
  }
  
  @objc
  func ShowMessageSync(_ message: NSString, duration: Double) -> Void{
    print("NATIVE MODULE SAYING HI!!!!");
    let alert = UIAlertController(title: nil, message: message as String, preferredStyle: .alert);
    let seconds:Double = duration;
    alert.view.backgroundColor = .black
    alert.view.alpha = 0.5
    alert.view.layer.cornerRadius = 14
    
    DispatchQueue.main.async {
      (UIApplication.shared.delegate as? AppDelegate)?.window.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds, execute: {alert.dismiss(animated: true, completion: nil)})

  }
  
  @objc
  func ShowMessage(_ message: String, duration: Double,
                  resolve: RCTPromiseResolveBlock, 
                  rejecter reject: RCTPromiseRejectBlock) -> Void{
    self.connectionCount = 0
    executionGroup = DispatchGroup()
    executionGroup.enter()
  
    self.command = message
    self.openSocketConnection()
    executionGroup.wait()
    resolve(self.response)
  }

  func _sendAddDeviceCommand() {
    let array = toByteArray(command)
    commandSent = true
    self.outputStream?.write(array, maxLength: array.count)
  }

  func closeSocketConnection() {
      print("Closing streams.")
      self.inputStream?.close()
      self.outputStream?.close()
      self.inputStream?.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
      self.outputStream?.remove(from: RunLoop.main, forMode: RunLoop.Mode.default)
      self.inputStream?.delegate = nil
      self.outputStream?.delegate = nil
      self.inputStream = nil
      self.outputStream = nil
  }
  
  func openSocketConnection(){
    commandSent = false
    if self.outputStream == nil && self.inputStream == nil {
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, ("10.10.100.254" as CFString), UInt32(8899), &readStream, &writeStream)
        self.outputStream = writeStream?.takeRetainedValue()
        self.inputStream = readStream?.takeRetainedValue()
        self.outputStream?.delegate = self
        self.inputStream?.delegate = self
        self.outputStream?.schedule(in: RunLoop.main, forMode: RunLoop.Mode.default)
        self.inputStream?.schedule(in: RunLoop.main, forMode: RunLoop.Mode.default)
        self.outputStream?.open()
        self.inputStream?.open()
    } else {
        closeSocketConnection()
    }
  }
  
  func readResponse(){
    var dataBuffer = Array<UInt8>(repeating: 0, count: 1024)
    let len = (self.inputStream?.read(&dataBuffer, maxLength: 1024))!
    if len > 0 {
      let newstr = bytesConvertToHexstring(byte: dataBuffer)
      print(newstr)
      closeSocketConnection()
      self.response = newstr
      executionGroup.leave()
    } else {
      closeSocketConnection()
      openSocketConnection()
      self.response = "Invalid response received"
    }
  }
  
  func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
      if aStream === self.inputStream {
          switch eventCode {
          case Stream.Event.errorOccurred:
            if(self.connectionCount < 3) {
              print("inputStream Socket Connection errorOccurred")
              openSocketConnection()
            }
          case Stream.Event.openCompleted:
              print("inputStream Socket Connection openCompleted")
          case Stream.Event.hasBytesAvailable:
                readResponse()
          default:
              print("inputStream Socket Connection default")
          }
      } else if aStream === self.outputStream {
          switch eventCode {
          case Stream.Event.errorOccurred:
            if(self.connectionCount < 3) {
              print("[SCKT]: ErrorOccurred: \(aStream.streamError?.localizedDescription)")
              openSocketConnection()
            }
          case Stream.Event.openCompleted:
            print("outputStream Socket Connection openCompleted")
          case Stream.Event.hasSpaceAvailable:
            if(!commandSent){
              commandSent = true
              self._sendAddDeviceCommand()
            }
          default:
              print("outputStream Socket Connection outputStream")
          }
      }
    }
    
    func toByteArray( _ hex:String ) -> [UInt8] {
        let hexString = hex
        let arrStr = Array(hexString)
        let size = hexString.count / 2
        var result:[UInt8] = [UInt8]( repeating: 0, count: size )
      
        for i in stride( from: 0, to: hexString.count, by: 2 ) {
          let subHexStr = String(arrStr[i..<i+2])
            result[ i / 2 ] = UInt8( subHexStr, radix: 16 )!
        }
        return result
    }
  
     func bytesConvertToHexstring(byte : [UInt8]) -> String {
          var string = ""
          for val in byte {
              string = string + String(format: "%02X", val)
          }
          return string
      }

}


