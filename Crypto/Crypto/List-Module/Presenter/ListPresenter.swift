//
//  ListPresenter.swift
//  Crypto
//
//  Created by Milan Shah on 1/18/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class ListPresenter: ViewToPresenterProtocol {
    
    var view: PresenterToViewProtocol?
    var interactor: PresenterToInteractorProtocol?
    var router: PresenterToRouterProtocol?
    var dataManager: InteractorToDataManagerProtocol?
    
    func startFetchingCryptoListData() {
        interactor?.fetchCryptoList()
    }
}

extension ListPresenter: InteractorToPresenterProtocol {

    func cryptoFetchedSuccess(cryptoModel: ListModel) {
        view?.showCrypto(cryptoListModel: cryptoModel)
    }
    
    func cryptoFetchFailed() {
        view?.showError()
    }
    
    func retrievedLocalBPIDict(_ bpiDict: [String : Any]?) {
        view?.retrievedLocalBPIDict(bpiDict)
    }
}
