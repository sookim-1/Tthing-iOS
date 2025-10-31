//
//  Date+Extension.swift
//  Tthing
//
//  Created by sookim on 11/1/25.
//

import Foundation

extension Date {
    var startOfDay: Date {
      Calendar.current.startOfDay(for: self)
    }

}
