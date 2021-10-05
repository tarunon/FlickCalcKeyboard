//
//  TokenProtocol.swift
//
//
//  Created by tarunon on 2021/10/03.
//

public protocol TokenProtocol {
  var text: String { get }
}

extension Sequence where Element: TokenProtocol {
  public var text: String {
    map { $0.text }.joined()
  }
}

extension RawRepresentable where RawValue == String, Self: TokenProtocol {
  var text: String { rawValue }
}
