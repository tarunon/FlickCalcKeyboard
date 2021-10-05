//
//  InputControl.swift
//
//
//  Created by tarunon on 2021/09/28.
//

import Bundles
import Core
import Foundation
import UIKit

public enum InputControlError: Error {
  case isEmpty
}

public enum InputDirection {
  case left
  case right
}

public struct InputControl<Token: TokenProtocol> {
  public internal(set) var tokens: [Token] = []
  public internal(set) var startPosition: Int = 0
  public internal(set) var endPosition: Int = 0

  public init() {}

  public mutating func insert(tokens: [Token]) {
    self.tokens.replaceSubrange(startPosition..<endPosition, with: tokens)
    endPosition = startPosition + tokens.count
    startPosition = endPosition
  }

  public mutating func insert(tokens: [Token], at index: Int) {
    self.tokens.insert(contentsOf: tokens, at: index)
    endPosition += tokens.count
    startPosition += tokens.count
  }

  public mutating func delete(direction: InputDirection, line: Bool) throws {
    if tokens.isEmpty {
      throw InputControlError.isEmpty
    } else if startPosition < endPosition {
      tokens.removeSubrange(startPosition..<endPosition)
      endPosition = startPosition
      return
    }

    switch (direction, line) {
    case (.left, true):
      while startPosition > 0 {
        tokens.remove(at: startPosition - 1)
        startPosition -= 1
      }
      endPosition = startPosition
    case (.left, false):
      if startPosition > 0 {
        tokens.remove(at: startPosition - 1)
        startPosition -= 1
        endPosition = startPosition
      }
    case (.right, true):
      while startPosition < tokens.count {
        tokens.remove(at: startPosition)
      }
    case (.right, false):
      if startPosition < tokens.count {
        tokens.remove(at: startPosition)
      }
    }
  }

  public mutating func clearAll() {
    startPosition = 0
    endPosition = 0
    tokens = []
  }

  public mutating func moveCursor(direction: InputDirection) throws {
    if tokens.isEmpty {
      throw InputControlError.isEmpty
    }
    switch direction {
    case .left:
      startPosition -= 1
      if startPosition < 0 {
        startPosition = 0
      }
    case .right:
      startPosition = endPosition
      startPosition += 1
      if startPosition > tokens.count {
        startPosition = tokens.count
      }
    }
    endPosition = startPosition
  }

  public mutating func moveCusorToEnd() {
    endPosition = tokens.count
    startPosition = tokens.count
  }

  public var text: String {
    tokens.text
  }

  public var previousToken: Token? {
    if startPosition == 0 {
      return nil
    }
    return tokens[startPosition - 1]
  }

  public var nextToken: Token? {
    if endPosition == tokens.count {
      return nil
    }
    return tokens[endPosition]
  }

  public var cursor: NSRange {
    get {
      return NSRange(
        location: tokens[0..<startPosition].text.count,
        length: tokens[startPosition..<endPosition].text.count
      )
    }
    set {
      setStart: do {
        for i in 0...tokens.count {
          if newValue.lowerBound
            <= tokens[0..<i].text.count
          {
            startPosition = i
            break setStart
          }
        }
        startPosition = tokens.count
      }

      setEnd: do {
        for i in 0..<tokens.count {
          if newValue.upperBound
            <= tokens[0..<i].text.count
          {
            endPosition = i
            break setEnd
          }
        }
        endPosition = tokens.count
      }
    }
  }
}
