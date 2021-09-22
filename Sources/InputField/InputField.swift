//
//  InputField.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Builder
import SwiftUI
import UIKit

@MainActor
public class TextFieldCoordinator: NSObject, InputFieldControllerDelegate {
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
public struct InputField: UIViewControllerRepresentable {
  public typealias UIViewControllerType = UIViewController

  var text: String
  var errorMessage: String
  @Binding var cursor: NSRange

  public init(text: String, errorMessage: String, cursor: Binding<NSRange>) {
    self.text = text
    self.errorMessage = errorMessage
    self._cursor = cursor
  }

  public func makeCoordinator() -> TextFieldCoordinator {
    TextFieldCoordinator(cursor: $cursor)
  }

  public func makeUIViewController(context: Context) -> UIViewController {
    let controller = InputFieldController()
    controller.delegate = context.coordinator
    controller.cursor = cursor
    controller.textField.text = text
    controller.errorMessage = errorMessage
    return controller
  }

  public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    let controller = uiViewController as! InputFieldController
    controller.textField.text = text
    controller.errorMessage = errorMessage
    controller.cursor = cursor
  }
}
