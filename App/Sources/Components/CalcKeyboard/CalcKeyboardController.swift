//
//  CalcKeyboard.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Core
import SwiftUI
import UIKit

final public class CalcKeyboardController: UIInputViewController {
  public static var shouldShowBottomMargin: Bool {
    UIDevice.current.userInterfaceIdiom == .phone && UIDevice.current.orientation.isPortrait
      && UIApplication.shared.delegate != nil
  }

  var margin: CGFloat {
    CalcKeyboardController.shouldShowBottomMargin ? 40.0 : 0.0
  }

  lazy var keyboardViewController = UIHostingController(
    rootView: CalcKeyboardView(
      action: { [weak self] action in
        guard let self = self else { return }
        switch action {
        case .insertText(let text):
          self.textDocumentProxy.insertText(text)
        case .deleteLeft(let line):
          if self.textDocumentProxy.selectedText != nil {
            self.textDocumentProxy.deleteBackward()
            return
          }
          self.textDocumentProxy.deleteBackward()
          if line {
            while let before = self.textDocumentProxy.documentContextBeforeInput, before != "\n" {
              self.textDocumentProxy.deleteBackward()
            }
          }
        case .deleteRight(let line):
          if self.textDocumentProxy.selectedText != nil {
            self.textDocumentProxy.deleteBackward()
            return
          }
          if let after = self.textDocumentProxy.documentContextAfterInput {
            self.textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
            self.textDocumentProxy.deleteBackward()
          }
          if line {
            while let after = self.textDocumentProxy.documentContextAfterInput, after != "" {
              self.textDocumentProxy.adjustTextPosition(byCharacterOffset: 1)
              self.textDocumentProxy.deleteBackward()
            }
          }
        case .moveCursor(let offset):
          self.textDocumentProxy.adjustTextPosition(byCharacterOffset: offset)
        case .exit:
          if UIApplication.shared.delegate == nil {  // is KeyboardExtension
            self.advanceToNextInputMode()
          } else {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          }
        }
      })
  )

  lazy var keyboardHeight: [NSLayoutConstraint] = [
    setup(
      from: self.inputView!.heightAnchor.constraint(
        lessThanOrEqualToConstant: min(256.0, UIScreen.main.bounds.height * 3.0 / 5.0)
      )
    ) {
      $0.priority = .defaultHigh
    },
    setup(
      from: self.inputView!.heightAnchor.constraint(
        equalToConstant: min(256.0, UIScreen.main.bounds.height * 3.0 / 5.0)
      )
    ) {
      $0.priority = .defaultHigh
    },
  ]

  lazy var bottomMargin: NSLayoutConstraint = self.inputView!.safeAreaLayoutGuide.bottomAnchor
    .constraint(equalTo: self.keyboardViewController.view.bottomAnchor, constant: self.margin)

  public override func viewDidLoad() {
    super.viewDidLoad()
    guard let inputView = inputView else {
      fatalError()
    }
    NSLayoutConstraint.activate(keyboardHeight)
    addChild(keyboardViewController)
    inputView.addSubview(keyboardViewController.view)
    keyboardViewController.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      inputView.topAnchor.constraint(equalTo: keyboardViewController.view.topAnchor),
      inputView.leftAnchor.constraint(equalTo: keyboardViewController.view.leftAnchor),
      inputView.rightAnchor.constraint(equalTo: keyboardViewController.view.rightAnchor),
      self.bottomMargin,
    ])
    didMove(toParent: keyboardViewController)
  }

  public override func viewWillLayoutSubviews() {
    view.frame.size.width = view.superview?.frame.width ?? 0.0
    super.viewWillLayoutSubviews()
  }

  public override func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)
    keyboardHeight.forEach {
      $0.constant = min(256.0, (UIScreen.main.bounds.height * 3.0 / 5.0))
    }
    bottomMargin.constant = margin
    self.inputView?.setNeedsLayout()
    coordinator.animate { _ in
      self.inputView?.layoutIfNeeded()
    }
  }

  public override func textWillChange(_ textInput: UITextInput?) {
    super.textWillChange(textInput)
  }

  public override func textDidChange(_ textInput: UITextInput?) {
    super.textDidChange(textInput)
  }
}
