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
    
    // UI Elements
    private let selectGifButton = NSButton(title: "Select Custom GIF...", target: nil, action: nil)
    private let restoreDefaultButton = NSButton(title: "Use Default Nyan Cat", target: nil, action: nil)
    private let gifSourceLabel = NSTextField(labelWithString: "")
    
    private let staticCheckbox = NSButton(checkboxWithTitle: "Static Mode (loop GIF in place without moving)", target: nil, action: nil)
    private let durationField = NSTextField()
    private let goBackCheckbox = NSButton(checkboxWithTitle: "Autoreverse (Walk back and forth)", target: nil, action: nil)
    private let fromValueField = NSTextField()
    private let toValueField = NSTextField()
    private let minWidthField = NSTextField()
    
    // Elements to enable/disable based on Static Mode
    private var movementRows: [NSView] = []
    
    override func loadView() {
        // Larger frame height to hold additional fields
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 360, height: 380))
        self.view = container
        
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12
        stackView.edgeInsets = NSEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        container.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
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
        
        // --- SECTION 1: GIF SOURCE ---
        let sourceHeader = NSTextField(labelWithString: "GIF Image Source")
        sourceHeader.font = NSFont.boldSystemFont(ofSize: 13)
        stackView.addArrangedSubview(sourceHeader)
        
        let sourceButtonsRow = NSStackView()
        sourceButtonsRow.orientation = .horizontal
        sourceButtonsRow.spacing = 8
        selectGifButton.target = self
        selectGifButton.action = #selector(selectGifClicked(_:))
        restoreDefaultButton.target = self
        restoreDefaultButton.action = #selector(restoreDefaultClicked(_:))
        sourceButtonsRow.addArrangedSubview(selectGifButton)
        sourceButtonsRow.addArrangedSubview(restoreDefaultButton)
        stackView.addArrangedSubview(sourceButtonsRow)
        
        gifSourceLabel.textColor = .secondaryLabelColor
        gifSourceLabel.font = NSFont.systemFont(ofSize: 11)
        stackView.addArrangedSubview(gifSourceLabel)
        
        let minWidthRow = createRow(labelTitle: "Min Width (points):", textField: minWidthField)
        stackView.addArrangedSubview(minWidthRow)
        minWidthField.delegate = self
        
        // Divider
        let divider1 = NSBox()
        divider1.boxType = .separator
        divider1.translatesAutoresizingMaskIntoConstraints = false
        divider1.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(divider1)
        NSLayoutConstraint.activate([
            divider1.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            divider1.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
        
        // --- SECTION 2: ANIMATION CONTROLS ---
        let animationHeader = NSTextField(labelWithString: "Animation & Movement")
        animationHeader.font = NSFont.boldSystemFont(ofSize: 13)
        stackView.addArrangedSubview(animationHeader)
        
        // Static checkbox
        staticCheckbox.target = self
        staticCheckbox.action = #selector(staticModeChanged(_:))
        stackView.addArrangedSubview(staticCheckbox)
        
        // Create rows and save to movementRows array
        let durRow = createRow(labelTitle: "Duration (seconds):", textField: durationField)
        let fromRow = createRow(labelTitle: "From Translation X:", textField: fromValueField)
        let toRow = createRow(labelTitle: "To Translation X:", textField: toValueField)
        
        movementRows = [durRow, goBackCheckbox, fromRow, toRow]
        
        // Add row configurations
        stackView.addArrangedSubview(durRow)
        
        goBackCheckbox.target = self
        goBackCheckbox.action = #selector(goBackChanged(_:))
        stackView.addArrangedSubview(goBackCheckbox)
        
        stackView.addArrangedSubview(fromRow)
        stackView.addArrangedSubview(toRow)
        
        // Set text field delegates
        durationField.delegate = self
        fromValueField.delegate = self
        toValueField.delegate = self
        
        // Divider
        let divider2 = NSBox()
        divider2.boxType = .separator
        divider2.translatesAutoresizingMaskIntoConstraints = false
        divider2.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(divider2)
        NSLayoutConstraint.activate([
            divider2.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            divider2.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
        
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
        minWidthField.stringValue = String(format: "%.0f", Preferences[.gifMinWidth] as Double)
        
        let isStatic: Bool = Preferences[.animationIsStatic]
        staticCheckbox.state = isStatic ? .on : .off
        
        let useCustom: Bool = Preferences[.useCustomGif]
        gifSourceLabel.stringValue = useCustom ? "Current Source: Custom GIF file" : "Current Source: Default Nyan Cat GIF"
        
        updateControlsAvailability(isStatic: isStatic)
    }
    
    private func updateControlsAvailability(isStatic: Bool) {
        durationField.isEnabled = !isStatic
        goBackCheckbox.isEnabled = !isStatic
        fromValueField.isEnabled = !isStatic
        toValueField.isEnabled = !isStatic
        
        // Subtly dim movement fields when static mode is active
        let alphaValue: CGFloat = isStatic ? 0.5 : 1.0
        for view in movementRows {
            view.alphaValue = alphaValue
        }
    }
    
    @objc private func staticModeChanged(_ sender: NSButton) {
        let isStatic = sender.state == .on
        Preferences[.animationIsStatic] = isStatic
        updateControlsAvailability(isStatic: isStatic)
        notifyWidget()
    }
    
    @objc private func goBackChanged(_ sender: NSButton) {
        Preferences[.animationGoBack] = sender.state == .on
        notifyWidget()
    }
    
    @objc private func selectGifClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select custom animated GIF file"
        openPanel.showsResizeIndicator = true
        openPanel.showsHiddenFiles = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["gif", "GIF"]
        
        openPanel.beginSheetModal(for: self.view.window!) { [weak self] response in
            if response == .OK, let url = openPanel.url {
                self?.saveCustomGif(from: url)
            }
        }
    }
    
    @objc private func restoreDefaultClicked(_ sender: NSButton) {
        Preferences[.useCustomGif] = false
        loadPreferencesState()
        notifyWidget()
    }
    
    private func saveCustomGif(from sourceURL: URL) {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else { return }
        let destinationFolder = appSupport.appendingPathComponent("com.HelloWorld.HelloWorld", isDirectory: true)
        
        do {
            if !fileManager.fileExists(atPath: destinationFolder.path) {
                try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
            }
            let destinationURL = destinationFolder.appendingPathComponent("custom.gif")
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            
            // Successfully copied, update preference key
            Preferences[.useCustomGif] = true
            loadPreferencesState()
            notifyWidget()
        } catch {
            NSLog("[HelloWorldWidget]: Failed to save custom GIF: \(error)")
            let alert = NSAlert()
            alert.messageText = "Failed to load custom GIF"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
        }
    }
    
    @objc private func resetClicked(_ sender: NSButton) {
        reset()
    }
    
    func reset() {
        Preferences.reset()
        // Remove custom GIF if reset
        let fileManager = FileManager.default
        if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let customURL = appSupport.appendingPathComponent("com.HelloWorld.HelloWorld/custom.gif")
            if fileManager.fileExists(atPath: customURL.path) {
                try? fileManager.removeItem(at: customURL)
            }
        }
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
            } else if textField == minWidthField {
                Preferences[.gifMinWidth] = max(0.0, doubleVal)
            }
            notifyWidget()
        }
    }
    
    private func notifyWidget() {
        NotificationCenter.default.post(name: .shouldReloadNyanWidget, object: nil)
    }
}
