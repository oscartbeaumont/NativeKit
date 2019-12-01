//
//  Console.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 14/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Foundation
import JavaScriptCore

// Javascript Console Global Type
@objc protocol JSCEConsoleExports: JSExport {
    static func clear()
    // TODO: debug, log & error should support unlimited arguments (Vardic)
    static func debug(_ msg: Any)
    static func log(_ msg: Any)
    static func error(_ msg: Any)
}

// Javascript Console Global
class JSCEConsole: NSObject, JSCEConsoleExports {
   
    class func clear() {}

    class func debug(_ msg: Any) {
        print("[DEBUG]", msg)
    }
    
    class func log(_ msg: Any) {
        print(msg)
    }
    
    class func error(_ msg: Any) {
        print("[ERROR]", msg)
    }
}
