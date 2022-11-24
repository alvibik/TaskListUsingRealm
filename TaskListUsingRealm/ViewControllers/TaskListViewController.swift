//
//  ViewController.swift
//  TaskListUsingRealm
//
//  Created by albik on 22.11.2022.
//

import UIKit
import RealmSwift

final class TaskListViewController: UITableViewController {
    
    //MARK: - Published properties

    var taskLists: Results<TaskList>!
    
    //MARK: - Overridet methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonPressed)
        )
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = editButtonItem
        createTempData()
        taskLists = StorageManager.shared.realm.objects(TaskList.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskListCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let taskList = taskLists[indexPath.row]
        content.text = taskList.name
//        content.secondaryText = "\(taskList.tasks.count)"
        content.secondaryText = "✔︎\(taskList.tasks.filter("isComplete = true").count)  ❏\(taskList.tasks.filter("isComplete = false").count)"
//        content.secondaryText = {() -> String in
//            let secondTextIsNonCom = taskList.tasks.filter("isComplete = false")
//            let secondTextIsCom = taskList.tasks.filter("isComplete = false")
//            if taskList.tasks.isEmpty {
//                //se
//            }
//            return "-"
//        }()

        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table View Data Source
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let taskList = taskLists[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.shared.delete(taskList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] _, _, isDone in
            showAlert(with: taskList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            isDone(true)
        }
        
        let doneAction = UIContextualAction(style: .normal, title: "Done") { _, _, isDone in
            StorageManager.shared.done(taskList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            isDone(true)
        }
        
        editAction.backgroundColor = .orange
        doneAction.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [doneAction, editAction, deleteAction])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        guard let tasksVC = segue.destination as? TasksViewController else { return }
        let taskList = taskLists[indexPath.row]
        tasksVC.taskList = taskList
    }
    
    //MARK: - IBAcations
    @IBAction func sortingList(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            taskLists = taskLists.sorted(byKeyPath: "name")
        default:
            taskLists = taskLists.sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }
    
    //MARK: - Private methods
    @objc private func addButtonPressed() {
        showAlert()
    }
    
    private func createTempData() {
        DataManager.shared.createTempData { [unowned self] in
            tableView.reloadData()
        }
    }
//    private func secondTextConfig() -> String{
//        let currentTasks = taskList.tasks.filter("isComplete = false")
//        var secondText = "-"
//        if taskLists.task.isEmpty {
//            secondText = "0"
//        }
//        return secondText
//    }
}
    //MARK: - Extensions
extension TaskListViewController {
    
    private func showAlert(with taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        let title = taskList != nil ? "Edit List" : "New List"
        let alert = UIAlertController.createAlert(withTitle: title, andMessage: "Please set title for new task list")
        
        alert.action(with: taskList) { [weak self] newValue in
            if let taskList = taskList, let completion = completion {
                StorageManager.shared.edit(taskList, newValue: newValue)
                completion()
            } else {
                self?.save(taskList: newValue)
            }
        }
        
        present(alert, animated: true)
    }
    
    private func save(taskList: String) {
        StorageManager.shared.save(taskList) { taskList in
            let rowIndex = IndexPath(row: taskLists.index(of: taskList) ?? 0, section: 0)
            tableView.insertRows(at: [rowIndex], with: .automatic)
        }
    }
}

