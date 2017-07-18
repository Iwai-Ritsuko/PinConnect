//
//  StringExtensions.swift
//  PinConnect
//
//  Created by KUROSAKI Ryota on 7/7/16.
//  Copyright © 2016 Ritsuko Iwai. All rights reserved.
//

import Foundation

extension String {
    // 丸数字を返す. 1から50まで
    public static func encircled(number number: Int) -> String {
        let c:Int
        switch(number) {
        case 0:
            c = 0x24ea
        case 1...20:
            c = 0x2460 + (number - 1)
        case 21...35:
        c = 0x3251 + (number - 21)
        default:
            c = 0x32b1 + (number - 36)
        }
        return String(UnicodeScalar(c))
    }
}
