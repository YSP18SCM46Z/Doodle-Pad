//
//  DrawView.swift
//  Doodle
//
//  Created by Yue Zhou on 1/19/17.
//  Copyright © 2017 Yue Zhou. All rights reserved.
//

import UIKit

class DrawView: UIView {

    // MARK: member variables
    fileprivate var path: DrawPath?
    var pathColor: UIColor?
    var lineWidth: CGFloat?
    var image: UIImage? {
        didSet {
//            self.paths.add(image as Any)
            self.paths.addObjects(from: [image as Any])
            
            // re-draw
            self.setNeedsDisplay()
        }
    }
    
    // MARK: lazy init
    fileprivate lazy var paths: NSMutableArray = {
        return NSMutableArray()
    }()
    

    
    /**
     * Clears all paths
     */
    func clear() {
        self.paths.removeAllObjects()
        self.setNeedsDisplay()
    }
    
    /**
     * Undo last path
     */
    func undo() {
        self.paths.removeLastObject()
        self.setNeedsDisplay()
    }
    
    
    // MARK: init
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUp()
    }
    

    
    /**
     * init
     */
    func setUp() {
        self.lineWidth = 1
        self.pathColor = UIColor.black
        // add pan gesture
        let pan = UIPanGestureRecognizer(target: self, action: #selector(DrawView.panGesture(_:)))
        self.addGestureRecognizer(pan)
    }
    
    func panGesture(_ pan: UIPanGestureRecognizer) {
        // finger's touch point
        let curP: CGPoint = pan.location(in: self)
        
        // beginning point of touch
        if pan.state == UIGestureRecognizerState.began {
            self.path = DrawPath()
            self.path!.lineWidth = self.lineWidth!
            self.path!.pathColor = self.pathColor!
            
            // move to point
            self.path!.move(to: curP)
            
            // save the path
            self.paths.addObjects(from: [path as Any])
        }
        
        // finger keeps moving
        // add line to curP
        path?.addLine(to: curP)
        
        // re-draw
        self.setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        for i in 0..<self.paths.count {
            if (self.paths.object(at: i) as AnyObject) is UIImage {
                // draw an image
                let image: UIImage = self.paths.object(at: i) as! UIImage
                
                let size = displaySize(with: image);
        
                // short image
                if size.height < UIScreen.main.bounds.height {
                    // center the image
                    let y = (self.frame.size.height - size.height) * 0.5
                    image.draw(in: CGRect(origin: CGPoint.init(x: 0, y: y), size: size))
                }
                else {  // long image
                    image.draw(in: CGRect(origin: CGPoint.zero, size: size))
                }
            }
            else {
                // draw a line
                (self.paths.object(at: i) as! DrawPath).pathColor?.set()
                (self.paths.object(at: i) as! DrawPath).stroke()
            }
        }
    }

    private func displaySize(with image: UIImage) -> CGSize {
        let scale = image.size.height / image.size.width
        
        // calculate the height based on ratio of original width/height
        let width = UIScreen.main.bounds.width
        let height = width * scale
        
        return CGSize(width: width, height: height)
    }
}
