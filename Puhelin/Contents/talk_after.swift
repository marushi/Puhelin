//
//  talk_after.swift
//  Puhelin
//
//  Created by 丸子司恩 on 2020/04/14.
//  Copyright © 2020 shion.maruko. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView
import AudioToolbox
import XLPagerTabStrip

class talk_after: UIViewController ,IndicatorInfoProvider{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nonarray: UILabel!
    
    @objc dynamic static var count:Int = 0
    
    var UserArray : [ChatRoomData] = []
    var UserDataArray:[MyProfileData] = []
    var nonReadMesArray:[String:Int] = [:]
    var listener2: ListenerRegistration!
    var adViewType:Int? = 0
    var itemInfo: IndicatorInfo = "通話後"
    var refreshControl = UIRefreshControl()
    
    let userDefaults = UserDefaults.standard
    let gradientLayer: CAGradientLayer = CAGradientLayer()
       

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.titleTextAttributes = [
        // 文字の色
            .foregroundColor: UIColor.black
        ]

        //セルの登録
        let nib = UINib(nibName: "TalkCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TalkCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.isHidden = true
        
        //下にスワイプした時に更新処理
        refreshControl.addTarget(self, action: #selector(self.refreshTable), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
    }
        
    //したにスワイプした時の更新処理
    @objc func refreshTable() {
        // 更新処理
        AudioServicesPlaySystemSound(1520)
        self.tableView.reloadData()
        refreshControl.endRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //通話後のデータ取得
        if listener2 == nil{
        // listener未登録なら、登録してスナップショットを受信する
            let Ref = Firestore.firestore().collection(Const.MatchingPath).whereField("\(userDefaults.integer(forKey: "gender"))", isEqualTo: userDefaults.string(forKey: "uid")!)
            listener2 = Ref.addSnapshotListener() { (querySnapshot, error) in
            if let error = error {
                print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                return
            }
            let sortedByReleaseDate: SortDescriptor<ChatRoomData> = { $0.LastRefreshTime!.dateValue() > $1.LastRefreshTime!.dateValue() }
            self.UserArray.sort(by: sortedByReleaseDate)
            self.UserArray = querySnapshot!.documents.map { document in
                print("DEBUG_PRINT: document取得 \(document.documentID)")
                let userData = ChatRoomData(document: document)
                return userData
                }
                self.getData()
                self.nonReadMesNum()
                self.tableView.reloadData()
                if self.UserArray.count == 0 {
                    self.tableView.isHidden = true
                    self.nonarray.isHidden = false
                }else{
                    self.tableView.isHidden = false
                    self.nonarray.isHidden = true
                }
            }
        }
    }
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    //----------配列の並び替え用---------
    typealias SortDescriptor<Value> = (Value, Value) -> Bool
    func combine<Value>(sortDescriptors: [SortDescriptor<Value>]) -> SortDescriptor<Value> {

        return { lhs, rhs in
            for isOrderedBefore in sortDescriptors {
                if isOrderedBefore(lhs,rhs) { return true }
                if isOrderedBefore(rhs,lhs) { return false }
            }
            return false
        }
    }
    //--------------------------------
    
    func getData() {
        //ユーザー情報
        let num = self.UserArray.count
        self.UserDataArray = []
        if num != 0 {
            for userdata in UserArray{
                var ref:DocumentReference!
                if self.userDefaults.integer(forKey: "gender") == 1 {
                    ref = Firestore.firestore().collection(UserDefaultsData.init().opDB!).document(userdata.female!)
                }else{
                    ref = Firestore.firestore().collection(UserDefaultsData.init().opDB!).document(userdata.male!)
                }
                ref.getDocument(){(data,error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    let setData:MyProfileData = MyProfileData(document: data!)
                    self.UserDataArray.append(setData)
                    if userdata == self.UserArray.last {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    func nonReadMesNum() {
        let num = self.UserArray.count
        self.nonReadMesArray = [:]
        if num != 0 {
            for userdata in UserArray{
                var opUid:String?
                if self.userDefaults.integer(forKey: "gender") == 1 {
                    opUid = userdata.female
                }else{
                    opUid = userdata.male
                }
                let Ref = Firestore.firestore().collection(Const.MatchingPath).document(userdata.roomId!).collection(Const.MessagePath).whereField("readed", isEqualTo: false).whereField("senderId", isEqualTo: opUid!)
                Ref.getDocuments() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    let num = querySnapshot?.count
                    self.nonReadMesArray[opUid!] = num
                    }
                }
            }
        }    
}

extension talk_after:UITableViewDataSource,UITableViewDelegate{
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserArray.count
    }
    
    //セルの中身
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let TalkCell = tableView.dequeueReusableCell(withIdentifier: "TalkCell", for: indexPath) as! TalkCell
        var data:String?
        if self.userDefaults.integer(forKey: "gender") == 1 {
            data = self.UserArray[indexPath.row].female
            if let num = self.nonReadMesArray[data!] {
                TalkCell.noneReadedMes = num
            }
            for i in self.UserDataArray {
                if i.uid == data {
                    TalkCell.profileData = i
                }
            }
        }else{
            data = self.UserArray[indexPath.row].male
            if let num = self.nonReadMesArray[data!] {
                TalkCell.noneReadedMes = num
            }
            for i in self.UserDataArray {
                if i.uid == data {
                    TalkCell.profileData = i
                }
            }
        }
        TalkCell.setData(UserArray[indexPath.row])
        TalkCell.selectionStyle = .none
        TalkCell.photo.tag = indexPath.row + 1
        let avatarImage = TalkCell.viewWithTag(indexPath.row + 1) as! UIImageView
        let avatarImageTap = UITapGestureRecognizer(target: self, action: #selector(tappedAvatar))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(avatarImageTap)
        return TalkCell
        
    }
    
    //セルを選択した時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ChatRoom2 = self.storyboard?.instantiateViewController(identifier: "ChatRoom2") as! ChatRoom2
        ChatRoom2.setData(UserArray[indexPath.row])
        navigationController?.pushViewController(ChatRoom2, animated: true)
    }
    
    //画像をタップ
    @objc func tappedAvatar(_ sender:UITapGestureRecognizer){
        let image = sender.view as? UIImageView
        let Profile = self.storyboard?.instantiateViewController(identifier: "Profile") as! Profile
        if userDefaults.integer(forKey: "gender") == 1 {
            Profile.setData(UserArray[image!.tag - 1].female!)
        }else{
            Profile.setData(UserArray[image!.tag - 1].male!)
        }
        Profile.ButtonMode = 5
        present(Profile,animated: true,completion: nil)
    }
    
    //バッチ処理
    @objc func TabbarButch(){
        let tabItem = self.tabBarController?.tabBar.items![2]
        tabItem?.badgeValue = ""
    }
}
