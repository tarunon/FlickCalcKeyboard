//
//  SwiftUIView.swift
//
//
//  Created by tarunon on 2021/09/19.
//

import Calculator
import FlickButton
import InputField
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
      ? .black
      : Color(.sRGB, red: 181 / 256, green: 184 / 256, blue: 194 / 256, opacity: 1.0)
  }

  var lightButtonColor: Color {
    colorScheme == .light
      ? Color.white : Color(.sRGB, red: 79 / 256, green: 84 / 256, blue: 88 / 256, opacity: 1.0)
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
      HStack(spacing: 0.0) {
        ForEach(Array(buttonParameters.enumerated()), id: \.offset) { (vOffset, line) in
          VStack(spacing: 0.0) {
            ForEach(Array(line.enumerated()), id: \.offset) { (hOffset, parameter) in
              FlickButton(
                title: parameter.title,
                subtitle: parameter.subtitle,
                voiceOverTitle: parameter.voiceOverTitle,
                action: parameter.action,
                actionWhilePressing: parameter.actionWhilePressing,
                onDrag: {
                  draggingLine = vOffset
                },
                backgroundColor: parameter.buttonType.buttonColor,
                directions: parameter.directions
              )
              if hOffset != 3 {
                Divider().background(.secondary)
              }
            }
          }.zIndex(draggingLine == vOffset ? 1 : 0)
          if vOffset != 4 {
            Divider().background(.secondary)
          }
        }
      }
      .padding(0.0)
      .frame(maxWidth: .infinity, maxHeight: 280.0, alignment: .bottom)
    }
    .clipped()
    .background(
      colorScheme == .dark
        ? Color(.sRGB, red: 70 / 256, green: 75 / 256, blue: 75 / 256, opacity: 1.0)
        : Color(.sRGB, red: 214 / 256, green: 216 / 256, blue: 222 / 256, opacity: 1.0)
    )
  }

  var buttonParameters: [[ButtonParameter]] {
    [
      [
        .init(
          title: "M+",
          subtitle: "M- MR MC",
          voiceOverTitle: L10N.VoiceOverTitle.memoryPlus.localizedString,
          action: {
            viewModel.memoryAdd()
          },
          buttonType: .function,
          directions: [
            .up: (
              title: "M-",
              voiceOverTitle: L10N.VoiceOverTitle.memoryMinus.localizedString,
              action: {
                viewModel.memorySub()
              }
            ),
            .right: (
              title: "MR",
              voiceOverTitle: L10N.VoiceOverTitle.memoryRecall.localizedString,
              action: {
                viewModel.inputMemory()
              }
            ),
            .down: (
              title: "MC",
              voiceOverTitle: L10N.VoiceOverTitle.memoryClear.localizedString,
              action: {
                viewModel.memoryClear()
              }
            ),
          ]
        ),
        .init(
          title: "%",
          subtitle: "^ √ !",
          voiceOverTitle: L10N.VoiceOverTitle.mod.localizedString,
          action: {
            viewModel.input(token: ModToken.instance)
          },
          buttonType: .function,
          directions: [
            .up: (
              title: "^",
              voiceOverTitle: L10N.VoiceOverTitle.pow.localizedString,
              action: {
                viewModel.input(token: PowToken.instance)
              }
            ),
            .right: (
              title: "√",
              voiceOverTitle: L10N.VoiceOverTitle.root.localizedString,
              action: {
                viewModel.input(token: RootToken.instance)
              }
            ),
            .down: (
              title: "!",
              voiceOverTitle: L10N.VoiceOverTitle.gamma.localizedString,
              action: {
                viewModel.input(token: GammaToken.instance)
              }
            ),
          ]
        ),
        .init(
          title: "π",
          subtitle: "e i",
          voiceOverTitle: L10N.VoiceOverTitle.pi.localizedString,
          action: {
            viewModel.input(token: ConstToken.pi)
          },
          buttonType: .function,
          directions: [
            .up: (
              title: "e",
              voiceOverTitle: L10N.VoiceOverTitle.napier.localizedString,
              action: {
                viewModel.input(token: ConstToken.napier)
              }
            ),
            .right: (
              title: "i",
              voiceOverTitle: L10N.VoiceOverTitle.imaginaly.localizedString,
              action: {
                viewModel.input(token: ConstToken.complex)
              }
            ),
          ]
        ),
        .init(
          title: "🌐\u{FE0E}",
          subtitle: "ans ret",
          voiceOverTitle: L10N.VoiceOverTitle.pref.localizedString,
          action: {
            viewModel.exit()
          },
          buttonType: .function,
          directions: [
            .up: (
              title: "ans",
              voiceOverTitle: L10N.VoiceOverTitle.ans.localizedString,
              action: {
                viewModel.inputAnswer()
              }
            ),
            .right: (
              title: "ret",
              voiceOverTitle: L10N.VoiceOverTitle.ret.localizedString,
              action: {
                viewModel.inputRetry()
              }
            ),
          ]
        ),
      ],
      [
        .init(
          title: "1",
          voiceOverTitle: "1",
          action: {
            viewModel.input(token: DigitToken._1)
          },
          buttonType: .number,
          directions: [:]
        ),
        .init(
          title: "4",
          subtitle: "sin",
          voiceOverTitle: "4",
          action: {
            viewModel.input(token: DigitToken._4)
          },
          buttonType: .number,
          directions: [
            .up: (
              title: "sinh",
              voiceOverTitle: L10N.VoiceOverTitle.sinh.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.sinh)
              }
            ),
            .left: (
              title: "sin",
              voiceOverTitle: L10N.VoiceOverTitle.sin.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.sin)
              }
            ),
            .right: (
              title: "asin",
              voiceOverTitle: L10N.VoiceOverTitle.asin.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.asin)
              }
            ),
            .down: (
              title: "asinh",
              voiceOverTitle: L10N.VoiceOverTitle.asinh.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.asinh)
              }
            ),
          ]
        ),
        .init(
          title: "7",
          voiceOverTitle: "7",
          action: {
            viewModel.input(token: DigitToken._7)
          },
          buttonType: .number,
          directions: [:]
        ),
        .init(
          title: "()",
          voiceOverTitle: L10N.VoiceOverTitle.bracket.localizedString,
          action: {
            viewModel.inputAutoBracket()
            viewModel.formatBrackets(withCompletion: false)
          },
          buttonType: .number,
          directions: [
            .left: (
              title: "(",
              voiceOverTitle: L10N.VoiceOverTitle.bracketOpen.localizedString,
              action: {
                viewModel.input(token: BracketToken.open)
                viewModel.formatBrackets(withCompletion: false)
              }
            ),
            .right: (
              title: ")",
              voiceOverTitle: L10N.VoiceOverTitle.bracketClose.localizedString,
              action: {
                viewModel.input(token: BracketToken.close)
                viewModel.formatBrackets(withCompletion: false)
              }
            ),
          ]
        ),
      ],
      [
        .init(
          title: "2",
          subtitle: "cos",
          voiceOverTitle: "2",
          action: {
            viewModel.input(token: DigitToken._2)
          },
          buttonType: .number,
          directions: [
            .up: (
              title: "cosh",
              voiceOverTitle: L10N.VoiceOverTitle.cosh.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.cosh)
              }
            ),
            .left: (
              title: "cos",
              voiceOverTitle: L10N.VoiceOverTitle.cos.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.cos)
              }
            ),
            .right: (
              title: "acos",
              voiceOverTitle: L10N.VoiceOverTitle.acos.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.acos)
              }
            ),
            .down: (
              title: "acosh",
              voiceOverTitle: L10N.VoiceOverTitle.acosh.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.acosh)
              }
            ),
          ]
        ),
        .init(
          title: "5",
          voiceOverTitle: "5",
          action: {
            viewModel.input(token: DigitToken._5)
          },
          buttonType: .number,
          directions: [:]
        ),
        .init(
          title: "8",
          subtitle: "log",
          voiceOverTitle: "8",
          action: {
            viewModel.input(token: DigitToken._8)
          },
          buttonType: .number,
          directions: [
            .left: (
              title: "ln",
              voiceOverTitle: L10N.VoiceOverTitle.ln.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.ln)
              }
            ),
            .up: (
              title: "log",
              voiceOverTitle: L10N.VoiceOverTitle.log.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.log)
              }
            ),
            .right: (
              title: "lg",
              voiceOverTitle: L10N.VoiceOverTitle.lg.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.lg)
              }
            ),
          ]
        ),
        .init(
          title: "0",
          subtitle: "00",
          voiceOverTitle: "0",
          action: {
            viewModel.input(token: DigitToken._0)
          },
          buttonType: .number,
          directions: [
            .left: (
              title: "00",
              voiceOverTitle: "00",
              action: {
                viewModel.input(token: DigitToken._0)
                viewModel.input(token: DigitToken._0)
              }
            ),
            .up: (
              title: "000",
              voiceOverTitle: "000",
              action: {
                viewModel.input(token: DigitToken._0)
                viewModel.input(token: DigitToken._0)
                viewModel.input(token: DigitToken._0)
              }
            ),
            .right: (
              title: "0000",
              voiceOverTitle: "0000",
              action: {
                viewModel.input(token: DigitToken._0)
                viewModel.input(token: DigitToken._0)
                viewModel.input(token: DigitToken._0)
                viewModel.input(token: DigitToken._0)
              }
            ),
          ]
        ),
      ],
      [
        .init(
          title: "3",
          voiceOverTitle: "3",
          action: {
            viewModel.input(token: DigitToken._3)
          },
          buttonType: .number,
          directions: [:]
        ),
        .init(
          title: "6",
          subtitle: "tan",
          voiceOverTitle: "6",
          action: {
            viewModel.input(token: DigitToken._6)
          },
          buttonType: .number,
          directions: [
            .up: (
              title: "tanh",
              voiceOverTitle: L10N.VoiceOverTitle.tanh.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.tanh)
              }
            ),
            .left: (
              title: "tan",
              voiceOverTitle: L10N.VoiceOverTitle.tan.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.tan)
              }
            ),
            .right: (
              title: "atan",
              voiceOverTitle: L10N.VoiceOverTitle.atan.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.atan)
              }
            ),
            .down: (
              title: "atanh",
              voiceOverTitle: L10N.VoiceOverTitle.atanh.localizedString,
              action: {
                viewModel.inputFunction(token: FunctionToken.atanh)
              }
            ),
          ]
        ),
        .init(
          title: "9",
          voiceOverTitle: "9",
          action: {
            viewModel.input(token: DigitToken._9)
          },
          buttonType: .number,
          directions: [:]
        ),
        .init(
          title: ".",
          voiceOverTitle: ".",
          action: {
            viewModel.inputAutoDot()
          },
          buttonType: .number,
          directions: [:]
        ),
      ],
      [
        .init(
          title: "⌫",
          voiceOverTitle: L10N.VoiceOverTitle.deleteLeft.localizedString,
          action: {
            viewModel.deleteLeft()
          },
          actionWhilePressing: true,
          buttonType: .function,
          directions: [
            .left: (
              title: "I⌫",
              voiceOverTitle: L10N.VoiceOverTitle.deleteLeftAll.localizedString,
              action: {
                viewModel.deleteLeftAll()
              }
            ),
            .up: (
              title: "⌦",
              voiceOverTitle: L10N.VoiceOverTitle.deleteRight.localizedString,
              action: {
                viewModel.deleteRight()
              }
            ),
            .down: (
              title: "⌦I",
              voiceOverTitle: L10N.VoiceOverTitle.deleteRightAll.localizedString,
              action: {
                viewModel.deleteRightAll()
              }
            ),
          ]
        ),
        .init(
          title: "+",
          subtitle: "- × ÷",
          voiceOverTitle: L10N.VoiceOverTitle.add.localizedString,
          action: {
            viewModel.input(token: AddToken.instance)
          },
          buttonType: .function,
          directions: [
            .up: (
              title: "×",
              voiceOverTitle: L10N.VoiceOverTitle.mul.localizedString,
              action: {
                viewModel.input(token: MulToken.instance)
              }
            ),
            .left: (
              title: "-",
              voiceOverTitle: L10N.VoiceOverTitle.sub.localizedString,
              action: {
                viewModel.input(token: SubToken.instance)
              }
            ),
            .down: (
              title: "÷",
              voiceOverTitle: L10N.VoiceOverTitle.div.localizedString,
              action: {
                viewModel.input(token: DivToken.instance)
              }
            ),
          ]
        ),
        .init(
          title: "→",
          voiceOverTitle: L10N.VoiceOverTitle.moveRight.localizedString,
          action: {
            viewModel.shiftToRight()
          },
          actionWhilePressing: true,
          buttonType: .function,
          directions: [
            .left: (
              title: "←",
              voiceOverTitle: L10N.VoiceOverTitle.moveLeft.localizedString,
              action: {
                viewModel.shiftToLeft()
              }
            )
          ]
        ),
        .init(
          title: "=",
          voiceOverTitle: "=",
          action: {
            viewModel.calculate()
          },
          buttonType: .equal,
          directions: [:]
        ),
      ],
    ]
  }

}
