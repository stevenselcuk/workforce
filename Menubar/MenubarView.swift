//
//  View.swift
//  workforce
//
//  Created by Steven J. Selcuk on 6.06.2022.
//

import SwiftUI

struct MenubarView: View {
    @ObservedObject var manager = Manager.share
    var body: some View {
        if manager.currentTask == nil ||  Manager.tasks().count == 0 {
            LazyHStack(alignment: .center, spacing: 0) {
                Image("WingMenubar")
                    .resizable()
                    .frame(width: 16, height: 16, alignment: .center)
                Text("")
                    .fontMonoMedium(color: Color("TextMain"), size: 12)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
        } else if manager.isDayFinished == true {
            LazyHStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 3) {
                    Image("WingMenubar")
                        .resizable()
                        .frame(width: 16, height: 16, alignment: .center)
                }.padding(.all, 3)
                    .cornerRadius(3)
                    .padding(.vertical, 3)

                Spacer()
                Text("Last task! Worked \(Manager.finishedHoursMins())")
                    .fontMonoMedium(color: .white, size: 12)
                    .padding(.horizontal, 4)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
            
        } else {
            LazyHStack(alignment: .center, spacing: 0) {
              
                HStack(alignment: .center, spacing: 3) {
                    Text(Manager.counter(time: TimeInterval(manager.currentTaskRemainingTime))).fontMonoMedium(color: .white, size: 12)
                }.padding(.all, 3)
                    .background(Color.gray.opacity(0.4))
                    .if(manager.currentTaskRemainingTime < 60) { view in
                        view.blinking()
                    }
                    .cornerRadius(3)
                    .padding(.vertical, 3)
                    

                Spacer()
                Text(manager.currentTask?.title ?? "")
                    .fontMonoMedium(color: .white, size: 12)
                    .padding(.horizontal, 4)
            }
            
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
          
        }
    }
}
