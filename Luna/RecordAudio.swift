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

final class RecordAudio: NSObject {

	var audioFile:File!
	var destinationFile: ExtAudioFileRef? = nil
	var error : OSStatus = noErr

	var audioUnit:   AudioUnit?     = nil

	var micPermission   =  false
	var sessionActive   =  false
	var isRecording     =  false

	var sampleRate : Double = 44100.0    // default audio sample rate

	let circBuffSize = 32768        // lock-free circular fifo/buffer size
	var circBuffer   = [Float](repeating: 0, count: 32768)  // for incoming samples
	var circInIdx  : Int =  0
	var audioLevel : Float  = 0.0

	private var hwSRate = 48000.0   // guess of device hardware sample rate
	private var micPermissionDispatchToken = 0
	private var interrupted = false     // for restart from audio interruption notification
    
    private var uuid:String = ""
    private var tokenid:String = ""
    private var voice_id:Int = 0
    
    func setUIID( id:String ) {
        self.uuid = id
    }
    func setToken( id:String ) {
        self.tokenid = id
    }

	func startRecording() {
		if isRecording { return }

		startAudioSession()
		if sessionActive {
			startAudioUnit()
		}
	}

	var numberOfChannels: Int       =  2

	private let outputBus: UInt32   =  0
	private let inputBus: UInt32    =  1

	func startAudioUnit() {
		var err: OSStatus = noErr

		if self.audioUnit == nil {
			setupAudioUnit()         // setup once
		}
		guard let au = self.audioUnit
			else { return }

		err = AudioUnitInitialize(au)
		gTmp0 = Int(err)
		if err != noErr { return }
		err = AudioOutputUnitStart(au)  // start

		gTmp0 = Int(err)
		if err == noErr {
			isRecording = true
		}
	}

	func startAudioSession() {
		if (sessionActive == false) {
			// set and activate Audio Session
			do {

				let audioSession = AVAudioSession.sharedInstance()

				if (micPermission == false) {
					if (micPermissionDispatchToken == 0) {
						micPermissionDispatchToken = 1
						audioSession.requestRecordPermission({(granted: Bool)-> Void in
							if granted {
								self.micPermission = true
								return
								// check for this flag and call from UI loop if needed
							} else {
								gTmp0 += 1
								// dispatch in main/UI thread an alert
								//   informing that mic permission is not switched on
							}
						})
					}
				}
				if micPermission == false { return }

				do {
					audioFile = try File(fileId: File.generateID(), file: Data(), document: "TEMP_WAV.wav")

					// Set format to 32-bit Floats, linear PCM
					var streamFormatDesc = self.getAudioStreamBasicDesc()

					error = ExtAudioFileCreateWithURL(
						audioFile.getFilePath()! as CFURL,
						kAudioFileWAVEType,
						&streamFormatDesc,
						nil,
						AudioFileFlags.eraseFile.rawValue,
						&destinationFile)

					error = ExtAudioFileSetProperty(destinationFile!,
					                                kExtAudioFileProperty_ClientDataFormat,
					                                UInt32(MemoryLayout<UInt32>.size),
					                                &streamFormatDesc)

				} catch {
					print("FAILED TO CREATE TEMP FILE")
					return
				}

				try audioSession.setCategory(AVAudioSessionCategoryRecord)
				// choose 44100 or 48000 based on hardware rate
				// sampleRate = 44100.0
				var preferredIOBufferDuration = 0.0058      // 5.8 milliseconds = 256 samples
				hwSRate = audioSession.sampleRate           // get native hardware rate
				if hwSRate == 48000.0 { sampleRate = 48000.0 }  // set session to hardware rate
				if hwSRate == 48000.0 { preferredIOBufferDuration = 0.0053 }
				let desiredSampleRate = sampleRate
				try audioSession.setPreferredSampleRate(desiredSampleRate)
				try audioSession.setPreferredIOBufferDuration(preferredIOBufferDuration)

				NotificationCenter.default.addObserver(
					forName: NSNotification.Name.AVAudioSessionInterruption,
					object: nil,
					queue: nil,
					using: myAudioSessionInterruptionHandler )

				try audioSession.setActive(true)
				sessionActive = true
			} catch /* let error as NSError */ {
				// handle error here
			}
		}
	}

