//
//  RecordAudio.swift
//
//  This is a Swift 3.0 class
//    that uses the iOS RemoteIO Audio Unit
//    to record audio input samples,
//  (should be instantiated as a singleton object.)
//
//  Created by Ronald Nicholson on 10/21/16.  Updated 2017Feb07
//  Copyright © 2017 HotPaw Productions. All rights reserved.
//  Distribution: BSD 2-clause license
//

import Foundation
import AVFoundation
import AudioUnit

// call startRecording() to start recording
final class VoiceRecorder: NSObject {
    
    static let instance:VoiceRecorder = VoiceRecorder()
    var audioSession: AVAudioSession!
    
    var audioFile:File!
    var destinationFile: ExtAudioFileRef? = nil
    var osErr: OSStatus = noErr
    internal private(set) var format = AudioStreamBasicDescription()
    
    var audioUnit:AudioUnit?    = nil
    
    public var micPermission    = false
    var sessionActive           = false
    var isRecording             = false
    
    var sampleRate:Double       = 16000.0    // default audio sample rate ORIG: 44100.0
    var numberOfChannels:Int    =  1         // mono(1) or dual(2) channel
    
    let circBuffSize            = 32768      // lock-free circular fifo/buffer size
    var circBuffer              = [Float](repeating: 0, count: 32768)  // for incoming samples
    var circInIdx:Int           = 0
    var audioLevel:Float        = 0.0
    
    private var hwSRate         = 48000.0   // guess of device hardware sample rate
    private var micPermissionDispatchToken = 0
    private var interrupted = false     // for restart from audio interruption notification
    
    internal override init() {
        // define audio format
        
        audioSession = AVAudioSession.sharedInstance()
        
        var formatFlags = AudioFormatFlags()
        formatFlags |= kLinearPCMFormatFlagIsSignedInteger
        formatFlags |= kLinearPCMFormatFlagIsPacked
        format                  = AudioStreamBasicDescription(
            mSampleRate         : Double( sampleRate ),
            mFormatID           : kAudioFormatLinearPCM,
            mFormatFlags        : formatFlags,
            mBytesPerPacket     : UInt32( numberOfChannels * MemoryLayout<Int16>.stride ),
            mFramesPerPacket    : 1,
            mBytesPerFrame      : UInt32( numberOfChannels * MemoryLayout<Int16>.stride ),
            mChannelsPerFrame   : UInt32 (numberOfChannels ),
            mBitsPerChannel     : UInt32( 8 * (MemoryLayout<Int16>.stride) ),
            mReserved           : UInt32(0)
        )
        
        //        // Set format to 32-bit Floats, linear PCM
        //        let nc = 2  // 2 channel stereo
        //        var streamFormatDesc:AudioStreamBasicDescription = AudioStreamBasicDescription(
        //            mSampleRate:        Double(sampleRate),
        //            mFormatID:          kAudioFormatLinearPCM,
        //            mFormatFlags:       ( kAudioFormatFlagsNativeFloatPacked ),
        //            mBytesPerPacket:    UInt32(nc * MemoryLayout<UInt32>.size),
        //            mFramesPerPacket:   1,
        //            mBytesPerFrame:     UInt32(nc * MemoryLayout<UInt32>.size),
        //            mChannelsPerFrame:  UInt32(nc),
        //            mBitsPerChannel:    UInt32(8 * (MemoryLayout<UInt32>.size)),
        //            mReserved:          UInt32(0)
        //        )
    }
    
