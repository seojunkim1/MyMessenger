//
//  AccountViewController.swift
//  FirebaseTalk
//
//  Created by Pigman on 18/02/2019.
//  Copyright © 2019 PigAngel. All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {

    @IBOutlet weak var conditionMessageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conditionMessageButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        conditionMessageButton.layer.shadowColor = UIColor.black.cgColor
        conditionMessageButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        conditionMessageButton.layer.shadowRadius = 5
        conditionMessageButton.layer.shadowOpacity = 1.0
       
    }
    
    @objc func showAlert() {
        
        let myAlertController = UIAlertController(title: "상태 메세지", message: nil, preferredStyle: .alert)
        myAlertController.addTextField { (textfield) in
            textfield.placeholder = "상태메세지를 입력해주세요"
        }
        myAlertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let myTextField = myAlertController.textFields?.first {
                let myDictionary = ["comment":myTextField.text!]
                let myUid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(myUid!).updateChildValues(myDictionary)
            }
        }))
        myAlertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            
        }))
        
        self.present(myAlertController, animated: true, completion: nil)
    }
    

    

}
