//
//  CalcEditorView.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import CalcKeyboard
import Foundation
import SwiftUI

@MainActor
class CalcTextView: UITextView {
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

@MainActor
public class CalcEditorViewCoordinator: NSObject, UITextViewDelegate {
  @Binding var text: String

  init(text: Binding<String>) {
    self._text = text
  }

  public func textViewDidChange(_ textView: UITextView) {
    text = textView.text
  }
}

@MainActor
public struct CalcEditorView: UIViewRepresentable {
  @Binding var text: String

  public init(text: Binding<String>) {
    self._text = text
  }

  public func makeCoordinator() -> CalcEditorViewCoordinator {
    CalcEditorViewCoordinator(text: $text)
  }

  public func makeUIView(context: Context) -> UITextView {
    let textView = CalcTextView()
    textView.text = text
    textView.font = UIFont.preferredFont(forTextStyle: .body)
    textView.adjustsFontForContentSizeCategory = true
    textView.delegate = context.coordinator
    textView.becomeFirstResponder()
    return textView
  }

  public func updateUIView(_ uiView: UITextView, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
  }
}
