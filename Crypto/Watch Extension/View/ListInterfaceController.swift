//
//  ListInterfaceController.swift
//  Watch Extension
//
//  Created by Milan Shah on 1/25/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import Realm

class ListInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet weak var listTable: WKInterfaceTable!
    var wcSession : WCSession?
    @objc dynamic var bpi = RLMArray<BPI>(objectClassName: BPI.className())
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
    }
    
    override func willActivate() {
        super.willActivate()
        
        if WCSession.isSupported() {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
    }
    
    // MARK: Session State
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print(activationState)
    }

    // MARK: ApplicationContext
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        print("didReceiveApplicationContext : \(applicationContext)")
        
        // Array of date keys
        var dateKeys: [Date] = []
        for (key, _) in applicationContext {
            let date = self.stringToDate(key)
            dateKeys.append(date)
        }
        
        // Sort the dates
        dateKeys = dateKeys.sorted().reversed()
        
        // Get the key and value from sorted date keys, add bpi object
        for key in dateKeys {
            let date = self.dateToString(key)
            let value = applicationContext[date] as? Double ?? 0
            
            // BPI object for model
            let bpi = BPI()
            bpi.timeAndDate = date
            let roundedValue = round( value * 100) / 100
            bpi.value = roundedValue
            self.bpi.add(bpi)
            
        }
        
        setListTableRows()
        
    }
    
    // MARK: Update Table
    func setListTableRows() {
        
        listTable.setNumberOfRows(Int(self.bpi.count), withRowType: "ListRow")
        
        //Row controller
        for index in 0..<listTable.numberOfRows {
            guard let controller = listTable.rowController(at: index) as? ListRowController else { continue }
            
            controller.cryptoNameLabel.setText("BTC")
            
            let bpiAtIndex = self.bpi[UInt(index)]
            let bpiKeyAtIndex = bpiAtIndex.timeAndDate
            let bpiValueAtIndex = bpiAtIndex.value
            let dateWithWeekDay = self.getDayWithWeekName(bpiKeyAtIndex)
            
            controller.cryptoDateLabel.setText(dateWithWeekDay)
            controller.cryptoValueLabel.setText("$\(bpiValueAtIndex)")
            
            // Calculate the change in % and $ from previous date
            if index < self.bpi.count - 1 {
                let bpiAtPreviousIndex = self.bpi[UInt(index + 1)]
                let bpiValueAtPreviousIndex = bpiAtPreviousIndex.value
                let changeInDollars = bpiValueAtIndex - bpiValueAtPreviousIndex
                let changeInPercentages = (changeInDollars / bpiValueAtIndex) * 100
                
                controller.cryptoValueChangeLabel.setText("\(changeInPercentages.rounded())%  (\(changeInDollars.rounded()))")
                
                if changeInDollars > 0 {
                    controller.cryptoValueChangeLabel.setTextColor(UIColor.green)
                } else {
                    controller.cryptoValueChangeLabel.setTextColor(UIColor.red)
                }
            } else {
                controller.cryptoValueChangeLabel.setText("N/A")
                controller.cryptoValueChangeLabel.setTextColor(UIColor.lightGray)
            }
            
        }
    }
    
    // MARK: Helpers
    func getDayWithWeekName(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: dateString)
        formatter.dateFormat = "EEEE"
        return "\(dateString)" + "  (" + formatter.string(from: date ?? Date()) + ")"
    }
    
    func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func stringToDate(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string) ?? Date()
    }
    
    func presentErrorAlert() {
        let okAction = WKAlertAction(title: "Okay", style: .default) {}
        presentAlert(withTitle: "Oops", message: "Something went wrong. Please try again.", preferredStyle: .alert, actions: [okAction])
    }
}

