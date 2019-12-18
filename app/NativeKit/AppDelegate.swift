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
