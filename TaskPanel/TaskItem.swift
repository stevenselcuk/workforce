//
//  TaskItem.swift
//  workforce
//
//  Created by Steven J. Selcuk on 29.07.2022.
//

import SwiftUI

struct TaskItem: View {
    @ObservedObject var task: Task
    var tasks: FetchedResults<Task>
    @ObservedObject var manager = Manager.share
    var data = PersistenceProvider.default
    var index: Int
    @State private var animationAmount: CGFloat = 1
    @State private var showingItemPopover: Bool = false
    @State private var hovered = false
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ProgressRing(progress: task.isDone ? 1 : Double(task.runnedTime / task.fullDuration), percent: (task.runnedTime / task.fullDuration) * 100, color: task.isDone ? .green : task.inProgress ? .yellow : task.isTaskPaused ? .orange : .red, isNotStarted: task.notStarted, isOnProgress: task.inProgress, isPaused: task.isTaskPaused, isDone: task.isDone, onClick: {
                if manager.currentTask != nil {
                    if manager.oldTask == nil {
                        manager.oldTask = manager.currentTask
                        manager.oldTask!.isTaskPaused = true
                        manager.oldTask!.inProgress = false
                        try? data.context.save()

                    } else if manager.oldTask?.id == task.id {
                    } else {
                        manager.oldTask = manager.currentTask
                        manager.oldTask!.isTaskPaused = true
                        manager.oldTask!.inProgress = false
                        try? data.context.save()
                    }
                }

                manager.currentTask = task
                manager.currentTaskFullTime = task.duration

                if tasks.count == 2 {
                    if index == 1 {
                        manager.previousTask = tasks[0]
                        manager.nextTask = nil
                    } else if index == 0 {
                        manager.previousTask = nil
                        manager.nextTask = tasks[1]
                    }

                } else if tasks.count > 2 {
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

                } else if tasks.count < 2 {
                }

                if manager.currentTask!.isDone == true {
                    return
                }

                if manager.currentTask == task {
                    if manager.currentTask!.notStarted == true && manager.currentTask!.isTaskPaused == false && manager.currentTask!.inProgress == false {
                        // FIRST Init
                        manager.currentTask!.inProgress = true
                        manager.currentTask!.notStarted = false
                        manager.currentTask!.isTaskPaused = false
                        try? data.context.save()
                        manager.isTimerRunning = true
                    } else if manager.currentTask!.isTaskPaused == false && manager.currentTask!.notStarted == false && manager.currentTask!.inProgress == true {
                        manager.currentTask!.isTaskPaused = true
                        manager.currentTask!.inProgress = false
                        manager.isTimerRunning = false
                        try? data.context.save()
                    } else if manager.currentTask!.isTaskPaused == true && manager.currentTask!.notStarted == false && manager.currentTask!.inProgress == false {
                        manager.currentTask!.isTaskPaused = false
                        manager.currentTask!.inProgress = true
                        try? data.context.save()
                        manager.isTimerRunning = true
                    }
                    try? data.context.save()
                }
            })
            .overlay(content: {
                if index != (tasks.count - 1) && task.duration < 60 * 3 {
                    Image(systemName: "arrow.down")
                        .offset(x: 2, y: 35)
                }
            })
            VStack(alignment: .leading, spacing: 5) {
                /*  if hovered {
                     Text("Estimated time: \(task.duration.hoursMinutesSecondsFormat) \(task.duration > (60 * 60) ? task.duration > ( 60 * 60 * 1) + 1 ? "hrs" : "hr" : "min.")")
                         .fontBold(size: 16)
                         .truncationMode(.middle)
                         .lineLimit(1)
                         .frame(width: 550, alignment: .leading)
                 } else {*/
                Text(task.title ?? "")
                    .fontBold(size: 16)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .frame(width: 550, alignment: .leading)
                //    }

            }.padding()
                .animation(.easeInOut(duration: 0.4), value: hovered)
                .transition(.opacity)
            Spacer()
            VStack {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18))
                    .rotationEffect(Angle.degrees(90))
                    .opacity(hovered ? 1 : 0.5)
                    .frame(width: 32, height: 32, alignment: .center)
                    .contentShape(Rectangle())
                    .padding(.top, 6)
                    .padding(.leading, 8)
            }
            .onTapGesture {
                showingItemPopover = true
            }
            .animation(.easeInOut(duration: 0.4), value: hovered)
            .transition(.opacity)
            .popover(isPresented: $showingItemPopover) {
                VStack(alignment: .leading, spacing: 10) {
                    if task.isDone != true {
                        HStack(alignment: .center, spacing: 0) {
                            Text("Update time")
                                .fontRegular(size: 12)
                            Spacer()
                            Stepper {
                                Text("\(Manager.counter(time: TimeInterval(task.duration / 60)))")
                                    .fontMonoMedium(color: Color("TextMain"), size: 12)
                                /*  if task.duration / 60 > 60 {
                                     Text("\(Manager.counter(time: TimeInterval(task.duration / 60)))")
                                     Text("\(String(format: "%.1f", task.duration / 60 / 60)) hrs.")
                                 } else {
                                     Text("\(Manager.counter(time: TimeInterval(task.duration / 60))) mins.")
                                     Text("\(String(format: "%.0f", task.duration / 60)) min.")
                                 }*/

                            } onIncrement: {
                                if task.duration / 60 > 59 {
                                    task.duration += 60 * 10
                                } else {
                                    task.duration += 60
                                }
                                try? data.context.save()
                            } onDecrement: {
                                if task.duration / 60 > 59 {
                                    task.duration -= 60 * 10
                                } else {
                                    task.duration -= 60
                                }
                                if task.duration > 1 {
                                    try? data.context.save()
                                } else {
                                    task.duration = 0
                                    try? data.context.save()
                                }
                            }
                            .fontRegular(size: 12)
                        }

                        HStack(alignment: .center, spacing: 0) {
                            Text("Mark as done")
                                .fontRegular(size: 12)
                            Spacer()
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.green)
                        }.onTapGesture {
                            task.isTaskPaused = true
                            task.inProgress = false
                            task.isDone = true
                            try? data.context.save()
                        }
                    }
                    HStack(alignment: .center, spacing: 0) {
                        Text("Delete task")
                            .fontRegular(size: 12)
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundColor(.red)

                    }.onTapGesture {
                        task.isTaskPaused = true
                        task.inProgress = false
                        try? data.context.save()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            data.delete(task)
                            try? data.context.save()
                        })
                    }
                }
                .padding(.all, 10)
                .frame(minWidth: 140, maxWidth: .infinity, minHeight: task.isDone != true ? 100 : 20, maxHeight: .infinity, alignment: .topLeading)
            }
        }

        .opacity(task.isDone ? 0.4 : 1)
        .onHover(perform: { isHover in
            if task.isDone == true { return }
            if hovered != isHover {
                hovered = isHover
            }
        })
    }
}
