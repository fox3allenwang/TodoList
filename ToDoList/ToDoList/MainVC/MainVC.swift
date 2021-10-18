//
//  MainVC.swift
//  ToDoList
//
//  Created by Wang Allen on 2021/10/1.
//

import UIKit
import RealmSwift

class MainVC: UIViewController {
    
    @IBOutlet weak var SortBtn: UIButton!
    @IBOutlet var UserNameTextField: UITextField!
    @IBOutlet var PasswordTextField: UITextField!
    @IBOutlet var EmailTextField: UITextField!
    @IBOutlet var MyTableView: UITableView!
    @IBOutlet var SaveDataButton: UIButton!
    
    var userEditing: Bool = false // 判斷是否正在編輯
    
    /* 使用者資料 */
    var user: String? = nil
    var password: String? = nil
    var email: String? = nil
    
    var userIndexPathRow: Int = 0 // 取得正在滑動那列的 IndexPath.Row
    var userPrimaryKey: String?  = nil // 取得該筆資料的 UUID().uuidString
    
    var isDataExsit: Bool = false // 用來判斷該筆資料是否存在
    
    /* 用來暫存排序後的資料 */
    var usersNameTmp = [String]()
    var userEmailTmp = [String]()
    var userPasswordTmp = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "MyTableViewCell", bundle: nil)
        MyTableView.register(cellNib, forCellReuseIdentifier: "Cell")
        MyTableView.dataSource = self
        MyTableView.delegate = self
    }
    
    // MARK: - IBAction
    
    @IBAction func sendUserData(_ sender: Any) {
        self.view.endEditing(true)
        DispatchQueue.main.async {
            if (self.userEditing) {
                self.updateData()
                self.alert(title: "", information: "更新成功")
                self.userEditing = false
                self.UserNameTextField.isEnabled = true
                self.SaveDataButton.setTitle("送出", for: .normal)
            } else {
                self.saveData()
                self.alert(title: "", information: "已送出")
            }
            self.userReloadData(keyPath: "updateTime", ascending: true)
        }
    }
    
    @IBAction func sortUser(_ sender: Any) {
        let alertController = UIAlertController(title: "", message: "請選擇使用者排序方式", preferredStyle: .actionSheet)
        let defaultAction = UIAlertAction(title: "預設排序", style: .default) { action in
            DispatchQueue.main.async {
                self.userReloadData(keyPath: "updateTime", ascending: true)
            }
        }
        let UserUpdateTimeEarlyToLate = UIAlertAction(title: "更新時間(早到晚)", style: .default) { action in
            DispatchQueue.main.async {
                self.userReloadData(keyPath: "updateTime", ascending: true)
            }
        }
        let UserUpdateTimeLateToEarly = UIAlertAction(title: "更新時間(晚到早)", style: .default) { action in
            DispatchQueue.main.async {
                self.userReloadData(keyPath: "updateTime", ascending: false)
            }
        }
        let sortUserNameAZ = UIAlertAction(title: "使用者名稱排序 (A -> Z)", style: .default) { action in
            DispatchQueue.main.async {
                self.userReloadData(keyPath: "UserName", ascending: true)
            }
        }
        let sortUserNameZA = UIAlertAction(title: "使用者名稱排序 (Z -> A)", style: .default) { action in
            DispatchQueue.main.async {
                self.userReloadData(keyPath: "UserName", ascending: false)
            }
        }
        let closeAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        alertController.addAction(UserUpdateTimeEarlyToLate)
        alertController.addAction(UserUpdateTimeLateToEarly)
        alertController.addAction(sortUserNameAZ)
        alertController.addAction(sortUserNameZA)
        alertController.addAction(closeAction)
        present(alertController,animated: true)
    }

    // MARK: - Function
    
    // 儲存資料
    func saveData() {
        let realm = try! Realm()
        
        guard UserNameTextField.text != "" else {
            let userEmptyAlertController = UIAlertController(title: "使用者不能為空", message: "按下確定後重新輸入", preferredStyle: .alert)
            let userEmptyAlertAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            userEmptyAlertController.addAction(userEmptyAlertAction)
            present(userEmptyAlertController, animated: true, completion: nil)
            return
        }
        guard EmailTextField.text != "" else {
            let emailEmptyAlertController = UIAlertController(title: "電子郵件地址不能為空", message: "按下確定後重新輸入", preferredStyle: .alert)
            let emailEmptyAlertAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            emailEmptyAlertController.addAction(emailEmptyAlertAction)
            present(emailEmptyAlertController, animated: true, completion: nil)
            return
        }
        guard PasswordTextField.text != "" else {
            let passwordEmptyAlertController = UIAlertController(title: "密碼不能為空", message: "按下確定後重新輸入", preferredStyle: .alert)
            let passwordEmptyAlertAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            passwordEmptyAlertController.addAction(passwordEmptyAlertAction)
            present(passwordEmptyAlertController, animated: true, completion: nil)
            return
        }

        for userData in realm.objects(Users.self) {
            if userData.UserName == UserNameTextField.text {
                isDataExsit = true
                break
            }
        }
        
        guard !isDataExsit else {
            let sameUserAlertController = UIAlertController(title: "使用者名稱已存在！", message: "按下確定後重新輸入", preferredStyle: .alert)
            let sameUserAlertAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            sameUserAlertController.addAction(sameUserAlertAction)
            present(sameUserAlertController, animated: true, completion: nil)
            return
        }
        
        user = UserNameTextField.text!
        email = EmailTextField.text!
        password = PasswordTextField.text!

        let userSave = Users()
        userSave.UserName = user!
        userSave.UserEmail  = email!
        userSave.UserPassword = password!
        userSave.updateTime = getSystemTime()
        try! realm.write{
            realm.add(userSave)
        }
        print("fileURL: \(realm.configuration.fileURL!)")
    }
    
    // 資料更新
    func updateData() {
        let realm = try! Realm()
        let updateUserInfo = Users()
        updateUserInfo.UserID = self.userPrimaryKey!
        updateUserInfo.UserName = UserNameTextField.text!
        updateUserInfo.UserPassword = PasswordTextField.text!
        updateUserInfo.UserEmail = EmailTextField.text!
        updateUserInfo.updateTime = getSystemTime()
        
        for userData in realm.objects(Users.self) {
            if userData.UserName == UserNameTextField.text {
                if userData.UserID != self.userPrimaryKey!{
                    isDataExsit = true
                }
                break
            }
        }
        
        guard !isDataExsit else {
            let sameUserAlertController = UIAlertController(title: "使用者名稱已存在！", message: "按下確定後重新輸入", preferredStyle: .alert)
            let sameUserAlertAction = UIAlertAction(title: "確定", style: .default, handler: nil)
            sameUserAlertController.addAction(sameUserAlertAction)
            present(sameUserAlertController, animated: true, completion: nil)
            return
        }
        
        try! realm.write{
            realm.add(updateUserInfo,update: .all)
        }
        print("fileURL: \(realm.configuration.fileURL!)")
    }
    
    // 找 UID
    func getUserPrimaryKey() {
        let realm = try! Realm()
        let id = realm.objects(Users.self)
        if (id.count > 0){
            self.userPrimaryKey = id[self.userIndexPathRow].UserID
        }
    }
    
