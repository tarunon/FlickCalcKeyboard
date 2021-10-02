//
//  InputField.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Core
import SwiftUI
import UIKit

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

struct InputFieldBody: UIViewControllerRepresentable {
  typealias UIViewControllerType = InputFieldController

  var text: String
  var placeholder: AttributedString?
  @Binding var cursor: NSRange

  public func makeCoordinator() -> TextFieldCoordinator {
    TextFieldCoordinator(cursor: $cursor)
  }

  public func makeUIViewController(context: Context) -> InputFieldController {
    setup(InputFieldController()) {
      $0.delegate = context.coordinator
      $0.textField.text = text
      $0.placeholder = placeholder
      $0.cursor = cursor
    }
  }

  public func updateUIViewController(_ uiViewController: InputFieldController, context: Context) {
    uiViewController.textField.text = text
    uiViewController.placeholder = placeholder
    uiViewController.cursor = cursor
  }
}

public struct InputField: View {
  var text: String
  var placeholder: AttributedString?
  @Binding var cursor: NSRange

  public init(text: String, placeholder: AttributedString?, cursor: Binding<NSRange>) {
    self.text = text
    self.placeholder = placeholder
    self._cursor = cursor
  }

  public var body: some View {
    InputFieldBody(text: text, placeholder: placeholder, cursor: $cursor)
  }
}

#if DEBUG

  public struct InputField_Preview: PreviewProvider {
    public static var previews: some View {
      InputField(
        text: "currentText `current` is selected.",
        placeholder: nil,
        cursor: .constant(.init(location: 0, length: 7))
      )
      .frame(width: .infinity, height: 30.0, alignment: .center)
      .previewLayout(.fixed(width: 320.0, height: 30.0))
    }
  }

#endif
