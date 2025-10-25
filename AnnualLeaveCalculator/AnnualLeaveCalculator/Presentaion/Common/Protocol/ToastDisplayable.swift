//
//  ToastDisplayable.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 10/26/25.
//

import Foundation

public protocol ToastDisplayable {
    func showToast(message: String)
}

public extension ToastDisplayable {
    func showToast(message: String) {
        ToastManager.shared.show(message: message)
    }
}
