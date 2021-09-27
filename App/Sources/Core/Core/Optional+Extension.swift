//
//  File.swift
//
//
//  Created by tarunon on 2021/09/27.
//

// swift-format-ignore-file

public struct NilError: Error {}

extension Optional {
  public var tryUnwrapped: Wrapped {
    get throws {
      if let self = self {
        return self
      } else {
        throw NilError()
      }
    }
  }
}
