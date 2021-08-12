//
//  StorageManager.swift
//  ToDoRealm
//
//  Created by Artiom on 7.08.21.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func deleteAll(){
        try! realm.write{
            realm.deleteAll()
        }
    }
    
    static func saveTaskList (taskList: TaskList) {
        try! realm.write{
            realm.add(taskList)
    }
}
    static func deleteList (taskList: TaskList) {
        try! realm.write{
            let tasks = taskList.tasks
            realm.delete(tasks)
            realm.delete(taskList)
        }
    }
    
    static func editList (taskList: TaskList, newListName: String){
        try! realm.write{
            taskList.name = newListName
        }
    }
    
    static func makeAllDone (_ taskList: TaskList){
        try! realm.write{
            taskList.tasks.setValue(true, forKey: "isComplete")
        }
    }
    
    static func editTask (task: Task, newTaskName: String, newNote: String){
        try! realm.write{
            task.name = newTaskName
            task.note = newNote
        }
    }
    
    static func saveTask (_ taskList: TaskList, task: Task){
        try! realm.write{
            taskList.tasks.append(task)
        }
    }
    
    static func deleteTask(task: Task){
        try! realm.write{
            realm.delete(task)
        }
    }
    
    static func makeDone(_ task: Task){
        try! realm.write{
            task.isComplete.toggle()
        }
    }
  
}
