//
//  CopiedPopUp.swift
//  Elysium
//
//  Created by Ivan Lele on 20.02.2023.
//

import SwiftUI

struct CopiedPopUpView: View {
    @State private var copied = false {
        didSet {
            if copied == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        copied = false
                    }
                }
            }
        }
    }
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if copied {
                    Text("Copied to clipboard")
                        .padding()
                        .background(Color.blue.cornerRadius(20))
                        .position(x: geo.frame(in: .local).width/2)
                        .transition(.move(edge: .top))
                        .padding(.top)
                        .animation(Animation.easeInOut(duration: 1))
                }
                
                VStack {
                    Text("Copy")
                        .onTapGesture(count: 2) {
                            withAnimation {
                                copied = true
                        }
                    }
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CopiedPopUpView_Previews: PreviewProvider {
    static var previews: some View {
        CopiedPopUpView()
    }
}
