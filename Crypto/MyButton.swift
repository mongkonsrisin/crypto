//
//  MyButton.swift
//  Crypto
//
//  Created by Mongkon on 2025-03-11.
//

import SwiftUI

enum MyButton {
    case Decrypt(text: String, action: () -> Void)
    case Encrypt(text: String, action: () -> Void)
    
    @ViewBuilder
    func content() -> some View {
        switch self {
        case .Decrypt(let text, let action):
            ButtonView(text: text, action: action, imageName: "lock.open.fill", color: "#EF5350")
        case .Encrypt(let text, let action):
            ButtonView(text: text, action: action, imageName: "lock.fill", color: "#66BB6A")
        }
    }
}

private struct ButtonView: View {
    let text: String
    let action: () -> Void
    let imageName: String
    let color: String
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                    .foregroundColor(.white)
                    .font(.system(size: 20))
                    .padding(.trailing, 5)
                Text(text)
                    .font(.system(size: 20))
            }
            .frame(minWidth: 120, maxWidth: .infinity)
            .padding()
            .background(Color(hex: color))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 10)
    }
}

extension MyButton: View {
    var body: some View {
        content()
    }
}
