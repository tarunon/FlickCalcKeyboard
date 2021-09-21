//
//  CalcHistoryView.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import CalcKeyboard
import Foundation
import SwiftUI

class CalcTextView: UITextView {
  lazy var keyboard = CalcKeyboardController()
  override var inputViewController: UIInputViewController? {
    let windowSize = window?.frame.size ?? UIScreen.main.bounds.size
    keyboard.view.frame = .init(
      origin: .zero,
      size: .init(
        width: windowSize.width,
        height: min(
          300.0, windowSize.height * 3 / 5
        )
      )
    )
    return keyboard
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.reloadInputViews()
  }
}

public class CalcHistoryViewCoordinator: NSObject, UITextViewDelegate {
  @Binding var text: String

  init(text: Binding<String>) {
    self._text = text
  }

  public func textViewDidChange(_ textView: UITextView) {
    text = textView.text
  }
}

public struct CalcHistoryView: UIViewRepresentable {
  @Binding var text: String

  public init(text: Binding<String>) {
    self._text = text
  }

  public func makeCoordinator() -> CalcHistoryViewCoordinator {
    CalcHistoryViewCoordinator(text: $text)
  }

  public func makeUIView(context: Context) -> UITextView {
    let textView = CalcTextView()
    textView.text = text
    textView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    textView.delegate = context.coordinator
    textView.becomeFirstResponder()
    return textView
  }

  public func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
  }
}
