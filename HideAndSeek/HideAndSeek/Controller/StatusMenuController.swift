//
//  StatusMenuController.swift
//  WeatherBar
//
//  Created by Brad Greenlee on 10/11/15.
//  Copyright © 2015 Etsy. All rights reserved.
//

import Cocoa
import Foundation
import Magnet

class StatusMenuController: NSObject, NSAlertDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var hideSwitchView: CommandView!

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var statusMenuItem: NSMenuItem!
    
    override func awakeFromNib() {
        
        statusItem.menu = statusMenu
        let icon = NSImage(named: "StatusIcon")
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.menu = statusMenu

        statusMenuItem = statusMenu.item(at: 0)
        statusMenuItem.view = hideSwitchView
        

        if let keyCombo = KeyCombo(keyCode: 11, carbonModifiers: 4352) {
            let hotKey = HotKey(identifier: "CommandControlB", keyCombo: keyCombo, target: self, action: #selector(switchDesktopMode))
            hotKey.register()
        }
    }
    
    // MARK: - IBAction
    
    @objc func switchDesktopMode() {
        hideSwitchView.toogleMode(sender: hideSwitchView.hideSwitch)
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
