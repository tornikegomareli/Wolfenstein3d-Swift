//
//  AppDelegate.swift
//  Wolfenstein3d-Macintosh
//
//  Created by Tornike Gomareli on 22.06.25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!
  var gameViewController: GameViewController!
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Create window
    let windowRect = NSRect(x: 0, y: 0, width: 1024, height: 768)
    window = NSWindow(contentRect: windowRect,
                      styleMask: [.titled, .closable, .miniaturizable, .resizable],
                      backing: .buffered,
                      defer: false)
    
    // Configure window
    window.title = "Wolfenstein 3D"
    window.styleMask.insert(.fullSizeContentView)
    window.titlebarAppearsTransparent = true
    window.titleVisibility = .hidden
    
    // Create and set game view controller
    gameViewController = GameViewController()
    window.contentViewController = gameViewController
    
    // Center window on screen
    if let screen = NSScreen.main {
      let screenRect = screen.visibleFrame
      let x = (screenRect.width - windowRect.width) / 2 + screenRect.minX
      let y = (screenRect.height - windowRect.height) / 2 + screenRect.minY
      window.setFrame(NSRect(x: x, y: y, width: windowRect.width, height: windowRect.height), display: true)
    }
    
    // Show window
    window.makeKeyAndOrderFront(nil)
    
    // Make first responder for keyboard input
    window.makeFirstResponder(gameViewController.view)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}