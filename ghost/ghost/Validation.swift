//
//  Validation.swift
//  ghost
//
//  Created by John Clarke on 6/1/16.
//  Copyright © 2016 hck. All rights reserved.
//

import Foundation

class Validation {
    
    // Range Check
    func isInRange(text: String, lo: Int, hi: Int) -> Bool {
        let textLength = text.characters.count
        if (textLength >= lo && textLength <= hi) {
            return true
        } else {
            return false
        }
    }
    
    // Alpha Numeric Character Check
    func isAlphaNumeric(text: String) -> Bool {
        let alphaNumerics = NSCharacterSet.alphanumericCharacterSet()
        for char in text.utf16 {
            if !alphaNumerics.characterIsMember(char) {
                return false
            }
        }
        return true
    }
}