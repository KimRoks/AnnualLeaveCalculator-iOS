//
//  Reusable.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/27/25.
//

import Foundation

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
