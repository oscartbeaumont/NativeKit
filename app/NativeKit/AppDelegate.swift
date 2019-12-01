//
//  AppDelegate.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 10/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Cocoa
import WebKit

let appEventEmitter = EventManager();
let windowEventEmitter = EventManager(); // TODO: This won't work for multiwindow support

func errorAlert(error: String, fatal: Bool) {
    let alert = NSAlert()
    alert.messageText = "A Fatal Error Occurred!"
    alert.informativeText = error
    alert.alertStyle = .critical
    alert.addButton(withTitle: "OK")
    alert.runModal()
    if(fatal) {
        fatalError(error)
    }
}

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
        jsContext?.setObject(Menu(), forKeyedSubscript: "Menu" as NSString)
        jsContext?.setObject(Config(), forKeyedSubscript: "config" as NSString)
        jsContext?.setObject(App(), forKeyedSubscript: "app" as NSString)
        
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


// TODO: JavaScriptCore should be done here not on a per window basis for multiwindow support
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // Handle Dock icon being clicked
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        appEventEmitter.trigger(eventName: "activate")
        return false
    }
    
    // Handle X button
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        windowEventEmitter.trigger(eventName: "closed") // TODO: This should go on the individual NSWindow if possible
        return false
    }
}
