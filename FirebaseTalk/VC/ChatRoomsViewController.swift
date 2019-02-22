//
//  ChatRoomsViewController.swift
//  FirebaseTalk
//
//  Created by Pigman on 13/02/2019.
//  Copyright © 2019 PigAngel. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


class ChatRoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var uid : String!
    var chatrooms : [ChatModel]! = []
    @objc var myUserModel : ModelUser?
    var destinationUsers = [String]()
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uid = Auth.auth().currentUser?.uid
        self.getChatRoomsList()
        
        
    }
    
    func getChatRoomsList() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            self.chatrooms.removeAll()
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                
                
                
                if let chatRoomsDictionary = item.value as? [String:AnyObject] {
                    let myChatModel = ChatModel(JSON: chatRoomsDictionary)
                    self.chatrooms.append(myChatModel!)
                }
            }
            self.myTableView.reloadData()
            
        })
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatrooms.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as! CustomCell
        
        
        
        var destinationUid :String?
        
        for item in chatrooms[indexPath.row].users {
            if(item.key != self.uid) {
                destinationUid = item.key
                destinationUsers.append(destinationUid!)
            }
        }
        
        Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: .value, with: {
            (datasnapshot) in
            self.myUserModel = ModelUser()
            
            
            self.myUserModel = (datasnapshot.value as! NSDictionary) ["myUserModel"] as? ModelUser
            
            print("\(self.myUserModel!) : Where is nil?")
            cell.titleLabel.text = self.myUserModel?.userName
            
            
            print(self.myUserModel!)
            print(self.myUserModel?.profileImageUrl!)
            let myURL = URL(string: (self.myUserModel?.profileImageUrl)!)

            cell.imgView.layer.cornerRadius = cell.imgView.frame.width / 2
            cell.imgView.layer.masksToBounds = true
            cell.imgView.kf.setImage(with: myURL)
            
            
            // 마지막으로 보낸 메세지를 나타내기
            let lastMessageKey = self.chatrooms[indexPath.row].comments.keys.sorted(){$0 > $1}
            cell.lastMessageLabel.text = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.message
            let myUnixTime = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.timestamp
            cell.timeStampLabel.text = myUnixTime?.myTodayTime
            
            
        })
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let myDestinationUid = self.destinationUsers[indexPath.row]
        let myView = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        myView.destinationUid = myDestinationUid
        self.navigationController?.pushViewController(myView, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }
    
    
}

class CustomCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var timeStampLabel: UILabel!
    
}
