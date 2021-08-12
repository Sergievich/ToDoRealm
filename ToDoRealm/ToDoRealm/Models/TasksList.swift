//
//  TasksList.swift
//  ToDoRealm
//
//  Created by Artiom on 7.08.21.
//

import Foundation
import RealmSwift

class TaskList: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    let tasks = List<Task>()
}