    func checkPermission(onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->())) {
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setActive(true)
            // choose 44100 or 48000 based on hardware rate
            // sampleRate = 44100.0
            var preferredIOBufferDuration = 0.0058      // 5.8 milliseconds = 256 samples
            hwSRate = audioSession.sampleRate           // get native hardware rate
            if hwSRate == 48000.0 { sampleRate = 48000.0 }  // set session to hardware rate
            if hwSRate == 48000.0 { preferredIOBufferDuration = 0.0053 }
            let desiredSampleRate = sampleRate
            try audioSession.setPreferredSampleRate(desiredSampleRate)
            try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)
            
            audioSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        VoiceRecorder.instance.micPermission = true
                        onSuccess(true)
                    } else {
                        onFail("No Permission to Record Audio")
                    }
                }
            }
        } catch {
            onFail("Failed to initialize")
        }
    }
    
    
    func startRecording(onSuccess:((Bool)->())?=nil, onFail:((String)->())?=nil) {
        if isRecording {
            if onFail != nil {
                onFail!("Recording already in progress...")
            }
        } else {
            startAudioSession(onSuccess:onSuccess, onFail:onFail)
            
            if sessionActive {
                startAudioUnit()
            }
        }
    }
    
    private let outputBus:UInt32   =  0
    private let inputBus:UInt32    =  1
    
    func startAudioUnit() {
        var err: OSStatus = noErr
        
        if self.audioUnit == nil {
            setupAudioUnit()         // setup once
        }
        guard let au = self.audioUnit
            else { return }
        
        err = AudioUnitInitialize(au)
        if err != noErr { return }
        err = AudioOutputUnitStart(au)  // start
        
        if err == noErr {
            isRecording = true
        }
    }
    
    func startAudioSession(onSuccess:((Bool)->())?=nil, onFail:((String)->())?=nil) {
        if !sessionActive {
            do {
                audioFile = try File(
                    fileId      : File.generateID(),
                    file        : Data(),
                    document    : "TEMP_AUDIO_RECORDING.wav",
                    path        : SystemFilePath.CACHE.rawValue
                )
                
                osErr = ExtAudioFileCreateWithURL(
                    audioFile.getFilePath()! as CFURL,
                    kAudioFileWAVEType,
                    &format,
                    nil,
                    AudioFileFlags.eraseFile.rawValue,
                    &destinationFile
                )
                
                osErr = ExtAudioFileSetProperty(
                    destinationFile!,kExtAudioFileProperty_ClientDataFormat,
                    UInt32( MemoryLayout<UInt32>.size ),
                    &format
                )
                
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name.AVAudioSessionInterruption,
                    object: nil,
                    queue: nil,
                    using: myAudioSessionInterruptionHandler
                )
                
                try audioSession.setActive(true)
                sessionActive = true
                if onSuccess != nil {
                    onSuccess!(true)
                }
            } catch let error as NSError {
                if onFail != nil {
                    onFail!(error.localizedDescription)
                }
            }
        } else {
            if onFail != nil {
                onFail!("No active sessions")
            }
        }
    }
    
    private func setupAudioUnit() {
        
        var componentDesc = AudioComponentDescription(
            componentType           : OSType( kAudioUnitType_Output ),
            componentSubType        : OSType( kAudioUnitSubType_RemoteIO ),
            componentManufacturer   : OSType( kAudioUnitManufacturer_Apple ),
            componentFlags          : UInt32( 0 ),
            componentFlagsMask      : UInt32( 0 )
        )

        
        let component:AudioComponent! = AudioComponentFindNext( nil, &componentDesc )
        
        var tempAudioUnit: AudioUnit?
        osErr = AudioComponentInstanceNew( component, &tempAudioUnit )
        self.audioUnit = tempAudioUnit
        
        guard let au = self.audioUnit else { return }
        
        // Enable I/O for input.
        
        var one_ui32:UInt32 = 1
        
        osErr = AudioUnitSetProperty(
            au,
            kAudioOutputUnitProperty_EnableIO,
            kAudioUnitScope_Input,
            inputBus,
            &one_ui32,
            UInt32( MemoryLayout<UInt32>.size )
        )
        
        osErr = AudioUnitSetProperty(
            au,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input, outputBus,
            &format,
            UInt32( MemoryLayout<AudioStreamBasicDescription>.size )
        )
        
        osErr = AudioUnitSetProperty(
            au,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Output,
            inputBus,
            &format,
            UInt32( MemoryLayout<AudioStreamBasicDescription>.size )
        )
        
        var inputCallbackStruct = AURenderCallbackStruct(
            inputProc       : recordingCallback,
            inputProcRefCon : UnsafeMutableRawPointer( Unmanaged.passUnretained(self).toOpaque()) )
        
        osErr = AudioUnitSetProperty(
            au,
            AudioUnitPropertyID( kAudioOutputUnitProperty_SetInputCallback ),
            AudioUnitScope( kAudioUnitScope_Global ),
            inputBus,
            &inputCallbackStruct,
            UInt32( MemoryLayout<AURenderCallbackStruct>.size )
        )
        
        // Ask CoreAudio to allocate buffers on render.
        osErr = AudioUnitSetProperty(
            au,
            AudioUnitPropertyID( kAudioUnitProperty_ShouldAllocateBuffer ),
            AudioUnitScope( kAudioUnitScope_Output ),
            inputBus,
            &one_ui32,
            UInt32( MemoryLayout<UInt32>.size )
        )
    }
    
    let recordingCallback:AURenderCallback = {(inRefCon, ioActionFlags, inTimeStamp, inBusNumber, frameCount, ioData) -> OSStatus in
        
        let audioObject = unsafeBitCast(inRefCon, to: VoiceRecorder.self)
        var err: OSStatus = noErr
        
        // set mData to nil, AudioUnitRender() should be allocating buffers
        var bufferList = AudioBufferList(
            mNumberBuffers: 1,
            mBuffers: AudioBuffer(
                mNumberChannels : UInt32( 2 ),
                mDataByteSize   : 16,
                mData           : nil
            )
        )
        
        if let au = audioObject.audioUnit {
            err = AudioUnitRender(
                au,
                ioActionFlags,
                inTimeStamp,
                inBusNumber,
                frameCount,
                &bufferList
            )
        }
        
        audioObject.processMicrophoneBuffer( inputDataList: &bufferList, frameCount: UInt32(frameCount) )
        
        return 0
    }
    
    // process RemoteIO Buffer from mic input
    func processMicrophoneBuffer( inputDataList: UnsafeMutablePointer<AudioBufferList>, frameCount : UInt32 ) {
        let inputDataPtr = UnsafeMutableAudioBufferListPointer(inputDataList)
        let mBuffers : AudioBuffer = inputDataPtr[0]
        let count = Int(frameCount)
        
        let bufferPointer = UnsafeMutableRawPointer(mBuffers.mData)
        if let bptr = bufferPointer {
            let dataArray = bptr.assumingMemoryBound(to: Float.self)
            var sum : Float = 0.0
            var j = self.circInIdx
            let m = self.circBuffSize
            for i in 0..<(count/2) {
                let x = Float(dataArray[i+i  ])   // copy left  channel sample
                let y = Float(dataArray[i+i+1])   // copy right channel sample
                self.circBuffer[j    ] = x
                self.circBuffer[j + 1] = y
                j += 2 ; if j >= m { j = 0 }                // into circular buffer
                sum += x * x + y * y
            }
            self.circInIdx = j              // circular index will always be less than size
            if sum > 0.0 && count > 0 {
                let tmp = 5.0 * (logf(sum / Float(count)) + 20.0)
                let r : Float = 0.2
                audioLevel = r * tmp + (1.0 - r) * audioLevel
            }
        }
        
        osErr = ExtAudioFileWrite(destinationFile!, frameCount, inputDataList)
        CommandProcessor.processAVAudioRecorderRecording(buffer: Data(bytes: bufferPointer!, count: count))
        //let bufferData = Data(bytes: bufferPointer!, count: count)
        //print( bufferData )
    }
    
    func stopRecording( onSuccess:((File)->())?=nil, onFail:((String)->())?=nil ) {
        if isRecording {
            AudioUnitUninitialize(self.audioUnit!)
            isRecording = false
            sessionActive = false
            
            osErr = ExtAudioFileDispose(destinationFile!)
            if onSuccess != nil {
                onSuccess!(audioFile)
            }
        } else {
            if onFail != nil {
                onFail!("Audio recorder is not recording")
            }
        }
    }
    
    func myAudioSessionInterruptionHandler(notification: Notification) -> Void {
        let interuptionDict = notification.userInfo
        if let interuptionType = interuptionDict?[AVAudioSessionInterruptionTypeKey] {
            let interuptionVal = AVAudioSessionInterruptionType(
                rawValue: (interuptionType as AnyObject).uintValue )
            if (interuptionVal == AVAudioSessionInterruptionType.began) {
                if (isRecording) {
                    stopRecording()
                    isRecording = false
                    let audioSession = AVAudioSession.sharedInstance()
                    do {
                        try audioSession.setActive(false)
                        sessionActive = false
                    } catch {
                    }
                    interrupted = true
                }
            } else if (interuptionVal == AVAudioSessionInterruptionType.ended) {
                if (interrupted) {
                    // potentially restart here
                }
            }
        }
    }
    
    //https://stackoverflow.com/questions/35738133/ios-code-to-convert-m4a-to-wav
    func convertToWav( audioFile:File, onSuccess:((File)->()), onFail:((String)->()) ) {
        var encodedAudioFile:File!
        do {
            encodedAudioFile = try File(fileId: File.generateID(), file: Data(), document: "TEMP_ENCODED_WAV.wav", path: SystemFilePath.CACHE.rawValue)
        } catch let e as NSError {
            onFail( e.localizedDescription )
            return
        }
        
        var error : OSStatus = noErr
        var destinationFile: ExtAudioFileRef? = nil
        var sourceFile : ExtAudioFileRef? = nil
        
        var srcFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        
        ExtAudioFileOpenURL(audioFile.getFilePath()! as CFURL, &sourceFile)
        
        var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))
        
        ExtAudioFileGetProperty(sourceFile!,
                                kExtAudioFileProperty_FileDataFormat,
                                &thePropertySize, &srcFormat)
        
        var formatFlags = AudioFormatFlags()
        formatFlags |= kLinearPCMFormatFlagIsSignedInteger
        formatFlags |= kLinearPCMFormatFlagIsPacked
        var dstFormat2 = AudioStreamBasicDescription(
            mSampleRate: 16000.0,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: formatFlags,
            mBytesPerPacket: UInt32(1*MemoryLayout<Int16>.stride),
            mFramesPerPacket: 1,
            mBytesPerFrame: UInt32(1*MemoryLayout<Int16>.stride),
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0
        )
        
        // Create destination file
        error = ExtAudioFileCreateWithURL(
            encodedAudioFile.getFilePath()! as CFURL,
            kAudioFileWAVEType,
            &dstFormat2,
            nil,
            AudioFileFlags.eraseFile.rawValue,
            &destinationFile)
        //print("Error 1 in convertAudio: \(error.description)")
        
        error = ExtAudioFileSetProperty(sourceFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat2)
        //print("Error 2 in convertAudio: \(error.description)")
        
        error = ExtAudioFileSetProperty(destinationFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat2)
        //print("Error 3 in convertAudio: \(error.description)")
        
        let bufferByteSize : UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: 32768)
        var sourceFrameOffset : ULONG = 0
        
        while(true){
            var fillBufList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: 2,
                    mDataByteSize: UInt32(srcBuffer.count),
                    mData: &srcBuffer
                )
            )
            var numFrames : UInt32 = 0
            
            if(dstFormat2.mBytesPerFrame > 0){
                numFrames = bufferByteSize / dstFormat2.mBytesPerFrame
            }
            
            error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
            //print("Error 4 in convertAudio: \(error.description)")
            
            if(numFrames == 0){
                error = noErr;
                break;
            }
            
            sourceFrameOffset += numFrames
            error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
            //print("Error 5 in convertAudio: \(error.description)")
        }
        
        error = ExtAudioFileDispose(destinationFile!)
        //print("Error 6 in convertAudio: \(error.description)")
        error = ExtAudioFileDispose(sourceFile!)
        print("Error 7 in convertAudio: \(error.description)")
        print("Finished converting file")
        onSuccess( encodedAudioFile )
    }
    
}

// end of class RecordAudio
