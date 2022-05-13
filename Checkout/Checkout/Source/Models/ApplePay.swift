//
//  ApplePay.swift
//  
//
//  Created by Harry Brown on 07/12/2021.
//

import Foundation

public struct ApplePay: Equatable {
  public let tokenData: Data
  public init(tokenData: Data) {
    self.tokenData = tokenData
  }
}
