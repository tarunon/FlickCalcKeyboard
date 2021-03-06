//
//  SwiftUIView.swift
//
//
//  Created by tarunon on 2021/09/19.
//

import Bundles
import Calculator
import Core
import FlickButton
import InputField
import SwiftUI

struct CalcKeyboardView: View {
  @State private var draggingLine: Int? = nil
  @ObservedObject private var viewModel: CalcKeyboardViewModel

  init(
    action: @escaping (CalcAction) -> Void
  ) {
    self.viewModel = CalcKeyboardViewModel(
      action: action
    )
  }

  var body: some View {
    VStack(spacing: 0.0) {
      InputField(
        text: viewModel.text,
        placeholder: viewModel.placeholder,
        cursor: .init(
          get: { viewModel.cursor },
          set: { viewModel.cursor = $0 }
        )
      )
      .padding(4.0)
      .frame(height: 36.0, alignment: .top)
      keyboardButtons
    }
    .clipped()
    .background(Color.backgroundColor)
  }

  var keyboardButtons: some View {
    HStack(spacing: 0.0) {
      ForEach(Array(buttonParameters.enumerated()), id: \.offset) { (hOffset, line) in
        VStack(spacing: 0.0) {
          ForEach(Array(line.enumerated()), id: \.offset) { (vOffset, parameter) in
            FlickButton(
              title: parameter.title,
              subtitle: parameter.subtitle,
              voiceOverTitle: parameter.voiceOverTitle,
              action: parameter.action,
              actionWhilePressing: parameter.actionWhilePressing,
              onDrag: {
                draggingLine = hOffset
              },
              backgroundColor: parameter.buttonType.buttonColor,
              directions: parameter.directions
            )
            if vOffset != 3 {
              Divider().background(.secondary)
            }
          }
        }.zIndex(draggingLine == hOffset ? 1 : 0)
        if hOffset != 4 {
          Divider().background(.secondary)
        }
      }
    }
    .padding(0.0)
    .frame(maxWidth: .infinity, maxHeight: 270.0, alignment: .bottom)
  }

