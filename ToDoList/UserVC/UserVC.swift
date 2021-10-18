//
//  UserVC.swift
//  ToDoList
//
//  Created by Wang Allen on 2021/10/4.
//

import UIKit

class UserVC: UIViewController {

    @IBOutlet var UserNameLabel: UILabel!
    
    var UserVariable: String!
    
    override func viewDidLoad() {
        
        UserNameLabel.text = UserVariable
        
        super.viewDidLoad()
    }



}
