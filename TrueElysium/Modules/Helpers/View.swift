//
//  View.swift
//  TrueElysium
//
//  Created by Ivan Lele on 27.02.2023.
//

import SwiftUI

struct LocalizedAlertError: LocalizedError {
    let underlyingError: LocalizedError
    var errorDescription: String? {
        underlyingError.errorDescription
    }
    var recoverySuggestion: String? {
        underlyingError.recoverySuggestion
    }

    init?(error: Error?) {
        guard let localizedError = error as? LocalizedError else { return nil }
        underlyingError = localizedError
    }
}

extension View {
    func errorAlert(error: Binding<LocalizedError?>, buttonTitle: String = "OK", actor: Binding<Bool>) -> some View {
        let localizedAlertError = LocalizedAlertError(error: error.wrappedValue)
        return alert(isPresented: .constant(localizedAlertError != nil), error: localizedAlertError) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
                actor.wrappedValue = true
            }
        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }
    }
}
