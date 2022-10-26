//
//  TaskPanelView.swift
//  workforce
//
//  Created by Steven J. Selcuk on 6.06.2022.
//

import ServiceManagement
import SwiftDate
import SwiftUI

let storage = UserDefaults.standard

struct TaskPanelView: View {
    var delegate: AppDelegate = NSApp.delegate as! AppDelegate
    var data = PersistenceProvider.default
    @ObservedObject var manager = Manager.share

    @State private var observer1: Any? = nil
    @State private var observer2: Any? = nil
    @State private var observer3: Any? = nil
    @State private var observer4: Any? = nil

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeRemaining = 10

    @FetchRequest(sortDescriptors: [SortDescriptor(\.order)], predicate: NSPredicate(format: "(createdAt >= %@) AND (createdAt <= %@)", Manager.share.theDay as CVarArg, Manager.share.theDay.dateAtEndOf(.day) as CVarArg))
    var tasks: FetchedResults<Task>
    
    var sum: Int64 {  Int64(tasks.reduce(0) { $0 + $1.duration }) }
    
    @State var showingPrefPop: Bool = false
    @State var autoMode: Bool = storage.optionalBool(forKey: "autoMode") ?? true
    @State var notificationsOn: Bool = storage.optionalBool(forKey: "notificationsOn") ?? false
    @State var totalWorkForce: Float = storage.optionalFloat(forKey: "totalWorkForce") ?? 60 * 60 * 8

