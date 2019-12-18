//
//  BrowserWindow.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 10/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Foundation
import Cocoa
import WebKit

@objc protocol BrowserWindowExports: JSExport {
    var width: Int { get }
    var height: Int { get }
    var x: Int { get }
    var y: Int { get }
    var title: String { get }
    var url: String { get }
    
    var emit: (@convention(block)(String, Any?) -> Void)? { get }
    var on: (@convention(block)(String, JSValue) -> Void)? { get }
    
    var close: (@convention(block)() -> Void)? { get }
//    var destroy: (@convention(block)() -> Void)? { get }
//    var focus: (@convention(block)() -> Void)? { get }
//    var blur: (@convention(block)() -> Void)? { get }
    var show: (@convention(block)() -> Void)? { get }
    var hide: (@convention(block)() -> Void)? { get }
    var maximize: (@convention(block)() -> Void)? { get }
    var minimize: (@convention(block)() -> Void)? { get }
//    var setBounds: (@convention(block)() -> Void)? { get }
    var setSize: (@convention(block)(Int, Int) -> Void)? { get }
//    var setResizable: (@convention(block)(Bool) -> Void)? { get } // https://vgable.com/blog/2008/04/11/nswindow-setresizable/
//    var setMovable: (@convention(block)(Bool) -> Void)? { get }
    var setAlwaysOnTop: (@convention(block)(Bool) -> Void)? { get }
    var moveTop: (@convention(block)() -> Void)? { get }
    var center: (@convention(block)() -> Void)? { get }
    var setPosition: (@convention(block)(Int, Int) -> Void)? { get }
    var setTitle: (@convention(block)(String) -> Void)? { get }
    var loadURL: (@convention(block)(String) -> Void)? { get }
    var loadFile: (@convention(block)(String) -> Void)? { get }
    var reload: (@convention(block)() -> Void)? { get }
//    var setMenu: (@convention(block)() -> Void)? { get }
     // TODO: newWindow.backgroundColor = NSColor(calibratedHue: 0, saturation: 1.0, brightness: 0, alpha: 0.7)
    // TODO: window.titleVisibility = .visible
}

// BrowserWindow is a global exposed to the JavaScriptCore
class BrowserWindow: NSObject, BrowserWindowExports {
    var mainWindow: NSWindow
    var webView: WKWebView
    
