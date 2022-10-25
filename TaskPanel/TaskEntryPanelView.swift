//
//  TaskEntryPanelView.swift
//  workforce
//
//  Created by Steven J. Selcuk on 27.06.2022.
//

import SwiftUI

struct TaskEntryPanelView: View {
    var data = PersistenceProvider.default
    @Environment(\.isFocused) var isFocused
    @ObservedObject var manager = Manager.share
    @State var note: String = ""

    @State private var observer1: Any? = nil
    @State private var observer2: Any? = nil

    @State private var showingTaskDuration: Bool = false
    @State private var showingSettingsPopover: Bool = false
    @State private var taskDuration: Float = 20 * 60
    @State private var hovered = false
    var color3 = #colorLiteral(red: 1, green: 0.003921568627, blue: 0.4588235294, alpha: 1)
    @State private var lastOrder: Int = 1
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(Manager.counter(time: TimeInterval(taskDuration / 60) ))")
                        .fontMonoMedium(color: .white, size: 24)
                        .foregroundColor(taskDuration > 60 * 60 * 4 ? Color("Red") : taskDuration > 60 * 60 * 2 ? Color("Yellow") : Color("TextMain"))
                        .opacity(0.5)
                    Text("\(taskDuration > 60 * 60 * 2 ? "hours" : taskDuration < 60 * 60 ? "minutes" : "hour")")
                        .fontMonoMedium(color: Color("TextMain"), size: 8)
                        .opacity(0.5)
                        .padding(.trailing, 2)
                }
                .padding(.horizontal, 10)
                .onTapGesture {
                    showingTaskDuration = true
                }
                .popover(isPresented: $showingTaskDuration) {
                    Slider(value: $taskDuration, in: 0 ... 60 * 60 * 8)
                        .introspectSlider(customize: { slider in
                            slider.trackFillColor = NSColor(named: "AccentColor")
                        })
                        .controlSize(.small)
                        .padding(.all, 10).frame(minWidth: 380, maxWidth: .infinity, minHeight: 20, maxHeight: .infinity, alignment: .topLeading)
                }
                TextField("What's the task?", text: $note)
                    .onChange(of: note, perform: { newVal in
                        if newVal.count > 50 {
                            let trimmed = newVal.dropLast()
                            note = String(trimmed)
                        
                        }
                    })
                    .frame(width: 550, alignment: .leading)
                    .textFieldStyle(PlainTextFieldStyle())
                    .background(.clear)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.middle)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(Font.custom("Gilroy Semibold", size: 22, relativeTo: .body))
                    .padding(.bottom, 10)
                    .onSubmit {
                        if note.isEmpty { return }
                        let task = Task(context: data.context)
                        task.id = UUID()
                        task.title = note
                        task.createdAt = Date()
                        task.duration = taskDuration
                        task.fullDuration = taskDuration
                        task.order = Int16(manager.lastOrder)
                        
                        try? data.context.save()
                        note = ""
                        manager.id = UUID()
                        storage.set(manager.lastOrder + 1, forKey: "lastOrder")
                    }
                    .focusable()
                        .touchBar {
                            Text("\(Manager.counter(time: TimeInterval(taskDuration / 60) )) \(taskDuration > 60 * 60 * 2 ? "hrs" : taskDuration < 60 * 60 ? "mins" : "hr.")")
                                .fontMonoMedium(color: .white, size: 18)
                                .foregroundColor(Color(hex: "#FFFFFF"))
                                .padding(.all, 6)
                                .background(Color(hex: "#1F201F"))
                                .cornerRadius(4)
                            Slider(value: $taskDuration, in: 60 ... 60 * 60 * 8)
                                .accentColor(Color.gray)
                                .controlSize(.mini)
                           
                        }
                    .padding(.horizontal, 2)
                    
                VStack {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .rotationEffect(Angle.degrees(90))
                        .opacity(hovered ? 1 : 0.5)
                      //  .frame(width: 32, height: 32, alignment: .center)
                        .contentShape(Rectangle())
                        .padding(.top, 6)
                        .padding(.trailing, 12)
                }
                .opacity(0)
                .onTapGesture {
                   // showingSettingsPopover = true
                }
                .popover(isPresented: $showingSettingsPopover) {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(alignment: .center, spacing: 0) {
                            Text("A")
                            Spacer()
                            Text("B")
                        }
                        Divider()
                        HStack(alignment: .center, spacing: 0) {
                            Text("A")
                            Spacer()
                            Text("B")
                        }
                        Divider()
                        HStack(alignment: .center, spacing: 0) {
                            Text("A")
                            Spacer()
                            Text("B")
                        }
                        Divider()
                        HStack(alignment: .center, spacing: 0) {
                            Text("A")
                            Spacer()
                            Text("B")
                        }
                    }
                    .padding(.all, 10)
                    .frame(minWidth: 120, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            Spacer()
        } .onHover(perform: { isHover in
            if hovered != isHover {
                hovered = isHover
            }
        })
         .onAppear(perform: {
             observer1 = NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: nil, queue: OperationQueue.main) { _ in
                 Manager.share.taskEntryPanelFocused = false
              /*   (NSApp.delegate as! AppDelegate).closeTaskEntryPanelWindow()
                 (NSApp.delegate as! AppDelegate).closeTaskPanelWindow()*/
             }

             observer2 = NotificationCenter.default.addObserver(forName: NSWindow.didBecomeKeyNotification, object: nil, queue: OperationQueue.main) { _ in
                 Manager.share.taskEntryPanelFocused = true
               /*  (NSApp.delegate as! AppDelegate).closeTaskEntryPanelWindow()
                 (NSApp.delegate as! AppDelegate).closeTaskPanelWindow()*/
             }
         })
         .onDisappear(perform: {
             NotificationCenter.default.removeObserver(observer1 as Any)
             NotificationCenter.default.removeObserver(observer2 as Any)
         })
         .onChange(of: isFocused, perform: { newVal in
             print(newVal)
             Manager.share.taskEntryPanelFocused = newVal
         })
        .background(Color.clear)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
    }
}
