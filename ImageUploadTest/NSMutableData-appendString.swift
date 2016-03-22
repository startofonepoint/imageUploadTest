//
//  NSMutableData-appendString.swift
//  ImageUploadTest
//
//  Created by lostin1 on 2016. 3. 15..
//  Copyright © 2016년 lostin. All rights reserved.
//

import Foundation
extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
