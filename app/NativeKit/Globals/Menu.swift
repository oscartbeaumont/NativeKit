//
//  Menu.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 10/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Foundation
import Cocoa
import WebKit

// JSValueArrayItterator loops over values in an array of type JSValue
func JSValueArrayItterator(arr: JSValue, fn: (Int, JSValue) -> Void) {
    if(!arr.isArray) {
        return;
    }
    
    // For each menu in the template
    for index in stride(from: 0, to: arr.toArray()?.count ?? 0, by: 1) {
        fn(index, arr.atIndex(index))
    }
}

// NSMenuItemActionClosure allows a closure to be used as an action handler for a NSMenuItem
class NSMenuItemActionClosure: NSMenuItem {
    var actionClosure: () -> () = {  }

    init() {
        super.init(title: "", action: #selector(self.clicked), keyEquivalent: "")
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func clicked(_ sender: NSMenuItem?) {
        self.actionClosure()
    }
}

@objc protocol menuItemInformationExports: JSExport {
    var state: Bool { get }
}

// Contains the menuItem's details for the click callback
class menuItemInformation: NSObject, menuItemInformationExports {
    let state: Bool
    
    init(_ menuItem: NSMenuItem) {
        if(menuItem.state == .on) {
            self.state = true
        } else {
            self.state = false
        }
    }
}

@objc protocol MenuExports: JSExport {
    func buildFromTemplate(_ template: JSValue) -> NSMenu
    func setApplicationMenu(_ menu: NSMenu)
}

// Menu is a global exposed to the JavaScriptCore
class Menu: NSObject, MenuExports {
    
    func buildFromTemplate(_ template: JSValue) -> NSMenu {
        let menu = NSMenu()
        
        func RecursivelyPopulateMenuItems(arr: JSValue, menu: NSMenu) {
            JSValueArrayItterator(arr: arr, fn: { (ii, subitem) in
                // Prevent creating not visible items
                if(subitem.hasProperty("visible") && subitem.forProperty("visible").toBool() == false) {
                    return;
                }
                
                // Get menu type
                let type = subitem.forProperty("type").toString() ?? ""
                
                // Create menu item and add to submenu unless its a seperator then assign a separator to the submenu
                let menuItem = NSMenuItemActionClosure()
                if type == "separator" {
                    menu.addItem(NSMenuItem.separator())
                    return;
                } else {
                    menu.addItem(menuItem)
                }
                
                
                // Setup menu item type
                if type == "checkbox" {
                    if subitem.hasProperty("checked") {
                        if subitem.forProperty("checked").toBool() {
                            menuItem.state = .on
                        } else {
                            menuItem.state = .off
                        }
                    } else {
                        menuItem.state = .off
                    }
                } else if type == "radio" {
                    // TODO
                }

                // Menu title
                menuItem.title = subitem.forProperty("label").toString() ?? ""
                
                // Add click handler
                if(subitem.hasProperty("click")) { // TODO: Handle disabled
                    menuItem.actionClosure = {() in
                        var args: [Any] = []
                        if type == "checkbox" {
                            if(menuItem.state == .on) {
                                menuItem.state = .off
                            } else {
                                menuItem.state = .on
                            }
                            args.append(menuItemInformation(menuItem))
                        }
                        
                        subitem.forProperty("click").call(withArguments: args)
                    }
                    menuItem.target = menuItem // Enable item
                }
                
                // Keyboard activator
                if(subitem.hasProperty("accelerator") && subitem.forProperty("accelerator")?.isString ?? false) {
                    let accelerators = (subitem.forProperty("accelerator")?.toString() ?? "").split(separator: "+")
                    menuItem.keyEquivalentModifierMask = []
                    for accelerator in accelerators {
                        if(accelerator == "Command" || accelerator == "Cmd" || accelerator == "CommandOrControl" || accelerator == "CmdOrCtrl" || accelerator == "Super") {
                            menuItem.keyEquivalentModifierMask.insert(.command)
                        } else if(accelerator == "Control" || accelerator == "Ctrl") {
                            menuItem.keyEquivalentModifierMask.insert(.control)
                        } else if(accelerator == "Option" || accelerator == "Alt") {
                            menuItem.keyEquivalentModifierMask.insert(.option)
                        } else if(accelerator == "Function" || accelerator == "Fn") {
                            menuItem.keyEquivalentModifierMask.insert(.function)
                        } else if(accelerator == "Shift") {
                            menuItem.keyEquivalentModifierMask.insert(.shift)
                        } else if(accelerator.count == 1) {
                            menuItem.keyEquivalent = String(accelerator).lowercased()
                        } else {
                            print("[NativeKit Warning] Invalid accelerator segment '" + accelerator + "' on menu item '" + menuItem.title + "' has been ignored.")
                        }
                    }
                }
                    
                // Subitems
                if(subitem.hasProperty("submenu") && subitem.forProperty("submenu")?.isArray ?? false) {
                    let subsubmenu = NSMenu()
                    RecursivelyPopulateMenuItems(arr: subitem.forProperty("submenu"), menu: subsubmenu)
                    menu.setSubmenu(subsubmenu, for:menuItem)
                    menuItem.target = menuItem // Enable item

                }
                
                // Enabled
                if(subitem.hasProperty("enabled") && subitem.forProperty("enabled").toBool() == true) {
                    menuItem.target = menuItem // Enable item
                }
                
            });
        }
        
        JSValueArrayItterator(arr: template, fn: { (i, item) in
            // Prevent creating not visible items
            if(item.hasProperty("visible") && item.forProperty("visible").toBool() == false) {
                return;
            }
            
            // Create submenu
            let submenu = NSMenu(title: item.forProperty("label").toString() ?? "")
            
            // TODO Handle action + accelerator when no subitems exist

            // Populate submenu items recursively
            RecursivelyPopulateMenuItems(arr: item.forProperty("submenu"), menu: submenu)
            
            // Add submenu to rootMenu
            menu.setSubmenu(submenu, for:menu.addItem(withTitle: submenu.title, action: nil, keyEquivalent: ""))
        })
        
        return menu;
    }
    
    
    func setApplicationMenu(_ menu: NSMenu) {
        // TODO: Error when Window is nott visible which needs fixing
        NSApp.mainMenu = menu
    }
}

