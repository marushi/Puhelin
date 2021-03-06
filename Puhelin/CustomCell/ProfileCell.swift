//
//  ProfileCell.swift
//  Puhelin
//
//  Created by 丸子司恩 on 2020/03/08.
//  Copyright © 2020 shion.maruko. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    //部品
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    //定数
    let titleArray = ["ニックネーム","年齢","居住地","身長","体型","職種","性格","会話","目的","お酒","タバコ","好きなこと趣味"]
    //変数
    var profileData:MyProfileData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(_ row:Int) {
        if profileData != nil {
        switch row {
        case 0:
            contentLabel.text = profileData?.name
            titleLabel.text = titleArray[0]
        case 1:
            if profileData?.age != nil {
                contentLabel.text = "\(profileData!.age!)" + "歳"
            }else{
                contentLabel.text = ""
            }
            titleLabel.text = titleArray[1]
        case 2:
            contentLabel.text = profileData?.region
            titleLabel.text = titleArray[2]
        case 3:
            if profileData?.tall != nil {
                contentLabel.text = "\(profileData!.tall!)" + "cm"
            }else{
                contentLabel.text = ""
            }
            titleLabel.text = titleArray[3]
        case 4:
            contentLabel.text = profileData?.bodyType
            titleLabel.text = titleArray[4]
        case 5:
            contentLabel.text = profileData?.job
            titleLabel.text = titleArray[5]
        
        case 6:
            contentLabel.text = profileData?.personality
            titleLabel.text = titleArray[6]
        
        case 7:
            contentLabel.text = profileData?.talk
            titleLabel.text = titleArray[7]
        
        case 8:
            contentLabel.text = profileData?.purpose
            titleLabel.text = titleArray[8]
        
        case 9:
            contentLabel.text = profileData?.alchoal
            titleLabel.text = titleArray[9]
        
        case 10:
            contentLabel.text = profileData?.tabako
            titleLabel.text = titleArray[10]
        
        case 11:
            contentLabel.text = profileData?.hobby
            titleLabel.text = titleArray[11]

        default:
            return
            }}
    
    }

}
