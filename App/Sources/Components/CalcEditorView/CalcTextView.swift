//
//  CalcEditorView.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import CalcKeyboard
import Core
import Foundation
import SwiftUI

final class TextView: UITextView {
  lazy var keyboard = CalcKeyboardController()
  override var inputViewController: UIInputViewController? {
    let windowSize = window?.frame.size ?? UIScreen.main.bounds.size
    keyboard.view.frame = .init(
      origin: .zero,
      size: .init(
        width: windowSize.width,
        height: min(
          300.0,
          windowSize.height * 3 / 5
        )
      )
    )
    return keyboard
  }
}

final class CalcTextViewCoordinator: NSObject, UITextViewDelegate {
  @Binding var text: String

  init(text: Binding<String>) {
    self._text = text
  }

  public func textViewDidChange(_ textView: UITextView) {
    text = textView.text
  }
}

struct CalcTextView: UIViewRepresentable {
  @Binding var text: String

  public init(text: Binding<String>) {
    self._text = text
  }

  public func makeCoordinator() -> CalcTextViewCoordinator {
    CalcTextViewCoordinator(text: $text)
  }

  public func makeUIView(context: Context) -> UITextView {
    setup(TextView()) {
      $0.text = text
      $0.font = UIFont.preferredFont(forTextStyle: .body)
      $0.adjustsFontForContentSizeCategory = true
      $0.delegate = context.coordinator
      $0.becomeFirstResponder()
    }
  }

  public func updateUIView(_ uiView: UITextView, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
  }
}
