//
//  InputField.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import SwiftUI
import UIKit

class TextFieldCoordinator: NSObject, UITextFieldDelegate {
  @Binding var cursor: NSRange

  init(cursor: Binding<NSRange>) {
    _cursor = cursor
    super.init()
  }

  func textFieldDidChangeSelection(_ textField: UITextField) {
    if let start = textField.selectedTextRange?.start,
      let end = textField.selectedTextRange?.end
    {
      cursor = NSRange(
        location: textField.offset(from: textField.beginningOfDocument, to: start),
        length: textField.offset(from: start, to: end)
      )
    }
  }
}

struct InputField: UIViewRepresentable {
  typealias UIViewType = UITextField

  var text: String
  @Binding var cursor: NSRange

  func makeCoordinator() -> TextFieldCoordinator {
    TextFieldCoordinator(cursor: $cursor)
  }

  func makeUIView(context: Context) -> UITextField {
    let textField = UITextField()
    textField.inputView = UIView()
    textField.text = text
    textField.delegate = context.coordinator
    textField.borderStyle = .roundedRect
    textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textField.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

    if let start = textField.position(
      from: textField.beginningOfDocument, offset: cursor.lowerBound),
      let end = textField.position(
        from: textField.beginningOfDocument, offset: cursor.upperBound),
      let range = textField.textRange(from: start, to: end)
    {
      textField.selectedTextRange = range
    }
    textField.becomeFirstResponder()
    return textField
  }

  func updateUIView(_ uiView: UITextField, context: Context) {
    uiView.text = text
    if let start = uiView.position(
      from: uiView.beginningOfDocument, offset: cursor.lowerBound),
      let end = uiView.position(
        from: uiView.beginningOfDocument, offset: cursor.upperBound),
      let range = uiView.textRange(from: start, to: end)
    {
      uiView.selectedTextRange = range
    }
    uiView.becomeFirstResponder()
  }
}
