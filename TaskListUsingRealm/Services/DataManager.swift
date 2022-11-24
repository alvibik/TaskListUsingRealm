//
//  DataManager.swift
//  TaskListUsingRealm
//
//  Created by albik on 22.11.2022.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    func createTempData(completion: @escaping () -> Void) {
        if !UserDefaults.standard.bool(forKey: "done") {
            let shoppingList = TaskList()
            shoppingList.name = "Shopping List"
            
            let moviesList = TaskList(
                value: [
                    "Movies List",
                    Date(),
                    [
                        ["Avatar"],
                        ["", "Must have", Date(), true]
                    ]
                ]
            )
            
            let milk = Task()
            milk.name = "Milk"
            milk.note = "2 L"
            
            let bread = Task(value: ["Bread", "", Date(), true])
            let apples = Task(value: ["name": "Apples", "note": "2 kg"])
            
            shoppingList.tasks.append(milk)
            shoppingList.tasks.insert(contentsOf: [bread, apples], at: 1)
            
            DispatchQueue.main.async {
                StorageManager.shared.save([shoppingList, moviesList])
                UserDefaults.standard.set(true, forKey: "done")
                completion()
            }
        }
    }
}
