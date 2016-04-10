//
//  DCDrawingStore.swift
//  Drawr
//
//  Created by David Cairns on 5/17/15.
//  Copyright (c) 2015 David Cairns. All rights reserved.
//

import UIKit

public class DCDrawingStore {
	static let sharedInstance = DCDrawingStore()
	
	var images: [UIImage]
	
	private let kCachedImagesKey = "kCachedImagesKey"
	init() {
		images = []
		if let storedImageDataArray = (NSUserDefaults.standardUserDefaults().arrayForKey(kCachedImagesKey) as? [NSData]) {
			for storedImageData in storedImageDataArray {
				if let decodedImage = UIImage(data: storedImageData) {
					images.append(decodedImage)
				}
			}
		}
	}
	
	func saveAllImagesToUserDefaults() {
		var imageDataArray: [NSData] = []
		for image in images {
			let imageData = UIImagePNGRepresentation(image)!
			imageDataArray.append(imageData)
		}
		
		NSUserDefaults.standardUserDefaults().setObject(imageDataArray, forKey: kCachedImagesKey)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	func saveImage(image: UIImage) {
		// Save to our app's settings.
		images.append(image)
		saveAllImagesToUserDefaults()
		
		// Also save this image to the photos album.
		UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
	}
}
