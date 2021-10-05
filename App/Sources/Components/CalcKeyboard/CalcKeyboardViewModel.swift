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

extension CalcToken: TokenProtocol {
  public var text: String { rawValue }
}

@MainActor
final class CalcKeyboardViewModel: ObservableObject {
  @Published private var inputControl = InputControl<CalcToken>()
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
    if inputControl.previousToken?.isDigit == true {
      input(.Digit.dot)
    } else {
      input(.Digit._0, .Digit.dot)
    }
  }

  func inputAutoBracket() {
    let bracket = build {
      if let previousToken = inputControl.previousToken {
        if previousToken.isNumber {
          CalcToken.Bracket.close
        } else if previousToken.isBracket {
          previousToken
        } else {
          CalcToken.Bracket.open
        }
      } else {
        CalcToken.Bracket.open
      }
    }

    if bracket == inputControl.nextToken {
      shift(direction: .right)
    } else {
      input(bracket)
    }
  }

  func inputFunction(token: CalcToken) {
    input(token, .Bracket.open, .Bracket.close)
    try! inputControl.moveCursor(direction: .left)
  }

  func inputAnswer() async {
    if inputControl.previousToken?.isAnswer == true {
      try! inputControl.delete(direction: .left, line: false)
    }
    let result = [memory.getAnswer()]
    await postVoiceOver(text: result.text)
    inputControl.insert(tokens: result)
  }

  func inputRetry() async {
    error = nil
    latestMemoryAction = nil
    inputControl.clearAll()
    inputControl.insert(tokens: memory.getTokens())
    await postVoiceOver(text: inputControl.text)
  }

  func inputMemory() async {
    let result = [memory.getMemory()]
    await postVoiceOver(text: result.text)
    inputControl.insert(tokens: result)
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
    let numberOfOpen = checkTarget.filter { $0 == .Bracket.open }.count
    let numberOfClose = checkTarget.filter { $0 == .Bracket.close }
      .count

    if numberOfClose > numberOfOpen {
      inputControl.insert(
        tokens: Array(
          repeating: CalcToken.Bracket.open,
          count: numberOfClose - numberOfOpen
        ),
        at: 0
      )
    }

    if withCompletion && numberOfOpen > numberOfClose {
      inputControl.insert(
        tokens: Array(
          repeating: CalcToken.Bracket.close,
          count: numberOfOpen - numberOfClose
        )
      )
    }
  }

  func shift(direction: InputDirection) {
    error = nil
    latestMemoryAction = nil
    do {
      try inputControl.moveCursor(direction: direction)
    } catch {
      action(.moveCursor(offset: direction == .left ? -1 : 1))
    }
  }

  func delete(direction: InputDirection, line: Bool) {
    error = nil
    latestMemoryAction = nil
    do {
      try inputControl.delete(direction: direction, line: line)
    } catch {
      action(direction == .left ? .deleteLeft(line: line) : .deleteRight(line: line))
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
        "\(inputControl.tokens.text) = \(CalcFormatter.format(answer))\n"
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
            L10N.ErrorMessage.parseError.localizedString + "(\(tokens.text))"
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
