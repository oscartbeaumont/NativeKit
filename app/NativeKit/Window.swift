//
//  Window.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 17/12/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Cocoa
import JavaScriptCore

class Window: NSObject {
    
    // Start the app by loading and executing the target apps javascript
    override init() {
        // Find the main.js resource
        guard let mainJsPath = Bundle.main.url(forResource: "main", withExtension: "js") else {
            errorAlert(error: "missing resource main.js", fatal: true)
            return
        }
        
        // Create the JS environment
        let jsContext = JSContext.init()
        
        // JS environment error handling
        jsContext?.exceptionHandler = { context, exception in
            if let exc = exception {
                errorAlert(error: "JavaScriptCore exception: " + exc.toString(), fatal: false)
            }
        }
        
        // Extend the Javascript core
        JSCoreExtended(jsContext!)
        
        // Define the BroswerWindow JS global
        let broswerWindow: @convention(block) ([String: Any]) -> BrowserWindow = BrowserWindow.init
        jsContext?.setObject(broswerWindow, forKeyedSubscript: "BrowserWindow" as (NSCopying & NSObjectProtocol)?)
        
        // Define JS global's
        jsContext?.setObject(App(), forKeyedSubscript: "app" as NSString)
        jsContext?.setObject(Menu(), forKeyedSubscript: "Menu" as NSString)
        jsContext?.setObject(Config(), forKeyedSubscript: "config" as NSString)
        
        // Execute main.js
        do {
            jsContext?.evaluateScript(try String(contentsOf: mainJsPath), withSourceURL: mainJsPath)
        } catch let error { // TODO: How to trigger this error. Wont it go to main error handler?
            errorAlert(error: "javascript execution failed" + error.localizedDescription, fatal: true)
        }
        
        // Send the ready event to keep Electron compatibility
        appEventEmitter.trigger(eventName: "ready")
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        NSApplication.shared.terminate(nil)
    }
}
