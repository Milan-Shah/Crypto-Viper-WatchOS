//
//  ListRouter.swift
//  Crypto
//
//  Created by Milan Shah on 1/18/19.
//  Copyright © 2019 Milan Shah. All rights reserved.
//

import Foundation
import UIKit

class ListRouter: PresenterToRouterProtocol {
    
    static func createModule() -> ListViewController {
    
        let view = mainStoryboard.instantiateViewController(withIdentifier: "CryptoListViewController") as! ListViewController
        let presenter: ViewToPresenterProtocol & InteractorToPresenterProtocol = ListPresenter()
        let interactor: PresenterToInteractorProtocol = ListInteractor()
        let router: PresenterToRouterProtocol = ListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return view
        
    }
    
    static var mainStoryboard: UIStoryboard {
        return UIStoryboard(name:"Main",bundle: Bundle.main)
    }
}
