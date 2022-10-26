//
//  FilteredList.swift
//  workforce
//
//  Created by Steven J. Selcuk on 26.10.2022.
//

import SwiftUI

struct FilteredList<T: NSManagedObject>: View {
    var fetchRequest: FetchRequest<Task>
    var tasks: FetchedResults<Task> { fetchRequest.wrappedValue }
    var data = PersistenceProvider.default
    @ObservedObject var manager = Manager.share
    var body: some View {
        if tasks.count > 0 {
            List {
                ForEach(Array(tasks.enumerated()), id: \.offset) { index, entry in
                    TaskItem(task: entry, tasks: tasks, index: index)
                        .padding(.bottom, 10)
                }
                .onMove(perform: move)
            }
            .removeBackground()
            .frame(height: 500)
            .edgesIgnoringSafeArea(.all)

        } else {
            VStack {
                Spacer()
                VStack(alignment: .center, spacing: 0) {
                    Image("WingMain")
                        .resizable()
                        .frame(width: 64, height: 64, alignment: .center)
                    Text("workforce")
                        .fontMonoMedium(color: Color("TextMain"), size: 22)
                    Text("Create your tasks, 🔥 your day")
                        .fontBold(color: Color("TextMain"), size: 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                Spacer()
            }.frame(height: 500)
        }
    }

    func move(from source: IndexSet, to destination: Int) {
        var revisedItems: [Task] = tasks.map { $0 }
        revisedItems.move(fromOffsets: source, toOffset: destination)

        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1) {
            revisedItems[reverseIndex].order = Int16(reverseIndex)
        }

        if manager.currentTask != nil {
            if manager.currentTask!.isTaskPaused == false && manager.currentTask!.notStarted == false && manager.currentTask!.inProgress == true {
                manager.currentTask!.isTaskPaused = true
                manager.currentTask!.inProgress = false
                manager.isTimerRunning = false
                manager.previousTask = nil
                manager.nextTask = nil
                manager.currentTask = nil
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            try? data.context.save()
        })
    }

    init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor] = []) {
        fetchRequest = FetchRequest<Task>(entity: Task.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
    }
}
