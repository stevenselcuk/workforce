//
//  AppDelegate.swift
//  workforce
//
//  Created by Steven J. Selcuk on 6.06.2022.
//

import Cocoa
import HotKey
import SwiftUI
@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var taskPanelWindow: NSWindow!
    var taskEntryPanelWindow: NSWindow!
    var aboutWindow: NSWindow!

    @ObservedObject var manager = Manager.share
    let data = PersistenceProvider.default
    
    let openTaskEntryPanelWindowShortcut = HotKey(key: .t, modifiers: [.command, .control])

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
       
        let menubarView = (statusBarItem.value(forKey: "window") as? NSWindow)?.contentView

        let hostingView = NSHostingView(rootView: MenubarView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        menubarView?.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: menubarView!.topAnchor),
            hostingView.rightAnchor.constraint(equalTo: menubarView!.rightAnchor),
            hostingView.bottomAnchor.constraint(equalTo: menubarView!.bottomAnchor),
            hostingView.leftAnchor.constraint(equalTo: menubarView!.leftAnchor),
        ])

        if let button = statusBarItem.button {
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        openTaskEntryPanelWindowShortcut.keyDownHandler  = {
            if self.manager.taskEntryPanelOpen == false && self.manager.taskPanelOpen == false {
                self.openTaskPanelWindow()
                self.openTaskEntryPanelWindow()
            } else {
                self.closeTaskPanelWindow()
                self.closeTaskEntryPanelWindow()
            }
        }
        
        let tasks = PersistenceProvider.default.allTasks
        for task in tasks {
            task.inProgress = false
            if task.notStarted == false {
                task.isTaskPaused = true
            }
            try? data.context.save()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if  manager.currentTask != nil {
            manager.currentTask?.isTaskPaused = true
            manager.currentTask?.inProgress = false
            try? data.context.save()
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
