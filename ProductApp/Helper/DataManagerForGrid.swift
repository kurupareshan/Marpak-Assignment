//
//  DataManagerForGrid.swift
//  ProductApp
//
//  Created by Kuru on 2024-05-02.
//

import Foundation
import Realm
import RealmSwift

class DataManagerForGrid {
    
    static let shared = DataManagerForGrid()
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
            let newTask = DetailsViewModelForGrid()
            newTask.name = name
            
            do {
                try realm.write {
                    realm.add(newTask)
                }
            } catch {
                print("Error saving task: \(error)")
            }
        }
        
        func fetchTasks() -> Results<DetailsViewModelForGrid> {
            return realm.objects(DetailsViewModelForGrid.self)
        }
        
        func updateTask(task: DetailsViewModelForGrid, name: String) {
            do {
                try realm.write {
                    task.name = name
                }
            } catch {
                print("Error updating task: \(error)")
            }
        }

    func deleteTask(task: DetailsViewModelForGrid) {
        do {
            try realm.write {
                realm.delete(task)
            }
        } catch {
            print("Error deleting task: \(error)")
        }
    }

}
