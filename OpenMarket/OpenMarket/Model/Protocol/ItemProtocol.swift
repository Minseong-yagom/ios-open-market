//
//  ItemProtocol.swift
//  OpenMarket
//
//  Created by 두기, minseong on 2022/05/10.
//

protocol ItemAble {
    var id: Int { get }
    var vendorId: Int { get }
    var name: String { get }
    var thumbnail: String { get }
    var currency: Currency.RawValue { get }
    var price: Double { get }
    var bargainPrice: Double { get }
    var discountedPrice: Double { get }
    var stock: Int { get }
    var createdAt: String { get }
    var issuedAt: String { get }
}
