//
//  TaskListTVC.swift
//  ToDoRealm
//
//  Created by Artiom on 7.08.21.
//

import UIKit
import RealmSwift

class TaskListTVC: UITableViewController {
    //Results - текущее значение БД
    var tasksList: Results<TaskList>!
    var notificationToken: NotificationToken?
    
        

    override func viewDidLoad() {
        super.viewDidLoad()

        tasksList = realm.objects(TaskList.self)/*Достать все значения*/.sorted(byKeyPath: "name")//сортировка

        notificationToken = tasksList.observe { change in
            switch change {
            case .initial:
                print ("initial element")

            case .update(_, let deletions, let insertions, let modifications):
                print("deletions \(deletions)")
                print("insertions \(insertions)")
                print("modifications \(modifications)")

            case .error(let error):
                print("error \(error)")
            }

        }

        navigationItem.leftBarButtonItem = editButtonItem

    }

    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {

        alertForAddAndUpdateList()

    }

    @IBAction func sortingList(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksList = tasksList.sorted(byKeyPath: "name")
        }
        else {
            tasksList = tasksList.sorted(byKeyPath: "date")
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        tasksList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskListCell", for: indexPath)
        let taskList = tasksList[indexPath.row]
        cell.textLabel?.text = taskList.name
        cell.detailTextLabel?.text = String(taskList.tasks.count)
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentList = tasksList[indexPath.row]

        let deleteCintextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(taskList: currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }

        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdateList(currentList, complition: {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
        let doneContextItem = UIContextualAction(style: .destructive, title: "Done"){ _, _, _ in
            StorageManager.makeAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        
        editContextItem.backgroundColor = .purple
        doneContextItem.backgroundColor = .green
        
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteCintextItem, editContextItem, doneContextItem])
        
        return swipeAction
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    
    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow{
            let tasksList = tasksList[indexPath.row]
            let tasksVC = segue.destination as! TasksTVC
            tasksVC.currentTasksList = tasksList
        }
    }
    

    private func alertForAddAndUpdateList(_ taskList: TaskList? = nil, complition: (() -> Void)? = nil) {
        let title = taskList == nil ? "New List" : "Edit List"
        let message = "Please insert list name"
        let doneBtnName = taskList == nil ? "Save" : "Update"

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var alertTextField = UITextField()

        let saveAction = UIAlertAction(title: doneBtnName, style: .default) { _ in
            guard let newListName = alertTextField.text, !newListName.isEmpty else { return }

            if let listName = taskList {
                StorageManager.editList(taskList: listName, newListName: newListName)
                if let complition = complition {
                    complition()
                }
                } else {
                    let tasksList = TaskList()
                    tasksList.name = newListName

                    StorageManager.saveTaskList(taskList: tasksList)
                    self.tableView.insertRows(at: [IndexPath(row: self.tasksList.count - 1, section: 0)], with: .automatic)
                }

            }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            alertTextField = textField
            alertTextField.placeholder = "List Name"
            
        }
        
        if let listName = taskList{
            alertTextField.text = listName.name
        }
        
        present(alert, animated: true)

    }
}
