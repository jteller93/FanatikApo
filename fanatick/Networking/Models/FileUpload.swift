//
//  FileUpload.swift
//  fanatick
//
//  Created by Yashesh on 06/06/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit

struct UploadFile {
    
    enum FileType {
        case image
        case pdf
        var contentType: String {
            switch self {
            case .image:
                return "image/png"
            case .pdf:
                return "application/pdf"
            }
        }
    }
    
    var ext: String {
        switch type! {
        case .image:
            return K.PathExtension.PNG.rawValue
        case .pdf:
            return K.PathExtension.PDF.rawValue
        }
    }
    
    var type: FileType!
    var image: UIImage?
    var sourceUrl: URL?
}
