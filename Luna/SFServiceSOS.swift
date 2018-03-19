//
//  SFServiceSOS.swift
//  Luna
//
//  Created by Mart Civil on 2017/09/04.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import ServiceCore
import ServiceSOS

class SFServiceSOS: SOSOnboardingBaseViewController {
    
    static let instance:SFServiceSOS = SFServiceSOS()
    var isValid = false
    
    override func willHandleConnectionPrompt() -> Bool {
        return true
    }
    
    override func connectionPromptRequested() {
        self.handleStartSession(self)
    }
    
    func getInstance() -> SFServiceSOS {
        if !isValid {
            self.instantiate()
        }
        return .instance
    }
    
    func start( isautoConnect:Bool, email:String, pod:String, org: String, deployment:String, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->())  ) {
        if !isValid {
            onFail( "SFServiceSOS not initialized" )
        } else {
            if let options = SOSOptions(liveAgentPod: pod, orgId: org, deploymentId: deployment) {
                if( isautoConnect ) {
                    options.setViewControllerClass(SFServiceSOS.self, for: SOSUIPhase.onboarding)
                }
                options.featureClientFrontCameraEnabled = true
                options.featureClientBackCameraEnabled = true
                options.featureClientScreenSharingEnabled = true
                options.initialCameraType = .frontFacing
                
                
                options.customFieldData = ["SCQuickSetup__CurrentEmail__c": email]
                ServiceCloud.shared().sos.startSession(with: options, completion: { (error, session) in
                    if error != nil {
                        let errorStr = error!.localizedDescription
                        var err = "The following SOSOptions are invalid: "
                        if( errorStr.contains("The following SOSOptions are invalid") ) {
                            if( errorStr.contains("orgId") ) {
                                err = err + " Org ID"
                            }
                            if( errorStr.contains("deploymentId") ) {
                                err = err + " Deployment ID"
                            }
                        }
                        onFail( err )
                    } else {
                        onSuccess( true )
                    }
                })
            } else {
                onFail( "SOSOptions failed to initialize" )
            }
        }
    }
    
    func stop( onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if !isValid {
            onFail( "SFServiceSOS not initialized" )
        } else {
            if ServiceCloud.shared().sos.state != SOSSessionState.active {
                onFail( "No active SOS session" )
            } else {
                ServiceCloud.shared().sos.stopSession(completion: { (error, session) in
                    if error != nil {
                        onFail( error!.localizedDescription )
                    } else {
                        onSuccess( true )
                    }
                })
            }
        }
    }
    
    func flush() {
        deinstantiate()
    }
    
    private func instantiate() {
        ServiceCloud.shared().sos.add( Shared.shared.ViewController )
        isValid = true
    }
    
    private func deinstantiate() {
        ServiceCloud.shared().sos.remove( Shared.shared.ViewController )
        isValid = false
    }
    
    func getState( state: SOSSessionState ) -> String {
        switch state {
        case .inactive:
            return "Inactive: No active session. There will be no outgoing/incoming SOS traffic"
        case .configuring:
            return "Configuring: Session is doing pre-initialization configuration steps, such as network testing"
        case .connecting:
            return "Connecting: Session state is initializing and preparing to connect"
        case .initializing:
            return "Initializing: Session is attempting a connection to a live agent"
        case .active:
            return "Active: Live agent has connected and the session is fully active"
        }
    }
    
    func getErrorLabel( reason: SOSStopReason ) -> String {
        switch reason {
        case .agentDisconnected:
            return "Agent disconnected the session"
        case .backgroundedBeforeConnected:
            return "Session ended because the app was backgrounded before the connection completed"
        case .externalUnknown:
            return "Session was ended in response to the application attempting to terminate"
        case .invalid:
            return "Reset the cause for session disconnection"
        case .sessionError:
            return "Session ended due to an error"
        case .sessionTimeout:
            return "Session failed due to timeout"
        case .userDisconnected:
            return "User disconnected the session"
        }
    }
}

