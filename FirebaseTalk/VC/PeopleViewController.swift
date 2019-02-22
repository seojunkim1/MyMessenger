//
//  PeopleViewController.swift
//  FirebaseTalk
//
//  Created by Pigman on 10/02/2019.
//  Copyright © 2019 PigAngel. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Kingfisher


class PeopleViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var myArray : [ModelUser] = []
    var myTableview : UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tabBar = self.tabBarController?.tabBar else {return}

        tabBar.tintColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        tabBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tabBar.unselectedItemTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        myTableview = UITableView()
        myTableview.dataSource = self
        myTableview.delegate = self
        myTableview.register(PeopleViewTableCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(myTableview)
        myTableview.snp.makeConstraints { (make) in
            make.top.equalTo(view)
            make.bottom.left.right.equalTo(view)
        }
        
        
        Database.database().reference().child("users").observe(DataEventType.value, with: { (snapShot) in
            
            self.myArray.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapShot.children {
                let fbChild = child as! DataSnapshot
                let userModel = ModelUser()

                userModel.setValuesForKeys(fbChild.value as! [String : Any])
                
                if(userModel.uid == myUid) {
                    continue
                }
                
                self.myArray.append(userModel)
                
            }
            DispatchQueue.main.async {
                self.myTableview.reloadData()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PeopleViewTableCell
        
        let myImageView = cell.myImgView!
        
        myImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(cell).offset(10)
            make.height.width.equalTo(50)
        }
        
        let myUrl = URL(string: myArray[indexPath.row].profileImageUrl!)
        
        myImageView.layer.cornerRadius = 50 / 2
        myImageView.layer.masksToBounds = true
        myImageView.kf.setImage(with: myUrl)
        
        
        let myLabel = cell.myLabel!
        myLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(cell)
            make.left.equalTo(myImageView.snp.right).offset(20)
        }
        myLabel.text = myArray[indexPath.row].userName
        
        let commentLabel = cell.commentLabel!
        commentLabel.snp.makeConstraints { (make) in
            make.right.equalTo(cell).offset(-10)
            make.centerY.equalTo(cell)
        }
        if let statusMessage = myArray[indexPath.row].comment {
            commentLabel.text = statusMessage
        }
        
        return cell
    }
    
    // row 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        view?.destinationUid = self.myArray[indexPath.row].uid
        
        self.navigationController?.pushViewController(view!, animated: true)    
    }
}

class PeopleViewTableCell : UITableViewCell {
    
    var myImgView: UIImageView! = UIImageView()
    var myLabel: UILabel! = UILabel()
    var commentLabel: UILabel! = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(myImgView)
        self.addSubview(myLabel)
        self.addSubview(commentLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
