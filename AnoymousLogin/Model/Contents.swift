//
//  Contents.swift
//  AnoymousLogin
//
//  Created by 田中誠 on 2020/08/26.
//  Copyright © 2020 田中誠. All rights reserved.
//

import Foundation

class Contents {
    
    var userNameString:String = ""
    var profileImageString:String = ""
    var contentImageString:String = ""
    var commentString:String = ""
    var postDateString:String = ""
    
        init(userNameString:String,profileImageString:String,contentImageString:String,commentString:String,postDateString:String){
            
            self.userNameString = userNameString
            self.profileImageString = profileImageString
            self.contentImageString = contentImageString
            self.commentString = commentString
            self.postDateString = postDateString
        
    }
    
}
