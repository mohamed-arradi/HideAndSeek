//
//  CommandView.swift
//  HideAndSeek
//
//  Created by Mohamed Arradi on 19/12/2019.
//  Copyright © 2019 Mohamed Arradi-Alaoui. All rights reserved.
//

import Foundation
import Cocoa
import OGSwitch

class CommandView: NSView {
    
    @IBOutlet weak var hideSwitch: OGSwitch!
    @IBOutlet weak var descriptionLabel: NSTextField!
    
    var appleScriptExecutor: AppleScriptExecutor!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        appleScriptExecutor = AppleScriptExecutor()
        updateSwitchState()
    }
    
    fileprivate func updateSwitchState() {
        
        let status = appleScriptExecutor.runScript(scriptName: "desktopStatus")
        
        hideSwitch.isOn = !status.success
    }
    
    @IBAction func toogleMode(sender: OGSwitch) {
        AppleScriptExecutor().runScript(scriptName: "HideOrSeek")
        updateSwitchState()
    }
}
