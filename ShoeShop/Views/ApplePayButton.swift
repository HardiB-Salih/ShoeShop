//
//  ApplePayButton.swift
//  ShoeShop
//
//  Created by HardiB.Salih on 5/11/24.
//

import SwiftUI
import PassKit

struct ApplePayButton: View {
    var action: () -> Void
    
    
    var body: some View {
        ApplePayButtonRepresentable(action: action)
            .frame(minWidth: 100, maxWidth: 400)
            .frame(height: 45)
            .frame(maxWidth: .infinity)
    }
}

extension ApplePayButton {
    struct ApplePayButtonRepresentable: UIViewRepresentable {
        var action: () -> Void
        
        func makeUIView(context: Context) -> UIView {
            context.coordinator.button
        }
        
        func updateUIView(_ rootView: UIView, context: Context) {
            context.coordinator.action = action
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(action: action)
        }
    }
    
    final class Coordinator: NSObject {
        var action: () -> Void
        var button = PKPaymentButton(paymentButtonType: .checkout, paymentButtonStyle: .automatic)
        
        init(action: @escaping () -> Void) {
            self.action = action
            super.init()
            
            button.addTarget(self, action: #selector(callback(_:)), for: .touchUpInside)
        }
        
        @objc
        func callback(_ sender: Any) {
            action()
        }
    }
}
