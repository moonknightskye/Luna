//
//  AVPlayerManager.swift
//  Luna
//
//  Created by Mart Civil on 2017/03/22.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public enum AVPlayerType:Int {
    case VIDEO              = 0
    case AUDIO              = 1
    case UNSUPPORTED        = -1
}

class AVPlayerManager {

    static var LIST:[AVPlayerManager] = [AVPlayerManager]();
    //static var counter = 0;
    
    private var avplayer_id:Int!
    private var playerLayer:AVPlayerLayer!
    private var videoFile:VideoFile?
    private var type = AVPlayerType.UNSUPPORTED
    private var autoplay:Bool = false
    private var mute:Bool = false
    
    public init( videoFile: VideoFile ) {
        //AVPlayerManager.counter += 1;
        
        self.avplayer_id = videoFile.getID()
        self.setType(type: AVPlayerType.VIDEO)
        self.playerLayer = AVPlayerLayer(player: videoFile.getAVPlayer()!)
        self.playerLayer.frame = Shared.shared.ViewController.view.frame
        self.setResizeAsAspectFill()
        self.setToBack()
        AVPlayerManager.LIST.append(self)
    }
    
    func setProperty( property: NSDictionary, animation: NSDictionary?=nil, onSuccess:((Bool)->())?=nil ) {
        if animation != nil {
            var duration = 0.0
            if let duration_val = animation!.value(forKey: "duration") as? Double {
                duration = duration_val
            }
            var delay = 0.0
            if let delay_val = animation!.value(forKey: "delay") as? Double {
                delay = delay_val
            }
            
            UIView.animate(withDuration: duration, delay: delay, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                self.setProperty(property: property)
            }, completion: { finished in
                if onSuccess != nil {
                    onSuccess!( finished )
                }
            })
        } else {
            self.setProperty(property: property)
            if onSuccess != nil {
                onSuccess!( true )
            }
        }
    }
    
    
    private func setProperty( property: NSDictionary ) {
        if let frame = property.value(forKeyPath: "frame") as? NSDictionary {
            if let width = frame.value(forKeyPath: "width") as? CGFloat {
                self.playerLayer.frame.size.width = width
            }
            if let height = frame.value(forKeyPath: "height") as? CGFloat {
                self.playerLayer.frame.size.height = height
            }
            if let x = frame.value(forKeyPath: "x") as? CGFloat {
                self.playerLayer.frame.origin.x = x
            }
            if let y = frame.value(forKeyPath: "y") as? CGFloat {
                self.playerLayer.frame.origin.y = y
            }
        }
        if let isOpaque = property.value(forKeyPath: "isOpaque") as? Bool {
            self.playerLayer.isOpaque = isOpaque;
        }
        if let alpha = property.value(forKeyPath: "opacity") as? Float {
            self.playerLayer.opacity = alpha
        }
        if let autoPlay = property.value(forKeyPath: "autoPlay") as? Bool {
            self.autoplay = autoPlay
        }
        if let mute = property.value(forKeyPath: "mute") as? Bool {
            self.playerLayer.player?.isMuted = mute
            self.mute = mute
        }
    }
    
    public func isAutoplay() -> Bool {
        return self.autoplay
    }
    public func isMute() -> Bool {
        return self.autoplay
    }
    public func seek( seconds: Double, onSuccess:((Bool)->())?=nil ) {
        //(Recommended timescales for movie files range from 600 to 90000.)
        self.playerLayer.player?.seek(to: CMTime(seconds: seconds, preferredTimescale: 600), completionHandler: { (result) in
            if onSuccess != nil {
                onSuccess!( result )
            }
        })
    }
    
    public func setResizeAsAspectFill(){
        self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
    public func setResizeAsHeightFill() {
        self.playerLayer.videoGravity = AVLayerVideoGravity.resize
    }
    public func setResizeAsWidthFill() {
        self.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
    }
    
    public func setToBack() {
        self.playerLayer.zPosition = -1
    }
    public func setToMiddle() {
        self.playerLayer.zPosition = 0
    }
    public func setToFront() {
        self.playerLayer.zPosition = 1
    }
    
    public func getAVPlayer() -> AVPlayerLayer {
        return self.playerLayer
    }
    
    public class func getManager( avplayer_id:Int?=nil, avPlayer:AVPlayerLayer?=nil ) -> AVPlayerManager? {
        for (_, manager) in AVPlayerManager.LIST.enumerated() {
            if avplayer_id != nil && manager.getID() == avplayer_id {
                return manager
            } else if avPlayer != nil && manager.getAVPlayer() == avPlayer {
                return manager
            }
        }
        return nil
    }
    
    private func setFile( file: File ) {
        switch self.getType() {
        case AVPlayerType.VIDEO:
            self.videoFile = file as? VideoFile
        default:
            break
        }
    }
    
    public func setType( type: AVPlayerType ) {
        self.type = type
    }
    public func getType() -> AVPlayerType {
        return self.type
    }
    
    public func getID() -> Int {
        return self.avplayer_id
    }
    
}
