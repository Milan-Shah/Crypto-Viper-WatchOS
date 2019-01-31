//
//  CryptoAPI.swift
//  Crypto
//
//  Created by Milan Shah on 1/20/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import Foundation

struct BaseAPI {
    static let base = "https://api.coindesk.com/v1/bpi/historical/close.json"
}

protocol CryptoAPI {
    var path: String { get }
    var url: URL { get }
}

enum CryptoAPIs {
    
    enum ListAPI: CryptoAPI {

        case lastTwoWeeksCryptoList
        
        internal var path: String {
            let weekAgoDate = Date().dateTwoWeeksAgo()
            let todaysDate = Date().todaysDate()
            return String(format: "start=%@&end=%@", weekAgoDate, todaysDate)
        }
        
        public var url: URL {
            return URL(string: String(format: "%@?%@", BaseAPI.base, path))!
        }
    }
}
