//
//  MessageData.swift
//  Puhelin
//
//  Created by 丸子司恩 on 2020/02/18.
//  Copyright © 2020 shion.maruko. All rights reserved.
//

import UIKit
import Firebase

class MessageData: NSObject {
    var id:String?
    var senderId: String?
    var displayName: String?
    var text: String?
    var sendTime: Timestamp?
    
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        let Dic = document.data()
        self.senderId = Dic["senderId"] as? String
        self.displayName = Dic["displayName"] as? String
        self.text = Dic["text"] as? String
        self.sendTime = Dic["sendTime"] as? Timestamp
    }
}
