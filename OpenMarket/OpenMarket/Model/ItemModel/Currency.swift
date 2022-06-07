//
//  Currency.swift
//  OpenMarket
//
//  Created by 두기, minseong on 2022/05/10.
//

enum Currency: String {
    case KRW
    case USD
    
    var index: Int {
        switch self {
        case .KRW:
            return 0
        case .USD:
            return 1
        }
    }
}
