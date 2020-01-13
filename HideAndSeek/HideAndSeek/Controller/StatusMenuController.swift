//
//  StatusMenuController.swift
//  WeatherBar
//
//  Created by Brad Greenlee on 10/11/15.
//  Copyright © 2015 Etsy. All rights reserved.
//

import Cocoa
import Foundation
import HotKey

class StatusMenuController: NSObject, NSAlertDelegate {
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var hideSwitchView: CommandView!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var statusMenuItem: NSMenuItem!
    var hotKey: HotKey!
    
    override func awakeFromNib() {
        
        statusItem.menu = statusMenu
        let icon = NSImage(named: "StatusIconHidden")
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.menu = statusMenu
        
        statusMenuItem = statusMenu.item(at: 0)
        statusMenuItem.view = hideSwitchView
        
        hotKey = HotKey(key: .h, modifiers: [.command, .option])
        
        hotKey.keyDownHandler = {
            self.hideSwitchView.changeHideMode()
            let status = AppleScriptExecutor().runScript(scriptName: "desktopStatus")
            self.statusItem.button?.image = self.imageForStatus(hidden: !status.success)
        }
    }
    
    fileprivate func imageForStatus(hidden: Bool) -> NSImage {
        
        let icon = NSImage(imageLiteralResourceName: hidden ? "StatusIconHidden" : "StatusIconVisible")
        icon.isTemplate = true
        
        return icon
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
