//
//  String+Extension.swift
//  SeSACRxThreads
//
//  Created by Minho on 3/28/24.
//

import Foundation

extension String {
   var isNumber: Bool {
   do {
      let regex = try NSRegularExpression(pattern: "^[0-9]+$", options: .caseInsensitive)
      if let _ = regex.firstMatch(in: self, options: .reportCompletion, range: NSMakeRange(0, count)) { return true }
      } catch { return false }
      return false
   }
}
