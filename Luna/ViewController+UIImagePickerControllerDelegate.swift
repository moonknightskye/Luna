//
//  ViewController+UIImagePickerControllerDelegate.swift
//  Luna
//
//  Created by Mart Civil on 2017/02/21.
//  Copyright © 2017年 salesforce.com. All rights reserved.
//

import Foundation
import UIKit

extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        CommandProcessor.processMediaPicker()
        self.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        CommandProcessor.processMediaPicker( media: info  )
        self.dismiss(animated: true, completion: nil);
    }
}
