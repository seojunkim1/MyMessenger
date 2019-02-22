//
//  NewLoginViewController.swift
//  FirebaseTalk
//
//  Created by Pigman on 09/02/2019.
//  Copyright © 2019 PigAngel. All rights reserved.
//


import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonSignup: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldEmail.delegate = self
        textFieldPassword.delegate = self
        
        try! Auth.auth().signOut()   // 로그아웃
        
        color = remoteConfig["splash_background"].stringValue
        buttonLogin.backgroundColor = UIColor(hex: color)
        buttonSignup.backgroundColor = UIColor(hex: color)
        
        buttonLogin.addTarget(self, action: #selector(eventLogin), for: .touchUpInside)
        buttonSignup.addTarget(self, action: #selector(signupPresent), for: .touchUpInside)
        
        
        
        // 유저 값이 nil이 아닐때 다음 뷰로 넘어감
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil) {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                
                self.present(view, animated: true, completion: nil)
            }
        }
    }
    
    @objc func eventLogin() {
            Auth.auth().signIn(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { (user, err) in
                if(err != nil) {
                    let alert = UIAlertController(title: "에러", message: err.debugDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
    }
    
   

    @objc func signupPresent() {
                let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController  //
                self.present(view, animated: true, completion: nil)
            }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTabBar" {
            let tabBarVC = segue.destination as! UITabBarController
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
        }

