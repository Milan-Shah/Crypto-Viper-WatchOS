//
//  ListProtocols.swift
//  Crypto
//
//  Created by Milan Shah on 1/18/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import UIKit
import RealmSwift

protocol ViewToPresenterProtocol: class {
    
    var view: PresenterToViewProtocol? { get set }
    var interactor: PresenterToInteractorProtocol? { get set }
    var router: PresenterToRouterProtocol? { get set }
    func startFetchingCryptoListData()
}

protocol PresenterToViewProtocol: class {
    func showCrypto(cryptoListModel: ListModel)
    func retrievedLocalBPIDict(_ bpiDict: [String: Any]?)
    func showError()
}

protocol PresenterToRouterProtocol: class {
    static func createModule()-> ListViewController
}

protocol PresenterToInteractorProtocol: class {
    var presenter:InteractorToPresenterProtocol? { get set }
    var dataManager: InteractorToDataManagerProtocol? { get set }
    func fetchCryptoList()
}

protocol InteractorToPresenterProtocol {
    func cryptoFetchedSuccess(cryptoModel: ListModel)
    func cryptoFetchFailed()
    func retrievedLocalBPIDict(_ bpiDict: [String: Any]?)
}

protocol InteractorToDataManagerProtocol {
    func retrieveLocalListModel() -> ListModel?
    func saveListModel(model: ListModel)
}
