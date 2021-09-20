//
//  CalcKeyboardViewModel.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import SwiftUI

@MainActor
class CalcKeyboardViewModel: ObservableObject {
  @Published var tokens: [Token] = []
  @Published var startIndex: Int = 0
  @Published var endIndex: Int = 0

  var action: (CalcAction) -> Void

  init(
    action: @escaping (CalcAction) -> Void
  ) {
    self.action = action
  }

  func input(token: Token) {
    tokens.removeSubrange(startIndex..<endIndex)
    endIndex = startIndex
    tokens.insert(token, at: startIndex)
    startIndex += 1
    endIndex = startIndex
  }

  func inputAutoDot() {
    tokens.removeSubrange(startIndex..<endIndex)
    endIndex = startIndex
    if startIndex == 0 {
      input(token: ._0)
      input(token: .dot)
    } else if tokens[startIndex - 1].isNumeric {
      input(token: .dot)
    } else {
      input(token: ._0)
      input(token: .dot)
    }
  }

  func inputAutoBracket() {
    tokens.removeSubrange(startIndex..<endIndex)
    endIndex = startIndex
    if startIndex == 0 {
      input(token: .bracketOpen)
    } else if tokens[startIndex - 1].isNumeric || tokens[startIndex - 1].isConstant {
      input(token: .bracketClose)
    } else if tokens[startIndex - 1] == .bracketClose {
      input(token: .bracketClose)
    } else {
      input(token: .bracketOpen)
    }
  }

  func formatBrackets(withCompletion: Bool) {
    let checkTarget = tokens[0..<startIndex]
    let numberOfOpen = checkTarget.filter { $0 == .bracketOpen }.count
    let numberOfClose = checkTarget.filter { $0 == .bracketClose }.count

    if numberOfClose > numberOfOpen {
      for _ in 0..<numberOfClose - numberOfOpen {
        tokens.insert(.bracketOpen, at: 0)
        startIndex += 1
        endIndex = startIndex
      }
    }

    if withCompletion && numberOfOpen > numberOfClose {
      for _ in 0..<numberOfOpen - numberOfClose {
        input(token: .bracketClose)
      }
    }
  }

  func shiftToLeft() {
    if tokens.isEmpty {
      action(.moveCursor(offset: -1))
    } else {
      startIndex -= 1
      if startIndex < 0 {
        startIndex = 0
      }
      endIndex = startIndex
    }
  }

  func shiftToRight() {
    if tokens.isEmpty {
      action(.moveCursor(offset: 1))
    } else {
      startIndex = endIndex
      startIndex += 1
      if startIndex > tokens.count {
        startIndex = tokens.count
      }
      endIndex = startIndex
    }
  }

  func shiftToEnd() {
    startIndex = tokens.count
    endIndex = startIndex
  }

  func deleteLeft() {
    if tokens.isEmpty {
      action(.deleteLeft(line: false))
    } else if startIndex < endIndex {
      tokens.removeSubrange(startIndex..<endIndex)
      endIndex = startIndex
    } else if startIndex > 0 {
      tokens.remove(at: startIndex - 1)
      startIndex -= 1
      endIndex = startIndex
    }
  }

  func deleteLeftAll() {
    if tokens.isEmpty {
      action(.deleteLeft(line: true))
    } else if startIndex < endIndex {
      tokens.removeSubrange(startIndex..<endIndex)
      endIndex = startIndex
    } else {
      while startIndex > 0 {
        tokens.remove(at: startIndex - 1)
        startIndex -= 1
      }
      endIndex = startIndex
    }
  }

  func deleteRight() {
    if tokens.isEmpty {
      action(.deleteRight(line: false))
    } else if startIndex < endIndex {
      tokens.removeSubrange(startIndex..<endIndex)
      endIndex = startIndex
    } else if startIndex < tokens.count {
      tokens.remove(at: startIndex)
    }
  }

  func deleteRightAll() {
    if tokens.isEmpty {
      action(.deleteRight(line: true))
    } else if startIndex < endIndex {
      tokens.removeSubrange(startIndex..<endIndex)
      endIndex = startIndex
    } else {
      while startIndex < tokens.count {
        tokens.remove(at: startIndex)
      }
    }
  }

  func parse() throws -> String {
    if tokens.isEmpty {
      throw CalcError.tokensEmpty
    }
    return "\(tokens.map { $0.rawValue }.joined()) = ???\n"
  }

  func calculate() {
    shiftToEnd()
    formatBrackets(withCompletion: true)
    do {
      try action(.insertText(parse()))
      clearAll()
    } catch (let error) {
      switch error {
      case CalcError.tokensEmpty:
        action(.insertText("\n"))
      default:
        print(error)
      }
    }
  }

  func clearAll() {
    startIndex = 0
    endIndex = 0
    tokens = []
  }

  func exit() {
    action(.exit)
  }

  var text: String {
    tokens.map { $0.rawValue }.joined()
  }

  var cursor: NSRange {
    get {
      return NSRange(
        location: tokens[0..<startIndex].map { $0.rawValue }.joined().count,
        length: tokens[startIndex..<endIndex].map { $0.rawValue }.joined().count
      )
    }
    set {
      setStart: do {
        for i in 0...tokens.count {
          if newValue.lowerBound
            <= tokens[0..<i].map({ $0.rawValue }).joined().count
          {
            startIndex = i
            break setStart
          }
        }
        startIndex = tokens.count
      }

      setEnd: do {
        for i in 0..<tokens.count {
          if newValue.upperBound
            <= tokens[0..<i].map({ $0.rawValue }).joined().count
          {
            endIndex = i
            break setEnd
          }
        }
        endIndex = tokens.count
      }
    }
  }
}
