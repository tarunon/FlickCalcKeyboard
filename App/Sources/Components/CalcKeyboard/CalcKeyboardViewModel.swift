//
//  CalcKeyboardViewModel.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Bundles
import CalcMemory
import Calculator
import Core
import FlickButton
import InputControl
import Numerics
import SwiftUI

enum ButtonType {
  case number
  case function
  case equal

  var buttonColor: Color {
    build {
      switch self {
      case .number: Color.lightButtonColor
      case .function: Color.darkButtonColor
      case .equal: Color.blue
      }
    }
  }
}

struct ButtonParameter {
  var title: String
  var subtitle: String?
  var voiceOverTitle: String
  var action: () -> Void
  var actionWhilePressing: Bool = false
  var buttonType: ButtonType
  var directions:
    [FlickButton.Direction: (title: String, voiceOverTitle: String, action: () -> Void)]
}

enum LatestMemoryAction {
  case add(Complex<Double>)
  case sub(Complex<Double>)
  case clear
}

@MainActor
final class CalcKeyboardViewModel: ObservableObject {
  @Published private var inputControl = InputControl()
  @Published private var error: CalcError?
  @Published private var latestMemoryAction: LatestMemoryAction?
  private var memory = CalcMemory()
  private var action: (CalcAction) -> Void

  init(
    action: @escaping (CalcAction) -> Void
  ) {
    self.action = action
  }

  func input(_ tokens: CalcToken...) {
    error = nil
    latestMemoryAction = nil
    memory.resetCursor()
    inputControl.insert(tokens: tokens)
  }

  func inputAutoDot() {
    if inputControl.previousToken is DigitToken {
      input(DotToken.instance)
    } else {
      input(DigitToken._0, DotToken.instance)
    }
  }

  func inputAutoBracket() {
    let bracket = build {
      switch inputControl.previousToken {
      case is NumberToken:
        BracketToken.close
      case let bracket as BracketToken:
        bracket
      default:
        BracketToken.open
      }
    }
    if bracket == inputControl.nextToken as? BracketToken {
      shiftToRight()
    } else {
      input(bracket)
    }
  }

  func inputFunction(token: FunctionToken) {
    input(token, BracketToken.open, BracketToken.close)
    try! inputControl.moveCursor(direction: .left)
  }

  func inputAnswer() async {
    if case .answer = inputControl.previousToken as? ConstToken {
      try! inputControl.delete(direction: .left, line: false)
    }
    let answer = memory.getAnswer()
    await postVoiceOver(text: CalcFormatter.format([answer]))
    inputControl.insert(tokens: [answer])
  }

  func inputRetry() async {
    inputControl.clearAll()
    inputControl.insert(tokens: memory.getTokens())
    await postVoiceOver(text: inputControl.text)
  }

  func inputMemory() async {
    let memory = self.memory.getMemory()
    await postVoiceOver(text: CalcFormatter.format([memory]))
    input(memory)
  }

  func memoryAdd() async {
    memory.addTokens(inputControl.tokens)
    do {
      inputControl.moveCusorToEnd()
      formatBrackets(withCompletion: true)
      let result = try Calculator.calc(tokens: inputControl.tokens)
      memory.memoryAdd(result)
      latestMemoryAction = .add(result)
      inputControl.clearAll()
      await postVoiceOver(text: placeholder!.description)
    } catch (let error) {
      inputControl.clearAll()
      if let error = error as? CalcError {
        self.error = error
      }
    }
  }

  func memorySub() async {
    memory.addTokens(inputControl.tokens)
    do {
      inputControl.moveCusorToEnd()
      formatBrackets(withCompletion: true)
      let result = try Calculator.calc(tokens: inputControl.tokens)
      memory.memorySub(result)
      latestMemoryAction = .sub(result)
      inputControl.clearAll()
      await postVoiceOver(text: placeholder!.description)
    } catch (let error) {
      inputControl.clearAll()
      if let error = error as? CalcError {
        self.error = error
      }
    }
  }

  func memoryClear() {
    memory.memoryClear()
    latestMemoryAction = .clear
  }

