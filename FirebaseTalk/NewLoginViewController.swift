//
//  NewLoginViewController.swift
//  FirebaseTalk
//
//  Created by Pigman on 09/02/2019.
//  Copyright © 2019 PigAngel. All rights reserved.
//


import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var textFieldEmail: UITextField!
    
    @IBOutlet weak var textFieldPassword: UITextField!
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonSignup: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()      // Firebase RemoteConfig 연결
    var color: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! Auth.auth().signOut()   // 로그아웃 시키는 코드. Firebase는 자동으로 로그인 되어있기 때문에 초기화 해주는곳에서 로그아웃을 해줘야함.
        
        color = remoteConfig["splash_background"].stringValue   // ViewController에서 선언해준 컬러값을 가져온거임. 이 코드를 통해 Firebase에서 원격으로 컬러를 조정할 수 있음.
        
        buttonLogin.backgroundColor = UIColor(hex: color)
        buttonSignup.backgroundColor = UIColor(hex: color)   // 이렇게 해주면 원격(Firebase에서)으로 컬러 조정할 수 있음.
        
        buttonLogin.addTarget(self, action: #selector(eventLogin), for: .touchUpInside)
        buttonSignup.addTarget(self, action: #selector(signupPresent), for: .touchUpInside)
        
        
        
        // 다음화면 넘어가는 이벤트. user 값이 nil이 아닐때 다음 화면으로 넘어가는 코드.
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil) {   // 유저값이 nil이 아닐때 다음 화면으로 넘어가기.
                let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                
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
                let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
                self.present(view, animated: true, completion: nil)
            }
    
        }

