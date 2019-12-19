//
//  Hider.swift
//  DIM
//
//  Created by G.J. Parker on 19/6/5.
//  Copyright © 2019 G.J. Parker. All rights reserved.
//
// somewhat of a silly class. we're going to do some 'magic' here and let the user *think* we've hidden the Desktop Icons
// we're not going to do any such thing (we're not allowed to in a sandboxed app anyway). instead, we'll take a picture
// of the Desktop(s) and put those pictures in windows just above the actual Desktop. from the user perspective, it appears
// the icons have vanished. they haven't, we're just hiding them behind the pictures
//
// works mostly ok. the hard bit here is getting the picture of the Desktop(s). here we'll use some Core Graphics tricks (see DesktopPictures extension to NSImage at end of file).
// for efficiency we'll only create the number of windows as there are (physical) screens, but we'll force those windows to go onto all Spaces.
// a further trick of setting window.level will make expose and mission control not see these windows.
//
// the only downside is if the user drags and tries to drop on the Desktop, it won't work (it's not the Desktop!), however its sort of consistent since they
// just told us to hide the icons so why would they add some now? it is good that clicking on the fake desktop does activate the Finder. so that's consistent.


import Foundation
import Cocoa

class Hider {
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.doHide), name: NSNotification.Name("doHide"), object: nil) // get notified when user hits Hide/Show Desktop Icons button
    }

    var transWindow = [NSWindow]()

    @objc func doHide() {
        if transWindow.count == 0 {  // appears the user want to hide icons
            let screenList = NSScreen.screens
            for screen in screenList {  // create the corresponding windows
                transWindow.append(createWin(screen))
            }
            spaceChange() // and go display them
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.spaceChange), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)  // catch when Spaces change
            NotificationCenter.default.addObserver(self, selector: #selector(self.screenChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)    // catch when Screens change
        } else {
            NSWorkspace.shared.notificationCenter.removeObserver(self, name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)  // don't care no more
            NotificationCenter.default.removeObserver(self, name: NSApplication.didChangeScreenParametersNotification, object: nil)      // don't care no more
            // teardown
            for (index, win) in transWindow.enumerated() {
                win.orderOut(self)
                transWindow[index].windowController?.window=nil
            }
            transWindow.removeAll() // we use the fact that transWindow.count = 0 keep track if the icons are hidden or not.
        }
    }

    @objc func screenChanged() {  // call back for when the user reconfigured the Screen
        let screens = NSScreen.screens
        if screens.count > transWindow.count {  // number of screens increase, so create some new windows
            for i in (transWindow.count)..<screens.count {
                transWindow.append(createWin(screens[i]))
            }
            spaceChange() // need to update the window if we added
        } else if screens.count < transWindow.count {  // ugh, they removed a screen. let's ignore that and just update
            spaceChange()
        } // otherwise they probably just adjusted the Arrangements which we can ignore
    }

    func createWin(_ screen: NSScreen) -> NSWindow {  // create a window w/ the same size as the screen we're given
        return resetWin(NSWindow(contentRect: NSMakeRect(0, 0, NSWidth(screen.frame), NSHeight(screen.frame)), styleMask: .borderless, backing: .buffered, defer: true, screen: screen))
    }

    func resetWin(_ win: NSWindow) -> NSWindow {
        win.collectionBehavior = NSWindow.CollectionBehavior.canJoinAllSpaces          // we want these windows to follow Spaces around
        win.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.backstopMenu)))  //hack? this makes mission control and expose ignore these windows

        // rest is to make the windows dumb
        win.canHide = false
        win.isExcludedFromWindowsMenu = true
        win.hidesOnDeactivate = false
        win.discardCursorRects()
        win.discardEvents(matching: NSEvent.EventTypeMask.any, before: nil)
        win.ignoresMouseEvents = true
        win.orderBack(nil)
        win.isRestorable = false
        win.animationBehavior = .none
        return win
    }

    @objc func spaceChange() {
        // grab pictures of the Desktop(s)
        var desktopPics = NSImage.desktopPictures()
        // cycle through the physical Screens
        for (index, screen) in NSScreen.screens.enumerated() {
            // go find the first desktop picture that has the same size as this screen
            for (numPic, desktopPic) in desktopPics.enumerated() {
                if desktopPic.size.height == screen.frame.height && desktopPic.size.width == screen.frame.width {
                    // get an imageView w/ the correct size and picture
                    let imageView = NSImageView(frame: screen.frame)
                    imageView.image = desktopPic
                    // make sure the window has the same size as the screen
                    if screen.frame != transWindow[index].frame {transWindow[index].setFrame(screen.frame, display: false, animate: false)}
                    // ok, replace the view
                    transWindow[index].contentView = imageView
                    // hopefully to avoid problems on which screen and which desktop, get rid of the ones we've done
                    desktopPics.remove(at: numPic)
                    break
                }
            }
        }
    }
}

extension NSImage { //don't need to do an extension, but it appears fun, so let's do it.

    static func desktopPictures() -> [NSImage] {  // for each desktop we find, take a picture add it onto an array and return it

        var images = [NSImage]()
        for window in CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as! [[ String : Any]] {
            print(window)
            // we need windows owned by Dock
            guard let owner = window["kCGWindowOwnerName"] as? String else {continue}
            if owner != "Dock" {
                continue
            }
            // we need windows named like "Desktop Picture %"
            guard let name = window["kCGWindowName"] as? String else {continue}
            if !name.hasPrefix("Desktop Picture") {
                continue
            }
            // ok, this belongs to a screen. grab a picture of it and appened to the return array
            guard let index = window["kCGWindowNumber"] as? CGWindowID else {continue}  //pendantic
            let cgImage = CGWindowListCreateImage(CGRect.null, CGWindowListOption(arrayLiteral: CGWindowListOption.optionIncludingWindow), index, CGWindowImageOption.nominalResolution)
            images.append(NSImage(cgImage: cgImage!, size: NSMakeSize(CGFloat(cgImage!.width), CGFloat(cgImage!.height))))
        }
        // return the array of Desktop pictures
        return images
    }
}
