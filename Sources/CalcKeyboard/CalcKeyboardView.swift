//
//  SwiftUIView.swift
//
//
//  Created by tarunon on 2021/09/19.
//

import FlickButton
import SwiftUI

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
            subtitle: "M-",
            action: {
            },
            onDrag: {
              draggingLine = 0
            },
            backgroundColor: darkButtonColor,
            directions: [
              .up: (
                label: "M-",
                action: {

                }
              ),
              .right: (
                label: "MR",
                action: {

                }
              ),
              .down: (
                label: "MC",
                action: {

                }
              ),
            ]
          )
          FlickButton(
            title: "%",
            subtitle: "^ √ !",
            action: {
              viewModel.input(token: .mod)
            },
            onDrag: {
              draggingLine = 0
            },
            backgroundColor: darkButtonColor,
            directions: [
              .up: (
                label: "^",
                action: {
                  viewModel.input(token: .pow)
                }
              ),
              .right: (
                label: "√",
                action: {
                  viewModel.input(token: .sqrt)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
              .down: (
                label: "!",
                action: {
                  viewModel.input(token: .factorial)
                }
              ),
            ]
          )
          FlickButton(
            title: "π",
            subtitle: "e i",
            action: {
              viewModel.input(token: .pi)
            },
            onDrag: {
              draggingLine = 0
            },
            backgroundColor: darkButtonColor,
            directions: [
              .up: (
                label: "e",
                action: {
                  viewModel.input(token: .napier)
                }
              ),
              .right: (
                label: "i",
                action: {
                  viewModel.input(token: .complex)
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

                }
              ),
              .right: (
                label: "ret",
                action: {

                }
              ),
            ]
          )
        }.zIndex(draggingLine == 0 ? 1 : 0)
        VStack(spacing: 4.0) {
          FlickButton(
            title: "1",
            action: {
              viewModel.input(token: ._1)
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
              viewModel.input(token: ._4)
            },
            onDrag: {
              draggingLine = 1
            },
            backgroundColor: lightButtonColor,
            directions: [
              .up: (
                label: "sinh",
                action: {
                  viewModel.input(token: .sinh)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
              .left: (
                label: "sin",
                action: {
                  viewModel.input(token: .sin)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
              .right: (
                label: "asin",
                action: {
                  viewModel.input(token: .asin)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
              .down: (
                label: "asinh",
                action: {
                  viewModel.input(token: .asinh)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
            ]
          )
          FlickButton(
            title: "7",
            action: {
              viewModel.input(token: ._7)
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
              draggingLine = 3
            },
            backgroundColor: lightButtonColor,
            directions: [
              .left: (
                label: "(",
                action: {
                  viewModel.input(token: .bracketOpen)
                  viewModel.formatBrackets(withCompletion: false)
                }
              ),
              .right: (
                label: ")",
                action: {
                  viewModel.input(token: .bracketClose)
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
              viewModel.input(token: ._2)
            },
            onDrag: {
              draggingLine = 2
            },
            backgroundColor: lightButtonColor,
            directions: [
              .up: (
                label: "cosh",
                action: {
                  viewModel.input(token: .cosh)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()

                }
              ),
              .left: (
                label: "cos",
                action: {
                  viewModel.input(token: .cos)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
              .right: (
                label: "acos",
                action: {
                  viewModel.input(token: .acos)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()

                }
              ),
              .down: (
                label: "acosh",
                action: {
                  viewModel.input(token: .acosh)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()

                }
              ),
            ]
          )
          FlickButton(
            title: "5",
            action: {
              viewModel.input(token: ._5)
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
              viewModel.input(token: ._8)
            },
            onDrag: {
              draggingLine = 2
            },
            backgroundColor: lightButtonColor,
            directions: [
              .left: (
                label: "ln",
                action: {

                  viewModel.input(token: .ln)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
              .right: (
                label: "lg",
                action: {

                  viewModel.input(token: .lg)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
            ]
          )
          FlickButton(
            title: "0",
            subtitle: "00...",
            action: {
              viewModel.input(token: ._0)
            },
            onDrag: {
              draggingLine = 2
            },
            backgroundColor: lightButtonColor,
            directions: [
              .left: (
                label: "00",
                action: {
                  viewModel.input(token: ._0)
                  viewModel.input(token: ._0)
                }
              ),
              .up: (
                label: "000",
                action: {
                  viewModel.input(token: ._0)
                  viewModel.input(token: ._0)
                  viewModel.input(token: ._0)
                }
              ),
              .right: (
                label: "0000",
                action: {
                  viewModel.input(token: ._0)
                  viewModel.input(token: ._0)
                  viewModel.input(token: ._0)
                  viewModel.input(token: ._0)
                }
              ),
            ]
          )
        }.zIndex(draggingLine == 2 ? 1 : 0)
        VStack(spacing: 4.0) {
          FlickButton(
            title: "3",
            action: {
              viewModel.input(token: ._3)
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
              viewModel.input(token: ._6)
            },
            onDrag: {
              draggingLine = 3
            },
            backgroundColor: lightButtonColor,
            directions: [
              .up: (
                label: "tanh",
                action: {
                  viewModel.input(token: .tanh)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
              .left: (
                label: "tan",
                action: {
                  viewModel.input(token: .tan)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
              .right: (
                label: "atan",
                action: {
                  viewModel.input(token: .atan)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
              .down: (
                label: "atanh",
                action: {
                  viewModel.input(token: .atanh)
                  viewModel.input(token: .bracketOpen)
                  viewModel.input(token: .bracketClose)
                  viewModel.shiftToLeft()
                }
              ),
            ]
          )
          FlickButton(
            title: "9",
            action: {
              viewModel.input(token: ._9)
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
              draggingLine = 1
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
              viewModel.input(token: .add)
            },
            onDrag: {
              draggingLine = 4
            },
            backgroundColor: darkButtonColor,
            directions: [
              .up: (
                label: "×",
                action: {
                  viewModel.input(token: .mul)
                }
              ),
              .left: (
                label: "-",
                action: {
                  viewModel.input(token: .sub)
                }
              ),
              .down: (
                label: "÷",
                action: {
                  viewModel.input(token: .div)
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
