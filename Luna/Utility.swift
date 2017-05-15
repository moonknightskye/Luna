//
//  Utility.swift
//  Salesforce Hybrid
//
//  Created by Mart Civil on 2016/12/27.
//  Copyright © 2016年 salesforce.com. All rights reserved.
//

import UIKit
import WebKit
import CoreData
import LocalAuthentication

class Utility: NSObject {
    static let shared = Utility()
    
    func showStatusBar() {
        UIApplication.shared.isStatusBarHidden = false
    }
    func hideStatusBar() {
        UIApplication.shared.isStatusBarHidden = true
    }
    func greet() {
        print("Hello World")
    }
    
    func getContext () -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func dictionaryToJSON( dictonary:NSDictionary )-> String{
        var allInfoJSONString: String?
        do {
            let allInfoJSON = try JSONSerialization.data(withJSONObject: dictonary, options: JSONSerialization.WritingOptions(rawValue: 0))
            allInfoJSONString = NSString(data: allInfoJSON, encoding: String.Encoding.utf8.rawValue)! as String
        } catch let error as NSError {
            print(error)
        }
        return allInfoJSONString!
    }
    
    func StringToDictionary( txt: String )-> NSDictionary? {
        if let data = txt.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject] as NSDictionary?
            } catch {}
        }
        return nil
    }
    
    func splitDataToChunks( file:Data, onSplit:((Data)->()), onSuccess:((Bool)->()) ) {
        let length = file.count
        let chunkSize = (1024 * 1024) * 3
        var offset = 0
        var count = 0
        repeat {
            // get the length of the chunk
            let thisChunkSize = ((length - offset) > chunkSize) ? chunkSize : (length - offset);
            
            // get the chunk
            onSplit( file.subdata(in: offset..<offset + thisChunkSize ) )
            
            count+=1
            print("processing chunk # \(count)")
            
            // update the offset
            offset += thisChunkSize;
        } while (offset < length);
        onSuccess( true )
    }
    
    func StringToData( txt: String ) -> Data {
        return txt.data(using: .utf8, allowLossyConversion: false)!
    }
    
    func DataToString( data: Data ) -> String {
        return NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
    }
    
    func DataToBase64( data: Data ) -> String {
        return data.base64EncodedString()
//        return data.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
    }
    
    func DictionaryToData( dict: NSDictionary ) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: dict)
    }
    
    func DataToDictionary( data:Data ) -> NSDictionary {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : Any] as NSDictionary!
    }
    
    func degrees(radians:Double) -> Double {
        return ( 180 / Double.pi ) * radians
    }
    
    func printDictionary( dictonary:NSDictionary ) {
        for (key, _) in dictonary {
            print( key )
            print( dictonary[ key ]! )
        }
    }

	func getDimentionScaleValue( originalDimention:CGRect, resizedDimention:CGRect ) -> CGFloat {
		let width = 1 - ((originalDimention.width - resizedDimention.width) / originalDimention.width)
		let height = 1 - ((originalDimention.height - resizedDimention.height) / originalDimention.height)
		return CGFloat(max(width, height))
	}

	func getScaledDimention( dimention:CGRect, scale:CGFloat ) -> CGRect {
		return CGRect(x: dimention.origin.x, y: dimention.origin.y, width: dimention.width * scale, height: dimention.height * scale)
	}

	func getAspectRatioCoordinates( origin:CGPoint, originalDimention:CGRect, resizedDimention:CGRect ) -> CGPoint {
		let x = ((1-origin.y) * originalDimention.width) - ((originalDimention.width - resizedDimention.width) / 2)
		let y = (origin.x * originalDimention.height) - ((originalDimention.height - resizedDimention.height) / 2)
		return CGPoint(x: x, y: y)
	}
    
}
