//
//  CropAreaView.swift
//  PhotoComparator
//
//  Posted on January 7, 2016 by Deb S
// https://appsbydeb.wordpress.com/2016/07/26/ios-swiftalternative-approach-image-cropuiscrollview-with-pan-and-zoom-enabled/
//

import UIKit

class CropAreaView: UIView {

    var fillColor = UIColor(red: 0.09, green: 0.56, blue: 0.8, alpha: 0.2)
//    var _frame: CROP_OPTIONS!
//    var cropType: CROP_TYPE!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    init(origin: CGPoint, width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: width, height: height))
        _cropOptions = CROP_OPTIONS()
        _cropOptions.Center = origin
        
        var insetRect = CGRect(origin: CGPoint(x: 0, y: 0), size: self.bounds.size)
        insetRect = insetRect.insetBy(dx: 1, dy: 1)
        
        self.accessibilityPath = UIBezierPath(roundedRect: insetRect, cornerRadius: 0.0)
        self.center = origin
        _cropOptions.Width = self.bounds.width
        _cropOptions.Height = self.bounds.height
        self.backgroundColor = UIColor.clear
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panning(panGR:))))
        addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(pinching(pinchGR:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func panning(panGR: UIPanGestureRecognizer) {
       self.superview!.bringSubviewToFront(self)
        var translation = panGR.translation(in: self)
        translation = translation.applying(self.transform)
        self.center.x += translation.x
        self.center.y += translation.y
        panGR.setTranslation(.zero, in: self)
       _cropOptions.Center = self.center
    }
    
    @objc func pinching(pinchGR: UIPinchGestureRecognizer) {
        self.superview!.bringSubviewToFront(self)
        let scale = pinchGR.scale
        self.transform = self.transform.scaledBy(x: scale, y: scale)
        _cropOptions.Height = self.frame.height
        _cropOptions.Width = self.frame.width
        pinchGR.scale = 1.0
    }
    
    override func draw(_ rect: CGRect) {
       self.fillColor.setFill()
       self.accessibilityPath!.fill()
        self.accessibilityPath!.lineWidth = 1
       UIColor.white.setStroke()
       self.accessibilityPath!.stroke()
    }
}
