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
	
	func sketchAddingLine(line: DCSketchLine) -> DCSketch {
		return DCSketch(lines: self.lines + [line])
	}
	func sketchReplacingLastLine(line: DCSketchLine) -> DCSketch {
		return DCSketch(lines: self.lines.prefixUpTo(max(0, self.lines.count - 1)) + [line])
	}
	func sketchRemovingLastLine() -> DCSketch {
		let newLines = Array(self.lines.prefixUpTo(max(0, self.lines.count - 1)))
		return DCSketch(lines: newLines)
	}
}

extension DCSketchLine {
	var path: CGPath {
		return self.points.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<CGPoint>) -> CGPath in
			let p = CGPathCreateMutable()
			CGPathAddLines(p, nil, buffer.baseAddress, self.points.count)
			return p
		}
	}
	func renderIn(context: CGContext) {
		CGContextSaveGState(context)
		CGContextSetStrokeColorWithColor(context, self.color)
		CGContextAddPath(context, self.path)
		CGContextStrokePath(context)
		CGContextRestoreGState(context)
	}
}
extension DCSketch {
	func render(size: CGSize) -> UIImage {
		UIGraphicsBeginImageContext(size)
		let context = UIGraphicsGetCurrentContext()!
		CGContextSetLineWidth(context, 8.0)
		
		for line in self.lines {
			line.renderIn(context)
		}
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image
	}
}

public class DCSketchingView: UIView {
	var sketch: DCSketch = DCSketch(lines: [])
	
	public var color = UIColor.redColor()
	
	public func clear() {
		self.sketch = DCSketch(lines: [])
		self.setNeedsDisplay()
	}
	
	
	public var image: UIImage {
		return self.sketch.render(self.bounds.size)
	}
	public override func drawRect(rect: CGRect) {
		self.image.drawInRect(self.bounds)
	}
	public override var bounds: CGRect {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	
	// MARK: - Touch Handling
	var trackingTouch: UITouch? = nil
	public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if trackingTouch != nil {
			return
		}
		
		if let touch = touches.first {
			trackingTouch = touch
			
			// Start a new line!
			let newLine = DCSketchLine(points: [touch.locationInView(self)], color: color.CGColor)
			self.sketch = self.sketch.sketchAddingLine(newLine)
			
			self.setNeedsDisplay()
		}
	}
	public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for touch in touches {
			if touch === trackingTouch {
				// Add a point to our sketch's last line.
				if let currentLine = self.sketch.lines.last {
					let lineNewPoints = currentLine.points + [touch.locationInView(self)]
					let newLine = DCSketchLine(points: lineNewPoints, color: color.CGColor)
					self.sketch = self.sketch.sketchReplacingLastLine(newLine)
				}
				self.setNeedsDisplay()
			}
		}
	}
	public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if trackingTouch != nil && touches.contains(trackingTouch!) {
			trackingTouch = nil
			self.setNeedsDisplay()
		}
	}
	public override func touchesCancelled(touches: Set<UITouch>!, withEvent event: UIEvent!) {
		if trackingTouch != nil && touches.contains(trackingTouch!) {
			trackingTouch = nil
			
			// Remove the last-drawn line from our sketch!
			self.sketch = self.sketch.sketchRemovingLastLine()
			self.setNeedsDisplay()
		}
	}
}
