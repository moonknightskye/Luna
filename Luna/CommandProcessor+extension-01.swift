//
//  CommandProcessor+extension-01.swift
//  Luna
//
//  Created by Mart Civil on 2017/05/25.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UserNotifications

extension CommandProcessor {
    
//    public class func checkUserSettingsAdd( command: Command ) {
//        checkUserSettingsAdd( command: command, onSuccess: { result in
//            command.resolve( value: result )
//        }, onFail: { errorMessage in
//            command.reject( errorMessage: errorMessage )
//        })
//    }
//    private class func checkUserSettingsAdd( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
//        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String,
//            let value = (command.getParameter() as AnyObject).value(forKeyPath: "value") as Any? {
//            UserSettings.instance.add(key: key, value: value, onSuccess:onSuccess, onFail:onFail)
//        } else {
//            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
//        }
//    }
    
    public class func checkUserSettingsDelete( command: Command ) {
        checkUserSettingsDelete( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkUserSettingsDelete( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String {
            UserSettings.instance.delete(key: key, onSuccess:onSuccess, onFail:onFail)
        } else {
            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
        }
    }
    
    public class func checkUserSettingsGet( command: Command ) {
        checkUserSettingsGet( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkUserSettingsGet( command: Command, onSuccess: @escaping((Any)->()), onFail: @escaping((String)->()) ){
        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String {
            if let value = UserSettings.instance.get(key: key) {
                onSuccess( value )
                return
            }
        }
        onFail( FileError.INVALID_PARAMETERS.localizedDescription )
    }
    
    public class func checkUserSettingsSet( command: Command ) {
        checkUserSettingsSet( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func checkUserSettingsSet( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
        if let key = (command.getParameter() as AnyObject).value(forKeyPath: "key") as? String,
            let value = (command.getParameter() as AnyObject).value(forKeyPath: "value") as Any? {
            UserSettings.instance.set(key: key, value: value)
            onSuccess( true )
        } else {
            onFail( FileError.INVALID_PARAMETERS.localizedDescription )
        }
    }
    
    public class func checkWebViewRecieveMessage( command: Command ) {
        getCommand(commandCode: CommandCode.WEB_VIEW_POSTMESSAGE) { (cmd) in
            if let isSendUntilRecieved = (cmd.getParameter() as AnyObject).value(forKeyPath: "isSendUntilRecieved") as? Bool {
                if isSendUntilRecieved {
                    checkWebViewPostMessage( command: cmd, isSysSent: true )
                }
            }
        }
    }
    
    public class func checkWebViewPostMessage( command: Command, isSysSent:Bool?=false ) {
        processWebViewPostMessage( command: command, isSysSent:isSysSent!, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    private class func processWebViewPostMessage( command: Command, isSysSent:Bool, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ){
        var isSent = false
        if let isSendToAll = (command.getParameter() as AnyObject).value(forKeyPath: "isSendToAll") as? Bool, let message = (command.getParameter() as AnyObject).value(forKeyPath: "message") as? String {
            getCommand(commandCode: CommandCode.WEB_VIEW_RECIEVEMESSAGE) { (recievecommand) in
                if isSendToAll {
                    recievecommand.update(value: message)
                    isSent = true
                } else {
                    if command.getTargetWebViewID() == recievecommand.getSourceWebViewID() {
                        recievecommand.update(value: message)
                        isSent = true
                    }
                }
            }
        }
        let isSendUntilRecieved = ((command.getParameter() as AnyObject).value(forKeyPath: "isSendUntilRecieved") as? Bool) ?? false
        
        if (!(isSendUntilRecieved) || isSysSent) {
            if isSent {
                onSuccess(true)
            } else {
                onFail("Unable to deliver message")
            }
        }
    }
    
    public class func checkUserSettingsLunaSettingsHtml( command: Command ) {
        processUserSettingsLunaSettingsHtml( command: command, onSuccess: { result, raw in
            command.resolve( value: result, raw: raw )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processUserSettingsLunaSettingsHtml( command: Command, onSuccess: ((NSDictionary, HtmlFile)->()), onFail: ((String)->()) ){
        let htmlFile = SettingsPage.instance.getPage()
        onSuccess( htmlFile.toDictionary(), htmlFile )
    }
    
    public class func checkUserNotification( command: Command ) {
        processUserNotification( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processUserNotification( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        UserNotification.instance.checkAccess(onSuccess:onSuccess, onFail:onFail)
    }
    
    public class func checkUserNotificationShowMessage( command: Command ) {
        processUserNotificationShowMessage( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processUserNotificationShowMessage( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        
        
        let content = UNMutableNotificationContent()
        let requestIdentifier = "LunaNotification\(command.getCommandID())"
        print( requestIdentifier )
        
        if let badge = (command.getParameter() as AnyObject).value(forKeyPath: "badge") as? NSNumber {
            content.badge = badge
        }
        if let title = (command.getParameter() as AnyObject).value(forKeyPath: "title") as? String {
            content.title = title
        }
        if let subtitle = (command.getParameter() as AnyObject).value(forKeyPath: "subtitle") as? String {
            content.subtitle = subtitle
        }
        if let body = (command.getParameter() as AnyObject).value(forKeyPath: "body") as? String {
            content.body = body
        }
        
        var options = [UNNotificationAction]()
        if let opts = (command.getParameter() as AnyObject).value(forKeyPath: "choices") as? [NSDictionary] {
            var hasOptions = false
            for (_, option) in opts.enumerated() {
                if let value = option.value(forKeyPath: "value") as? String, let title = option.value(forKeyPath: "title") as? String {
                    hasOptions = true
                    options.append(UNNotificationAction(identifier: value, title: title, options: [.foreground]))
                }
                
            }
            if hasOptions {
                let category = UNNotificationCategory(identifier: "LunaActionCategory\(command.getCommandID())", actions: options, intentIdentifiers: [], options: [])
                
                UNUserNotificationCenter.current().setNotificationCategories([category])
                content.categoryIdentifier = "LunaActionCategory\(command.getCommandID())"
                
                print( "LunaActionCategory\(command.getCommandID())" )
            }
        }
        
        content.sound = UNNotificationSound.default()
        
        // If you want to attach any image to show in local notification
        var imgAttachment:ImageFile?
        do {
            imgAttachment = try ImageFile(fileId: File.generateID(), bundle: "luna.jpg", path: "resource/img")
            let attachment = try? UNNotificationAttachment(identifier: requestIdentifier, url: imgAttachment!.getFilePath()!, options: nil)
            content.attachments = [attachment!]
        } catch {}
        
        var timeInterval = ((command.getParameter() as AnyObject).value(forKeyPath: "timeInterval") as? Double ) ?? 0.5
        if timeInterval < 0.5 {
            timeInterval = 0.5
        }
        let isRepeating = ((command.getParameter() as AnyObject).value(forKeyPath: "repeat") as? Bool ) ?? false
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: timeInterval, repeats: isRepeating)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            
            if error != nil {
                onFail(error!.localizedDescription)
                return
            }
            print("Notification Register Success")
            //onSuccess(true)
        }
    }
    
    public class func checkHttpPost( command: Command ) {
        processHttpPost( command: command, onSuccess: { result in
            command.resolve( value: result )
        }, onFail: { errorMessage in
            command.reject( errorMessage: errorMessage )
        })
    }
    
    private class func processHttpPost( command: Command, onSuccess: @escaping((NSDictionary)->()), onFail: @escaping((String)->()) ) {
        
        
        if let url = ((command.getParameter() as AnyObject).value(forKeyPath: "url") as? String ) {
            var request = URLRequest(url: URL(string: url)!)
            
            let method = ((command.getParameter() as AnyObject).value(forKeyPath: "method") as? String ) ?? "POST"
            request.httpMethod = method
            
            if let parameters = ((command.getParameter() as AnyObject).value(forKeyPath: "data") as? NSDictionary ) {
                request.httpBody = Utility.shared.dictionaryToJSON(dictonary: parameters).data(using: .utf8)
            }
            if let multipart = ((command.getParameter() as AnyObject).value(forKeyPath: "multipart") as? NSDictionary ) {
                
                //let boundary = "Boundary-\(UUID().uuidString)"
                let boundary = self.createBoundary()
                print( boundary )
                print( "Boundary-\(UUID().uuidString)" )
                
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                let pmtrs = multipart.value(forKeyPath: "parameters") as! NSDictionary
                let dataUrl = multipart.value(forKeyPath: "dataUrl") as! URL
                let data = multipart.value(forKeyPath: "data") as! Data
                let mimeType = multipart.value(forKeyPath: "mimeType") as! String
                let filename = multipart.value(forKeyPath: "filename") as! String
                request.httpBody = self.createBody( parameters: pmtrs,
                                                    boundary: boundary,
                                                    dataUrl: dataUrl,
                                                    data: data,
                                                    mimeType: mimeType,
                                                    filename: filename)
            
            }
            if let header = ((command.getParameter() as AnyObject).value(forKeyPath: "headers") as? NSDictionary ) {
                for (key, _) in header {
                    request.addValue(header[ key ] as! String, forHTTPHeaderField: key as! String)
                }
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    // check for fundamental networking error
                    onFail( error!.localizedDescription )
                    //print("error=\(error!)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(response!)")
                }
                
                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString****** = \(responseString)")
                    if let resp = Utility.shared.StringToDictionary(txt: responseString) {
                        onSuccess( resp )
                        return
                    }
                }
                print( "NO RESPONSE" )
                onFail("NO RESPONSE")
                
            }
            task.resume()
        }
    }
    
    public class func createBody( parameters: NSDictionary,
                    boundary: String,
                    dataUrl: URL,
                    data: Data,
                    mimeType: String,
                    filename: String) -> Data {
        
        //https://newfivefour.com/swift-form-data-multipart-upload-URLRequest.html
        
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")

			print(key)
			print(value)
        }
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"voice\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))


		print(filename)
		print(mimeType)
		print(boundary)

        return body as Data
    }
    
    public class func createBoundary() -> String {
        let multipartChars = "-_1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let length = Int(30 + floor(Double(arc4random_uniform(10))))
        var boundary = "---------------------------";
        for _ in 0...length {
            let char = multipartChars.charAt(at: Int(  Int(arc4random_uniform(10)) * multipartChars.length ) / 10  )
            boundary.append(char)
        }
        return boundary
    }


	public class func checkAVAudioRecorderInit( command: Command ) {
		processAVAudioRecorderInit( command: command, onSuccess: { result in
			command.resolve( value: result )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func processAVAudioRecorderInit( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {

		let recorder = VoiceRecorder.instance
		recorder.checkPermission(onSuccess: onSuccess, onFail: onFail)
	}

	public class func checkAVAudioRecorderRecord( command: Command ) {
		processAVAudioRecorderRecord( command: command, onSuccess: { result in
			command.resolve( value: result )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func processAVAudioRecorderRecord( command: Command, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {

		let recorder = VoiceRecorder.instance
		recorder.checkPermission(onSuccess: { (result) in
			recorder.startRecording(onSuccess: onSuccess, onFail: onFail)
		}) { (error) in
			onFail( error )
		}
	}

	public class func checkAVAudioRecorderStop( command: Command ) {
		processAVAudioRecorderStop( command: command, onSuccess: { result, raw in
			command.resolve( value: result, raw: raw )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func processAVAudioRecorderStop( command: Command, onSuccess: @escaping((NSDictionary, File)->()), onFail: @escaping((String)->()) ) {

		let recorder = VoiceRecorder.instance
		recorder.checkPermission(onSuccess: { (result) in
			recorder.finishRecording(onSuccess: { (recordedFile) in
				onSuccess(recordedFile.toDictionary(), recordedFile)
			}, onFail: { (error) in
				onFail( error )
			})
		}) { (error) in
			onFail( error )
		}
	}

	public class func checkAVAudioConvertToWav( command: Command ) {
		processAVAudioConvertToWav( command: command, onSuccess: { result, raw in
			command.resolve( value: result, raw: raw )
		}, onFail: { errorMessage in
			command.reject( errorMessage: errorMessage )
		})
	}
	private class func processAVAudioConvertToWav( command: Command, onSuccess: @escaping((NSDictionary, File)->()), onFail: @escaping((String)->()) ) {

		let recorder = VoiceRecorder.instance

		if let audioFile = ((command.getParameter() as AnyObject).value(forKeyPath: "file") as? NSDictionary ) {
			do {
				let file = try File( file: audioFile )
				recorder.convertToWav(audioFile: file, onSuccess: { (encodedFile) in
					onSuccess(encodedFile.toDictionary(), encodedFile)
				}) { (error) in
					onFail(error)
				}
			} catch let error as NSError {
				onFail( error.localizedDescription )
			}

		} else {
			onFail(FileError.INVALID_PARAMETERS.localizedDescription)
		}
	}


	//



}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
