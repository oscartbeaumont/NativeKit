//
//  main.swift
//  NativeKit
//
//  Created by Oscar Beaumont on 10/11/19.
//  Copyright © 2019 Oscar Beaumont. All rights reserved.
//
// This file fixes the bug documented here: https://stackoverflow.com/a/50750540
// https://lapcatsoftware.com/articles/working-without-a-nib-part-10.html
// https://github.com/lapcat/NiblessMenu

import AppKit

autoreleasepool {
    let window = Window() // TODO: Declared inside delegate (should be app controller)
    let delegate = AppDelegate()
    // NSApplication delegate is a weak reference,
    // so we have to make sure it's not deallocated.
    // In Objective-C you would use NS_VALID_UNTIL_END_OF_SCOPE
    withExtendedLifetime(delegate, {
        let application = NSApplication.shared
        application.delegate = delegate
        application.run()
        application.delegate = nil

    })
}
