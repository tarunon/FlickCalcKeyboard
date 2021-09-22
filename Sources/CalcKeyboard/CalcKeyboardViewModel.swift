//
//  CalcKeyboardViewModel.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Calculator
import SwiftUI
import Numerics

@MainActor
class CalcKeyboardViewModel: ObservableObject {
  @Published var tokens: [CalcToken] = []
  @Published var error: CalcError?
  @Published var startIndex: Int = 0
  @Published var endIndex: Int = 0

  var action: (CalcAction) -> Void

  var answerHistory: [Complex<Double>] = []
  var latestTokens: [CalcToken] = []
  var memory: Complex<Double> = 0

  init(
    action: @escaping (CalcAction) -> Void
  ) {
    self.action = action
  }

  func input(token: CalcToken) {
    error = nil
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
      input(token: DigitToken._0)
      input(token: DigitToken.dot)
    } else if tokens[startIndex - 1] is DigitToken {
      input(token: DigitToken.dot)
    } else {
      input(token: DigitToken._0)
      input(token: DigitToken.dot)
    }
  }

  func inputAutoBracket() {
    tokens.removeSubrange(startIndex..<endIndex)
    endIndex = startIndex
    if startIndex == 0 {
      input(token: BracketToken.open)
    } else if tokens[startIndex - 1] is NumberToken {
      input(token: BracketToken.close)
    } else if let bracket = tokens[startIndex - 1] as? BracketToken, bracket == .close {
      input(token: BracketToken.close)
    } else {
      input(token: BracketToken.open)
    }
  }

  func inputAnswer() {
    tokens.removeSubrange(startIndex..<endIndex)
    endIndex = startIndex
    if let answer = answerHistory.last {
      if startIndex == 0 {
        input(token: ConstToken.answer(answer: answer, index: answerHistory.count - 1))
      } else if case .answer(_, let index) = tokens[startIndex - 1] as? ConstToken {
        deleteLeft()
        let nextIndex = index == 0 ? answerHistory.count - 1 : index - 1
        input(token: ConstToken.answer(answer: answerHistory[nextIndex], index: nextIndex))
      } else {
        input(token: ConstToken.answer(answer: answer, index: answerHistory.count - 1))
      }
    }
  }

  func inputRetry() {
    clearAll()
    tokens = latestTokens
    endIndex = latestTokens.count
    startIndex = latestTokens.count
  }

  func inputMemory() {
    input(token: ConstToken.answer(answer: memory, index: 0))
  }

  func memoryAdd() {
    do {
      shiftToEnd()
      formatBrackets(withCompletion: true)
      memory += try Calculator.calc(tokens: tokens)
    } catch (let error) {
      clearAll()
      self.error = error as? CalcError
    }
  }

  func memorySub() {
    do {
      shiftToEnd()
      formatBrackets(withCompletion: true)
      memory -= try Calculator.calc(tokens: tokens)
    } catch (let error) {
      clearAll()
      self.error = error as? CalcError
    }
  }

  func memoryClear() {
    memory = 0
  }

  func formatBrackets(withCompletion: Bool) {
    let checkTarget = tokens[0..<startIndex]
    let numberOfOpen = checkTarget.filter { ($0 as? BracketToken) == BracketToken.open }.count
    let numberOfClose = checkTarget.filter { ($0 as? BracketToken) == BracketToken.close }.count

    if numberOfClose > numberOfOpen {
      for _ in 0..<numberOfClose - numberOfOpen {
        tokens.insert(BracketToken.open, at: 0)
        startIndex += 1
        endIndex = startIndex
      }
    }

    if withCompletion && numberOfOpen > numberOfClose {
      for _ in 0..<numberOfOpen - numberOfClose {
        input(token: BracketToken.close)
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

  func calculate() {
    shiftToEnd()
    formatBrackets(withCompletion: true)
    do {
      let answer = try Calculator.calc(tokens: tokens)
      action(.insertText("\(CalcFormatter.format(tokens)) = \(CalcFormatter.format(answer))\n"))
      answerHistory.append(answer)
      latestTokens = tokens
      clearAll()
    } catch (let error) {
      switch error {
      case CalcError.tokensEmpty:
        action(.insertText("\n"))
      default:
        clearAll()
        self.error = error as? CalcError
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
    CalcFormatter.format(tokens)
  }

  var errorMessage: String {
    switch error {
    case nil, .tokensEmpty:
      return ""
    case .runtimeError(let reason), .parseError(let reason):
      return reason
    }
  }

  var cursor: NSRange {
    get {
      return NSRange(
        location: CalcFormatter.format(tokens[0..<startIndex]).count,
        length: CalcFormatter.format(tokens[startIndex..<endIndex]).count
      )
    }
    set {
      setStart: do {
        for i in 0...tokens.count {
          if newValue.lowerBound
            <= CalcFormatter.format(tokens[0..<i]).count
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
            <= CalcFormatter.format(tokens[0..<i]).count
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
