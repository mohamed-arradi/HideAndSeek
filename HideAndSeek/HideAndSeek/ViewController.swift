//
//  ViewController.swift
//  HideAndSeek
//
//  Created by Mohamed Arradi on 6/17/19.
//  Copyright © 2019 Mohamed Arradi-Alaoui. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Switcher.switchDesktopMode(mode: .hide)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

