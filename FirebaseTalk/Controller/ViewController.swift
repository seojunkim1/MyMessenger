//
//  ViewController.swift
//  FirebaseTalk
//
//  Created by PigAngel on 07/02/2019.
//  Copyright © 2019 PigAngel. All rights reserved.
//

import UIKit
import SnapKit
import Firebase


class ViewController: UIViewController {
    
    var box = UIImageView()
    var remoteConfig: RemoteConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in // TimeInterval(0) -> 앱을 켤때마다 요청
            if status == .success {
                print("컴파일 성공!")
                self.remoteConfig.activateFetched()
            } else {
                print("컴파일 실패!")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.displayWelcome()
        }
        
        self.view.addSubview(box)
        box.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
        }
        box.image = UIImage(named: "talking_icon")
        self.view.backgroundColor = UIColor(hex: "#add8e6")
        box.widthAnchor.constraint(equalToConstant: 150).isActive = true
        box.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        
    }
    
    func displayWelcome() {
        let color = remoteConfig["splash_background"].stringValue
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if (caps) { // caps값이 true이면 alert 나타남
            let alert = UIAlertController(title: "공지사항", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
                exit(0)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {    // caps값이 false이면 메인뷰 나타남
            
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(loginVC, animated: false, completion: nil)
            
        }
        self.view.backgroundColor = UIColor(hex: color!)
    }
}

extension UIColor {     // 16진수 컬러
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        
        
        scanner.scanLocation = 1
        // 1부터 설정해줘야 #aabbcc 형식의 컬러코드를 제대로 호출함
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

let color = UIColor(hex: "ff0000")

