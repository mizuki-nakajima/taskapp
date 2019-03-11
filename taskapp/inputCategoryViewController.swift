//
//  inputCategoryViewController.swift
//  taskapp
//
//  Created by Nakajima Mizuki on 2019/03/10.
//  Copyright © 2019 Nakajima Mizuki. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class inputCategoryViewController: UIViewController {
    
 @IBOutlet weak var newCategoryTextField: UITextField!
    
    var categoryClass: Category!
    //var categoryClass: Category!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        
        //newCategoryTextField.text = categoryClass.categoryName
        
    }
    
    //遷移する際に、画面が非表示になるとき呼ばれる
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            print(newCategoryTextField)
            print(categoryClass)
            self.categoryClass.categoryName = self.newCategoryTextField.text!
            self.realm.add(self.categoryClass, update: true)
        }
        
        super.viewWillDisappear(animated)
    }
    

    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
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
