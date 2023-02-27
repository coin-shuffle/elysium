//
//  LaunchScreenStateManager.swift
//  Elysium
//
//  Created by Ivan Lele on 20.02.2023.
//

import Foundation

final class LaunchScreenStateManager: ObservableObject {
    @MainActor @Published var state = true
        @MainActor func dismiss() {
            Task {
                try? await Task.sleep(for: Duration.seconds(1))

                self.state = false
            }
        }
}
