//
//  Cart.swift
//  ShoeShop
//
//  Created by HardiB.Salih on 5/11/24.
//

import Foundation

struct Cart: Identifiable {
    var id = UUID()
    var product: Product
    var quantity: Int
}
