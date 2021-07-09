//
//  AddNewItemViewController.swift
//  P1ShoppingList
//
//  Created by naoki-mrnk on 2021/07/09.
//  Copyright © 2021 naoki-mrnk. All rights reserved.
//

import UIKit
import RealmSwift

class AddNewItemViewController: UIViewController {
    
    // MARK: - Properties
    let realmManager = RealmManager.shared
    var items: Results<Item>!
    
    // MARK: - IBOutlet
    @IBOutlet private weak var itemListTableView: UITableView!
    @IBOutlet private weak var inputNewItemTextField: UITextField!
    
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupItemListTableView()
        
        items = realmManager.realm.objects(Item.self)
        itemListTableView.reloadData()
        
        setupNotification()
//        tapGesture()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        itemListTableView.endEditing(true)
    }
    
    func tapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.itemListTableView.addGestureRecognizer(tapGesture)
    }
    /// 画面をタップした時にキーボードを閉じる処理
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification: )), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// キーボードが出た時にてtextFieldを上げる処理
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            } else {
                let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                self.view.frame.origin.y -= suggestionHeight
            }
        }
    }
    
    /// キーボードが閉まった時に元に戻す処理
    @objc func keyboardWillHide() {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func setupItemListTableView() {
        itemListTableView.delegate = self
        itemListTableView.dataSource = self
    }
    
    // MARK: - IBAction
    @IBAction func tappedAddItemButton(_ sender: UIButton) {
        // TextFieldが空か判定
        let isEmpty = inputNewItemTextField.text?.isEmpty ?? false
        
        if isEmpty {
            let alert = UIAlertController(title: "TextField is empty.", message: "Please enter a TextField", preferredStyle: UIAlertController.Style.alert)
            
            let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel, handler: {
                (action: UIAlertAction!) -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
        } else {
            
            let itemName = inputNewItemTextField.text!
            // 入力された値がItemDBに保存されているか判定
            let result = items.filter("itemName == '\(itemName)'")
            if (result.count == 0) {
                let item = Item()
                try! realmManager.realm.write {
                    item.itemName = itemName
                }
                realmManager.writeDB(DB: item)
                
                let shoppingItem = ShoppingItem()
                try! realmManager.realm.write {
                    shoppingItem.itemID = item.itemID
                    shoppingItem.createAt = Date()
                }
                realmManager.writeDB(DB: shoppingItem)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.itemListTableView.reloadData()
                
                    let alert = UIAlertController(title: "Registration complete.", message: "", preferredStyle: UIAlertController.Style.alert)
                    
                    let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel, handler: {
                        (action: UIAlertAction!) -> Void in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                    alert.addAction(okButton)
                    self.present(alert, animated: true, completion: nil)
                }
                
            } else {
                let alert = UIAlertController(title: "\(itemName) has already been registered.", message: "Please select from the list", preferredStyle: UIAlertController.Style.alert)
                
                let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel, handler: {
                    (action: UIAlertAction!) -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                alert.addAction(okButton)
                present(alert, animated: true, completion: nil)
            }
        }
    }
}


// MARK: - UITableViewDataSource
extension AddNewItemViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = items  else { return 0 }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        let object = items[indexPath.row]
        cell.textLabel?.text = object.itemName
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AddNewItemViewController: UITableViewDelegate {
    
    // cellで選択したものを追加する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tap")
        let item = items[indexPath.row]
        
        guard let shoppingList = self.realmManager.realm.objects(ShoppingItem.self).filter("itemID == '\(item.itemID)'").last else {
            return
        }
        
        let isDelete = shoppingList.boughtAt == nil ? false : true
        if isDelete {
            let shoppingItem = ShoppingItem()
            shoppingList.itemID = item.itemID
            try! realmManager.realm.write {
                shoppingList.itemID = item.itemID
                shoppingList.createAt = Date()
            }
            realmManager.writeDB(DB: shoppingItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.itemListTableView.reloadData()
                
                let alert = UIAlertController(title: "Registration complete.", message: "", preferredStyle: UIAlertController.Style.alert)
                
                let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel, handler: {
                    (action: UIAlertAction!) -> Void in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                alert.addAction(okButton)
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: "It is already on the ShoppingList.", message: "Please return top page", preferredStyle: UIAlertController.Style.alert)
            
            let okButton = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel, handler: {
                (action: UIAlertAction!) -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.dismiss(animated: true, completion: nil)
                }
            })
            alert.addAction(okButton)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
