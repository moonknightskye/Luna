//
//  RecordWav.swift
//  Luna
//
//  Created by 志美瑠 真斗 on 2017/06/21.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import AVFoundation


//https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
//https://stackoverflow.com/questions/42178958/write-array-of-floats-to-a-wav-audio-file-in-swift

class VoiceRecorder {

	static let instance:VoiceRecorder = VoiceRecorder()
	var recordingSession: AVAudioSession!
	var audioRecorder: AVAudioRecorder!
	public var isPermitted = false
	var recorderAudioFile:File?

	init() {
		recordingSession = AVAudioSession.sharedInstance()
	}

	func checkPermission(onSuccess:@escaping ((Bool)->()), onFail:@escaping ((String)->())) {
		do {
			try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
			try recordingSession.setActive(true)
			recordingSession.requestRecordPermission() { allowed in
				DispatchQueue.main.async {
					if allowed {
						VoiceRecorder.instance.isPermitted = true
						//self.isPermitted = true
						onSuccess(true)
					} else {
						onFail("No Permission")
					}
				}
			}
		} catch {
			onFail("Failed to initialize")
			// failed to record!
		}
	}

	func startRecording( onSuccess:((Bool)->())?=nil, onFail:((String)->())?=nil ) {
		if !VoiceRecorder.instance.isPermitted {
			if onFail != nil {
				onFail!( "No Permission to record" )
			}
			return
		}

		do {
			recorderAudioFile = try File(fileId: File.generateID(), file: Data(), document: "TEMP_RECORDING.m4a", path: SystemFilePath.CACHE.rawValue)
		} catch let e as NSError {
			if onFail != nil {
				onFail!( e.localizedDescription )
			}
			return
		}

//		let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
		let settings = [
			AVFormatIDKey: Int(kAudioFormatMPEG4AAC), //kAudioFormatLinearPCM
			AVSampleRateKey: Float64(16000.0),
			AVNumberOfChannelsKey: 1,
			AVLinearPCMBitDepthKey:32,
			AVLinearPCMIsFloatKey: true,
			AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
		] as [String : Any]

		do {
			audioRecorder = try AVAudioRecorder(url: recorderAudioFile!.getFilePath()!, settings: settings)
			audioRecorder.delegate = Shared.shared.ViewController
			audioRecorder.record()
			//recordButton.setTitle("Tap to Stop", for: .normal)

			print("recording.....")
//			let _ = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.finishRecording), userInfo: nil, repeats: false)

			if onSuccess != nil {
				onSuccess!(true)
			}
		} catch {
			finishRecording()
		}
	}

	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}

	func finishRecording( onSuccess:((File)->())?=nil, onFail:((String)->())?=nil ) {
		if audioRecorder.isRecording {
			audioRecorder.stop()
			audioRecorder = nil
			if onSuccess != nil {
				onSuccess!( recorderAudioFile! )
			}
		} else {
			if onFail != nil {
				onFail!("not recording")
			}
		}


		print( "stopped" );
		//let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
		//let wavFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
		//convertAudio(audioFilename, outputURL: wavFilename)
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
