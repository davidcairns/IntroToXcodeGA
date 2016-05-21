import Foundation
import UIKit

public class Flickr {
	let apiKey: String
	
	// Use this with your own API key!
	public init(apiKey: String) {
		self.apiKey = apiKey
	}
	// Use this to use David’s private API key (NOTE: ONLY WORKS DURING CLASS) :D
	// To get your own API key, visit this page and follow the instructions (don’t worry, it’s easy!):
	//			-->	https://www.flickr.com/services/api/misc.api_keys.html <--
	convenience public init() {
		let url = NSURL(string: "http://davidcairns.org/src/flickr-api-key.txt")!
		let data = NSData(contentsOfURL: url)!
		let key = NSString(data: data, encoding: NSUTF8StringEncoding)!
		self.init(apiKey: key.substringToIndex(key.length - 1))
	}

	
	// The whole shebang
	public func imagesForSearch(search: String?) -> [UIImage] {
		guard let search = search else { return [] }
		let urls = self.photoURLsForSearch(search)
		return urls.map { url in self.imageFromURL(url) }
	}
	
	
	private func flickrSearchURLForSearchTerm(searchTerm:String) -> NSURL {
		let escapedTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
		let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(self.apiKey)&text=\(escapedTerm)&per_page=30&format=json&nojsoncallback=1"
		return NSURL(string: URLString)!
	}
	
	public func photoURLsForSearch(search: String) -> [NSURL] {
		let url = flickrSearchURLForSearchTerm(search)
		guard let data = NSData(contentsOfURL: url) else {
			print("ERROR: Falied to request data from \(url)")
			return []
		}
		let resultsDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
		
		let resultStatus = resultsDictionary!["stat"] as! String
		switch (resultStatus) {
		case "ok":
			break
		default:
			print("ERROR: request returned status '\(resultStatus)'")
			return []
		}
		
		let photosContainer = resultsDictionary!["photos"] as! NSDictionary
		let photosReceived = photosContainer["photo"] as! [NSDictionary]
		
		return photosReceived.map {
			photoDictionary in
			
			let photoID = photoDictionary["id"] as? String ?? ""
			let farm = photoDictionary["farm"] as? Int ?? 0
			let server = photoDictionary["server"] as? String ?? ""
			let secret = photoDictionary["secret"] as? String ?? ""
			
			return NSURL(string: "http://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_m.jpg")!
		}
	}
	
	
	// Loading images
	public func imageFromURL(string: String) -> UIImage {
		return imageFromURL(NSURL(string: string)!)
	}
	public func imageFromURL(URL: NSURL) -> UIImage {
		let response = NSData(contentsOfURL: URL)!
		return UIImage(data: response)!
	}
	
	
	// ASYNC
	private func doAsync <T> (block: () -> T, then: T -> ()) {
		let queue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
		dispatch_async(queue) {
			let result = block()
			dispatch_async(dispatch_get_main_queue()) {
				then(result)
			}
		}
	}
	public func photoURLsForSearchAsync(search: String, completion: [NSURL] -> ()) {
		doAsync({ self.photoURLsForSearch(search) } , then: completion)
	}
	public func imageFromURLAsync(URL: NSURL, completion: UIImage? -> ()) {
		doAsync({ self.imageFromURL(URL) }, then: completion)
	}
}
