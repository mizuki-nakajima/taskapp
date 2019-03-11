//
//  InputViewController.swift
//  taskapp
//
//  Created by Nakajima Mizuki on 2019/03/08.
//  Copyright © 2019 Nakajima Mizuki. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    //カテゴリー表示用テーブル
    @IBOutlet weak var tableView: UITableView!
    
    
    var task: Task!
    //var category: Task!
    let realm = try! Realm()
    
    // 選択中のカテゴリ
    var selectedCategory: Category?
    
    //カテゴリー用DB
    // 作成順\順でソート：降順
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "categoryId", ascending: false)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false //tableViewのdidSelectが呼ばれないので追加
        self.view.addGestureRecognizer(tapGesture)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        selectedCategory = task.category //追加
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    
    //画面遷移時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputCategoryViewController:inputCategoryViewController = segue.destination as! inputCategoryViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputCategoryViewController.categoryClass = categoryArray[indexPath!.row]
        } else {
            let categoryClass = Category()
            
            let allCategory = realm.objects(Category.self)
            if allCategory.count != 0 {
                categoryClass.categoryId = allCategory.max(ofProperty: "categoryId")! + 1
            }
            
            inputCategoryViewController.categoryClass = categoryClass
        }
        
    }
    
    
    //遷移する際に、画面が非表示になるとき呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            //   let category = categoryArray[indexPath.row]
            self.task.date = self.datePicker.date
            self.task.category = selectedCategory
            self.realm.add(self.task, update: true)
        }
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //カテゴリー用セルの内容を返すメソッド
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let categoryCell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // categoryCellに値を設定する.
        let categoryClass = categoryArray[indexPath.row]
        categoryCell.textLabel?.text = categoryClass.categoryName
        
        // categoryCell.detailTextLabel?.text = dateString
        
        return categoryCell
    }
    
    //セルを選択したときに実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(categoryArray[indexPath.row].categoryName)
        // self.task.category = categoryName
        selectedCategory = categoryArray[indexPath.row]
    }
    
    
    // タスクのローカル通知を登録する
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        
        
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
}
