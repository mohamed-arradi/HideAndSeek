//
//  CommandView.swift
//  HideAndSeek
//
//  Created by Mohamed Arradi on 19/12/2019.
//  Copyright © 2019 Mohamed Arradi-Alaoui. All rights reserved.
//

import Foundation
import Cocoa

class CommandView: NSView {
    
    @IBOutlet weak var toogleButton: NSButton!
    @IBOutlet weak var eyeImageView: NSImageView!
    
    fileprivate var appleScriptExecutor = AppleScriptExecutor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateViews()
    }
    
    func updateViews() {
        
        let status = updatedDesktopStatus()
        
        if (status) {
            toogleButton.title = "Hide Desktop Icons"
        } else {
            toogleButton.title = "Show Desktop Icons"
        }
        
        NSAnimationContext.runAnimationGroup({ _ in
            NSAnimationContext.current.duration = 0.5
            NSAnimationContext.current.allowsImplicitAnimation = true
            self.eyeImageView.animator().layer?.setAffineTransform(CGAffineTransform(scaleX: 0.500, y: 1))
            self.eyeImageView.animator().layer?.setAffineTransform(CGAffineTransform(scaleX: 0, y: 1))
            
        }, completionHandler:{
            DispatchQueue.main.async {
                self.eyeImageView.animator().layer?.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
                self.eyeImageView.image = NSImage(imageLiteralResourceName: status ? "EyeVisible" : "EyeLock")
            }
        })
    }
    
    @discardableResult
    fileprivate func updatedDesktopStatus() -> Bool {
        
        let status = appleScriptExecutor.runScript(scriptName: "desktopStatus")
        return status.success
    }
    
    @IBAction func toogleMode(sender: NSButton) {
        changeHideMode()
    }
    
    @IBAction func toogleImageMode(sender: NSImageView) {
        changeHideMode()
    }
    
    @objc func changeHideMode() {
        
        let completion = AppleScriptExecutor().runScript(scriptName: "HideOrSeek")
        
        if completion.success {
            updateViews()
        }
    }
}
