//
//  ListViewController.swift
//  Crypto
//
//  Created by Milan Shah on 1/18/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity
import RealmSwift
import Realm

class ListViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    var presenter: ViewToPresenterProtocol?
    var listModel: ListModel?
    var timer: Timer?
    var wcSession : WCSession?
    var bpis: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.delegate = self
        listTableView.dataSource = self
        view.backgroundColor = hexStringToUIColor(hex: "00ced1")
        showCryptoProgressIndicator(view: self.view)
        presenter?.startFetchingCryptoListData()

        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { (timer) in
            self.presenter?.startFetchingCryptoListData()
        })
        
        if (WCSession.isSupported()) {
            wcSession = WCSession.default
            wcSession?.delegate = self
            wcSession?.activate()
        }
        
    }
    
}

extension ListViewController: PresenterToViewProtocol {
    
    func retrievedLocalBPIDict(_ bpiDict: [String : Any]?) {
        self.bpis = bpiDict
    }
    
    func showCrypto(cryptoListModel: ListModel) {
        self.listModel = cryptoListModel
        self.listTableView.reloadData()
        hideCryptoProgressIndicator(view: self.view)
        
        // Send the latest data to WCSession if reachable
        sendBPIDictToWCSession()
        
    }
    
    func showError() {
        hideCryptoProgressIndicator(view: self.view)
        let errorAlert = UIAlertController(title: "Oops", message: "Something went wrong. Please try again.", preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(errorAlert, animated: true, completion: nil)
    }
}

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - TableView DataSource and Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let listModel = listModel {
            return Int(listModel.bpi.count)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CryptoCell", for: indexPath) as! ListCryptoCell
        cell.cryptoNameLabel.text = "BTC"
        cell.selectionStyle = .none
        
        /* // Applying corner radius to seperator
        cell.cryptoSeperatorView.layer.masksToBounds = true
        cell.cryptoSeperatorView.layer.cornerRadius = 4.0
        */
        
        if let listModel = listModel {
            
            let bpiAtIndex = listModel.bpi[UInt(indexPath.row)]
            let bpiKeyAtIndex = bpiAtIndex.timeAndDate
            let bpiValueAtIndex = bpiAtIndex.value
            let dateWithWeekDay = Date().getDayWithWeekName(bpiKeyAtIndex)
            
            cell.cryptoDateLabel.text = dateWithWeekDay
            cell.cryptoValueLabel.text = "$\(bpiValueAtIndex)"
            
            // Calculate the change in % and $ from previous date
            if indexPath.row < listModel.bpi.count - 1 {
                let bpiAtPreviousIndex = listModel.bpi[UInt(indexPath.row + 1)]
                let bpiValueAtPreviousIndex = bpiAtPreviousIndex.value
                let changeInDollars = bpiValueAtIndex - bpiValueAtPreviousIndex
                let changeInPercentages = (changeInDollars / bpiValueAtIndex) * 100
                
                cell.cryptoValueChangeLabel.text = "\(changeInPercentages.rounded())%  (\(changeInDollars.rounded()))"
                
                if changeInDollars > 0 {
                    cell.cryptoValueChangeLabel.textColor = UIColor.green
                } else {
                    cell.cryptoValueChangeLabel.textColor = UIColor.red
                }
                
            } else {
                cell.cryptoValueChangeLabel.text = "N/A"
                cell.cryptoValueChangeLabel.textColor = UIColor.lightGray
            }
            
        }
        
        return cell
    }
    
}

extension ListViewController: WCSessionDelegate {
    
    // MARK: - WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("sessionWatchStateDidChange: \(session)")
    }
    
    func sendBPIDictToWCSession () {
        if let bpis = self.bpis, WCSession.default.isReachable {
            do {
                try wcSession?.updateApplicationContext(bpis)
            } catch {
                print("Something went wrong")
            }
        }
    }
}

// MARK: - ListCryptoCell
class ListCryptoCell: UITableViewCell {
    
    @IBOutlet weak var cryptoNameLabel: UILabel!
    @IBOutlet weak var cryptoDateLabel: UILabel!
    @IBOutlet weak var cryptoValueLabel: UILabel!
    @IBOutlet weak var cryptoValueChangeLabel: UILabel!
    @IBOutlet weak var cryptoSeperatorView: UIView!
    
    
}


