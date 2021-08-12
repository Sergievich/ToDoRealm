//
//  TasksTVC.swift
//  ToDoRealm
//
//  Created by Artiom on 7.08.21.
//

import UIKit
import RealmSwift

class TasksTVC: UITableViewController {
    
    var currentTasksList: TaskList!
    
    private var inComplete: Results<Task>!
    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentTasksList.name
        filteringTasks()
    }

    @IBAction func editBtnPressed(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
    }
    
    
    @IBAction func addBtnPressed(_ sender: Any) {
        alertForAddAndUpdateList()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let inCompleted = inComplete.count
        let completedTask = completedTasks.count
        let sections = section == 0 ? inCompleted : completedTask
        return sections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String{
        section == 0 ? "In Complete TASKS" : "Completed TASKS"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        
        let task = indexPath.section == 0 ? inComplete[indexPath.row] : completedTasks[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? inComplete[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete"){_, _, _ in
            StorageManager.deleteTask(task: task)
            self.filteringTasks()
        }
        
        let editContextItem = UIContextualAction(style: .destructive, title: "Edit"){_, _, _ in
            self.alertForAddAndUpdateList()
        }
        
        let doneContextItem = UIContextualAction(style: .destructive, title: "Done"){_, _, _ in
            StorageManager.makeDone(task)
            self.filteringTasks()
        }
        
        editContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])
        
        return swipeActions
    }
    
    //MARK: - Private
    
    private func filteringTasks(){
        inComplete = currentTasksList.tasks.filter("isComplete = false")
        completedTasks = currentTasksList.tasks.filter("isComplete = true")
        tableView.reloadData()
    }
    
    private func alertForAddAndUpdateList(_ taskName: Task? = nil) {
        let title = "Task Value"
        let message = (taskName == nil) ? "Please insert new task value" : "Please edit your task"
        let doneBtnName = taskName == nil ? "Save" : "Update"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var taskTextField: UITextField!
        var noteTextField: UITextField!

        let saveAction = UIAlertAction(title: doneBtnName, style: .default) { _ in
            guard let newNameTask = taskTextField.text, !newNameTask.isEmpty else { return }

            if let taskName = taskName {
                if let newNote = noteTextField.text, !newNote.isEmpty{
                    StorageManager.editTask(task: taskName, newTaskName: newNameTask, newNote: newNote)
                } else {
                    StorageManager.editTask(task: taskName, newTaskName: newNameTask, newNote: "")
                }
                self.filteringTasks()
            } else {
                let task = Task()
                task.name = newNameTask
                if let note = noteTextField.text, !note.isEmpty{
                    task.note = note
                }
                StorageManager.saveTask(self.currentTasksList, task: task)
                self.filteringTasks()
            }
    }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = "NewTask"
            
            if let taskName = taskName{
                taskTextField.text = taskName.name
            }
        }
        
        alert.addTextField{textField in
            noteTextField = textField
            noteTextField.placeholder = "Note"
            
            if let taskName = taskName{
                noteTextField.text = taskName.note
            }
        }
        
        present(alert, animated: true)


}
}