    @State var launchAtLogin: Bool = storage.bool(forKey: "launchAtLogin")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FocusView()
                .frame(width: 0, height: 0, alignment: .leading)
                .touchBar {
                    Text(Manager.counter(time: TimeInterval(manager.currentTaskRemainingTime)))
                        .fontMonoMedium(color: Color("TextMain"), size: 18)
                        .padding(.all, 6)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(4)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(tasks.enumerated()), id: \.element) { _, task in
                                HStack {
                                    if task.isDone == true {
                                        Text("🍔")
                                            .font(.system(size: 16))
                                            .padding(.horizontal, 4)
                                    } else if task.inProgress == true {
                                        Text("🚀")
                                            .font(.system(size: 16))
                                            .padding(.horizontal, 4)
                                    } else {
                                        Text("🧅")
                                            .font(.system(size: 16))
                                            .padding(.horizontal, 4)
                                    }
                                    Text(task.title ?? "")
                                        .fontBold(size: 12)
                                        .foregroundColor(task.isDone == true ? Color(hex: "#FFFFFF") : task.inProgress == true ? Color(hex: "#FFFFFF") : Color(hex: "#949494"))
                                        .truncationMode(.middle)
                                        .lineLimit(1)
                                        .frame(width: 100, alignment: .leading)
                                        .padding(.vertical, 6)
                                }
                                .background(task.isDone == true ? Color("AccentColor") : task.inProgress == true ? Color("Yellow") : Color(hex: "#1A1918"))
                                .cornerRadius(4)
                            }
                        }
                    }.frame(width: 550)
                }
            FilteredList(predicate: NSPredicate(format: "(createdAt >= %@) AND (createdAt <= %@)", manager.theDay as CVarArg, manager.theDay.dateAtEndOf(.day) as CVarArg), sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)])
                .id(manager.id)

            HStack(alignment: .center, spacing: 20) {
                VStack {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .fontBold(size: 12)
                .padding()
                .onTapGesture {
                    showingPrefPop = true
                }
                .popover(isPresented: $showingPrefPop) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "backward.fill")
                                .onTapGesture(perform: {
                                    withAnimation {
                                        manager.theDay = manager.theDay.getYesterday()!
                                        manager.id = UUID()
                                    }
                                })
                            Spacer()
                            Text("\(manager.theDay.string(format: "EEEE, MMM d"))")
                                .fontRegular(size: 12)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .frame(width: 100, alignment: .center)
                                .onTapGesture(perform: {
                                    withAnimation {
                                        manager.theDay = Date().dateAtStartOf(.day)
                                        manager.id = UUID()
                                    }
                                })
                            Spacer()
                            Image(systemName: "forward.fill")
                                .opacity(manager.theDay.isAfterDate(Date().dateAtStartOf(.day), orEqual: true, granularity: .day) ? 0.3 : 1)
                                .onTapGesture(perform: {
                                    if manager.theDay.isAfterDate(Date().dateAtStartOf(.day), orEqual: true, granularity: .day) == true { return }
                                    withAnimation {
                                        manager.theDay = manager.theDay.add(.day, value: 1)!
                                        manager.id = UUID()
                                    }

                                })
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Text("Chain Mode")
                                .fontRegular(size: 12)
                            Spacer()
                            Toggle("", isOn: $autoMode)
                                .onChange(of: autoMode, perform: { newVal in
                                    storage.set(newVal, forKey: "autoMode")
                                })
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Text("Daily Workforce")
                                .fontRegular(size: 12)
                            Spacer()
                            Stepper {
                                Text("\(Manager.counter(time: TimeInterval(manager.dailyWorkForce / 60)))")
                                    .fontMonoMedium(color: Color("TextMain"), size: 12)
                            } onIncrement: {
                                manager.dailyWorkForce += 60 * 10
                                storage.set(manager.dailyWorkForce, forKey: "totalWorkForce")
                            } onDecrement: {
                                if manager.dailyWorkForce > 60 * 60 {
                                    manager.dailyWorkForce -= 60 * 10
                                    storage.set(manager.dailyWorkForce, forKey: "totalWorkForce")
                                }
                            }
                            .fontRegular(size: 12)
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Text("Launch at login")
                                .fontRegular(size: 12)
                            Spacer()
                            Toggle("", isOn: $launchAtLogin)
                                .onChange(of: launchAtLogin) { newValue in
                                    SMLoginItemSetEnabled(Constants.helperBundleID as CFString,
                                                          launchAtLogin)
                                    print(newValue.description)
                                    print(launchAtLogin)
                                    storage.set(newValue.description, forKey: "launchAtLogin")
                                }
                                .fontRegular(size: 12)
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Text("About")
                                .fontRegular(size: 12)
                            Spacer()
                            Button(action: {
                                Manager.openAbout()
                            }, label: {
                                Text("Workforce 1.0")
                            })
                            .fontRegular(size: 12)
                        }
                    }
                    .padding(.all, 10)
                    .frame(minWidth: 160, maxWidth: .infinity, minHeight: 220, maxHeight: .infinity, alignment: .topLeading)
                }

                Spacer()

                VStack(alignment: .center, spacing: 5) {
                    if manager.isTimerRunning {
                        Text("Finished \(Manager.finishedPercent())% of daily workload")
                            .fontMonoMedium(color: Color("TextMain"), size: 10)

                        Text("Worked \(Manager.finishedHoursMins())")
                            .fontMonoMedium(color: Color("TextMain"), size: 10)

                    } else {
                        Text("Reached \(Manager.plannedPercent())% of daily workforce")
                            .fontMonoMedium(color: Color("TextMain"), size: 10)
                            .foregroundColor(Manager.checkLimit() ? Color(hex: "#FAC24F") : Color("TextMain"))

                        Text("Planned \(Manager.plannedHoursMins()) of work")
                            .fontMonoMedium(color: Color("TextMain"), size: 10)
                            .foregroundColor(Manager.checkLimit() ? Color(hex: "#FAC24F") : Color("TextMain"))
                    }
                }
                .padding()
                Spacer()
                VStack {
                    VStack {
                        Image(systemName: "power")
                        Text("Quit")
                    }
                    .fontBold(size: 12)
                    .onTapGesture {
                        Manager.quitApp()
                    }
                }
                .padding()
            }.border(width: 1, edges: [.top], color: Color.gray.opacity(0.1))
        }
        .onReceive(timer) { _ in
            if let task = manager.currentTask {
                if task.inProgress == true && task.duration == 60 {
                    NSSound(named: "select")?.play()
                }
                if task.inProgress == true && task.duration > 1 {
                    task.duration = (task.duration - 1).rounded()
                    try? data.context.save()
                    task.runnedTime = task.runnedTime + 1
                    manager.currentTaskElapsedTime = manager.currentTaskElapsedTime + 1
                    manager.currentTaskRemainingTime = task.duration - 1
                    try? data.context.save()

                } else if task.duration <= 1 {
                    task.duration = 0
                    task.runnedTime = task.fullDuration
                    task.inProgress = false
                    task.isTaskPaused = false
                    task.isDone = true
                    task.notStarted = false
                    try? data.context.save()
                    manager.isTimerRunning = false

                    if manager.nextTask == nil && task.inProgress == false {
                      //  manager.isDayFinished = true
                      //  manager.menubarMessage = "Total \(Manager.finishedHoursMins()) worked"
                    } else {
                       // manager.isDayFinished = false
                    }

                    if manager.nextTask != nil && self.autoMode == true {
                        if task.isDone == true {
                            NSSound(named: "error")?.play()
                        }
                        manager.currentTask = manager.nextTask
                        manager.currentTask?.notStarted = false
                        manager.currentTask?.isTaskPaused = false
                        manager.currentTask?.inProgress = true
                        manager.isTimerRunning = true
                        try? data.context.save()
                        if let index = Manager.tasks().firstIndex(where: { $0 === manager.currentTask }) {
                            if Manager.tasks().count == 2 {
                                if index == 1 {
                                    manager.previousTask = tasks[0]
                                    manager.nextTask = nil
                                } else if index == 0 {
                                    manager.previousTask = nil
                                    manager.nextTask = tasks[1]
                                }

                            } else if Manager.tasks().count > 2 {
                                if index > 0 && index != tasks.count - 1 {
                                    manager.previousTask = tasks[index - 1]
                                    manager.nextTask = tasks[index + 1]
                                } else if index == tasks.count - 1 {
                                    manager.previousTask = tasks[tasks.count - 2]
                                    manager.nextTask = nil
                                } else if index == 0 {
                                    manager.previousTask = nil
                                    manager.nextTask = tasks[1]
                                }
                            }
                        }
                    }
                }
            }
        }
        .background(Color.clear)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        .onAppear(perform: {
            observer1 = NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: OperationQueue.main) { _ in
                Manager.share.theDay = Date().dateAtStartOf(.day)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    if Manager.share.taskEntryPanelFocused == false {
                        (NSApp.delegate as! AppDelegate).closeTaskEntryPanelWindow()
                        (NSApp.delegate as! AppDelegate).closeTaskPanelWindow()
                    }
                })
            }

            observer2 = NotificationCenter.default.addObserver(forName: NSWindow.didResignMainNotification, object: nil, queue: OperationQueue.main) { _ in
                Manager.share.theDay = Date().dateAtStartOf(.day)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    if Manager.share.taskEntryPanelFocused == false {
                        (NSApp.delegate as! AppDelegate).closeTaskEntryPanelWindow()
                        (NSApp.delegate as! AppDelegate).closeTaskPanelWindow()
                    }
                })
            }

        })
        .onDisappear(perform: {
            NotificationCenter.default.removeObserver(observer1 as Any)
            NotificationCenter.default.removeObserver(observer2 as Any)
        })
    }
}
