//
//  Task.swift
//
//
//  Created by Aaron B on 3/21/16.
//
//

import Foundation
import RealmSwift

class Task: Object {
    dynamic var id = String()
    dynamic var name = String()
    dynamic var dueDate:NSDate = NSDate()
    dynamic var hashtag:Noun?
    dynamic var isCompleted:Bool = false
    dynamic var distanceFromUser:Double = Double()
    
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func createNewTaskWithID(id:String, name:String, dueDate:NSDate, noun:Noun, withCompletionHandler handler: ((newTask: Task) -> ())?) {
        let newTask = Task(value: [id, name, dueDate, noun, false, Double(0.0)])
        try! uiRealm.write { () -> Void in
            uiRealm.add(newTask)
            handler?(newTask: newTask)
        }
    }
    
    func readAllTasks(withCompletionHandler handler: (tasks: Results<Task>?) -> () ){
        let taskList = uiRealm.objects(Task).sorted("name", ascending: true)
        handler(tasks: taskList)
    }

    func readTasksDueSoon(withCompletionHandler handler: (tasks: Results<Task>) -> () ) {
        let taskList = uiRealm.objects(Task).sorted("dueDate", ascending: true)
        handler(tasks: taskList)
    }
    
    func readCloseTasks(withCompletionHandler  handler: (tasks: Results<Task>) -> () ) {
        let taskList = uiRealm.objects(Task).sorted("distanceFromUser", ascending: true)
        handler(tasks: taskList)
    }
    
    func removeTask(task: Task, withCompletionHandler handler: (tasks: Results<Task>?) ->()) {
        try! uiRealm.write({ 
            uiRealm.delete(task)
            let taskList = uiRealm.objects(Task).sorted("dueDate", ascending:  true)
            handler(tasks: taskList)
        })
    }
}