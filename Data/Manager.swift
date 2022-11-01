//
//  Manager.swift
//  workforce
//
//  Created by Steven J. Selcuk on 6.06.2022.
//

import Foundation
import Cocoa
class Manager: ObservableObject {
    static var share = Manager()
 
    @Published var id: UUID = UUID()
    @Published var theDay: Date = Date().dateAtStartOf(.day)
    @Published var taskPanelOpen: Bool = false
    @Published var taskEntryPanelOpen: Bool = false
    @Published var currentTaskFullTime: Float = 0
    @Published var currentTaskRemainingTime: Float = 0
    @Published var currentTaskElapsedTime: Float = 0
    @Published var isTimerRunning: Bool = false
    @Published var previousTask: Task?
    @Published var currentTask: Task?
    @Published var oldTask: Task?
    @Published var nextTask: Task?
    @Published var isDayFinished: Bool = false
    @Published var menubarMessage: String = ""
    // Dynamic Settings
    @Published var showMenubarTimer: Bool = storage.optionalBool(forKey: "showMenubarTimer") ?? true
    @Published var showTouchbarTimer: Bool = storage.optionalBool(forKey: "showTouchbarTimer") ?? true
    @Published var dailyWorkForce: Float = storage.optionalFloat(forKey: "totalWorkForce") ?? 8 * 60 * 60
    @Published var lastOrder: Int = storage.optionalInt(forKey: "lastOrder") ?? 1
    
    @Published var isAboutOpen: Bool = false
    
    @Published var taskEntryPanelFocused: Bool = false
  
    
    static public func counter(time: TimeInterval) -> String {
        if !time.isNormal {
            return "00:00"
        }
        let hours = Int(floor(time / 3600))
        let minutes = Int(floor((time / 60).truncatingRemainder(dividingBy: 60)))
        let seconds = Int(floor(time.truncatingRemainder(dividingBy: 60)))
        let minutesAndSeconds = NSString(format: "%02d:%02d", minutes, seconds) as String
        if hours > 0 {
            return NSString(format: "%02d:%@", hours, minutesAndSeconds) as String
        } else {
            return minutesAndSeconds
        }
    }
    
    static public func counterMinimal(time: TimeInterval) -> String {
        if !time.isNormal {
            return "00:00"
        }
        let hours = Int(floor(time / 3600))
        let minutes = Int(floor((time / 60).truncatingRemainder(dividingBy: 60)))
        let seconds = Int(floor(time.truncatingRemainder(dividingBy: 60)))
        let minutesAndSeconds = NSString(format: "%02d:%02d", minutes, seconds) as String
        let minutes2 = NSString(format: "%02d", minutes) as String
        if hours > 0 {
            return NSString(format: "%02d:%@", hours, minutes2) as String
        } else {
            return minutesAndSeconds
        }
    }
    
    static public func quitApp() {
            NSApp.terminate(self)
    }
    
    static public func openAbout() {
        if Manager.share.isAboutOpen == false {
            (NSApp.delegate as! AppDelegate).openAboutWindow()
            Manager.share.isAboutOpen = true
        } else {
            Manager.closeAbout()
            return
        }
       
    }
    
    static public func closeAbout() {
        if Manager.share.isAboutOpen == true {
            (NSApp.delegate as! AppDelegate).closeAboutWindow()
            Manager.share.isAboutOpen = false
        } else {
            return
        }
    }
    
    static public func tasks() -> [Task] {
       return PersistenceProvider.default.getFilteredTasks(filterDate: Manager.share.theDay)
    }
    
    static public func finishedPercent() -> String {
       let tasks = PersistenceProvider.default.getFilteredTasks(filterDate: Manager.share.theDay)
        return String(format: "%.0f", ((tasks.reduce(0) { $0 + $1.runnedTime } / 60 / 60) / (tasks.reduce(0) { $0 + $1.fullDuration } / 60 / 60)) * 100)
    }
    
    static public func finishedHoursMins() -> String {
       let tasks = PersistenceProvider.default.getFilteredTasks(filterDate: Manager.share.theDay)
        if tasks.reduce(0, { $0 + $1.runnedTime }) / 60 < 60 {
            return String(format: "%.0f minutes", tasks.reduce(0) { $0 + $1.runnedTime } / 60)
        } else {
            return String(format: "%.1f hours", tasks.reduce(0) { $0 + $1.runnedTime } / 60 / 60)
        }
    }
    
    static public func plannedPercent() -> String {
        let tasks = PersistenceProvider.default.getFilteredTasks(filterDate: Manager.share.theDay)
        return String(format: "%.0f", (tasks.reduce(0) { $0 + $1.fullDuration } / 28800) * 100)
    }
    
    static public func plannedHoursMins() -> String {
        let tasks = PersistenceProvider.default.getFilteredTasks(filterDate: Manager.share.theDay)
        if tasks.reduce(0) { $0 + $1.fullDuration } / 60 < 60 {
            return String(format: "%.0f minutes", tasks.reduce(0) { $0 + $1.fullDuration } / 60)
        } else {
            return String(format: "%.1f hours", tasks.reduce(0) { $0 + $1.fullDuration } / 60 / 60)
        }
    }
    
    static public func checkLimit() -> Bool {
        let tasks = PersistenceProvider.default.getFilteredTasks(filterDate: Manager.share.theDay)
        return tasks.reduce(0) { $0 + $1.fullDuration } / Manager.share.dailyWorkForce * 100 > 90
    }
}
