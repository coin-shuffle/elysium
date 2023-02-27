//
//  MainLoaderView.swift
//  Elysium
//
//  Created by Ivan Lele on 16.02.2023.
//

import Foundation
import SwiftUI

struct MainLoaderView: View {
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.white)
            VStack{
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("ELYSIUM")
                    .font(.custom("AncientGeek", size: 35))
            }
        }
    }
}

struct MainLoaderView_Previews: PreviewProvider {
    static var previews: some View {
        MainLoaderView()
    }
}
