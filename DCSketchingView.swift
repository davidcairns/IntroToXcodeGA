//
//  DCSketchingView.swift
//  Drawrrr
//
//  Created by David Cairns on 5/3/15.
//  Copyright (c) 2015 David Cairns. All rights reserved.
//

import UIKit

struct DCSketchLine {
	let points: [CGPoint]
	let color: CGColorRef
}

struct DCSketch {
	let lines: [DCSketchLine]
}

public class DCSketchingView: UIView {
	var sketch: DCSketch = DCSketch(lines: [])
	
	public var image: UIImage {
		UIGraphicsBeginImageContext(self.bounds.size)
		let context = UIGraphicsGetCurrentContext()
		CGContextSetLineWidth(context, 8.0)
		
		for line in self.sketch.lines {
			CGContextSetStrokeColorWithColor(context, line.color)
			
			let path = line.points.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<CGPoint>) -> CGPath in
				let p = CGPathCreateMutable()
				CGPathAddLines(p, nil, buffer.baseAddress, line.points.count)
				return p
			}
			CGContextAddPath(context, path)
			CGContextStrokePath(context)
		}
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
	
	
	public override func drawRect(rect: CGRect) {
		self.image.drawInRect(rect)
	}
	
	
	// MARK: - Touch Handling
	var trackingTouch: UITouch? = nil
	var color = UIColor.redColor()
	public override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
		if trackingTouch != nil {
			return
		}
		
		if let touch = (touches.first as? UITouch) {
			trackingTouch = touch
			
			// Start a new line!
			self.sketch = DCSketch(lines: self.sketch.lines + [DCSketchLine(points: [touch.locationInView(self)], color: color.CGColor)])
			
			self.setNeedsDisplay()
		}
	}
	public override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
		for touch in (touches as! Set<UITouch>) {
			if touch === trackingTouch {
				// Add a point to our sketch's last line.
				if let currentLine = self.sketch.lines.last {
					let lineNewPoints = currentLine.points + [touch.locationInView(self)]
					self.sketch = DCSketch(lines: self.sketch.lines + [DCSketchLine(points: lineNewPoints, color: color.CGColor)])
				}
				self.setNeedsDisplay()
			}
		}
	}
	public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
		if trackingTouch != nil && touches.contains(trackingTouch!) {
			trackingTouch = nil
			self.setNeedsDisplay()
		}
	}
	public override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
		if trackingTouch != nil && touches.contains(trackingTouch!) {
			trackingTouch = nil
			
			// Remove the last-drawn line from our sketch!
			self.sketch = DCSketch(lines: Array(self.sketch.lines[0 ... min(0, self.sketch.lines.count - 1)]))
			self.setNeedsDisplay()
		}
	}
}
