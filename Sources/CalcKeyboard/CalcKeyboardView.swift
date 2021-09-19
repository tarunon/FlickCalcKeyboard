//
//  SwiftUIView.swift
//
//
//  Created by tarunon on 2021/09/19.
//

import FlickButton
import SwiftUI

public struct CalcKeyboardView: View {
  @State var draggingLine: Int? = nil

  public init() {}
  public var body: some View {
    HStack(spacing: 4.0) {
      VStack(spacing: 4.0) {
        FlickButton(
          label: "M+",
          action: {
          },
          onDrag: {
            draggingLine = 0
          },
          backgroundColor: .init(white: 0.8),
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
          label: "%",
          action: {
          },
          onDrag: {
            draggingLine = 0
          },
          backgroundColor: .init(white: 0.8),
          directions: [
            .up: (
              label: "^",
              action: {

              }
            ),
            .right: (
              label: "√",
              action: {

              }
            ),
            .down: (
              label: "!",
              action: {

              }
            ),
          ]
        )
        FlickButton(
          label: "π",
          action: {
          },
          onDrag: {
            draggingLine = 0
          },
          backgroundColor: .init(white: 0.8),
          directions: [
            .right: (
              label: "e",
              action: {

              }
            ),
            .down: (
              label: "i",
              action: {

              }
            ),
          ]
        )
        FlickButton(
          label: "ans",
          action: {
          },
          onDrag: {
            draggingLine = 0
          },
          backgroundColor: .init(white: 0.8),
          directions: [
            .right: (
              label: "ret",
              action: {

              }
            )
          ]
        )
      }.zIndex(draggingLine == 0 ? 1 : 0)
      VStack(spacing: 4.0) {
        FlickButton(
          label: "7",
          action: {
          },
          onDrag: {
            draggingLine = 1
          },
          directions: [:]
        )
        FlickButton(
          label: "4",
          action: {
          },
          onDrag: {
            draggingLine = 1
          },
          directions: [
            .up: (
              label: "sinh",
              action: {

              }
            ),
            .left: (
              label: "sin",
              action: {

              }
            ),
            .right: (
              label: "asin",
              action: {

              }
            ),
            .down: (
              label: "asinh",
              action: {

              }
            ),
          ]
        )
        FlickButton(
          label: "1",
          action: {
          },
          onDrag: {
            draggingLine = 1
          },
          directions: [:]
        )
        FlickButton(
          label: ".",
          action: {
          },
          onDrag: {
            draggingLine = 1
          },
          directions: [:]
        )
      }.zIndex(draggingLine == 1 ? 1 : 0)
      VStack(spacing: 4.0) {
        FlickButton(
          label: "8",
          action: {
          },
          onDrag: {
            draggingLine = 2
          },
          directions: [
            .up: (
              label: "cosh",
              action: {

              }
            ),
            .left: (
              label: "cos",
              action: {

              }
            ),
            .right: (
              label: "acos",
              action: {

              }
            ),
            .down: (
              label: "acosh",
              action: {

              }
            ),
          ]
        )
        FlickButton(
          label: "5",
          action: {
          },
          onDrag: {
            draggingLine = 2
          },
          directions: [:]
        )
        FlickButton(
          label: "2",
          action: {
          },
          onDrag: {
            draggingLine = 2
          },
          directions: [
            .left: (
              label: "ln",
              action: {

              }
            ),
            .right: (
              label: "lg",
              action: {

              }
            ),
          ]
        )
        FlickButton(
          label: "0",
          action: {
          },
          onDrag: {
            draggingLine = 2
          },
          directions: [
            .left: (
              label: "00",
              action: {

              }
            ),
            .up: (
              label: "000",
              action: {

              }
            ),
            .right: (
              label: "0000",
              action: {

              }
            ),
          ]
        )
      }.zIndex(draggingLine == 2 ? 1 : 0)
      VStack(spacing: 4.0) {
        FlickButton(
          label: "9",
          action: {
          },
          onDrag: {
            draggingLine = 3
          },
          directions: [:]
        )
        FlickButton(
          label: "6",
          action: {
          },
          onDrag: {
            draggingLine = 3
          },
          directions: [
            .up: (
              label: "tanh",
              action: {

              }
            ),
            .left: (
              label: "tan",
              action: {

              }
            ),
            .right: (
              label: "atan",
              action: {

              }
            ),
            .down: (
              label: "atanh",
              action: {

              }
            ),
          ]
        )
        FlickButton(
          label: "3",
          action: {
          },
          onDrag: {
            draggingLine = 3
          },
          directions: [:]
        )
        FlickButton(
          label: "()",
          action: {
          },
          onDrag: {
            draggingLine = 3
          },
          directions: [
            .left: (
              label: "(",
              action: {

              }
            ),
            .right: (
              label: ")",
              action: {

              }
            ),
          ]
        )
      }.zIndex(draggingLine == 3 ? 1 : 0)
      VStack(spacing: 4.0) {
        VStack(spacing: 4.0) {
          FlickButton(
            label: "⌫",
            action: {
            },
            onDrag: {
              draggingLine = 4
            },
            backgroundColor: .init(white: 0.8),
            directions: [:]
          )
          FlickButton(
            label: "+",
            action: {
            },
            onDrag: {
              draggingLine = 4
            },
            backgroundColor: .init(white: 0.8),
            directions: [
              .up: (
                label: "×",
                action: {

                }
              ),
              .left: (
                label: "-",
                action: {

                }
              ),
              .down: (
                label: "÷",
                action: {

                }
              ),
            ]
          )
        }.zIndex(1)
        FlickButton(
          label: "=",
          action: {
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
    .padding(4.0)
    .background(Color.init(white: 0.9))
    .frame(maxWidth: .infinity, maxHeight: 280.0, alignment: .bottom)
  }
}
