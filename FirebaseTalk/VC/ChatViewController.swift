//
//  ChatViewController.swift
//  FirebaseTalk
//
//  Created by Pigman on 11/02/2019.
//  Copyright © 2019 PigAngel. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    public var destinationUid : String? // 채팅할 대상의 uid 선언
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var myRealTextView: UITextView!
    @IBOutlet weak var myRealTextViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var sendButtonAction: UIButton!
    
    
    var uid: String?
    var chatRoomUid: String?
    var comments : [ChatModel.Comment] = []
    @objc var destinationUserModel : ModelUser?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
        sendButtonAction.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
        self.tabBarController?.tabBar.isHidden = true
        let myTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(myTap)
        
        // xib 파일 등록
        myTableView.register(UINib(nibName: "MyCell", bundle: nil), forCellReuseIdentifier: "myCell")
        myTableView.register(UINib(nibName: "YourCell", bundle: nil), forCellReuseIdentifier: "yourCell")
        
    }
    
    // 옵저버 작동
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 옵저버 없어짐
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func keyboardWillShow(notification: Notification) {
        
        if let keyboardSize: NSValue = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            self.viewBottomConstraint.constant = keyboardSize.cgRectValue.height

        }
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }, completion: {
            (complete) in
            if self.comments.count > 0 {
                self.myTableView.scrollToRow(at: IndexPath(item: self.comments.count - 1 , section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
        self.viewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    
    @objc func dismissKeyboard() {
        
        self.view.endEditing(true)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(self.comments[indexPath.row].uid == uid) {
            let view = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyCell
            view.myMessageTextView.text = self.comments[indexPath.row].message
            
            if let myTime = self.comments[indexPath.row].timestamp {
                view.timeStampLabel.text = myTime.myTodayTime
            }
            
            return view
            
        } else {
            
            let view = tableView.dequeueReusableCell(withIdentifier: "yourCell", for: indexPath) as! YourCell
            
            view.yourNameLabel.text = destinationUserModel?.userName
            view.yourMessageTextView.text = self.comments[indexPath.row].message
        
            let myUrl = URL(string:(self.destinationUserModel?.profileImageUrl)!)
            view.yourProfileImgView.layer.cornerRadius = view.yourProfileImgView.frame.width / 2
            view.yourProfileImgView.layer.masksToBounds = true
            view.yourProfileImgView.kf.setImage(with: myUrl)
            
            
            if let myTime = self.comments[indexPath.row].timestamp {
                view.timeStampLabel.text = myTime.myTodayTime
            }
            
            
    }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    

    // 채팅방 생성
    @objc func createRoom() {
        let createRoomInfo:Dictionary<String,Any> = [ "users" : [
            
            uid! : true,
            destinationUid! : true
            ]
        ]
        
        if (chatRoomUid == nil) {
            self.sendButtonAction.isEnabled = false
            Database.database().reference().child("chatrooms").childByAutoId().setValue(createRoomInfo, withCompletionBlock: { (err, ref) in
                if(err == nil) {
                    self.checkChatRoom()
                }
            })
            
        } else {
            
            let myValue : Dictionary<String,Any> =  [
                    "uid" : uid!,
                    "message" : myRealTextView.text!,
                    "timestamp" : ServerValue.timestamp()
            ]
            Database.database().reference().child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(myValue, withCompletionBlock: { (err, ref) in
                self.myRealTextView.text! = ""
            })
        }
    }
    
    // 중복되는 채팅방 제거
    func checkChatRoom() {
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                if let chatRoomDic = item.value as? [String:AnyObject] {
                    
                    let myChatModel = ChatModel(JSON: chatRoomDic)
                    if(myChatModel?.users[self.destinationUid!] == true) {
                        self.chatRoomUid = item.key
                        self.sendButtonAction.isEnabled = true
                        self.getMessageList()
                        self.getDestinationInfo()
                    }
                }
            }
        })
    }
    
    // 채팅 상대방 유저정보 가져오기
    func getDestinationInfo() {
        
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value, with: { (datasnapshot) in
            
            self.destinationUserModel = ModelUser()
            
            self.destinationUserModel = (datasnapshot.value as! NSDictionary) ["destinationUserModel"] as? ModelUser
            
            print(self.destinationUserModel)
            // 👹datasnapshot.value를 딕셔너리 값으로 가져오면, 거기서 objectforkey username이랑 profileulriMage 값을 뽑아서 새롭게 선언한 ModelUser()에 값을 넣어주는거임. 넣어준 값을 거기서 프로퍼티로 접근해서 뽑아서 쓰면 됨.
            
// datasnapshot으로 넘어온 값을 딕셔너리로 만든다음에 넘겨주면, 키가 세팅이 돼서 오브젝트가 만들어짐.
            
            self.getMessageList()
            
        })
        
    }
    
    // // 메세지 리스트 가져오기
    func getMessageList() {
        Database.database().reference().child("chatrooms").child(self.chatRoomUid!).child("comments").observe(DataEventType.value, with: { (datasnapshot) in
            
            self.comments.removeAll()
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {

                let myComment = ChatModel.Comment(JSON: (item.value as! NSMutableDictionary) as! [String : Any])
                
                self.comments.append(myComment!)
            }
            
            self.myTableView.reloadData()
            
            // 말풍선과 스크롤바가 같이 내려가게 하기
            if self.comments.count > 0 {
                self.myTableView.scrollToRow(at: IndexPath(item: self.comments.count - 1 , section: 0), at: .bottom, animated: true)

            }
            
        })
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.contentSize.height <= 40 {
            myRealTextViewHeight.constant = 40
            
        } else if textView.contentSize.height >= 100 {
            myRealTextViewHeight.constant = 100
        } else {
            myRealTextViewHeight.constant = textView.contentSize.height
        }
    }
    
    

    
}
extension Int {
    
    var myTodayTime : String {
        let myDateFormatter = DateFormatter()


        myDateFormatter.dateStyle = .medium
        myDateFormatter.timeStyle = .medium
        myDateFormatter.dateFormat = "M월 d일 h:mm a"
        let date = Date()
        return myDateFormatter.string(from: date)
    }
}
