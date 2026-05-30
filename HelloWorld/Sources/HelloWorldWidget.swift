//
//  HelloWorldWidget.swift
//  HelloWorld
//
//  Created by Gabriela Tovar on 30/05/26.
//

import Foundation
import AppKit
import PockKit

// MARK: - Custom NyanWidgetView
class NyanWidgetView: NSView {
    
    private let imageView = NSImageView()
    private var lastWidth: CGFloat = 0
    
    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 150, height: 30))
        setupView()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: NSRect(x: 0, y: 0, width: 150, height: 30))
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.wantsLayer = true
        
        // FIX: Clip subviews to bounds so the 680-wide moving image doesn't overflow onto other widgets.
        self.layer?.masksToBounds = true
        
        // Setup Auto Layout priorities for stretching to fill empty space
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
        self.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        // Setup the image view and position it initially off-screen to the left
        imageView.wantsLayer = true
        imageView.frame = CGRect(x: -680, y: 0, width: 680, height: 30)
        imageView.animates = false // Controlled dynamically in viewDidAppear
        imageView.canDrawSubviewsIntoLayer = true
        imageView.imageScaling = .scaleProportionallyDown
        
        // Load the GIF locally from the widget's bundle
        if let gifPath = Bundle(for: type(of: self)).path(forResource: "nyancat", ofType: "gif") {
            imageView.image = NSImage(contentsOfFile: gifPath)
        }
        
        addSubview(imageView)
    }
    
    // Allow the width to stretch dynamically while keeping height at 30
    override var intrinsicContentSize: NSSize {
        return NSSize(width: NSView.noIntrinsicMetric, height: 30)
    }
    
    // Listen for size/layout changes and adjust the animation range dynamically
    override func layout() {
        super.layout()
        if self.bounds.width != lastWidth {
            lastWidth = self.bounds.width
            // If currently animating, restart with the new width
            if imageView.layer?.animation(forKey: "nyanMovement") != nil {
                startMovingAnimation()
            }
        }
    }
    
    // Lifecycle Animation Management (Coding Practice from StatusWidget)
    func startMovingAnimation() {
        stopMovingAnimation() // Prevent duplicate animations
        
        // Read latest customized settings
        let duration: Double = Preferences[.animationDuration]
        let goBack: Bool = Preferences[.animationGoBack]
        let fromValue: Double = Preferences[.animationFromValue]
        let toValue: Double = Preferences[.animationToValue]
        
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = fromValue
        animation.toValue = toValue
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.autoreverses = goBack
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        imageView.layer?.add(animation, forKey: "nyanMovement")
        imageView.animates = true
    }
    
    func stopMovingAnimation() {
        imageView.layer?.removeAnimation(forKey: "nyanMovement")
        imageView.animates = false
    }
}

// MARK: - HelloWorldWidget conforming to PKWidget
class HelloWorldWidget: PKWidget {
    
    static var identifier: String = "com.HelloWorld.HelloWorld"
    var customizationLabel: String = "HelloWorld"
    var view: NSView!
    
    private var nyanView: NyanWidgetView {
        return view as! NyanWidgetView
    }
    
    required init() {
        self.view = NyanWidgetView()
    }
    
    // Start animation and register live updates observer when widget is visible
    func viewDidAppear() {
        nyanView.startMovingAnimation()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWidgetAnimation), name: .shouldReloadNyanWidget, object: nil)
    }
    
    // Stop animation and remove observer when widget is hidden
    func viewWillDisappear() {
        nyanView.stopMovingAnimation()
        NotificationCenter.default.removeObserver(self, name: .shouldReloadNyanWidget, object: nil)
    }
    
    @objc private func reloadWidgetAnimation() {
        nyanView.startMovingAnimation()
    }
    
    // Customization preview image (required for draggability in the customization palette)
    var imageForCustomization: NSImage {
        return NSImage(named: NSImage.touchBarAddDetailTemplateName) ?? NSImage()
    }
    
}
