//
//  HelloWorldWidget.swift
//  HelloWorld
//
//  Created by Gabriela Tovar on 30/05/26.
//  
//

import Foundation
import AppKit
import PockKit

class HelloWorldWidget: PKWidget {
    
    static var identifier: String = "com.HelloWorld.HelloWorld"
    var customizationLabel: String = "HelloWorld"
    var view: NSView!
    
    required init() {
        self.view = PKButton(title: "HelloWorld", target: self, action: #selector(printMessage))
    }
    
    @objc private func printMessage() {
        NSLog("[HelloWorldWidget]: Hello, World!")
    }
    
}
