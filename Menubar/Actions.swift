//
//  Actions.swift
//  workforce
//
//  Created by Steven J. Selcuk on 6.06.2022.
//

import Cocoa
import Foundation
import SwiftUI
extension AppDelegate {
    @objc func togglePopover(_ sender: AnyObject?) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.leftMouseUp {
                if manager.taskEntryPanelOpen == false {
                    openTaskEntryPanelWindow()
                    openTaskPanelWindow()
                    Manager.share.theDay = Date().dateAtStartOf(.day)
                    Manager.share.id =  UUID()
                } else {
                    closeTaskEntryPanelWindow()
                    closeTaskPanelWindow()
                }
        } else if event.type == NSEvent.EventType.rightMouseUp {
        }
    }

    func openTaskPanelWindow() {
        taskPanelWindow = NSWindow(
            contentRect: NSRect(x: -((NSScreen.main?.frame.height)! / 2 - 250), y: -((NSScreen.main?.frame.width)! / 2 + 300), width: 700, height: 600),
            styleMask: [.titled, .borderless],
            backing: .buffered, defer: false)

        taskPanelWindow.level = NSWindow.Level.normal + 1
        taskPanelWindow.isReleasedWhenClosed = false
        taskPanelWindow.positionCenter()
        taskPanelWindow.titlebarAppearsTransparent = true
        taskPanelWindow.titleVisibility = .hidden
        taskPanelWindow.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)

        let visualEffect = NSVisualEffectView()
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.blendingMode = .behindWindow
        visualEffect.material = .popover
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        //  visualEffect.layer?.cornerRadius = 16.0

        taskPanelWindow.titleVisibility = .hidden
        taskPanelWindow.backgroundColor = .clear
        taskPanelWindow.isMovableByWindowBackground = true

        taskPanelWindow.contentView?.addSubview(visualEffect)
        let v = NSHostingView(rootView: TaskPanelView() .environment(\.managedObjectContext, PersistenceProvider.default.context))
        v.translatesAutoresizingMaskIntoConstraints = false
        taskPanelWindow.contentView?.addSubview(v)
        guard let constraints = taskPanelWindow.contentView else {
            return
        }

        v.leadingAnchor.constraint(equalTo: constraints.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: constraints.trailingAnchor).isActive = true
        v.topAnchor.constraint(equalTo: constraints.topAnchor).isActive = true
        v.bottomAnchor.constraint(equalTo: constraints.bottomAnchor).isActive = true

        visualEffect.leadingAnchor.constraint(equalTo: constraints.leadingAnchor).isActive = true
        visualEffect.trailingAnchor.constraint(equalTo: constraints.trailingAnchor).isActive = true
        visualEffect.topAnchor.constraint(equalTo: constraints.topAnchor).isActive = true
        visualEffect.bottomAnchor.constraint(equalTo: constraints.bottomAnchor).isActive = true
        taskPanelWindow.makeKeyAndOrderFront(nil)
        manager.taskPanelOpen = true
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    func openTaskEntryPanelWindow() {
        taskEntryPanelWindow = NSWindow(
            contentRect: NSRect(x: -((NSScreen.main?.frame.height)! / 2 - 250), y: -((NSScreen.main?.frame.width)! / 2 + 300), width: 700, height: 76),
            styleMask: [.borderless, .titled],
            backing: .buffered, defer: false)

        taskEntryPanelWindow.level = NSWindow.Level.normal + 1
        taskEntryPanelWindow.isReleasedWhenClosed = false
        taskEntryPanelWindow.positionTopCenter()
        taskEntryPanelWindow.titlebarAppearsTransparent = true
        taskEntryPanelWindow.titleVisibility = .hidden
        taskEntryPanelWindow.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)

        let visualEffect = NSVisualEffectView()
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.blendingMode = .behindWindow
        visualEffect.material = .popover
        visualEffect.state = .active
        visualEffect.wantsLayer = true
        //  visualEffect.layer?.cornerRadius = 16.0

        taskEntryPanelWindow.titleVisibility = .hidden
        taskEntryPanelWindow.backgroundColor = .clear
        taskEntryPanelWindow.isMovableByWindowBackground = true

        taskEntryPanelWindow.contentView?.addSubview(visualEffect)
        let v = NSHostingView(rootView: TaskEntryPanelView() .environment(\.managedObjectContext, PersistenceProvider.default.context))
        v.translatesAutoresizingMaskIntoConstraints = false
        taskEntryPanelWindow.contentView?.addSubview(v)
        guard let constraints = taskEntryPanelWindow.contentView else {
            return
        }

        v.leadingAnchor.constraint(equalTo: constraints.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: constraints.trailingAnchor).isActive = true
        v.topAnchor.constraint(equalTo: constraints.topAnchor).isActive = true
        v.bottomAnchor.constraint(equalTo: constraints.bottomAnchor).isActive = true

        visualEffect.leadingAnchor.constraint(equalTo: constraints.leadingAnchor).isActive = true
        visualEffect.trailingAnchor.constraint(equalTo: constraints.trailingAnchor).isActive = true
        visualEffect.topAnchor.constraint(equalTo: constraints.topAnchor).isActive = true
        visualEffect.bottomAnchor.constraint(equalTo: constraints.bottomAnchor).isActive = true

        taskEntryPanelWindow.makeKeyAndOrderFront(nil)
        taskEntryPanelWindow.makeKey()
        manager.taskEntryPanelOpen = true
    }

    func closeTaskPanelWindow() {
        if taskPanelWindow == nil {return}
        if manager.taskPanelOpen == true {
            taskPanelWindow.close()
            manager.taskPanelOpen = false
        }
    }
    
    func closeTaskEntryPanelWindow() {
        if taskEntryPanelWindow == nil {return}
        if manager.taskEntryPanelOpen == true {
            taskEntryPanelWindow.close()
            manager.taskEntryPanelOpen = false
        }
    }
    
    func closeAboutWindow() {
        aboutWindow.close()
    }
    
    func openAboutWindow() {
        aboutWindow = NSWindow(
            contentRect: NSRect(x: -((NSScreen.main?.frame.height)! / 2 - 250), y: -((NSScreen.main?.frame.width)! / 2 + 300), width: 300, height: 380),
            styleMask: [.titled, .borderless, .closable],
            backing: .buffered, defer: false)

        aboutWindow.level = NSWindow.Level.normal + 2
        aboutWindow.isReleasedWhenClosed = false
        aboutWindow.positionCenter()
        aboutWindow.titlebarAppearsTransparent = true
        aboutWindow.titleVisibility = .visible
        aboutWindow.styleMask.insert(NSWindow.StyleMask.fullSizeContentView)

        let visualEffect = NSVisualEffectView()
        visualEffect.translatesAutoresizingMaskIntoConstraints = false
        visualEffect.blendingMode = .behindWindow
        visualEffect.material = .popover
        visualEffect.state = .active
        visualEffect.wantsLayer = true
      //  visualEffect.layer?.cornerRadius = 16.0

        aboutWindow.backgroundColor = .clear
        aboutWindow.isMovableByWindowBackground = true

        aboutWindow.contentView?.addSubview(visualEffect)
        let v = NSHostingView(rootView: AboutView())
        v.translatesAutoresizingMaskIntoConstraints = false
        aboutWindow.contentView?.addSubview(v)
        guard let constraints = aboutWindow.contentView else {
            return
        }

        v.leadingAnchor.constraint(equalTo: constraints.leadingAnchor).isActive = true
        v.trailingAnchor.constraint(equalTo: constraints.trailingAnchor).isActive = true
        v.topAnchor.constraint(equalTo: constraints.topAnchor).isActive = true
        v.bottomAnchor.constraint(equalTo: constraints.bottomAnchor).isActive = true

        visualEffect.leadingAnchor.constraint(equalTo: constraints.leadingAnchor).isActive = true
        visualEffect.trailingAnchor.constraint(equalTo: constraints.trailingAnchor).isActive = true
        visualEffect.topAnchor.constraint(equalTo: constraints.topAnchor).isActive = true
        visualEffect.bottomAnchor.constraint(equalTo: constraints.bottomAnchor).isActive = true
        aboutWindow.makeKeyAndOrderFront(nil)
    }
    
}
