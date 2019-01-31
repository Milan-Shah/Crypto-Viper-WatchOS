//
//  ListInterfaceController.swift
//  Watch Extension
//
//  Created by Milan Shah on 1/25/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import WatchKit
import Foundation
import Realm
import UIKit


class ListInterfaceController: WKInterfaceController {

    @IBOutlet weak var listTable: WKInterfaceTable!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // listTable.setNumberOfRows(10, withRowType: "ListRow")
        
        //Realm - Store database inside the group
        let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.crypto.list")!
        let realmPath = directory.appendingPathComponent("db.realm")
        let config = RLMRealmConfiguration.default()
        config.fileURL = realmPath.absoluteURL
        RLMRealmConfiguration.setDefault(config)
        
        reloadWKTableData()
        
    }

    func reloadWKTableData() {
        
        let realm = RLMRealm.default()
        if let listModel = ListModel.allObjects().firstObject() as? ListModel {
            
            let numberOfRowsCount = Int(listModel.bpi.count)
            listTable.setNumberOfRows(numberOfRowsCount, withRowType: "ListRow")
            
            
            for index in 0..<numberOfRowsCount {
                let bpiAtIndex = listModel.bpi[UInt(index)]
                let bpiKeyAtIndex = bpiAtIndex.timeAndDate
                let bpiValueAtIndex = bpiAtIndex.value
                
                if let row = listTable.rowController(at: index) as? ListRowController {
                    row.cryptoDateLabel.setText(bpiKeyAtIndex)
                    row.cryptoValueLabel.setText("$\(bpiValueAtIndex)")
                    
                    if index >= 1 {
                        let bpiAtPreviousIndex = listModel.bpi[UInt(index - 1)]
                        let bpiValueAtPreviousIndex = bpiAtPreviousIndex.value
                        let changeInDollars = bpiValueAtIndex - bpiValueAtPreviousIndex
                        let changeInPercentages = (changeInDollars / bpiValueAtIndex) * 100
                        
                        row.cryptoValueChangeLabel.setText("\(changeInPercentages.rounded())%  (\(changeInDollars.rounded()))")
                        
                        if changeInDollars > 0 {
                            row.cryptoValueChangeLabel.setTextColor(UIColor.green)
                        } else {
                            row.cryptoValueChangeLabel.setTextColor(UIColor.red)
                        }
                        
                    } else {
                        row.cryptoValueChangeLabel.setText("N/A")
                    }
                    
                }
            }
        } else {
            
            // Show error
            let errorAction = WKAlertAction.init(title: "Okay", style:.cancel) {
                print("Error in loading data from Realm Database source")
            }
            
            presentAlert(withTitle: "Oops", message: "Something went wrong. Please try again.", preferredStyle: .alert, actions: [errorAction])
        }
    }
}
