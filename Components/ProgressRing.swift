//
//  ProgressRing.swift
//  workforce
//
//  Created by Steven J. Selcuk on 29.07.2022.
//

import SwiftUI

struct ProgressRing: View {
    var progress: Double
    var percent: Float
    var color: Color
    var isNotStarted: Bool
    var isOnProgress: Bool
    var isPaused: Bool
    var isDone: Bool
    var onClick: () -> Void
    @State private var hovered = false
    @State private var tapped = false
    var green = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    var color2 = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
    var color3 = #colorLiteral(red: 1, green: 0.003921568627, blue: 0.4588235294, alpha: 1)
    var color4 = #colorLiteral(red: 0.9921568627, green: 0.9294117647, blue: 0.1333333333, alpha: 1)
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.3),
                    lineWidth: 2
                )
              

            if isNotStarted == true {
                Image(systemName: "circle")
                    .font(.system(size: 16))
            } else {
                if isPaused == true && isDone == false {
                    if hovered == true {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                    } else {
                        Text("\(percent, specifier: "%.0f")%")
                            .fontMonoMedium(size: 12)
                                .opacity(0.5)
                    }
                } else if isDone == true {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                } else if isOnProgress == true {
                    if hovered == true {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 18))
                    } else {
                        Text("\(percent, specifier: "%.0f")%")
                            .fontMonoMedium(size: 12)
                                .opacity(0.5)
                    }
                }
            }

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: 1,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
              //  .animation(.easeOut, value: progress)

        }
        .contentShape(Rectangle())
        .frame(width: 36, height: 36, alignment: .center)
        .padding(.leading,4)
            .contentShape(Rectangle())
            .onHover(perform: { isHover in
                if isDone == true { return }
                if hovered != isHover {
                    hovered = isHover
                }
               
            })
            .shadow(color: color.opacity(isOnProgress ? 0.4 : 0), radius: 2)
            .scaleEffect(hovered ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: hovered)
            .simultaneousGesture(TapGesture().onEnded {
                if isDone == true { return }
                onClick()
            })
    }
}
