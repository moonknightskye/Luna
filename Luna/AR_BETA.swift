//
//  AR.swift
//  Luna
//
//  Created by Mart Civil on 2018/02/24.
//  Copyright © 2018年 salesforce.com. All rights reserved.
//

import Foundation
import ARKit

class AR_BETA {
    static let instance:AR_BETA = AR_BETA()
    
    var sceneView: ARSCNView!
    var touchpoint:ARHitTestResult?
    var ACCOUNT_ID:String?
    var PRIVATE_KEY:String?
    var MODEL_ID:String?
    
    
    init() {}
    
    func addClose() {
        let text:String = ""
        let font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(32))
        let width = 100.0
        let height = 100.0
        
        let fontAttrs: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: font as Any]
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(width), height: CGFloat(height)))
        let image = renderer.image { context in
            let color = UIColor.red.withAlphaComponent(CGFloat(0.75))
            
            let rect = CGRect(x: (width * 0),y: (height * 0),width: (width * 1),height: (height * 1))
            
            color.setFill()
            context.fill(rect)
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            
            text.draw(with: rect, options: .usesLineFragmentOrigin, attributes: fontAttrs, context: nil)
        }
        
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = image
        //let plane = SCNPlane(width: 0.05, height: 0.05)
        //plane.firstMaterial?.diffuse.contents = image
        
        let node = SCNNode(geometry: box)
        node.position = SCNVector3(0, 0.03, -0.4)
        node.name = "CLOSE"
        sceneView.scene.rootNode.addChildNode(node)
    }
    func add3dClose() {
        let text = SCNText(string: "Tap box to Close", extrusionDepth: 1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        text.materials = [material]
        
        let node = SCNNode()
        node.position = SCNVector3(x:-0.1, y:-0.03, z:-0.4)
        node.scale = SCNVector3(x:0.002, y:0.002, z:0.002)
        node.geometry = text
        node.name = "CLOSE"
        sceneView.scene.rootNode.addChildNode(node)
    }
    func add3dText() {
        let text = SCNText(string: "Tap anywhere to predict image", extrusionDepth: 1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.gray
        text.materials = [material]
        
        let node = SCNNode()
        node.position = SCNVector3(x:-0.18, y:-0.07, z:-0.55)
        node.scale = SCNVector3(x:0.002, y:0.002, z:0.002)
        node.geometry = text
        node.name = "3DTEXT"
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func getNode( text:String?="Hello, Stack Overflow." ) -> SCNNode{
        //let text = "Hello, Stack Overflow."
        let font = UIFont(name: "HelveticaNeue-Thin", size: CGFloat(16))
        let width = 200.0
        let height = 200.0
        
        let fontAttrs: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: font as Any]
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: CGFloat(width), height: CGFloat(height)))
        let image = renderer.image { context in
            let color = UIColor.gray.withAlphaComponent(CGFloat(0.75))
            
            let rect = CGRect(x: (width * 0.5),y: (height * 0.5),width: (width * 0.5),height: (height * 0.5))
            
            color.setFill()
            context.fill(rect)
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            
            text!.draw(with: rect, options: .usesLineFragmentOrigin, attributes: fontAttrs, context: nil)
        }
        
        let plane = SCNPlane(width: CGFloat(0.15), height: CGFloat(0.15))
        plane.firstMaterial?.diffuse.contents = image
        
        let node = SCNNode(geometry: plane)
        
        node.name = "EINSTEIN"
        return node
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func run(accountId:String?=nil, privateKey:String?=nil, modelId:String?=nil) {
        sceneView = ARSCNView(frame:UIScreen.main.bounds)
        sceneView.alpha = 0
        sceneView.frame.origin.y = 40
        add3dClose()
        addClose()
        add3dText()
        addTapGestureToSceneView()
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        ACCOUNT_ID = accountId
        PRIVATE_KEY = privateKey
        MODEL_ID = modelId
        
        Shared.shared.ViewController.view.addSubview(sceneView)
        UIView.animate(withDuration: 0.4, delay: 1.0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.sceneView.alpha = 1
            self.sceneView.frame.origin.y = 0
        }, completion: { finished in})
    }
    
    func pause() {
        sceneView.session.pause()
    }
    
    func addPlane() {
        let paths = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask )
        let url = URL( string:paths[0].absoluteString + "arasset/ship.scn")
        var scene2:SCNScene!
        do {
            scene2 = try SCNScene(url: url!, options:nil)
            sceneView.scene = scene2
        } catch{}
    }
    

    
    func addBox() {
        //let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        //let pyramid = SCNPyramid(width: 0.1, height: 0.1, length: 0.1)
        let plain = SCNPlane(width: 0.05, height: 0.05)
        //plain.insertMaterial(SCNMaterial, at: <#T##Int#>)
        
        
        let boxNode = SCNNode()
        boxNode.geometry = plain
        boxNode.position = SCNVector3(0, 0, -0.2)
        boxNode.name = "CLOSE"
        
        sceneView.scene.rootNode.addChildNode(boxNode)
        //sceneView.scene.a
    }
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let hapticParameter = NSMutableDictionary()
        hapticParameter.setValue( "medium", forKey: "type")
        let hapticSuccess = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
        CommandProcessor.queue(command: hapticSuccess)
        
        let rotate = simd_float4x4(SCNMatrix4MakeRotation(sceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
        let rotateTransform = simd_mul(touchpoint!.worldTransform, rotate)
        
        //node.position = SCNVector3(x:-0.15, y:-0.07, z:-0.45)
        let node3 = self.getNode( text: "Thinking..." )
        node3.transform = SCNMatrix4(rotateTransform)
        node3.position = SCNVector3((x - 0.035), (y + 0.035), z)
        self.sceneView.scene.rootNode.addChildNode(node3)
        
        let generateEinsteinLabel = { (label: String) -> () in
   
            let node = self.getNode( text: label)
            node.transform = SCNMatrix4(rotateTransform)
            node.position = SCNVector3((x - 0.035), (y + 0.035), z)
            
//            // Create a LookAt constraint, point at the cameras POV
//            let constraint = SCNLookAtConstraint(target: self.sceneView.pointOfView)
//            // Keep the rotation on the horizon
//            constraint.isGimbalLockEnabled = true
//            // Slow the constraint down a bit
//            constraint.influenceFactor = 0.01
//            // Finally add the constraint to the node
//            node.constraints = [constraint]
            
            self.sceneView.scene.rootNode.addChildNode(node)
            
            node3.removeFromParentNode()
        }
        
        snap( onSuccess: { imageFile in
            EinsteinAuth.instance.getToken(accountId: self.ACCOUNT_ID, privateKey: self.PRIVATE_KEY, onSuccess: { (token) in

                let execute = { base64val in
                    EinsteinVision.instance.predict(token: token, modelId: self.MODEL_ID, base64: base64val, onSuccess: { (results) in
                        if let probabilities = results.value(forKey: "probabilities") as? [NSDictionary] {
                            let probability = probabilities[0] as NSDictionary
                            let label = probability.value(forKey: "label") as! String
                            var prob = probability.value(forKey: "probability") as! Double
                            prob = round(prob * 100)
                            
                            generateEinsteinLabel( String(prob) + "%" + " " + label )
                            hapticParameter.setValue( "success", forKey: "type")
                            let hapticSuccess = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
                            CommandProcessor.queue(command: hapticSuccess)
                        }
                    }, onFail: { (errorMessage) in
                        print(errorMessage)
                        generateEinsteinLabel( errorMessage )
                        hapticParameter.setValue( "error", forKey: "type")
                        let hapticSuccess = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
                        CommandProcessor.queue(command: hapticSuccess)
                    })
                }
                
                EinsteinVision.instance.preprocessImage(imageFile: imageFile, onSuccess: { (base64) in
                    execute( base64 )
                }, onError: { (errorMessage) in
                    generateEinsteinLabel( errorMessage )
                    hapticParameter.setValue( "error", forKey: "type")
                    let hapticSuccess = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
                    CommandProcessor.queue(command: hapticSuccess)
                })


                //print( imageFile.getFileName()! + " was generated" )
            }, onFail: { (error) in
                print(error)
            })
        })
    }
    
    func snap(onSuccess:((ImageFile)->())?=nil, onFail:((String)->())?=nil) {
        do {
            let imageFile = try ImageFile(fileId: File.generateID(), uiimage: sceneView.snapshot(), savePath: SystemFilePath.CACHE.rawValue)
            onSuccess?( imageFile )
        } catch let error as NSError {
            print(error)
            onFail?( error.localizedDescription )
        }
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let hapticParameter = NSMutableDictionary()
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                touchpoint = hitTestResultsWithFeaturePoints.first
                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                addBox(x: translation.x, y: translation.y, z: translation.z)
            }
            return
        }
        guard let name = node.name else {
            return
        }
        
        
        if name == "EINSTEIN" {
            hapticParameter.setValue( "medium", forKey: "type")
            let hapticSuccess = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
            CommandProcessor.queue(command: hapticSuccess)
            node.removeFromParentNode()
        } else {
            hapticParameter.setValue( "error", forKey: "type")
            let hapticSuccess = Command( commandCode: CommandCode.HAPTIC_FEEDBACK, parameter: hapticParameter, priority: .CRITICAL )
            CommandProcessor.queue(command: hapticSuccess)
            
            UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.sceneView.alpha = 0
                self.sceneView.frame.origin.y = 40
            }, completion: { finished in
                self.sceneView.session.pause()
                self.sceneView.removeFromSuperview()
            })
        }
        
    }
}


extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
