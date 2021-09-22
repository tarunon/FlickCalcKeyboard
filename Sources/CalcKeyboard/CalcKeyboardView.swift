//
//  SwiftUIView.swift
//
//
//  Created by tarunon on 2021/09/19.
//

import FlickButton
import SwiftUI
import Calculator

@MainActor
public struct CalcKeyboardView: View {
  @State private var draggingLine: Int? = nil
  @ObservedObject private var viewModel: CalcKeyboardViewModel
  @Environment(\.colorScheme) private var colorScheme

  public init(
    action: @escaping (CalcAction) -> Void
  ) {
    self.viewModel = CalcKeyboardViewModel(
      action: action
    )
  }

  var darkButtonColor: Color {
    colorScheme == .dark
      ? Color(.sRGB, red: 79 / 256, green: 84 / 256, blue: 88 / 256, opacity: 1.0)
      : Color(.sRGB, red: 181 / 256, green: 184 / 256, blue: 194 / 256, opacity: 1.0)
  }

  var lightButtonColor: Color {
    colorScheme == .light
      ? Color.white : Color(.sRGB, red: 128 / 256, green: 127 / 256, blue: 127 / 256, opacity: 1.0)
  }

  public var body: some View {
    VStack(spacing: 0.0) {
      InputField(
        text: viewModel.text,
        errorMessage: viewModel.errorMessage,
        cursor: .init(
          get: { viewModel.cursor },
          set: { viewModel.cursor = $0 }
        )
      )
      .padding(4.0)
      .frame(height: 36.0, alignment: .top)
      HStack(spacing: 4.0) {
        VStack(spacing: 4.0) {
          FlickButton(
            title: "M+",
            subtitle: "M- MR MC",
            action: {
              viewModel.memoryAdd()
            },
            onDrag: {
              draggingLine = 0
            },
            backgroundColor: darkButtonColor,
            directions: [
              .up: (
                label: "M-",
                action: {
                  viewModel.memorySub()
                }
              ),
              .right: (
                label: "MR",
                action: {
                  viewModel.inputMemory()
                }
              ),
              .down: (
                label: "MC",
                action: {
                  viewModel.memoryClear()
                }
              ),
            ]
          )
          FlickButton(
            title: "%",
            subtitle: "^ √ !",
            action: {
              viewModel.input(token: ModToken.instance)
            },
            onDrag: {
              draggingLine = 0
            },
            backgroundColor: darkButtonColor,
            directions: [
              .up: (
                label: "^",
                action: {
                  viewModel.input(token: PowToken.instance)
                }
              ),
              .right: (
                label: "√",
                action: {
                  viewModel.input(token: RootToken.instance)
                }
              ),
              .down: (
                label: "!",
                action: {
                  viewModel.input(token: GammaToken.instance)
                }
              ),
            ]
          )
          FlickButton(
            title: "π",
            subtitle: "e i",
            action: {
              viewModel.input(token: ConstToken.pi)
            },
            onDrag: {
              draggingLine = 0
            },
            backgroundColor: darkButtonColor,
            directions: [
              .up: (
                label: "e",
                action: {
                  viewModel.input(token: ConstToken.napier)
                }
              ),
              .right: (
                label: "i",
                action: {
                  viewModel.input(token: ConstToken.complex)
                }
              ),
            ]
          )
          FlickButton(
            title: "🌐\u{FE0E}",
            subtitle: "ans ret",
            action: {
              viewModel.exit()
            },
            onDrag: {
              draggingLine = 0
            },
            backgroundColor: darkButtonColor,
            directions: [
              .up: (
                label: "ans",
                action: {
                  viewModel.inputAnswer()
                }
              ),
              .right: (
                label: "ret",
                action: {
                  viewModel.inputRetry()
                }
              ),
            ]
          )
        }.zIndex(draggingLine == 0 ? 1 : 0)
        VStack(spacing: 4.0) {
          FlickButton(
            title: "1",
            action: {
              viewModel.input(token: DigitToken._1)
            },
            onDrag: {
              draggingLine = 1
            },
            backgroundColor: lightButtonColor,
            directions: [:]
          )
          FlickButton(
            title: "4",
            subtitle: "sin",
            action: {
              viewModel.input(token: DigitToken._4)
            },
            onDrag: {
              draggingLine = 1
            },
            backgroundColor: lightButtonColor,
            directions: [
              .up: (
                label: "sinh",
                action: {
                  viewModel.input(token: FunctionToken.sinh)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
              .left: (
                label: "sin",
                action: {
                  viewModel.input(token: FunctionToken.sin)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
              .right: (
                label: "asin",
                action: {
                  viewModel.input(token: FunctionToken.asin)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
              .down: (
                label: "asinh",
                action: {
                  viewModel.input(token: FunctionToken.asinh)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
            ]
          )
          FlickButton(
            title: "7",
            action: {
              viewModel.input(token: DigitToken._7)
            },
            onDrag: {
              draggingLine = 1
            },
            backgroundColor: lightButtonColor,
            directions: [:]
          )
          FlickButton(
            title: "()",
            action: {
              viewModel.inputAutoBracket()
              viewModel.formatBrackets(withCompletion: false)
            },
            onDrag: {
              draggingLine = 1
            },
            backgroundColor: lightButtonColor,
            directions: [
              .left: (
                label: "(",
                action: {
                  viewModel.input(token: BracketToken.open)
                  viewModel.formatBrackets(withCompletion: false)
                }
              ),
              .right: (
                label: ")",
                action: {
                  viewModel.input(token: BracketToken.close)
                  viewModel.formatBrackets(withCompletion: false)
                }
              ),
            ]
          )
        }.zIndex(draggingLine == 1 ? 1 : 0)
        VStack(spacing: 4.0) {
          FlickButton(
            title: "2",
            subtitle: "cos",
            action: {
              viewModel.input(token: DigitToken._2)
            },
            onDrag: {
              draggingLine = 2
            },
            backgroundColor: lightButtonColor,
            directions: [
              .up: (
                label: "cosh",
                action: {
                  viewModel.input(token: FunctionToken.cosh)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()

                }
              ),
              .left: (
                label: "cos",
                action: {
                  viewModel.input(token: FunctionToken.cos)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
              .right: (
                label: "acos",
                action: {
                  viewModel.input(token: FunctionToken.acos)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()

                }
              ),
              .down: (
                label: "acosh",
                action: {
                  viewModel.input(token: FunctionToken.acosh)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()

                }
              ),
            ]
          )
          FlickButton(
            title: "5",
            action: {
              viewModel.input(token: DigitToken._5)
            },
            onDrag: {
              draggingLine = 2
            },
            backgroundColor: lightButtonColor,
            directions: [:]
          )
          FlickButton(
            title: "8",
            subtitle: "log",
            action: {
              viewModel.input(token: DigitToken._8)
            },
            onDrag: {
              draggingLine = 2
            },
            backgroundColor: lightButtonColor,
            directions: [
              .left: (
                label: "ln",
                action: {

                  viewModel.input(token: FunctionToken.ln)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
              .up: (
                label: "log",
                action: {
                  viewModel.input(token: FunctionToken.log)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
              .right: (
                label: "lg",
                action: {

                  viewModel.input(token: FunctionToken.lg)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
            ]
          )
          FlickButton(
            title: "0",
            subtitle: "00",
            action: {
              viewModel.input(token: DigitToken._0)
            },
            onDrag: {
              draggingLine = 2
            },
            backgroundColor: lightButtonColor,
            directions: [
              .left: (
                label: "00",
                action: {
                  viewModel.input(token: DigitToken._0)
                  viewModel.input(token: DigitToken._0)
                }
              ),
              .up: (
                label: "000",
                action: {
                  viewModel.input(token: DigitToken._0)
                  viewModel.input(token: DigitToken._0)
                  viewModel.input(token: DigitToken._0)
                }
              ),
              .right: (
                label: "0000",
                action: {
                  viewModel.input(token: DigitToken._0)
                  viewModel.input(token: DigitToken._0)
                  viewModel.input(token: DigitToken._0)
                  viewModel.input(token: DigitToken._0)
                }
              ),
            ]
          )
        }.zIndex(draggingLine == 2 ? 1 : 0)
        VStack(spacing: 4.0) {
          FlickButton(
            title: "3",
            action: {
              viewModel.input(token: DigitToken._3)
            },
            onDrag: {
              draggingLine = 3
            },
            backgroundColor: lightButtonColor,
            directions: [:]
          )
          FlickButton(
            title: "6",
            subtitle: "tan",
            action: {
              viewModel.input(token: DigitToken._6)
            },
            onDrag: {
              draggingLine = 3
            },
            backgroundColor: lightButtonColor,
            directions: [
              .up: (
                label: "tanh",
                action: {
                  viewModel.input(token: FunctionToken.tanh)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
              .left: (
                label: "tan",
                action: {
                  viewModel.input(token: FunctionToken.tan)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
              .right: (
                label: "atan",
                action: {
                  viewModel.input(token: FunctionToken.atan)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
              .down: (
                label: "atanh",
                action: {
                  viewModel.input(token: FunctionToken.atanh)
                  viewModel.input(token: BracketToken.open)
                  viewModel.input(token: BracketToken.close)
                  viewModel.shiftToLeft()
                }
              ),
            ]
          )
          FlickButton(
            title: "9",
            action: {
              viewModel.input(token: DigitToken._9)
            },
            onDrag: {
              draggingLine = 3
            },
            backgroundColor: lightButtonColor,
            directions: [:]
          )
          FlickButton(
            title: ".",
            action: {
              viewModel.inputAutoDot()
            },
            onDrag: {
              draggingLine = 3
            },
            backgroundColor: lightButtonColor,
            directions: [:]
          )
        }.zIndex(draggingLine == 3 ? 1 : 0)
        VStack(spacing: 4.0) {
          FlickButton(
            title: "⌫",
            action: {
              viewModel.deleteLeft()
            },
            actionWhilePressing: true,
            onDrag: {
              draggingLine = 4
            },
            backgroundColor: darkButtonColor,
            directions: [
              .left: (
                label: "I⌫",
                action: {
                  viewModel.deleteLeftAll()
                }
              ),
              .up: (
                label: "⌦",
                action: {
                  viewModel.deleteRight()
                }
              ),
              .down: (
                label: "⌦I",
                action: {
                  viewModel.deleteRightAll()
                }
              ),
            ]
          )
          FlickButton(
            title: "+",
            subtitle: "- × ÷",
            action: {
              viewModel.input(token: AddToken.instance)
            },
            onDrag: {
              draggingLine = 4
            },
            backgroundColor: darkButtonColor,
            directions: [
              .up: (
                label: "×",
                action: {
                  viewModel.input(token: MulToken.instance)
                }
              ),
              .left: (
                label: "-",
                action: {
                  viewModel.input(token: SubToken.instance)
                }
              ),
              .down: (
                label: "÷",
                action: {
                  viewModel.input(token: DivToken.instance)
                }
              ),
            ]
          )
          FlickButton(
            title: "→",
            action: {
              viewModel.shiftToRight()
            },
            actionWhilePressing: true,
            onDrag: {
              draggingLine = 4
            },
            backgroundColor: darkButtonColor,
            directions: [
              .left: (
                label: "←",
                action: {
                  viewModel.shiftToLeft()
                }
              )
            ]
          )
          FlickButton(
            title: "=",
            action: {
              viewModel.calculate()
            },
            onDrag: {
              draggingLine = 4
            },
            backgroundColor: .blue,
            directions: [:]
          )
        }
        .zIndex(draggingLine == 4 ? 1 : 0)
      }
      .padding(EdgeInsets(top: 0.0, leading: 4.0, bottom: 4.0, trailing: 4.0))
      .frame(maxWidth: .infinity, maxHeight: 280.0, alignment: .bottom)
    }
    .background(
      colorScheme == .dark
        ? Color(.sRGB, red: 70 / 256, green: 75 / 256, blue: 75 / 256, opacity: 1.0)
        : Color(.sRGB, red: 214 / 256, green: 216 / 256, blue: 222 / 256, opacity: 1.0))
  }
}
