//
//  Helper.swift
//  eRTCApp
//
//  Created by Logan on 19/10/2022.
//  Copyright © 2022 Ripbull Network. All rights reserved.
//

import Foundation

func safePrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    items.forEach { (item) in
        print(item, separator: separator, terminator: "")
    }
    print("", separator:separator, terminator: terminator)
#endif
}
