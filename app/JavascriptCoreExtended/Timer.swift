//
//  Console.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 14/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//

import Foundation
import JavaScriptCore

// Thanks to https://www.innoq.com/en/blog/ios-javascriptcore-polyfills/ for the code source
class JSCETimer {
    init(_ context: JSContext) {
        // clearInterval
        let clearInterval: @convention(block) (String) -> () = { identifier in
            self.removeTimer(identifier: identifier)
        }
        context.setObject(clearInterval, forKeyedSubscript: "clearInterval" as NSString)

        // clearTimeout
        let clearTimeout: @convention(block) (String) -> () = { identifier in
            self.removeTimer(identifier: identifier)
        }
        context.setObject(clearTimeout, forKeyedSubscript: "clearTimeout" as NSString)

        // setInterval
        let setInterval: @convention(block) (JSValue, Double) -> String = { (callback, ms) in
            return self.createTimer(callback: callback, ms: ms, repeats: true)
        }
        context.setObject(setInterval, forKeyedSubscript: "setInterval" as NSString)

        // setTimeout
        let setTimeout: @convention(block) (JSValue, Double) -> String = { (callback, ms) in
            return self.createTimer(callback: callback, ms: ms, repeats: false)
        }
        context.setObject(setTimeout, forKeyedSubscript: "setTimeout" as NSString)
    }

    var timers = [String: Timer]()

    func removeTimer(identifier: String) {
        let timer = self.timers.removeValue(forKey: identifier)

        timer?.invalidate()
    }

    func createTimer(callback: JSValue, ms: Double, repeats : Bool) -> String {
        let timeInterval  = ms/1000.0

        let uuid = NSUUID().uuidString

        DispatchQueue.main.async(execute: {
            let timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                             target: self,
                                             selector: #selector(self.callJsCallback),
                                             userInfo: callback,
                                             repeats: repeats)
            self.timers[uuid] = timer
        })

        return uuid
    }

    @objc func callJsCallback(_ timer: Timer) {
        let callback = (timer.userInfo as! JSValue)

        callback.call(withArguments: nil)
    }
}