    // TODO: Update on resize/move win
    var width = 0
    var height = 0
    var x = 0
    var y = 0
    var title = "NativeKit App"
    var url = "" // TODO: Update on navigation
    
    
    init(_ opts: [String: Any]) {
        // Store options to the class
        self.width = opts["width"] as? Int ?? Int(CGFloat(NSScreen.main!.frame.midX))
        
        self.height = opts["height"] as? Int ?? Int(CGFloat(NSScreen.main!.frame.midY))
        
        self.title = opts["title"] as? String ?? "NativeKit"
        
        self.url = opts["url"] as? String ?? ""
        
        // Create & configure the broswer window
        self.mainWindow = NSWindow(contentRect: .init(origin: .zero, // TODO: Centered
            size: .init(width: self.width,
                        height: self.height)),
                styleMask: [.titled, .closable, .miniaturizable, .resizable ],
                   backing: .buffered,
                   defer: false)
        self.mainWindow.title = self.title
        
        if(opts["center"] as? Bool ?? false) {
           self.mainWindow.center()
        }
        
        let webViewE = WKWebViewExtended()
        self.webView = webViewE
        webViewE.contentController.mainWindow = self.mainWindow
        self.mainWindow.contentView = self.webView
        
        if(self.url != "") {
            self.webView.load(URLRequest(url: URL(string: url)!))
        }
        
        if(opts["rightClickDevtools"] as? Bool ?? false) {
            self.webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        }
        
        // Set Default Menu Layout
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        let menu = NSMenu()
        let appNameMenu = NSMenu(title: appName)
        appNameMenu.addItem(withTitle: "About " + appName, action: #selector(NSApplication.shared.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appNameMenu.addItem(NSMenuItem.separator())
        appNameMenu.addItem(withTitle: "Hide " + appName, action: #selector(NSApplication.shared.hide(_:)), keyEquivalent: "h")
        appNameMenu.addItem(withTitle: "Hide Others", action: #selector(NSApplication.shared.hideOtherApplications(_:)), keyEquivalent: "H")
        appNameMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.shared.unhideAllApplications(_:)), keyEquivalent: "") // TODO: Not working
        appNameMenu.addItem(NSMenuItem.separator())
        appNameMenu.addItem(NSMenuItem(title: "Quit " + appName, action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: "q"))
        menu.setSubmenu(appNameMenu, for:menu.addItem(withTitle: appNameMenu.title, action: nil, keyEquivalent: ""))
        
        let editMenu = NSMenu(title: "Edit")
//        editMenu.addItem(withTitle: "Undo", action: #selector(NSApplication.shared.undo(_:)), keyEquivalent: "z")
//        editMenu.addItem(withTitle: "Redo", action: #selector(NSApplication.shared.orderFrontStandardAboutPanel(_:)), keyEquivalent: "Z")
//        editMenu.addItem(withTitle: "Redo", action: #selector(NSMenuItem.copy(_:)), keyEquivalent: "Z")
//        editMenu.addItem(NSMenuItem.copy() as! NSMenuItem) // action: #selector(NSPasteboard.cut), keyEquivalent: "x"
//        editMenu.addItem(withTitle: "Paste", action: #selector(NSApplication.shared.hide(_:)), keyEquivalent: "c")
//        editMenu.addItem(withTitle: "Copy", action: #selector(NSApplication.shared.hide(_:)), keyEquivalent: "v")
//        editMenu.addItem(withTitle: "Paste and Match Style", action: #selector(NSApplication.shared.hide(_:)), keyEquivalent: "V") // TODO
//        editMenu.addItem(withTitle: "Select All", action: #selector(NSApplication.shared.hide(_:)), keyEquivalent: "a")
//        appNameMenu.addItem(NSMenuItem.separator())
//        // TODO: Emoji and Symbols menu
        menu.setSubmenu(editMenu, for:menu.addItem(withTitle: editMenu.title, action: nil, keyEquivalent: ""))
        
        // Find
        
        
        
        
        let viewMenu = NSMenu(title: "View")
        viewMenu.addItem(withTitle: "Enter Full Screen ", action: #selector(self.mainWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        menu.setSubmenu(viewMenu, for:menu.addItem(withTitle: viewMenu.title, action: nil, keyEquivalent: ""))
        
        // TODO: Finish and Test Default Menubar
        
        NSApp.mainMenu = menu
        
        // TODO: Overridable
//        self.mainWindow.toggleFullScreen(nil)
//        print(self.mainWindow.styleMask.contains(.fullScreen))
//        let search = NSKeyCommand(input: "", modifierFlags: .command, action: #selector(findFriends), discoverabilityTitle: "Find Friends")
        
        // Show the window
        self.mainWindow.makeKeyAndOrderFront(nil) // TODO: Option to be defered and done in JS
        
        super.init()
    }
    
    var emit: (@convention(block)(String, Any?) -> Void)? {
        return { (event, info) in
            windowEventEmitter.trigger(eventName: event, information: info)
        }
    }
    
    var on: (@convention(block)(String, JSValue) -> Void)? {
        return { (event, handler) in
            windowEventEmitter.listenTo(eventName: event, action: { (info) in
                handler.call(withArguments: [info as Any])
            });
        }
    }
    
    var close: (@convention(block)() -> Void)? {
        return { [unowned self] () in
            self.mainWindow.close()
        }
    }
    
    var show: (@convention(block)() -> Void)? {
        return { [unowned self] () in
            self.mainWindow.makeKeyAndOrderFront(nil)
        }
    }
    
    var hide: (@convention(block)() -> Void)? {
        return { [unowned self] () in
            self.mainWindow.orderOut(nil)
        }
    }
    
    var maximize: (@convention(block)() -> Void)? {
        return { [unowned self] () in
            if let screen = NSScreen.main {
                self.mainWindow.setFrame(screen.visibleFrame, display: true, animate: true)
            }
        }
    }
    
    var minimize: (@convention(block)() -> Void)? {
        return { [unowned self] () in
            self.mainWindow.performMiniaturize(self)
        }
    }
    
    var setSize: (@convention(block)(Int, Int) -> Void)? {
        return { [unowned self] (width, height) in
            var frame = self.mainWindow.frame
            frame.origin.y = frame.origin.y + CGFloat(height)
            frame.origin.x = frame.origin.x + CGFloat(width)
            frame.size.height = CGFloat(height)
            frame.size.width = CGFloat(width)
            self.mainWindow.setFrame(frame, display: true)
        }
    }
    
    var setAlwaysOnTop: (@convention(block)(Bool) -> Void)? {
        return { [unowned self] (enabled) in
            if(enabled) {
                self.mainWindow.level = .floating
            } else {
                self.mainWindow.level = .normal
            }
        }
    }
    
    var moveTop: (@convention(block)() -> Void)? {
        return { [unowned self] () in
            self.mainWindow.orderFrontRegardless()
        }
    }
    
    var center: (@convention(block)() -> Void)? {
        return { [unowned self] () in
            self.mainWindow.center()
        }
    }
    
    var setPosition: (@convention(block)(Int, Int) -> Void)? {
        return { [unowned self] (x, y) in
            var frame = self.mainWindow.frame
            frame.origin.x = CGFloat(x)
            frame.origin.y = CGFloat(y)
            self.mainWindow.setFrame(frame, display: true)
        }
    }
    
    var setTitle: (@convention(block)(String) -> Void)? {
        return { [unowned self] (title: String) in
            self.title = title
            self.mainWindow.title = title
        }
    }
    
    var loadURL: (@convention(block)(String) -> Void)? {
        return { [unowned self] (url: String) in
            self.url = url
            self.webView.load(URLRequest(url: URL(string: url)!))
        }
    }
    
    var loadFile: (@convention(block)(String) -> Void)? {
        return { [unowned self] (path: String) in
            let pathSplit = path.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true)
            if(pathSplit.count != 2) {
                fatalError("[NativeKit] Invalid path parsed to loadFile()")
            }
            
            if let url = Bundle.main.url(forResource: String(pathSplit[0]), withExtension: String(pathSplit[1])) {
                let request = URLRequest(url: url)
                self.webView.load(request)
            }
        }
    }
    
    var reload: (@convention(block)() -> Void)? {
        return { [unowned self] () in
            self.webView.reload()
        }
    }
}
