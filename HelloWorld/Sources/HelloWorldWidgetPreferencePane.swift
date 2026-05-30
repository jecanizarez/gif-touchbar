//
//  HelloWorldWidgetPreferencePane.swift
//  HelloWorld
//
//  Created by Gabriela Tovar on 30/05/26.
//

import Cocoa
import PockKit

class HelloWorldWidgetPreferencePane: NSViewController, NSTextFieldDelegate, PKWidgetPreference {
    
    static var nibName: NSNib.Name = ""
    
    private let durationField = NSTextField()
    private let goBackCheckbox = NSButton(checkboxWithTitle: "Autoreverse (Walk back and forth)", target: nil, action: nil)
    private let fromValueField = NSTextField()
    private let toValueField = NSTextField()
    
    override func loadView() {  
        // Design a clean, padded configuration container
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 340, height: 230))
        self.view = container
        
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 14
        stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        // Header Title
        let titleLabel = NSTextField(labelWithString: "Animation Sizing & Control")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 13)
        stackView.addArrangedSubview(titleLabel)
        
        // Helper to construct a uniform preference row
        func createRow(labelTitle: String, textField: NSTextField) -> NSView {
            let rowStack = NSStackView()
            rowStack.orientation = .horizontal
            rowStack.spacing = 10
            rowStack.alignment = .centerY
            
            let label = NSTextField(labelWithString: labelTitle)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.widthAnchor.constraint(equalToConstant: 130).isActive = true
            
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.widthAnchor.constraint(equalToConstant: 90).isActive = true
            
            rowStack.addArrangedSubview(label)
            rowStack.addArrangedSubview(textField)
            return rowStack
        }
        
        // Add row configurations
        stackView.addArrangedSubview(createRow(labelTitle: "Duration (seconds):", textField: durationField))
        
        goBackCheckbox.target = self
        goBackCheckbox.action = #selector(goBackChanged(_:))
        stackView.addArrangedSubview(goBackCheckbox)
        
        stackView.addArrangedSubview(createRow(labelTitle: "From Translation X:", textField: fromValueField))
        stackView.addArrangedSubview(createRow(labelTitle: "To Translation X:", textField: toValueField))
        
        // Set text field delegates
        durationField.delegate = self
        fromValueField.delegate = self
        toValueField.delegate = self
        
        // Reset to Defaults Button
        let resetButton = NSButton(title: "Reset to Defaults", target: self, action: #selector(resetClicked(_:)))
        stackView.addArrangedSubview(resetButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPreferencesState()
    }
    
    private func loadPreferencesState() {
        durationField.stringValue = String(format: "%.1f", Preferences[.animationDuration] as Double)
        goBackCheckbox.state = (Preferences[.animationGoBack] as Bool) ? .on : .off
        fromValueField.stringValue = String(format: "%.1f", Preferences[.animationFromValue] as Double)
        toValueField.stringValue = String(format: "%.1f", Preferences[.animationToValue] as Double)
    }
    
    @objc private func goBackChanged(_ sender: NSButton) {
        Preferences[.animationGoBack] = sender.state == .on
        notifyWidget()
    }
    
    @objc private func resetClicked(_ sender: NSButton) {
        reset()
    }
    
    func reset() {
        Preferences.reset()
        loadPreferencesState()
        notifyWidget()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField {
            let doubleVal = Double(textField.stringValue) ?? 0.0
            if textField == durationField {
                Preferences[.animationDuration] = max(0.1, doubleVal)
            } else if textField == fromValueField {
                Preferences[.animationFromValue] = doubleVal
            } else if textField == toValueField {
                Preferences[.animationToValue] = doubleVal
            }
            notifyWidget()
        }
    }
    
    private func notifyWidget() {
        NotificationCenter.default.post(name: .shouldReloadNyanWidget, object: nil)
    }
}
