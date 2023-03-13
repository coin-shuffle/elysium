//
//  MainLoaderView.swift
//  Elysium
//
//  Created by Ivan Lele on 16.02.2023.
//

import Foundation
import SwiftUI

struct MainLoaderView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(spacing: 20) {
                Image("logo2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350)
                    .padding(.top, 80)
                Text("ELYSIUM")
                    .font(.custom("AncientGeek", size: 50))
                    .foregroundColor(.black)
            }
        }
        .ignoresSafeArea()
    }
}


struct MainLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        MainLoaderView()
    }
}
