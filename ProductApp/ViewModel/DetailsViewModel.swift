//
//  DetailsViewModel.swift
//  ProductApp
//
//  Created by Kuru on 2024-05-02.
//

import Foundation

import Realm
import RealmSwift

class DetailsViewModel: Object, Codable{
    
    @objc dynamic var name: String = ""
    
    required override init() {
        super.init()
    }
}

class DetailsViewModelForGrid: Object, Codable{
    
    @objc dynamic var name: String = ""

    required override init() {
        super.init()
    }
}

