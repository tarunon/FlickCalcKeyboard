//
//  InputFieldController.swift
//
//
//  Created by tarunon on 2021/09/22.
//

import Builder
import SwiftUI
import UIKit

@MainActor
@objc protocol InputFieldControllerDelegate: NSObjectProtocol {
  @objc optional func inputFieldDidChangeSelection(_ controller: InputFieldController)
}

@MainActor
class InputFieldController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
  lazy var textField: UITextField = build {
    let textField = UITextField()
    textField.delegate = self
    textField.borderStyle = .roundedRect
    textField.text = ""
    textField.selectedTextRange = textField.textRange(
      from: textField.beginningOfDocument,
      to: textField.endOfDocument
    )
    textField.addGestureRecognizer(self.dragGestureRecognizer)
    return textField
  }

  lazy var textMarker = UIHostingController(
    rootView: TextMarker(
      flushing: true
    )
  )
  lazy var dragGestureRecognizer: UILongPressGestureRecognizer = build {
    let dragGestureRecognizer = UILongPressGestureRecognizer(
      target: self,
      action: #selector(self.didDrag(_:))
    )
    dragGestureRecognizer.minimumPressDuration = 0.0
    dragGestureRecognizer.delegate = self
    return dragGestureRecognizer
  }
  var delegate: InputFieldControllerDelegate?

  var errorMessage: String = "" {
    didSet {
      textField.attributedPlaceholder = NSAttributedString(
        string: errorMessage,
        attributes: [
          .foregroundColor: UIColor.systemRed
        ]
      )
      textMarker.view.isHidden = !errorMessage.isEmpty
    }
  }

  override func loadView() {
    view = textField
    addChild(textMarker)
    view.addSubview(textMarker.view)
    textMarker.view.frame = .init(x: 7.0, y: 3.0, width: 2.0, height: 22.0)
    textMarker.didMove(toParent: self)
  }

  var cursor: NSRange? {
    get {
      guard let start = textField.selectedTextRange?.start,
        let end = textField.selectedTextRange?.end
      else {
        return nil
      }
      return NSRange(
        location: textField.offset(from: textField.beginningOfDocument, to: start),
        length: textField.offset(from: start, to: end)
      )
    }
    set {
      guard let newValue = newValue,
        let start = textField.position(
          from: textField.beginningOfDocument,
          offset: newValue.lowerBound
        ),
        let end = textField.position(
          from: textField.beginningOfDocument,
          offset: newValue.upperBound
        ),
        let range = textField.textRange(from: start, to: end)
      else {
        textField.selectedTextRange = nil
        return
      }
      textField.selectedTextRange = range
    }
  }

  func updateCursor() {
    if let start = textField.selectedTextRange?.start,
      let end = textField.selectedTextRange?.end
    {
      let rect = textField.caretRect(for: start).union(textField.caretRect(for: end))
      let inputOrigin = textField.textInputView.convert(
        textField.textInputView.frame,
        to: textField
      ).origin
      textMarker.view.frame = rect.applying(
        .identity.translatedBy(x: inputOrigin.x / 2, y: inputOrigin.y / 2)
      )
      // Notes: √ change line height.
      textMarker.view.frame.origin.y = 3.0
      textMarker.view.frame.size.height = 22.0
      textMarker.rootView = .init(flushing: start == end)
    }
  }

  @objc func didDrag(_ recognizer: UILongPressGestureRecognizer) {
    let location = recognizer.location(in: textField)
    guard let cursor = textField.closestPosition(to: location),
      let start = textField.selectedTextRange?.start,
      let end = textField.selectedTextRange?.end
    else {
      return
    }
    if start == end {
      textField.selectedTextRange = textField.textRange(from: cursor, to: cursor)
    }
    updateCursor()
  }

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    false
  }

  func textFieldDidChangeSelection(_ textField: UITextField) {
    updateCursor()
    delegate?.inputFieldDidChangeSelection?(self)
  }

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    true
  }
}
