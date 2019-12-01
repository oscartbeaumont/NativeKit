//
//  App.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 29/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Foundation
import Cocoa
import WebKit

@objc protocol AppExports: JSExport {
    func emit(_ event: String, _ info: Any?)
    func on(_ event: String, _ handler: JSValue)
    func quit()
}

// App is a global exposed to the JavaScriptCore
class App: NSObject, AppExports {
    func emit(_ event: String, _ info: Any?) {
        appEventEmitter.trigger(eventName: event, information: info)
    }
    
    
    func on(_ event: String, _ handler: JSValue) {
        appEventEmitter.listenTo(eventName: event, action: {
            handler.call(withArguments: [])
        });
    }
    
    
    func quit() {
        exit(0);
    }
}
