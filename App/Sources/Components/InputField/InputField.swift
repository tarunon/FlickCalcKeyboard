//
//  InputField.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Core
import SwiftUI
import UIKit

@MainActor
final public class TextFieldCoordinator: NSObject, InputFieldControllerDelegate {
  @Binding var cursor: NSRange

  init(cursor: Binding<NSRange>) {
    _cursor = cursor
    super.init()
  }

  func inputFieldDidChangeSelection(_ controller: InputFieldController) {
    if let cursor = controller.cursor {
      self.cursor = cursor
    }
  }
}

@MainActor
struct InputFieldBody: UIViewControllerRepresentable {
  typealias UIViewControllerType = InputFieldController

  var text: String
  var errorMessage: String
  @Binding var cursor: NSRange

  public func makeCoordinator() -> TextFieldCoordinator {
    TextFieldCoordinator(cursor: $cursor)
  }

  public func makeUIViewController(context: Context) -> InputFieldController {
    setup(InputFieldController()) {
      $0.delegate = context.coordinator
      $0.textField.text = text
      $0.errorMessage = errorMessage
      $0.cursor = cursor
    }
  }

  public func updateUIViewController(_ uiViewController: InputFieldController, context: Context) {
    uiViewController.textField.text = text
    uiViewController.errorMessage = errorMessage
    uiViewController.cursor = cursor
  }
}

@MainActor
public struct InputField: View {
  var text: String
  var errorMessage: String
  @Binding var cursor: NSRange

  public init(text: String, errorMessage: String, cursor: Binding<NSRange>) {
    self.text = text
    self.errorMessage = errorMessage
    self._cursor = cursor
  }

  public var body: some View {
    InputFieldBody(text: text, errorMessage: errorMessage, cursor: $cursor)
  }
}
