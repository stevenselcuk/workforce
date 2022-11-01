//
//  AboutView.swift
//  workforce
//
//  Created by Steven J. Selcuk on 15.08.2022.
//

import SwiftUI

struct AboutView: View {
    var nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
    var body: some View {
        let version = nsObject as! String
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            VStack(alignment: .center) {
                Image("WingMain")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)

                Text("workforce \(version)")
                    .fontBold(size: 18)
                    .padding(.vertical, 5.0)
                    .accessibility(hint: Text("Kotor \(version)"))
                Spacer()
                VStack {
                    Text("Why workforce?")
                        .fontRegular(size: 12)
                        .padding(.bottom, 10)
                    Text("Burnout is real. Creating awareness against burnout, and fighting back was my main motivation for creating the workforce app.")
                        .fontRegular(size: 12)
                }.padding(.horizontal, 20)

                Spacer()
                Text("Created by Steven J. Selcuk")
                    .fontRegular(size: 12)
                    .onTapGesture {
                        let email = "https://github.com/stevenselcuk"
                        if let url = URL(string: email) {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .accessibility(hint: Text("This app created by Steven Selcuk. Opens developers GitHub profile on click."))
            }

            HStack {
                Text("Bug or Feature?")
                    .fontRegular(size: 12)

                Button(action: {
                    let email = "https://twitter.com/hevalandsteven"
                    if let url = URL(string: email) {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Text("Tell Me")
                        .fontRegular(size: 12)
                }
            }.accessibility(hint: Text("Opens developers Twitter profile"))

            Spacer()
        }
        .background(Color.clear)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
    }
}
