//
//  Category.swift
//  taskapp
//
//  Created by Nakajima Mizuki on 2019/03/09.
//  Copyright © 2019 Nakajima Mizuki. All rights reserved.
//

import RealmSwift

class Category : Object{
    
    // 管理用 ID。プライマリーキー
    @objc dynamic var categoryId = 0
    
    //作成したカテゴリー名
    @objc dynamic var categoryName = ""

    /**
     id をプライマリーキーとして設定
     */
    override static func primaryKey() -> String? {
        return "categoryId"
    }
}
