//
//  JavaScriptCoreExtended.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 14/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Foundation
import JavaScriptCore

// JSCoreExtended attaches the Javascript core extentions to a JavaScriptCore JSContext
func JSCoreExtended(_ jsContext: JSContext) {
    // JSCEConsole Global -> console
    jsContext.setObject(JSCEConsole.self, forKeyedSubscript: "console" as (NSCopying & NSObjectProtocol)?)
    
    // JSCETimer Global -> setTimeout, setInterval
    let _ = JSCETimer(jsContext)

    // Future:
    // - JSCERequire Global -> require
    // - fs module, ignore electron require
    // - Promise's (assume not already supported)
}
