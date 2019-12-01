//
//  Config.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 27/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Foundation
import Cocoa
import WebKit

@objc protocol ConfigExports: JSExport {
    func set(_ key: String, _ value: Any)
    func get(_ key: String) -> Any?
    func delete(_ key: String)
    func clear()
}

// Config is a global exposed to the JavaScriptCore
class Config: NSObject, ConfigExports {
    private let defaults = UserDefaults.standard
    
    func set(_ key: String, _ value: Any) {
        defaults.set(value, forKey: key)
    }
    
    func get(_ key: String) -> Any? {
        return defaults.object(forKey: key)
    }
    
    func delete(_ key: String) {
        defaults.removeObject(forKey: key)
    }
    
    func clear() {
        defaults.dictionaryRepresentation().keys.forEach(defaults.removeObject(forKey:))
    }
}
