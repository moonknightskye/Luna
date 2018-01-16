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
    var chatConfig:SCSChatConfiguration?
    
    func instantiate(liveAgentPod: String, orgId: String, deploymentId: String, buttonId: String, visitorName:String, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->())) {
        flush()
        ServiceCloud.shared().chat.add(Shared.shared.ViewController)
        if let _chatConfig = SCSChatConfiguration(liveAgentPod: liveAgentPod, orgId: orgId, deploymentId: deploymentId, buttonId: buttonId) {
            chatConfig = _chatConfig
            chatConfig!.visitorName = visitorName
            isValid = true
            onSuccess(true)
        } else {
            onFail("Failed to initialize Live Agent")
        }
    }
    
    func getInstance() -> SFServiceLiveAgent? {
        if !isValid {
            return nil
        }
        return .instance
    }
    
    func clearPrechatObject( onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if !isValid {
            onFail( "SFServiceLiveAgent not initialized" )
        } else {
            chatConfig!.prechatEntities.removeAllObjects()
            chatConfig!.prechatFields.removeAllObjects()
            onSuccess(true)
        }
    }
    
    func addPrechatObject( prechatObject:NSDictionary, onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if !isValid {
            onFail( "SFServiceLiveAgent not initialized" )
        } else {
            var isAdded = false
            var entity:SCSPrechatEntity?
            if let entityName = prechatObject.value(forKeyPath: "entityName") as? String {
                entity = SCSPrechatEntity(entityName: entityName)

                if let saveToTranscript = prechatObject.value(forKeyPath: "saveToTranscript") as? String {
                    entity!.saveToTranscript = saveToTranscript
                }
                if let linkToEntityName = prechatObject.value(forKeyPath: "linkToEntityName") as? String {
                    entity!.linkToEntityName = linkToEntityName
                }
                if let linkToEntityField = prechatObject.value(forKeyPath: "linkToEntityField") as? String {
                    entity!.linkToEntityField = linkToEntityField
                }
                if let showOnCreate = prechatObject.value(forKeyPath: "showOnCreate") as? Bool {
                    entity!.showOnCreate = showOnCreate
                }
                chatConfig!.prechatEntities.add(entity!)
            }
            
            if let fields = prechatObject.value(forKeyPath: "fields") as? [NSDictionary] {
                for ( _, field) in fields.enumerated() {
                    if let label = field.value(forKeyPath: "label") as? String,
                        let value = field.value(forKeyPath: "value") as? String {

                        chatConfig!.prechatFields.add(SCSPrechatObject(label: label, value: value))
                        
                        isAdded = true
                        
                        if entity != nil {
                            if let fieldName = field.value(forKeyPath: "fieldName") as? String {
                                let entityField = SCSPrechatEntityField(fieldName: fieldName, label: label)
                                entityField.doFind = field.value(forKeyPath: "doFind") as? Bool ?? false
                                entityField.isExactMatch = field.value(forKeyPath: "isExactMatch") as? Bool ?? false
                                entityField.doCreate = field.value(forKeyPath: "doCreate") as? Bool ?? false
                                entity!.entityFieldsMaps.add(entityField)
                            }
                        }
                    }
                }
                
                if isAdded {
                    onSuccess(true)
                } else {
                    onFail("No Prechat Fields defined")
                }
            } else {
                onFail("No Prechat Fields defined")
            }
        }
    }
    
    func checkAvailability( onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->()) ) {
        if !isValid {
            onFail( "SFServiceLiveAgent not initialized" )
        } else {
            ServiceCloud.shared().chat.determineAvailability(with: chatConfig!, completion: { (error: Error?, available: Bool) in
                if error != nil {
                    let errorStr = error!.localizedDescription
                    onFail( errorStr )
                } else {
                    onSuccess( available )
                }
            })
        }
    }
    
    func start( onSuccess: @escaping((Bool)->()), onFail: @escaping((String)->())  ) {
        if !isValid {
            onFail( "SFServiceLiveAgent not initialized" )
        } else {
            // https://developer.salesforce.com/docs/atlas.en-us.noversion.service_sdk_ios.meta/service_sdk_ios/live_agent_prechat_fields.htm
            
            // https://login.salesforce.com/?un=admin%40swtt16auto.demo&pw=sfdcj111
            
            //                // Add a required email field (with an email keyboard and no auto-correction)
            //                let emailField = SCSPrechatTextInputObject(label: "Email")
            //                emailField!.isRequired = true
            //                emailField!.keyboardType = .emailAddress
            //                emailField!.autocorrectionType = .no
            //                options.prechatFields.add(emailField!)
            //                options.fullscreenPrechat = false
            
            
            ServiceCloud.shared().chat.startSession(with: chatConfig!, completion: { (error, session) in
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
        }
    }
    
    func flush() {
        deinstantiate()
    }
    
    private func deinstantiate() {
        ServiceCloud.shared().chat.remove( Shared.shared.ViewController )
        isValid = false
    }
    
    func getState( state: SCSChatSessionState ) -> String {
        switch state {
        case .loading:
            return "Loading: Session is being loaded to begin connection process."
        case .connecting:
            return "Connecting: A connection with Live Agent servers is being established."
        case .connected:
            return "Connected: Connected with an agent to facilitate a chat session."
        case .queued:
            return "Queued: A connection has been established, but queueing for next available agent."
        case .prechat:
            return "Prechat: Prechat details are being filled out by the end-user."
        case .ending:
            return "Ending: Session is in the process of cleaning up network connections and ending."
        case .ended:
            return "Ended: Session has ended. Will proceed to the inactive state."
        case .inactive:
            return "Inactive: No active session. There will be no outgoing/incoming Chat traffic."
            
        }
    }
    
    func getErrorLabel( reason: SCSChatEndReason ) -> String {
        switch reason {
        // If the agent ended the session..
        case .agent:
            return "Agent disconnected the session"
            
        // If the user ended the session...
        case .user:
            return "User disconnected the session"
            
        // If the session ended in an error...
        case .sessionError:
            return "Session ended due to an error"
            
        // If there was a session timeout...
        case .timeout:
            return "Session ended due to timeout"
        }
    }
}
