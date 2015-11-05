//
//  Meme.swift
//  MemeMe
//
//  Created by Jeff Tilson on 2015-10-29.
//  Copyright © 2015 Jeff Tilson. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    var topText: String?
    var bottomText: String?
    var originalImage: UIImage?
    var memedImage: UIImage?
    
    init(topText: String, bottomText: String, originalImage: UIImage?, memedImage: UIImage?) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}
