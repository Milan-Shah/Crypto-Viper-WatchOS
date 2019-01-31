//
//  ListInteractor.swift
//  Crypto
//
//  Created by Milan Shah on 1/18/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import Foundation
import Realm

class ListInteractor: PresenterToInteractorProtocol {
    
    var presenter: InteractorToPresenterProtocol?
    var dataManager: InteractorToDataManagerProtocol?
    
    func fetchCryptoList() {
        
        if let localModel = self.retrieveLocalListModel() {
            self.presenter?.cryptoFetchedSuccess(cryptoModel: localModel)
        }
        
        // Getting Crypto List Data using Native URLSession Task request
        let coindeskQueue = DispatchQueue(label: "coindesk.get.request-queue", qos: .utility, attributes: [.concurrent])
        let mainQueue = DispatchQueue.main
        let request = URLRequest(url: CryptoAPIs.ListAPI.lastTwoWeeksCryptoList.url)
        
        print("Getting new Crypto List on custom queue: \(coindeskQueue)")
        let task = URLSession.shared.dataTask(with: request) { data , response, error in
            coindeskQueue.async {
                
                // Check for error
                guard error == nil else {
                    return
                }
                
                // Check for data
                guard let data = data else {
                    return
                }
                
                // JSONSerialize jsonObject with data
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                        
                        // Going back on Main to update View
                        mainQueue.async {
                            
                            print("Got new Crypto List resonse. Updating UI on main thread now.")
                            
                            let listModel = ListModel()
                            
                            // Disclaimer
                            let disclaimer = json["disclaimer"] as? String
                            listModel.disclaimer = disclaimer ?? ""
                            
                            // Time
                            if let timeDict = json["time"] as? [String: String], let lastUpdatedTime = timeDict["updated"] {
                                listModel.time = lastUpdatedTime
                            }
                            
                            // BPIs
                            guard let bpis = json["bpi"] as? [String: Any] else {
                                self.presenter?.cryptoFetchFailed()
                                return
                            }

                            // Array of date keys
                            var dateKeys: [Date] = []
                            for (key, _) in bpis {
                                let date = key.toDate()
                                dateKeys.append(date)
                            }
                            
                            // Sort the dates
                            dateKeys = dateKeys.sorted().reversed()
                            
                            // Get the key and value from sorted date keys, add bpi object
                            for key in dateKeys {
                                let date = key.toString()
                                let value = bpis[date] as? Double ?? 0
                                
                                // BPI object for model
                                let bpi = BPI()
                                bpi.timeAndDate = date
                                let roundedValue = round( value * 100) / 100
                                bpi.value = roundedValue
                                listModel.bpi.add(bpi)
                                
                            }
                            
                            self.presenter?.cryptoFetchedSuccess(cryptoModel: listModel)
                            self.presenter?.retrievedLocalBPIDict(bpis)
                            self.saveListModel(model: listModel)
                            
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                    mainQueue.async {
                        // Going back on Main to update View
                        print("Bad response: \(String(describing: response))")
                        self.presenter?.cryptoFetchFailed()
                    }
                }
            }
        }
        
        task.resume()

    }
    
}

// MARK: Realm
extension ListInteractor {
    
    func saveListModel(model: ListModel) {
        let realm = RLMRealm.default()
        realm.beginWriteTransaction()
        realm.add(model)
        try! realm.commitWriteTransaction()
    }
    
    func retrieveLocalListModel() -> ListModel? {
        if let datasource = ListModel.allObjects().firstObject() as? ListModel {
            return datasource
        }
        return nil
    }
    
}
