import UIKit
import PKHUD
import Firebase


class StartScreen: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    let userDefaults = UserDefaults.standard
    let fromAppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let imageNameArray = ["Ligar","Ligar3","Ligar4","Ligar5","Ligar6","Ligar7","Ligar8","Ligar9","Ligar10","Ligar11","Ligar12","Ligar13","Ligar14","Ligar15","Ligar16","Ligar17"]
    
    var selectLis :ListenerRegistration!
    var downLis :ListenerRegistration!
    var goodLis :ListenerRegistration!
    var footLis :ListenerRegistration!
    var recieveLis :ListenerRegistration!
    var userData:MyProfileData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    override func viewDidAppear(_ animated: Bool) {
        self.LaunchAction()
    }
    
    func LaunchAction(){
        //ログイン　→ Yes
        if self.userDefaults.string(forKey: "uid") != nil{
            // ログイン時の処理
            let uid = self.userDefaults.string(forKey: "uid")
            //情報を取ってくる
            let ref = Firestore.firestore().collection(Const.FemalePath).document(uid!)
            ref.getDocument(){(document,error) in
                if let error = error {
                    print(error)
                    self.removeUserDefaults()
                    if Auth.auth().currentUser != nil {
                        do {
                            try Auth.auth().signOut()
                        } catch let signOutError as NSError {
                          print ("Error signing out: %@", signOutError)
                        }
                        let phoneLogin = self.storyboard?.instantiateViewController(identifier: "LoginTop")
                        phoneLogin!.modalTransitionStyle = .crossDissolve
                        HUD.hide()
                        self.present(phoneLogin!,animated: true, completion: nil)
                    }
                    return
                }
                if document == nil {
                    self.loginFunction()
                }
                self.userData = MyProfileData(document: document!)
                if self.userData?.signupDate == nil {
                    let Ref = Firestore.firestore().collection(Const.MalePath).document(uid!)
                    Ref.getDocument(){(document2,error) in
                        if let error = error{
                            print(error)
                            self.removeUserDefaults()
                            if Auth.auth().currentUser != nil {
                                do {
                                    try Auth.auth().signOut()
                                } catch let signOutError as NSError {
                                  print ("Error signing out: %@", signOutError)
                                }
                                let phoneLogin = self.storyboard?.instantiateViewController(identifier: "LoginTop")
                                phoneLogin!.modalTransitionStyle = .crossDissolve
                                HUD.hide()
                                self.present(phoneLogin!,animated: true, completion: nil)
                            }
                            return
                        }
                        self.userData = MyProfileData(document: document2!)
                        //性別を登録
                        self.userDefaults.set(1, forKey: "gender")
                        self.loginFunction()
                    }
                }else{
                    //性別を登録
                    self.userDefaults.set(2, forKey: "gender")
                    self.loginFunction()
                }
                
            }
        //ログイン　→ No
        }else{
            let phoneLogin = self.storyboard?.instantiateViewController(identifier: "LoginTop")
            phoneLogin!.modalTransitionStyle = .crossDissolve
            self.present(phoneLogin!,animated: true, completion: nil)
        }
    }
    
    func removeUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
    }
    
    //情報の有無
    func loginFunction(){
        //情報　→ 無し
        if userData?.signupDate == nil {
            //ニックネーム入力画面に飛ぶ
            let NavigationController = self.storyboard?.instantiateViewController(identifier: "NavigationController")
            HUD.hide()
            self.present(NavigationController!,animated: true,completion: nil)
        }else {
            //---データ用のスナップショットを登録する---
            //データがある場合(過去にログイン済みの場合）
            //課金データと本人確認データをuserdefaultsに入れる
            //いいね数
            if let remaingood:Int = self.userData?.remainGoodNum{
                self.userDefaults.set(remaingood, forKey: UserDefaultsData.remainGoodNum)
            }
            //いいね制限
            if let goodLimit:Int = self.userData?.goodLimit{
                self.userDefaults.set(goodLimit, forKey: UserDefaultsData.goodLimit)
            }
            //マッチング券
            if let matchingTicket:Int = self.userData?.matchingTicket{
                self.userDefaults.set(matchingTicket, forKey: UserDefaultsData.matchingNum)
            }
            //回復券
            if let recoveryTicket:Int = self.userData?.recoveryTicket{
                self.userDefaults.set(recoveryTicket, forKey: UserDefaultsData.ticketNum)
            }
            //本人確認
            if let ident:Int = self.userData?.identification{
                self.userDefaults.set(ident, forKey: UserDefaultsData.identification)
            }
            //selectData
            if self.selectLis == nil {
                let selectRef = Firestore.firestore().collection(UserDefaultsData.init().myDB!).document(self.userDefaults.string(forKey: "uid")!).collection(Const.SelectUsers).order(by: "date",descending: true)
                self.selectLis = selectRef.addSnapshotListener() {(querysnapshot,error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    self.fromAppDelegate.selectUserData = (querysnapshot?.documents.map { document in
                    print("DEBUG_PRINT: document取得 \(document.documentID)")
                    let userData = FootUsers(document: document)
                    return userData
                })!
                let num = self.fromAppDelegate.selectUserData.count
                if num != 0 {
                    self.fromAppDelegate.selectIdArray = []
                    for i in 0...num - 1{
                    self.fromAppDelegate.selectIdArray.append(self.fromAppDelegate.selectUserData[i].uid!)
                
                    }
                    }
            //downData
            if self.downLis == nil {
                let downRef = Firestore.firestore().collection(UserDefaultsData.init().myDB!).document(self.userDefaults.string(forKey: "uid")!).collection(Const.DownUsers).order(by: "date",descending: true)
                self.downLis = downRef.addSnapshotListener() {(querysnapshot,error) in
                if let error = error {
                    print(error)
                    return
                    }
                    self.fromAppDelegate.downUserData = (querysnapshot?.documents.map { document in
                     
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = FootUsers(document: document)
                        return userData
                        }
                        )!
                    let num = self.fromAppDelegate.downUserData.count
                    if num != 0 {
                        for i in 0...num - 1{
                            self.fromAppDelegate.downIdArray.append(self.fromAppDelegate.downUserData[i].uid!)
                        }
                    }
            //goodData
            if self.goodLis == nil {
            
                let goodRef = Firestore.firestore().collection(UserDefaultsData.init().myDB!).document(self.userDefaults.string(forKey: "uid")!).collection(Const.GoodPath).order(by: "date",descending: true)
                self.goodLis = goodRef.addSnapshotListener() {(querysnapshot,error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    self.fromAppDelegate.goodUserData = (querysnapshot?.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = goodData(document: document)
                        return userData
                        }
                        )!
                    let num = self.fromAppDelegate.goodUserData.count
                    if num != 0 {
                        for i in 0...num - 1{
                            self.fromAppDelegate.goodIdArray.append(self.fromAppDelegate.goodUserData[i].uid!)
                        }
                    }
            //footData
            if self.footLis == nil {
            
                let footRef = Firestore.firestore().collection(UserDefaultsData.init().myDB!).document(self.userDefaults.string(forKey: "uid")!).collection(Const.FoorPrints).order(by: "date",descending: true)
                self.footLis = footRef.addSnapshotListener() {(querysnapshot,error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    self.fromAppDelegate.FootUserData = (querysnapshot?.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let userData = FootUsers(document: document)
                        return userData
                        }
                        )!
                    let num = self.fromAppDelegate.FootUserData.count
                    if num != 0 {
                        for i in 0...num - 1{
                            self.fromAppDelegate.footIdArray.append(self.fromAppDelegate.FootUserData[i].uid!)
                        }
                    }
                    if self.recieveLis == nil {
                        let recieveRef = Firestore.firestore().collection(UserDefaultsData.init().myDB!).document(self.userDefaults.string(forKey: "uid")!).collection(Const.ReceiveData).order(by: "date",descending: true)
                        self.recieveLis = recieveRef.addSnapshotListener() {(querysnapshot,error) in
                            if let error = error {
                                print(error)
                                return
                            }
                            self.fromAppDelegate.receiveData = (querysnapshot?.documents.map { document in
                                print("DEBUG_PRINT: document取得 \(document.documentID)")
                                let userData = FootUsers(document: document)
                                return userData
                                }
                                )!
                            let num = self.fromAppDelegate.receiveData.count
                            if num != 0 {
                                for i in 0...num - 1{
                                    self.fromAppDelegate.receiveIdArray.append(self.fromAppDelegate.FootUserData[i].uid!)
                                }
                            }
            //---^^^---
            let TabBarConrtroller = self.storyboard?.instantiateViewController(identifier: "TabBarConrtroller")
                    HUD.hide()
            self.present(TabBarConrtroller!,animated: false,completion: nil)
                    
                }
                    }
                }
                    }
                }
                    }
                }
            }
        }
    }
}
}
    
    func startAnimation(){
        // UIImage の配列を作る
        var imageListArray :Array<UIImage> = []
        // UIImage 各要素を追加、ちょっと冗長的ですが...
        for i in 0...15 {
            imageListArray.append(UIImage(named:self.imageNameArray[i])!)
        }
        // 画像Arrayをアニメーションにセット
        imageView.animationImages = imageListArray
        
        // 間隔（秒単位）
        imageView.animationDuration = 1
        // 繰り返し
        imageView.animationRepeatCount = 1
        // アニメーションを開始
        imageView.startAnimating()
        // アニメーションを終了
        //imageView.stopAnimating()
               
    }
}
private extension ArraySlice {

    var startItem: Element {
        return self[self.startIndex]
    }

}
