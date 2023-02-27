//
//  LoaderView.swift
//  Elysium
//
//  Created by Ivan Lele on 20.02.2023.
//

import SwiftUI

struct LoaderView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.white.opacity(0.5))
            ProgressView()
        }
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView()
    }
}