  func formatBrackets(withCompletion: Bool) {
    let checkTarget = inputControl.tokens[0..<inputControl.startPosition]
    let numberOfOpen = checkTarget.filter { ($0 as? BracketToken) == BracketToken.open }.count
    let numberOfClose = checkTarget.filter { ($0 as? BracketToken) == BracketToken.close }.count

    if numberOfClose > numberOfOpen {
      inputControl.insert(
        tokens: Array(repeating: BracketToken.open, count: numberOfClose - numberOfOpen),
        at: 0
      )
    }

    if withCompletion && numberOfOpen > numberOfClose {
      inputControl.insert(
        tokens: Array(repeating: BracketToken.close, count: numberOfOpen - numberOfClose)
      )
    }
  }

  func shiftToLeft() {
    do {
      try inputControl.moveCursor(direction: .left)
    } catch {
      action(.moveCursor(offset: -1))
    }
  }

  func shiftToRight() {
    do {
      try inputControl.moveCursor(direction: .right)
    } catch {
      action(.moveCursor(offset: 1))
    }
  }

  func deleteLeft(line: Bool) {
    do {
      try inputControl.delete(direction: .left, line: line)
    } catch {
      action(.deleteLeft(line: line))
    }
  }

  func deleteRight(line: Bool) {
    do {
      try inputControl.delete(direction: .right, line: line)
    } catch {
      action(.deleteLeft(line: line))
    }
  }

  func calculate() async {
    error = nil
    latestMemoryAction = nil
    inputControl.moveCusorToEnd()
    formatBrackets(withCompletion: true)
    memory.addTokens(inputControl.tokens)
    do {
      let answer = try Calculator.calc(tokens: inputControl.tokens)
      let result =
        "\(CalcFormatter.format(inputControl.tokens)) = \(CalcFormatter.format(answer))\n"
      await postVoiceOver(text: result)
      action(.insertText(result))
      memory.addAnswer(answer)
      inputControl.clearAll()
    } catch (let error) {
      switch error {
      case CalcError.tokensEmpty:
        action(.insertText("\n"))
      default:
        inputControl.clearAll()
        if let error = error as? CalcError {
          self.error = error
          await postVoiceOver(text: placeholder!.description)
        }
      }
    }
  }

  func exit() {
    action(.exit)
  }

  func postVoiceOver(text: String) async {
    if UIAccessibility.isVoiceOverRunning {
      for await _ in NotificationCenter.default.notifications(
        named: UIAccessibility.announcementDidFinishNotification,
        object: nil
      ) {
        break
      }
    }
    UIAccessibility.post(notification: .announcement, argument: text)
  }

  var text: String {
    inputControl.text
  }

  var placeholder: AttributedString? {
    build {
      if let errorText = build({
        switch error {
        case nil, .tokensEmpty:
          String?.none
        case .parseError(let tokens):
          String?.some(
            L10N.ErrorMessage.parseError.localizedString + "(\(CalcFormatter.format(tokens)))"
          )
        case .runtimeError(let reason):
          String?.some(L10N.ErrorMessage.runtimeError.localizedString + "(\(reason))")
        }
      }) {
        AttributedString?.some(
          .init(errorText, attributes: .init().foregroundColor(UIColor.systemRed))
        )
      } else if let memoryText = build({
        build {
          switch latestMemoryAction {
          case .add(let value):
            String?.some(
              L10N.Placeholder.memoryAdd.localizedString + "(\(CalcFormatter.format(value)))"
            )
          case .sub(let value):
            String?.some(
              L10N.Placeholder.memorySub.localizedString + "(\(CalcFormatter.format(value)))"
            )
          case .clear:
            String?.some(L10N.Placeholder.memoryClear.localizedString)
          case nil:
            String?.none
          }
        }
      }) {
        AttributedString?.some(
          .init(memoryText, attributes: .init().foregroundColor(UIColor.systemBlue))
        )
      } else {
        AttributedString?.none
      }
    }
  }

  var cursor: NSRange {
    get { inputControl.cursor }
    set { inputControl.cursor = newValue }
  }
}
