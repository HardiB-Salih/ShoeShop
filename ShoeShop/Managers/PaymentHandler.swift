//
//  PaymentHandler.swift
//  ShoeShop
//
//  Created by HardiB.Salih on 5/11/24.
//

import Foundation
import PassKit


final class PaymentHandler: NSObject {
    typealias PaymentCompletionHandler = (Bool) -> Void
    
    var paymentController: PKPaymentAuthorizationController?
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: PaymentCompletionHandler?
    
    static let supportedNetworks: [PKPaymentNetwork] = [
        .visa,
        .masterCard,
        .amex,
        .discover
        ]
}

////MARK: -Start Payment
extension PaymentHandler {
   
    func startPayment(items: [Cart], total: Int, completion: @escaping PaymentCompletionHandler) {
        let countryCode: String = "US"
        let currencyCode: String = "USD"
        let merchantIdentifier: String = "merchant.app.hardibsalih.shoeshop"
        completionHandler = completion
        
        paymentSummaryItems = []
        
        items.forEach { cartItem in
            let item = PKPaymentSummaryItem(label: cartItem.product.name, amount: NSDecimalNumber(string: "\(cartItem.product.price * cartItem.quantity).00"), type: .final)
            paymentSummaryItems.append(item)
        }
        
        let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "\(total).00"), type: .final)
        paymentSummaryItems.append(total)
        
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = merchantIdentifier
        paymentRequest.merchantCapabilities = .capability3DS
        paymentRequest.countryCode = countryCode
        paymentRequest.currencyCode = currencyCode
        paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks
        paymentRequest.shippingType = .delivery
        paymentRequest.shippingMethods = shippingCalculator()
        paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
        
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { presented in
            if presented {
                debugPrint("Presented payment controller")
            } else {
                debugPrint("Failed to present payment controller")
            }
        })
    }
}

//MARK: -Shipping Calculator
extension PaymentHandler {
    func shippingCalculator() -> [PKShippingMethod] {
        let today = Date()
        let calendar = Calendar.current
        
        let shippingStart = calendar.date(byAdding: .day, value: 5, to: today)
        let shippingEnd = calendar.date(byAdding: .day, value: 10, to: today)
        
        if let shippingStart = shippingStart, let shippingEnd = shippingEnd {
            let startComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingStart)
            let endComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: shippingEnd)
            
            let shippingDeliveryMethod = PKShippingMethod(label: "Delivery", amount: NSDecimalNumber(string: "0.00"))
            shippingDeliveryMethod.dateComponentsRange = PKDateComponentsRange(start: startComponents, end: endComponents)
            shippingDeliveryMethod.detail = "Shoes are on their way!!!"
            shippingDeliveryMethod.identifier = "DELIVERY"
            
            return [shippingDeliveryMethod]
        }
        return []
    }
}

extension PaymentHandler: PKPaymentAuthorizationControllerDelegate {
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        let errors = [Error]()
        let status = PKPaymentAuthorizationStatus.success
        
        self.paymentStatus = status
        completion(PKPaymentAuthorizationResult(status: status, errors: errors))
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    if let completionHandler = self.completionHandler {
                        completionHandler(true)
                    }
                } else {
                    if let completionHandler = self.completionHandler {
                        completionHandler(false)
                        print("Payment VC Canceled")
                    }
                }
            }
        }
    }
}

/*
 // Define constants for shipping dates
 let shippingDelayDays: Int = 5
 let shippingDurationDays: Int = 10

 func calculateShippingDates() -> (start: Date, end: Date)? {
     let today = Date()
     let calendar = Calendar.current
     
     guard let shippingStart = calendar.date(byAdding: .day, value: shippingDelayDays, to: today),
           let shippingEnd = calendar.date(byAdding: .day, value: shippingDelayDays + shippingDurationDays, to: today) else {
         return nil
     }
     
     return (shippingStart, shippingEnd)
 }

 func createShippingMethod(with dates: (start: Date, end: Date)) -> PKShippingMethod {
     let calendar = Calendar.current
     let startComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: dates.start)
     let endComponents = calendar.dateComponents([.calendar, .year, .month, .day], from: dates.end)
     
     let shippingDeliveryMethod = PKShippingMethod(label: "Delivery", amount: NSDecimalNumber(string: "0.00"))
     shippingDeliveryMethod.dateComponentsRange = PKDateComponentsRange(start: startComponents, end: endComponents)
     shippingDeliveryMethod.detail = "Shoes are on their way!!!"
     shippingDeliveryMethod.identifier = "DELIVERY"
     
     return shippingDeliveryMethod
 }

 func shippingCalculator() -> [PKShippingMethod] {
     guard let dates = calculateShippingDates() else {
         print("Error: Unable to calculate shipping dates")
         return []
     }
     
     let shippingMethod = createShippingMethod(with: dates)
     return [shippingMethod]
 }
 */

/*
 // Define constants for country code, currency code, and merchant identifier
 let countryCode: String = "US"
 let currencyCode: String = "USD"
 let merchantIdentifier: String = "merchant.com.devtechie.shoeshopfinal"

 extension PaymentHandler {
     func startPayment(items: [Cart], total: Int, completion: @escaping PaymentCompletionHandler) {
         completionHandler = completion
         
         // Create payment summary items
         let paymentSummaryItems = createPaymentSummaryItems(from: items, total: total)
         
         // Set up payment request
         let paymentRequest = createPaymentRequest(with: paymentSummaryItems)
         
         // Present payment controller
         presentPaymentController(with: paymentRequest, completion: completion)
     }
     
     private func createPaymentSummaryItems(from items: [Cart], total: Int) -> [PKPaymentSummaryItem] {
         var paymentSummaryItems: [PKPaymentSummaryItem] = []
         
         items.forEach { cartItem in
             let item = PKPaymentSummaryItem(label: cartItem.product.name, amount: NSDecimalNumber(string: "\(cartItem.product.price * cartItem.quantity).00"), type: .final)
             paymentSummaryItems.append(item)
         }
         
         let totalItem = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(string: "\(total).00"), type: .final)
         paymentSummaryItems.append(totalItem)
         
         return paymentSummaryItems
     }
     
     private func createPaymentRequest(with paymentSummaryItems: [PKPaymentSummaryItem]) -> PKPaymentRequest {
         let paymentRequest = PKPaymentRequest()
         paymentRequest.paymentSummaryItems = paymentSummaryItems
         paymentRequest.merchantIdentifier = merchantIdentifier
         paymentRequest.merchantCapabilities = .capability3DS
         paymentRequest.countryCode = countryCode
         paymentRequest.currencyCode = currencyCode
         paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks
         paymentRequest.shippingType = .delivery
         paymentRequest.shippingMethods = shippingCalculator()
         paymentRequest.requiredShippingContactFields = [.name, .postalAddress]
         
         return paymentRequest
     }
     
     private func presentPaymentController(with paymentRequest: PKPaymentRequest, completion: @escaping PaymentCompletionHandler) {
         paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
         paymentController?.delegate = self
         paymentController?.present { [weak self] presented, error in
             if let error = error {
                 debugPrint("Error presenting payment controller: \(error.localizedDescription)")
                 return
             }
             
             if presented {
                 debugPrint("Presented payment controller")
             } else {
                 debugPrint("Failed to present payment controller")
             }
         }
     }
 }
 */
