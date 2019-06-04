//
//  SignupViewController.swift
//  FirebaseTalk
//
//  Created by Angelpig on 07/02/2019.
//  Copyright © 2019 PigAngel. All rights reserved.
//

import UIKit
import Firebase

class SignupViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signupButtonOutlet: UIButton!
    @IBOutlet weak var cancelButtonOutlet: UIButton!
    
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        nameTextField.delegate = self
        passwordTextField.delegate = self
        
        
        color = remoteConfig["splash_background"].stringValue

        signupButtonOutlet.backgroundColor = UIColor(hex: color!)
        cancelButtonOutlet.backgroundColor = UIColor(hex: color!)
        
        signupButtonOutlet.addTarget(self, action: #selector(signupEvent), for: .touchUpInside)
        cancelButtonOutlet.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
        
        emailTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        
        emailErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))  // 이미지 선택
        

    }
    
    // 회원가입 뷰 UI
    @objc func textFieldEdited(textField: UITextField) {
        
        if textField == emailTextField {
            
            if isValidEmail(email: textField.text) == true {
                emailErrorLabel.isHidden = true
                
            } else {
                if emailTextField.text?.count == 0 {
                    emailErrorLabel.isHidden = true
                } else {
                    emailErrorLabel.isHidden = false
                }
            }
            
        } else if textField == passwordTextField {
            
            if isValidPassword(pw: textField.text) == true{
                passwordErrorLabel.isHidden = true
                
            } else {
                if passwordTextField.text?.count == 0 {
                    passwordErrorLabel.isHidden = true
                } else {
                passwordErrorLabel.isHidden = false
                }
            }
        }
    }
    
    // 이미지 구현
    @objc func imagePicker() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // 선택한 이미지를 뷰에 담아줌
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imgView.image = info[.originalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc func signupEvent() {
        
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error ) in
            let uid = user?.user.uid
            let image = self.imgView.image?.jpegData(compressionQuality: 0.1)
            let imageStorage = Storage.storage().reference().child("userImages").child(uid!)
            
            imageStorage.putData(image!, metadata: nil, completion: { (data, error) in
                
                imageStorage.downloadURL(completion: { (url, error) in
                    let values = ["userName":self.nameTextField.text!,"profileImageUrl":url?.absoluteString, "uid":Auth.auth().currentUser?.uid]    // 
                    Database.database().reference().child("users").child(uid!).setValue(values, withCompletionBlock: { (err, ref) in
                        
                        if (err == nil) {
                            self.cancelEvent()
                        }
                    })
                })
                
            })
        }
    }
    @objc func cancelEvent() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // 이메일 정규식
    func isValidEmail(email: String?) -> Bool {
        guard email != nil else { return false }
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    func isValidPassword(pw: String?) -> Bool {
        if let hasPassword = pw {
            if hasPassword.count < 8 {
                return false
            }
        }
        return true
    }


}
