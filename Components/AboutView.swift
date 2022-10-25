//
//  AboutView.swift
//  workforce
//
//  Created by Steven J. Selcuk on 15.08.2022.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image("WingMain")
                .resizable()
                .frame(width: 64, height: 64, alignment: .center)
            Text("workforce")
                .fontMonoMedium(color: Color("TextMain"), size: 22)
            Text("1.0")
                .fontBold(color: Color("TextMain"), size: 12)
        }
            .frame(width: 200, height: 200, alignment: .center)
    }
}

