//
//  AppDelegate.swift
//  HideAndSeek
//
//  Created by Mohamed Arradi on 6/17/19.
//  Copyright © 2019 Mohamed Arradi-Alaoui. All rights reserved.
//

import Cocoa
import LoginServiceKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        let bundle = Bundle.main.bundlePath
         if LoginServiceKit.isExistLoginItems(at: bundle) == false {
             LoginServiceKit.addLoginItems(at: bundle)
         }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

 
