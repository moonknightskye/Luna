//
//  SFLiveAgent.swift
//  Luna
//
//  Created by Mart Civil on 2017/09/14.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import ServiceCore
import ServiceChat

class SFServiceLiveAgent {
    static let instance:SFServiceLiveAgent = SFServiceLiveAgent()
    var isValid = false
    
    func getInstance() -> SFServiceSOS {
        if !isValid {
            self.instantiate()
        }
        return .instance
    }
    
    func start( pod:String, org: String, deployment:String, buttonid:String, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->())  ) {
        
        if !isValid {
            onFail( "SFServiceLiveAgent not initialized" )
        } else {
            if let options = SCSChatConfiguration(liveAgentPod: pod, orgId: org, deploymentId: deployment, buttonId: buttonid) {
                SCServiceCloud.sharedInstance().chat.startSession(with: options, completion: { (error, session) in
                    if error != nil {
                        let errorStr = error!.localizedDescription
//                        var err = "The following SOSOptions are invalid: "
//                        if( errorStr.contains("The following SOSOptions are invalid") ) {
//                            if( errorStr.contains("orgId") ) {
//                                err = err + " Org ID"
//                            }
//                            if( errorStr.contains("deploymentId") ) {
//                                err = err + " Deployment ID"
//                            }
//                        }
                        onFail( errorStr )
                    } else {
                        onSuccess( true )
                    }
                })
            } else {
                onFail( "SOSOptions failed to initialize" )
            }
        }
    }
    
    func flush() {
        deinstantiate()
    }
    
    private func instantiate() {
        SCServiceCloud.sharedInstance().chat.add(Shared.shared.ViewController)
        isValid = true
    }
    
    private func deinstantiate() {
        SCServiceCloud.sharedInstance().chat.remove( Shared.shared.ViewController )
        isValid = false
    }
}
