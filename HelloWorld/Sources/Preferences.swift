//
//  Preferences.swift
//  HelloWorld
//
//  Created by Gabriela Tovar on 30/05/26.
//

import Foundation

extension NSNotification.Name {
    static let shouldReloadNyanWidget = NSNotification.Name("shouldReloadNyanWidget")
}

internal struct Preferences {
    internal enum Keys: String {
        case animationDuration
        case animationGoBack
        case animationFromValue
        case animationToValue
        case useCustomGif
        case animationIsStatic
        case gifMinWidth
    }
    static subscript<T>(_ key: Keys) -> T {
        get {
            guard let value = UserDefaults.standard.value(forKey: key.rawValue) as? T else {
                switch key {
                case .animationDuration:
                    return 8.0 as! T
                case .animationGoBack:
                    return true as! T
                case .animationFromValue:
                    return 0.0 as! T
                case .animationToValue:
                    return 830.0 as! T
                case .useCustomGif:
                    return false as! T
                case .animationIsStatic:
                    return false as! T
                case .gifMinWidth:
                    return 0.0 as! T
                }
            }
            return value
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: key.rawValue)
        }
    }
    static func reset() {
        Preferences[.animationDuration] = 8.0
        Preferences[.animationGoBack] = true
        Preferences[.animationFromValue] = 0.0
        Preferences[.animationToValue] = 830.0
        Preferences[.useCustomGif] = false
        Preferences[.animationIsStatic] = false
        Preferences[.gifMinWidth] = 0.0
    }
}
