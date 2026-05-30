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
        
        // Setup the image view properties
        imageView.wantsLayer = true
        imageView.animates = false // Controlled dynamically in viewDidAppear
        imageView.canDrawSubviewsIntoLayer = true
        
        addSubview(imageView)
        
        loadGif()
        updateImageViewLayout()
    }
    
    private func loadGif() {
        let fileManager = FileManager.default
        let useCustom: Bool = Preferences[.useCustomGif]
        
        if useCustom, let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let customURL = appSupport.appendingPathComponent("com.HelloWorld.HelloWorld/custom.gif")
            if fileManager.fileExists(atPath: customURL.path),
               let image = NSImage(contentsOf: customURL) {
                imageView.image = image
                return
            }
        }
        
        // Fallback to bundled nyancat
        if let gifPath = Bundle(for: type(of: self)).path(forResource: "nyancat", ofType: "gif") {
            imageView.image = NSImage(contentsOfFile: gifPath)
        }
    }
    
    private func updateImageViewLayout() {
        guard let image = imageView.image else { return }
        let isStatic: Bool = Preferences[.animationIsStatic]
        
        if isStatic {
            // Static mode: Fill container and scale appropriately
            imageView.frame = self.bounds
            imageView.imageScaling = .scaleProportionallyUpOrDown
        } else {
            // Scrolling mode: Calculate proportional width based on standard height (30)
            let imageSize = image.size
            let scaledWidth = imageSize.height > 0 ? (30.0 / imageSize.height) * imageSize.width : 680
            
            // Set starting frame positioned off-screen to the left
            imageView.frame = CGRect(x: -scaledWidth, y: 0, width: scaledWidth, height: 30)
            imageView.imageScaling = .scaleProportionallyDown
        }
    }
    
    // Allow the width to stretch dynamically while keeping height at 30
    override var intrinsicContentSize: NSSize {
        return NSSize(width: NSView.noIntrinsicMetric, height: 30)
    }
    
    // Listen for size/layout changes and adjust the animation range dynamically
    override func layout() {
        super.layout()
        
        updateImageViewLayout()
        
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
        
        loadGif()
        updateImageViewLayout()
        
        let isStatic: Bool = Preferences[.animationIsStatic]
        if isStatic {
            // Just loop the GIF in place
            imageView.animates = true
            return
        }
        
        // Read latest customized settings
        let duration: Double = Preferences[.animationDuration]
        let goBack: Bool = Preferences[.animationGoBack]
        let prefFromValue: Double = Preferences[.animationFromValue]
        let prefToValue: Double = Preferences[.animationToValue]
        
        let currentWidth = self.bounds.width > 0 ? self.bounds.width : 150
        let imageWidth = imageView.frame.width
        
        let defaultFromValue = 0.0
        let defaultToValue = imageWidth + currentWidth
        
        // Scale values dynamically if they are still on standard defaults
        let fromValue = prefFromValue == 0.0 ? defaultFromValue : prefFromValue
        let toValue = prefToValue == 830.0 ? defaultToValue : prefToValue
        
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
        let fileManager = FileManager.default
        let useCustom: Bool = Preferences[.useCustomGif]
        
        if useCustom, let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let customURL = appSupport.appendingPathComponent("com.HelloWorld.HelloWorld/custom.gif")
            if fileManager.fileExists(atPath: customURL.path),
               let image = NSImage(contentsOf: customURL) {
                return image
            }
        }
        
        if let gifPath = Bundle(for: NyanWidgetView.self).path(forResource: "nyancat", ofType: "gif"),
           let image = NSImage(contentsOfFile: gifPath) {
            return image
        }
        
        return NSImage(named: NSImage.touchBarAddDetailTemplateName) ?? NSImage()
    }
    
}