//    func sort() {
//        var array = [Users]()
//        array.sort(by: <)
//    }
    
    func getSystemTime() -> String {
        let currentDate = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.ReferenceType.system
        return dateFormatter.string(from: currentDate)
    }
    
    // tableView 更新
    func userReloadData(keyPath: String, ascending: Bool) {
        let realm = try! Realm()
        let sort = realm.objects(Users.self).sorted(byKeyPath: keyPath,ascending: ascending)
        
        self.usersNameTmp.removeAll()
        self.userPasswordTmp.removeAll()
        self.userEmailTmp.removeAll()
        
        for userInfo in sort {
            self.usersNameTmp.append(userInfo.UserName)
            self.userPasswordTmp.append(userInfo.UserPassword)
            self.userEmailTmp.append(userInfo.UserEmail)
        }
        self.MyTableView.reloadData()
    }
    
    func alert(title: String, information: String) {
        let alertController = UIAlertController(title: title, message: information, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
        alertController.addAction(closeAction)
        present(alertController, animated: true)
    }
}
// MARK: - TableView Delegate、DataSource

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let userInfo = realm.objects(Users.self)
        return userInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MyTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MyTableViewCell
        let realm = try! Realm()
        let user = realm.objects(Users.self).sorted(byKeyPath: "UserName",ascending: true)
        
        for userInfo in user {
            self.usersNameTmp.append(userInfo.UserName)
            self.userEmailTmp.append(userInfo.UserEmail)
            self.userPasswordTmp.append(userInfo.UserPassword)
        }
        
        if (user.count > 0) {
            cell.userNameLabel.text = usersNameTmp[indexPath.row]
        }
        return cell
    }
    
    // 右滑編輯
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "編輯") { (action,sourceView, completeHandler) in
            self.userIndexPathRow = indexPath.row
            self.userEditing = true
            self.SaveDataButton.setTitle("更新使用者名稱", for: .normal)
            let realm = try! Realm()
            let updateUser = realm.objects(Users.self).sorted(byKeyPath: "updateTime", ascending: true)
            self.UserNameTextField.text = updateUser[self.userIndexPathRow].UserName
            self.PasswordTextField.text = updateUser[self.userIndexPathRow].UserPassword
            self.EmailTextField.text = updateUser[self.userIndexPathRow].UserEmail
            self.userPrimaryKey = updateUser[self.userIndexPathRow].UserID
            completeHandler(true)
        }
        editAction.backgroundColor = UIColor(red: 0.0/255.0, green: 127.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let leadingSwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [editAction])
        return leadingSwipeActionsConfiguration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "刪除") { (action, sourceView,completeHandler) in
            self.userIndexPathRow = indexPath.row
            self.getUserPrimaryKey()
            let realm = try! Realm()
            let deleteUser = realm.objects(Users.self).filter("UserID = '\(self.userPrimaryKey!)'").first
            try! realm.write {
                realm.delete(deleteUser!)
                self.userReloadData(keyPath: "updateTime", ascending: true)
            }
            completeHandler(true)
        }
        let trailingSwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return trailingSwipeActionsConfiguration
    }
}
