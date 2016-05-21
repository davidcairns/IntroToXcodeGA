import Foundation
import AppKit

public class Flickr {
	let API_KEY = ""
	
	public init() { }
	
	private func flickrSearchURLForSearchTerm(searchTerm:String) -> NSURL {
//		let escapedTerm = searchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
		
		let escapedTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet())
		let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(API_KEY)&text=\(escapedTerm)&per_page=30&format=json&nojsoncallback=1"
		return NSURL(string: URLString)!
	}
	
	public func photoURLsForSearch(search: String) -> [NSURL] {
		let url = flickrSearchURLForSearchTerm(search)
//		guard let data = NSData(contentsOfURL: url) else {
//			print("ERROR: Falied to request data from \(url)")
//			return []
//		}
//		let resultsDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
		
//		switch (resultsDictionary!["stat"] as! String) {
//		case "ok":
//			break
//		default:
//			return []
//		}
//		
//		let photosContainer = resultsDictionary!["photos"] as! NSDictionary
//		let photosReceived = photosContainer["photo"] as! [NSDictionary]
//		
//		return photosReceived.map {
//			photoDictionary in
//			
//			let photoID = photoDictionary["id"] as? String ?? ""
//			let farm = photoDictionary["farm"] as? Int ?? 0
//			let server = photoDictionary["server"] as? String ?? ""
//			let secret = photoDictionary["secret"] as? String ?? ""
//			
//			return NSURL(string: "http://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_m.jpg")!
//		}
		return []
	}
	public func photoURLsForSearchAsync(search: String, completion: [NSURL] -> ()) {
		doAsync({ self.photoURLsForSearch(search) } , then: completion)
	}
	
	
	
	public func imageFromURL(string: String) -> NSImage {
		return imageFromURL(NSURL(string: string)!)
	}
	public func imageFromURL(URL: NSURL) -> NSImage {
		let response = NSData(contentsOfURL: URL)!
		return NSImage(data: response)!
	}
	public func imageFromURLAsync(URL: NSURL, completion: NSImage? -> ()) {
		doAsync({ self.imageFromURL(URL) }, then: completion)
	}
}
