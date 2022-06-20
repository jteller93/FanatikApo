//
//  UIImage+Helper.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

extension UIImage {
    static func asOriginal(named: String) -> UIImage? {
        return UIImage(named: named)?.withRenderingMode(.alwaysOriginal)
    }
    
    static func generateQRcode(qrCodeString: String?) -> UIImage? {
        guard let myString = qrCodeString else {
            return nil
        }
        // Get data from the string
        let data = myString.data(using: String.Encoding.ascii)
        // Get a QR CIFilter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        // Input the data
        qrFilter.setValue(data, forKey: "inputMessage")
        // Get the output image
        guard let qrImage = qrFilter.outputImage else { return nil }
        // Scale the image
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        // Do some processing to get the UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

extension UIImageView {
    func setImage(urlString: String?, placeholder: UIImage? = nil, completion: ((Alamofire.DataResponse<UIImage>) -> Swift.Void)? = nil) {
        guard var url = urlString, !url.isEmpty else {
            image = placeholder
            return
        }
        
        if !url.hasPrefix("http") {
            url = "https:" + url
        }
        
        if let imgURL = URL(string: url.replacingOccurrences(of: " ", with: "%20")) {
            af_setImage(withURL: imgURL, placeholderImage: nil, completion: completion)
        } else {
            self.image = placeholder
        }
    }
}

extension UIButton {
    func setImage(urlString: String?, for state: UIControl.State = .normal) {
        guard var url = urlString, !url.isEmpty else {
            return
        }
        
        if !url.hasPrefix("http") {
            url = "https:" + url
        }
        
        if let imgURL = URL(string: url) {
            af_setImage(for: state, url: imgURL)
        }
    }
    
    func alignTextBelow(spacing: CGFloat = 6.0, leftSpacing: CGFloat = 0) {
        
        if let image = imageView?.image {
            let imageSize: CGSize = image.size
            titleEdgeInsets = UIEdgeInsets(top: spacing, left: -imageSize.width - leftSpacing, bottom: -(imageSize.height) , right: 0.0)
            let labelString = NSString(string: titleLabel!.text!)
            let titleSize = labelString.size(withAttributes: [NSAttributedString.Key.font: titleLabel!.font])
            imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        }
    }
}
