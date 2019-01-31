//
//  ListModel.swift
//  Crypto
//
//  Created by Milan Shah on 1/23/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import Foundation
import Realm

class ListModel: RLMObject {
    @objc dynamic var bpi = RLMArray<BPI>(objectClassName: BPI.className())
    @objc dynamic var disclaimer = ""
    @objc dynamic var time = ""
}

class BPI: RLMObject {
    @objc dynamic var timeAndDate = ""
    @objc dynamic var value : Double = 0.0
}

