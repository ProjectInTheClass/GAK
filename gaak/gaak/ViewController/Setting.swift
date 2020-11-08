//
//  Setting.swift
//  gaak
//
//  Created by 서인재 on 2020/11/05.
//  Copyright © 2020 Ted Kim. All rights reserved.
//

import Foundation

// Setting TableView Cell에 담길 내용을 위한 struct
struct Setting {
    var content: String
        init(content: String) {
            self.content = content
        }
    }

// 이거를 Constants에 넣어서 불러오고 싶었는데 왜 안될까요??
// 솔직히 이거 없이, SettingTableViewController내에 그냥 선언해도 되는데, 뭔가 한번 MVC 따라서 해보고싶었습니다 ㅋㅋㅋㅋ
