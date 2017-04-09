//
//  DownloadManager.swift
//  Luna
//
//  Created by 志美瑠 真斗 on 2017/04/10.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation

class DownloadManager {

	static var QUEUE:[DownloadManager] = [DownloadManager]();
	static var counter = 0;
	private var download_id = DownloadManager.counter
	private var downloadFile:File!

	private var downloadTask: URLSessionDownloadTask!
	private var backgroundSession: URLSession!

	public init( file: File ) throws {
		if file.getPathType() == FilePathType.URL_TYPE {
			self.downloadFile = file

			for (_, manager) in DownloadManager.QUEUE.enumerated() {
				if manager.getFile().getFilePath() == self.getFile().getFilePath() {
					throw FileError.DOWNLOAD_ALREADY_INQUEUE
				}
			}

			DownloadManager.QUEUE.append(self)
			DownloadManager.counter += 1;
		} else {
			throw FileError.ONLY_URL_TYPE
		}
	}

	public func getFile() -> File {
		return self.downloadFile
	}
}


