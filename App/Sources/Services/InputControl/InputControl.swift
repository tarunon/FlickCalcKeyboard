//
//  InputControl.swift
//
//
//  Created by tarunon on 2021/09/28.
//

import Bundles
import Calculator
import Core
import Foundation

public enum InputControlError: Error {
  case isEmpty
}

public enum InputDirection {
  case left
  case right
}

public struct InputControl {
  public internal(set) var tokens: [CalcToken] = [] {
    didSet {
      error = nil
    }
  }
  public internal(set) var startPosition: Int = 0
  public internal(set) var endPosition: Int = 0
  var error: CalcError?

  public init() {}

  public mutating func insert(tokens: [CalcToken]) {
    self.tokens.replaceSubrange(startPosition..<endPosition, with: tokens)
    endPosition = startPosition + tokens.count
    startPosition = endPosition
  }

  public mutating func insert(tokens: [CalcToken], at index: Int) {
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

  public mutating func errorOccured(_ error: CalcError) {
    self.error = error
  }

  public var text: String {
    CalcFormatter.format(tokens)
  }

  public var errorMessage: String {
    build {
      switch error {
      case nil, .tokensEmpty:
        ""
      case .parseError(let tokens):
        L10N.ErrorMessage.parseError.localizedString + "(\(CalcFormatter.format(tokens)))"
      case .runtimeError(let reason):
        L10N.ErrorMessage.runtimeError.localizedString + "(\(reason))"
      }
    }
  }

  public var previousToken: CalcToken? {
    if startPosition == 0 {
      return nil
    }
    return tokens[startPosition - 1]
  }

  public var nextToken: CalcToken? {
    if endPosition == tokens.count {
      return nil
    }
    return tokens[endPosition]
  }

  public var cursor: NSRange {
    get {
      return NSRange(
        location: CalcFormatter.format(tokens[0..<startPosition]).count,
        length: CalcFormatter.format(tokens[startPosition..<endPosition]).count
      )
    }
    set {
      setStart: do {
        for i in 0...tokens.count {
          if newValue.lowerBound
            <= CalcFormatter.format(tokens[0..<i]).count
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
            <= CalcFormatter.format(tokens[0..<i]).count
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
