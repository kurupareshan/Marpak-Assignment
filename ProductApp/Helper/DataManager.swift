//
//  DataManager.swift
//  ProductApp
//
//  Created by Kuru on 2024-05-02.
//

import Foundation
import Realm
import RealmSwift

class Datamanager {
    
    static let shared = Datamanager()
    private let realm: Realm
    
    private init() {
        do {
            realm = try Realm()
        } catch {
            fatalError("Error initializing Realm: \(error)")
        }
    }
    
    // MARK: - Tasks
    
    func createTask(name: String) {
        let newUser = DetailsViewModel()
        newUser.name = name
        do {
            try realm.write {
                realm.add(newUser)
            }
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    func fetchTasks() -> Results<DetailsViewModel> {
        return realm.objects(DetailsViewModel.self)
    }
    
    func updateTask(task: DetailsViewModel, name: String) {
        do {
            try realm.write {
                task.name = name
            }
        } catch {
            print("Error updating task: \(error)")
        }
    }
    
    func deleteTask(task: DetailsViewModel) {
        do {
            try realm.write {
                realm.delete(task)
            }
        } catch {
            print("Error deleting task: \(error)")
        }
    }
}

