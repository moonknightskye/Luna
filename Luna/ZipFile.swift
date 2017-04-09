//
//  ZipFile.swift
//  Luna
//
//  Created by 志美瑠 真斗 on 2017/04/08.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

class ZipFile: File {

	private var unzipPath:String = SystemFilePath.DOCUMENT.rawValue

	override init(){
		super.init()
	}

	public override init( document:String, filePath: URL) {
		super.init( document:document, filePath:filePath )
	}

	public override init( document:String, path:String?=nil, filePath:URL?=nil ) throws {
		try super.init(document: document, path: path, filePath: filePath)
	}


	public override init( bundle:String, filePath: URL ) {
		super.init(bundle: bundle, filePath: filePath)
	}
	public override init( bundle:String, path:String?=nil, filePath:URL?=nil) throws {
		try super.init(bundle: bundle, path: path, filePath: filePath)
	}

	public override init( filePath: URL ) {
		super.init( filePath:filePath )
	}

	public convenience init( file:NSDictionary ) throws {
		var isValid = true

		let fileName:String? = file.value(forKeyPath: "filename") as? String
		let path:String? = file.value(forKeyPath: "path") as? String

		if let pathType = file.value(forKeyPath: "path_type") as? String {
			if let filePathType = FilePathType( rawValue: pathType ) {
				switch filePathType {
				case .BUNDLE_TYPE:
					if fileName != nil {
						try self.init( bundle: fileName!, path:path)
						return
					} else {
						isValid = false
					}
					break
				case .DOCUMENT_TYPE:
					if fileName != nil {
						try self.init( document: fileName!, path:path )
						return
					} else {
						isValid = false
					}
					break
				default:
					isValid = false
					break
				}

			} else {
				isValid = false
			}
		} else {
			isValid = false
		}

		if !isValid {
			throw FileError.INVALID_FILE_PARAMETERS
		}
		self.init()
	}

	public func setUnzipPath( unzipPath:String ) {
		self.unzipPath = unzipPath
	}

	public func getUnzipPath() -> String {
		return self.unzipPath
	}



}
