//
//  Task.swift
//  ToDoRealm
//
//  Created by Artiom on 7.08.21.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    @objc dynamic var note = ""
    @objc dynamic var isComplete = false
}
