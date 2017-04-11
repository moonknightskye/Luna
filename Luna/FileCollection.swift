//
//  FileCollection.swift
//  Luna
//
//  Created by Mart Civil on 2017/04/11.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import Zip

class FileCollection {
    
    static var FILES:[File] = [File]()
    static var DIRECTORIES:[URL] = [URL]()
    private var path:String = SystemFilePath.DOCUMENT.rawValue
    private var pathType:FilePathType = FilePathType.DOCUMENT_TYPE
    private var filePath:URL!
    
    
    init( relative:String?=nil, pathType:FilePathType?=nil, filePath:URL?=nil ) {
        if relative != nil {
            self.path = relative!
        }
        if pathType != nil {
            self.pathType = pathType!
        }
        if filePath != nil {
            self.filePath = filePath!
        } else {
            self.filePath = FileManager.getDocumentsDirectoryPath( pathType: self.pathType, relative: self.path )
        }
        
        if let fileCollection = FileManager.getDocumentsFileList( path: self.filePath ) {
            for (_, file) in fileCollection.enumerated() {
                if file.absoluteString.endsWith(string: "/") {
                    FileCollection.DIRECTORIES.append(file)
                } else {
                    let file = File(path:self.path, filePath: file)
                    switch( File.getFileType( fileExt: file.getFileExtension() ) ) {
                    case .ZIP_FILE:
//                        let zip = file as? ZipFile
//                        print( zip?.getID() )
                        break
                    default:
                        break
                    }
                    
                    
                    FileCollection.FILES.append( file )
                }
            }
        }
    }
}