  var buttonParameters: [[ButtonParameter]] {
    [
      [
        .init(
          title: "M+",
          subtitle: "M- MR MC",
          voiceOverTitle: L10N.VoiceOverTitle.memoryPlus.localizedString,
          action: {
            Task { [self] in
              await self.viewModel.memoryAdd()
            }
          },
          buttonType: .function,
          directions: [
            .up: (
              title: "M-",
              voiceOverTitle: L10N.VoiceOverTitle.memoryMinus.localizedString,
              action: {
                Task { [self] in
                  await self.viewModel.memorySub()
                }
              }
            ),
            .right: (
              title: "MR",
              voiceOverTitle: L10N.VoiceOverTitle.memoryRecall.localizedString,
              action: {
                Task { [self] in
                  await self.viewModel.inputMemory()
                }
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
          subtitle: "^ ??? !",
          voiceOverTitle: L10N.VoiceOverTitle.mod.localizedString,
          action: {
            viewModel.input(.Operator.mod)
          },
          buttonType: .function,
          directions: [
            .up: (
              title: "^",
              voiceOverTitle: L10N.VoiceOverTitle.pow.localizedString,
              action: {
                viewModel.input(.Operator.pow)
              }
            ),
            .right: (
              title: "???",
              voiceOverTitle: L10N.VoiceOverTitle.root.localizedString,
              action: {
                viewModel.input(.Operator.root)
              }
            ),
            .down: (
              title: "!",
              voiceOverTitle: L10N.VoiceOverTitle.gamma.localizedString,
              action: {
                viewModel.input(.Operator.gamma)
              }
            ),
          ]
        ),
        .init(
          title: "??",
          subtitle: "e i",
          voiceOverTitle: L10N.VoiceOverTitle.pi.localizedString,
          action: {
            viewModel.input(.Const.pi)
          },
          buttonType: .function,
          directions: [
            .up: (
              title: "e",
              voiceOverTitle: L10N.VoiceOverTitle.napier.localizedString,
              action: {
                viewModel.input(.Const.napier)
              }
            ),
            .right: (
              title: "i",
              voiceOverTitle: L10N.VoiceOverTitle.imaginaly.localizedString,
              action: {
                viewModel.input(.Const.imaginaly)
              }
            ),
          ]
        ),
        .init(
          title: "????\u{FE0E}",
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
                Task { [self] in
                  await self.viewModel.inputAnswer()
                }
              }
            ),
            .right: (
              title: "ret",
              voiceOverTitle: L10N.VoiceOverTitle.ret.localizedString,
              action: {
                Task { [self] in
                  await self.viewModel.inputRetry()
                }
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
            viewModel.input(.Digit._1)
          },
          buttonType: .number,
          directions: [:]
        ),
        .init(
          title: "4",
          subtitle: "sin",
          voiceOverTitle: "4",
          action: {
            viewModel.input(.Digit._4)
          },
          buttonType: .number,
          directions: [
            .up: (
              title: "sinh",
              voiceOverTitle: L10N.VoiceOverTitle.sinh.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.sinh)
              }
            ),
            .left: (
              title: "sin",
              voiceOverTitle: L10N.VoiceOverTitle.sin.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.sin)
              }
            ),
            .right: (
              title: "asin",
              voiceOverTitle: L10N.VoiceOverTitle.asin.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.asin)
              }
            ),
            .down: (
              title: "asinh",
              voiceOverTitle: L10N.VoiceOverTitle.asinh.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.asinh)
              }
            ),
          ]
        ),
        .init(
          title: "7",
          voiceOverTitle: "7",
          action: {
            viewModel.input(.Digit._7)
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
                viewModel.input(.Bracket.open)
                viewModel.formatBrackets(withCompletion: false)
              }
            ),
            .right: (
              title: ")",
              voiceOverTitle: L10N.VoiceOverTitle.bracketClose.localizedString,
              action: {
                viewModel.input(.Bracket.close)
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
            viewModel.input(.Digit._2)
          },
          buttonType: .number,
          directions: [
            .up: (
              title: "cosh",
              voiceOverTitle: L10N.VoiceOverTitle.cosh.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.cosh)
              }
            ),
            .left: (
              title: "cos",
              voiceOverTitle: L10N.VoiceOverTitle.cos.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.cos)
              }
            ),
            .right: (
              title: "acos",
              voiceOverTitle: L10N.VoiceOverTitle.acos.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.acos)
              }
            ),
            .down: (
              title: "acosh",
              voiceOverTitle: L10N.VoiceOverTitle.acosh.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.acosh)
              }
            ),
          ]
        ),
        .init(
          title: "5",
          voiceOverTitle: "5",
          action: {
            viewModel.input(.Digit._5)
          },
          buttonType: .number,
          directions: [:]
        ),
        .init(
          title: "8",
          subtitle: "log",
          voiceOverTitle: "8",
          action: {
            viewModel.input(.Digit._8)
          },
          buttonType: .number,
          directions: [
            .left: (
              title: "ln",
              voiceOverTitle: L10N.VoiceOverTitle.ln.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.ln)
              }
            ),
            .up: (
              title: "log",
              voiceOverTitle: L10N.VoiceOverTitle.log.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.log)
              }
            ),
            .right: (
              title: "lg",
              voiceOverTitle: L10N.VoiceOverTitle.lg.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.lg)
              }
            ),
          ]
        ),
        .init(
          title: "0",
          subtitle: "00",
          voiceOverTitle: "0",
          action: {
            viewModel.input(.Digit._0)
          },
          buttonType: .number,
          directions: [
            .left: (
              title: "00",
              voiceOverTitle: "00",
              action: {
                viewModel.input(.Digit._0, .Digit._0)
              }
            ),
            .up: (
              title: "000",
              voiceOverTitle: "000",
              action: {
                viewModel.input(.Digit._0, .Digit._0, .Digit._0)
              }
            ),
            .right: (
              title: "0000",
              voiceOverTitle: "0000",
              action: {
                viewModel.input(.Digit._0, .Digit._0, .Digit._0, .Digit._0)
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
            viewModel.input(.Digit._3)
          },
          buttonType: .number,
          directions: [:]
        ),
        .init(
          title: "6",
          subtitle: "tan",
          voiceOverTitle: "6",
          action: {
            viewModel.input(.Digit._6)
          },
          buttonType: .number,
          directions: [
            .up: (
              title: "tanh",
              voiceOverTitle: L10N.VoiceOverTitle.tanh.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.tanh)
              }
            ),
            .left: (
              title: "tan",
              voiceOverTitle: L10N.VoiceOverTitle.tan.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.tan)
              }
            ),
            .right: (
              title: "atan",
              voiceOverTitle: L10N.VoiceOverTitle.atan.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.atan)
              }
            ),
            .down: (
              title: "atanh",
              voiceOverTitle: L10N.VoiceOverTitle.atanh.localizedString,
              action: {
                viewModel.inputFunction(token: .Function.atanh)
              }
            ),
          ]
        ),
        .init(
          title: "9",
          voiceOverTitle: "9",
          action: {
            viewModel.input(.Digit._9)
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
          title: "???",
          voiceOverTitle: L10N.VoiceOverTitle.deleteLeft.localizedString,
          action: {
            viewModel.delete(direction: .left, line: false)
          },
          actionWhilePressing: true,
          buttonType: .function,
          directions: [
            .left: (
              title: "I???",
              voiceOverTitle: L10N.VoiceOverTitle.deleteLeftAll.localizedString,
              action: {
                viewModel.delete(direction: .left, line: true)
              }
            ),
            .up: (
              title: "???",
              voiceOverTitle: L10N.VoiceOverTitle.deleteRight.localizedString,
              action: {
                viewModel.delete(direction: .right, line: false)
              }
            ),
            .down: (
              title: "???I",
              voiceOverTitle: L10N.VoiceOverTitle.deleteRightAll.localizedString,
              action: {
                viewModel.delete(direction: .right, line: true)
              }
            ),
          ]
        ),
        .init(
          title: "+",
          subtitle: "- ?? ??",
          voiceOverTitle: L10N.VoiceOverTitle.add.localizedString,
          action: {
            viewModel.input(.Operator.add)
          },
          buttonType: .function,
          directions: [
            .up: (
              title: "??",
              voiceOverTitle: L10N.VoiceOverTitle.mul.localizedString,
              action: {
                viewModel.input(.Operator.mul)
              }
            ),
            .left: (
              title: "-",
              voiceOverTitle: L10N.VoiceOverTitle.sub.localizedString,
              action: {
                viewModel.input(.Operator.sub)
              }
            ),
            .down: (
              title: "??",
              voiceOverTitle: L10N.VoiceOverTitle.div.localizedString,
              action: {
                viewModel.input(.Operator.div)
              }
            ),
          ]
        ),
        .init(
          title: "???",
          voiceOverTitle: L10N.VoiceOverTitle.moveRight.localizedString,
          action: {
            viewModel.shift(direction: .right)
          },
          actionWhilePressing: true,
          buttonType: .function,
          directions: [
            .left: (
              title: "???",
              voiceOverTitle: L10N.VoiceOverTitle.moveLeft.localizedString,
              action: {
                viewModel.shift(direction: .left)
              }
            )
          ]
        ),
        .init(
          title: "=",
          voiceOverTitle: "=",
          action: {
            Task { [self] in
              await self.viewModel.calculate()
            }
          },
          buttonType: .equal,
          directions: [:]
        ),
      ],
    ]
  }
}

#if DEBUG
  struct CalcKeyboardView_Preview: PreviewProvider {
    static var previews: some View {
      CalcKeyboardView { _ in }
        .frame(height: 256.0, alignment: .bottom)
        .previewLayout(.fixed(width: 300.0, height: 256.0))
    }
  }
#endif