	private func getAudioStreamBasicDesc() -> AudioStreamBasicDescription {
//		let nc = 2  // 2 channel stereo
//		let streamFormatDesc:AudioStreamBasicDescription = AudioStreamBasicDescription(
//			mSampleRate:        Double(sampleRate),
//			mFormatID:          kAudioFormatLinearPCM,
//			mFormatFlags:       ( kAudioFormatFlagsNativeFloatPacked ),
//			mBytesPerPacket:    UInt32(nc * MemoryLayout<UInt32>.size),
//			mFramesPerPacket:   1,
//			mBytesPerFrame:     UInt32(nc * MemoryLayout<UInt32>.size),
//			mChannelsPerFrame:  UInt32(nc),
//			mBitsPerChannel:    UInt32(8 * (MemoryLayout<UInt32>.size)),
//			mReserved:          UInt32(0)
//		)
		var formatFlags = AudioFormatFlags()
		formatFlags |= kLinearPCMFormatFlagIsSignedInteger
		formatFlags |= kLinearPCMFormatFlagIsPacked
		let streamFormatDesc = AudioStreamBasicDescription(
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
		return streamFormatDesc;
	}

	private func setupAudioUnit() {

		var componentDesc:  AudioComponentDescription
			= AudioComponentDescription(
				componentType:          OSType(kAudioUnitType_Output),
				componentSubType:       OSType(kAudioUnitSubType_RemoteIO),
				componentManufacturer:  OSType(kAudioUnitManufacturer_Apple),
				componentFlags:         UInt32(0),
				componentFlagsMask:     UInt32(0) )

		var osErr: OSStatus = noErr

		let component: AudioComponent! = AudioComponentFindNext(nil, &componentDesc)

		var tempAudioUnit: AudioUnit?
		osErr = AudioComponentInstanceNew(component, &tempAudioUnit)
		self.audioUnit = tempAudioUnit

		guard let au = self.audioUnit
			else { return }

		// Enable I/O for input.

		var one_ui32: UInt32 = 1

		osErr = AudioUnitSetProperty(au,
		                             kAudioOutputUnitProperty_EnableIO,
		                             kAudioUnitScope_Input,
		                             inputBus,
		                             &one_ui32,
		                             UInt32(MemoryLayout<UInt32>.size))

		// Set format to 32-bit Floats, linear PCM
		var streamFormatDesc = self.getAudioStreamBasicDesc()
        

		osErr = AudioUnitSetProperty(au,
		                             kAudioUnitProperty_StreamFormat,
		                             kAudioUnitScope_Input, outputBus,
		                             &streamFormatDesc,
		                             UInt32(MemoryLayout<AudioStreamBasicDescription>.size))

		osErr = AudioUnitSetProperty(au,
		                             kAudioUnitProperty_StreamFormat,
		                             kAudioUnitScope_Output,
		                             inputBus,
		                             &streamFormatDesc,
		                             UInt32(MemoryLayout<AudioStreamBasicDescription>.size))

		var inputCallbackStruct
			= AURenderCallbackStruct(inputProc: recordingCallback,
			                         inputProcRefCon:
				UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))

		osErr = AudioUnitSetProperty(au,
		                             AudioUnitPropertyID(kAudioOutputUnitProperty_SetInputCallback),
		                             AudioUnitScope(kAudioUnitScope_Global),
		                             inputBus,
		                             &inputCallbackStruct,
		                             UInt32(MemoryLayout<AURenderCallbackStruct>.size))

		// Ask CoreAudio to allocate buffers on render.
		osErr = AudioUnitSetProperty(au,
		                             AudioUnitPropertyID(kAudioUnitProperty_ShouldAllocateBuffer),
		                             AudioUnitScope(kAudioUnitScope_Output),
		                             inputBus,
		                             &one_ui32,
		                             UInt32(MemoryLayout<UInt32>.size))

		gTmp0 = Int(osErr)
	}

	let recordingCallback: AURenderCallback = { (
		inRefCon,
		ioActionFlags,
		inTimeStamp,
		inBusNumber,
		frameCount,
		ioData ) -> OSStatus in

		let audioObject = unsafeBitCast(inRefCon, to: RecordAudio.self)
		var err: OSStatus = noErr

		// set mData to nil, AudioUnitRender() should be allocating buffers
		var bufferList = AudioBufferList(
			mNumberBuffers: 1,
			mBuffers: AudioBuffer(
				mNumberChannels: UInt32(2),
				mDataByteSize: 16,
				mData: nil))

		if let au = audioObject.audioUnit {
			err = AudioUnitRender(au,
			                      ioActionFlags,
			                      inTimeStamp,
			                      inBusNumber,
			                      frameCount,
			                      &bufferList)
		}

		audioObject.processMicrophoneBuffer( inputDataList: &bufferList,
		                                     frameCount: UInt32(frameCount) )


		return 0
	}

	func processMicrophoneBuffer(   // process RemoteIO Buffer from mic input
		inputDataList : UnsafeMutablePointer<AudioBufferList>,
		frameCount : UInt32 )
	{
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

		error = ExtAudioFileWrite(destinationFile!, frameCount, inputDataList)
	}

	func stopRecording() {
		AudioUnitUninitialize(self.audioUnit!)
		isRecording = false

		error = ExtAudioFileDispose(destinationFile!)
		print("stopped...")
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


}

var gTmp0 = 0 //  temporary variable for debugger viewing

// end of class RecordAudio
