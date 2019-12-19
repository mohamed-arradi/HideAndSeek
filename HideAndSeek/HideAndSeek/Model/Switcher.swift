//
//  Switcher.swift
//  HideAndSeek
//
//  Created by Mohamed Arradi on 6/17/19.
//  Copyright © 2019 Mohamed Arradi-Alaoui. All rights reserved.
//

import Foundation

enum DesktopMode {
    case show
    case hide
}

struct Switcher {
    
    static func switchDesktopMode(mode: DesktopMode) {
        
        let show = mode == .show ? true : false
        
        shell("defaults write com.apple.finder CreateDesktop \(show.description)")
        shell("killall Finder")
    }
    
    @discardableResult
    static private func shell(_ command: String) -> String? {
        
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        return output
    }
}
