//
//  WKWebViewExtended.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 30/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Foundation
import WebKit

let javascriptRuntime = """
var nativeKit = {
    app: {
        _eventHandlers: {},
        _eventCalled: (event, data) => {
            window.nativeKit.app._eventHandlers[event].forEach(handler => handler(data));
        },
        on: (event, handler) => {
            if(window.nativeKit.app._eventHandlers[event] === undefined) {
                window.nativeKit.app._eventHandlers[event] = [];
                window.webkit.messageHandlers._wkwebviewEventEmitterOnApp.postMessage(event);
            }
            window.nativeKit.app._eventHandlers[event].push(handler);
        },
        emit: (event, info) => {
            window.webkit.messageHandlers._wkwebviewEventEmitterEmitApp.postMessage([event, info]);
        }
    },
    win: {
        _eventHandlers: {},
        _eventCalled: (event, data) => {
            window.nativeKit.win._eventHandlers[event].forEach(handler => handler(data));
        },
        on: (event, handler) => {
            if(window.nativeKit.win._eventHandlers[event] === undefined) {
                window.nativeKit.win._eventHandlers[event] = [];
                window.webkit.messageHandlers._wkwebviewEventEmitterOnWin.postMessage(event);
            }
            window.nativeKit.win._eventHandlers[event].push(handler);
        },
        emit: (event, info) => {
            window.webkit.messageHandlers._wkwebviewEventEmitterEmitWin.postMessage([event, info]);
        }
    },
    
};

Element.prototype.requestFullscreen = () => window.webkit.messageHandlers._wkwebviewRequest.postMessage("fullscreen");
Element.prototype.exitFullscreen = () => window.webkit.messageHandlers._wkwebviewRequest.postMessage("exit-fullscreen");
"""

class WKContentController: NSObject, WKScriptMessageHandler {
    var webView: WKWebViewExtended? = nil
    var mainWindow: NSWindow? = nil
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "_wkwebviewEventEmitterOnApp") {
            let eventName = message.body as? String ?? ""
            if(eventName == "") {
                return
            }
            appEventEmitter.listenTo(eventName: eventName, action: { info in
                if let webView = self.webView {
                    let infoStr = info as? String ?? "undefined" // TODO: Support Objects, Arrays, etc
                    webView.evaluateJavaScript("window.nativeKit.app._eventCalled(`" + eventName + "`, `" + infoStr + "`)", completionHandler: nil)
                }
                
            });
        } else if(message.name == "_wkwebviewEventEmitterEmitApp") {
            let args = message.body as? NSArray ?? []
            let eventName = args[0] as? String ?? ""
            if(eventName == "") {
                return
            }
            appEventEmitter.trigger(eventName: eventName, information: args[1] as? String ?? "");
        } else if(message.name == "_wkwebviewEventEmitterOnWin") {
            let eventName = message.body as? String ?? ""
            if(eventName == "") {
                return
            }
            windowEventEmitter.listenTo(eventName: eventName, action: { info in
                if let webView = self.webView {
                    let infoStr = info as? String ?? "undefined" // TODO: Support Objects, Arrays, etc
                    webView.evaluateJavaScript("window.nativeKit.win._eventCalled(`" + eventName + "`, `" + infoStr + "`)", completionHandler: nil)
                }
                
            });
        } else if(message.name == "_wkwebviewEventEmitterEmitWin") {
            let args = message.body as? NSArray ?? []
            let eventName = args[0] as? String ?? ""
            if(eventName == "") {
                return
            }
            windowEventEmitter.trigger(eventName: eventName, information: args[1] as? String ?? "");
        } else if(message.name == "_wkwebviewRequest") {
            let action = message.body as? String ?? ""
            if(action == "fullscreen") {
                if let window = self.mainWindow {
                    window.toggleFullScreen(self) // TODO: only enter fullscreen
                }
            } else if(action == "exit-fullscreen") {
                if let window = self.mainWindow {
                    window.toggleFullScreen(self) // TODO: only exit fullscreen
                }
            }
        }
    }
}

class WKWebViewDelegate: NSObject, WKNavigationDelegate {
    // TODO: Show loader in UI to user while webpage is loading. Possibly customisable
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        windowEventEmitter.trigger(eventName: "ready", information: "") // TODO: Attach to correct Navigation event
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        print("start to load")
    }

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
//        print("finish to load")
    }

    private func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.localizedDescription)
    }
}


class WKWebViewExtended: WKWebView {
    var contentController = WKContentController()
    private let delegate = WKWebViewDelegate()
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        // Inject javascript runtime to broswers JS context
        let script = WKUserScript(source: javascriptRuntime, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(script)
        
        // Provide js runtime method for swift communication
        configuration.userContentController.add(self.contentController, name: "_wkwebviewEventEmitterOnApp")
        configuration.userContentController.add(self.contentController, name: "_wkwebviewEventEmitterEmitApp")
        configuration.userContentController.add(self.contentController, name: "_wkwebviewEventEmitterOnWin")
        configuration.userContentController.add(self.contentController, name: "_wkwebviewEventEmitterEmitWin")
        configuration.userContentController.add(self.contentController, name: "_wkwebviewRequest")
        
        // Parse the frame and config through to the WKWebView
        super.init(frame: frame, configuration: configuration)
        contentController.webView = self
        
        // Expose broswer events through
        self.navigationDelegate = delegate
    }
    
    required init?(coder: NSCoder) {
        // TODO
        fatalError("init(coder:) has not been implemented")
    }
}
