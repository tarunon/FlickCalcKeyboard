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

  var keyboardSize: CGSize {
    let windowSize = window?.frame.size ?? UIScreen.main.bounds.size
    return .init(
      width: windowSize.width,
      height:
        UIDevice.current.userInterfaceIdiom == .pad
        ? CGFloat(260.0)
        : (min(256.0, windowSize.height * 3.0 / 5.0)
          + CGFloat(CalcKeyboardController.shouldShowBottomMargin ? 40.0 : 0.0)
          + (window?.safeAreaInsets.bottom ?? 0.0))
    )
  }

  var verticalSizeClass: UserInterfaceSizeClass? {
    didSet {
      keyboard.view.frame.size = keyboardSize
    }
  }

  override var inputViewController: UIInputViewController? {
    return keyboard
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    keyboard.view.frame.size = keyboardSize
    reloadInputViews()
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
  @Environment(\.verticalSizeClass) var verticalSizeClass

  public init(text: Binding<String>) {
    self._text = text
  }

  public func makeCoordinator() -> CalcTextViewCoordinator {
    CalcTextViewCoordinator(text: $text)
  }

  public func makeUIView(context: Context) -> TextView {
    setup(TextView()) {
      $0.text = text
      $0.font = UIFont.preferredFont(forTextStyle: .body)
      $0.adjustsFontForContentSizeCategory = true
      $0.delegate = context.coordinator
      $0.becomeFirstResponder()
      $0.verticalSizeClass = verticalSizeClass
    }
  }

  public func updateUIView(_ uiView: TextView, context: Context) {
    if uiView.text != text {
      uiView.text = text
    }
    uiView.verticalSizeClass = verticalSizeClass
  }
}

#if DEBUG
  struct CalcTextView_Preview: PreviewProvider {
    static var previews: some View {
      CalcTextView(text: .constant("1+e^πi = 0"))
    }
  }
#endif
