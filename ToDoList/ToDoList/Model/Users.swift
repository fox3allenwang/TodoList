//
//  Data.swift
//  ToDoList
//
//  Created by Wang Allen on 2021/10/1.
//

import RealmSwift

class Users: Object, Comparable{
    static func < (lhs: Users, rhs: Users) -> Bool {
        return lhs.UserName < rhs.UserName
    }
    
    @objc dynamic var UserID = UUID().uuidString
    @objc dynamic var UserName:String = ""
    @objc dynamic var UserPassword:String = ""
    @objc dynamic var UserEmail:String = ""
    @objc dynamic var updateTime:String = ""
    
    override static func primaryKey() -> String? {
        return "UserID"
    }
}
