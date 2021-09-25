//
//  InputFieldController.swift
//
//
//  Created by tarunon on 2021/09/22.
//

import Builder
import Core
import SwiftUI
import UIKit

@MainActor
class InputTextField: UITextField {
  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return super.textRect(forBounds: bounds).inset(
      by: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 50.0)
    )
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return super.editingRect(forBounds: bounds).inset(
      by: .init(top: 0.0, left: 0.0, bottom: 0.0, right: 50.0)
    )
  }
}

@MainActor
@objc protocol InputFieldControllerDelegate: NSObjectProtocol {
  @objc optional func inputFieldDidChangeSelection(_ controller: InputFieldController)
}

@MainActor
class InputFieldController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
  lazy var textField = setup(from: UITextField()) {
    $0.translatesAutoresizingMaskIntoConstraints = false
    $0.delegate = self
    $0.borderStyle = .none
    $0.font = UIFont.preferredFont(forTextStyle: .body)
    $0.adjustsFontForContentSizeCategory = true
    $0.text = ""
    $0.selectedTextRange = $0.textRange(from: $0.beginningOfDocument, to: $0.endOfDocument)
    $0.addGestureRecognizer(self.dragGestureRecognizer)
    $0.setContentCompressionResistancePriority(.required, for: .vertical)
  }

  lazy var scrollView = setup(from: UIScrollView()) {
    $0.backgroundColor = UIColor.tertiarySystemBackground
    $0.layer.cornerRadius = 5.0
    $0.panGestureRecognizer.minimumNumberOfTouches = 3
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
  }

  lazy var textMarker = setup(
    from: UIHostingController(
      rootView: TextMarker(
        flushing: true
      )
    )
  ) {
    $0.view.frame = .init(x: 7.0, y: 3.0, width: 2.0, height: 22.0)
    $0.view.backgroundColor = .clear
  }

  lazy var dragGestureRecognizer = setup(
    from: UILongPressGestureRecognizer(
      target: self,
      action: #selector(self.didDrag(_:))
    )
  ) {
    $0.minimumPressDuration = 0.0
    $0.delegate = self
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
    view = scrollView
    scrollView.addSubview(textField)
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: scrollView.topAnchor),
      textField.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 5.0),
      textField.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: 5.0),
      textField.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      textField.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
      textField.widthAnchor.constraint(
        greaterThanOrEqualTo: scrollView.widthAnchor,
        constant: -10.0
      ),
    ])
    addChild(textMarker)
    scrollView.addSubview(textMarker.view)
    textMarker.didMove(toParent: self)
  }

  var doAfterLayoutStack: [() -> Void] = []

  func callAfterLayout(_ f: @escaping (() -> Void)) {
    doAfterLayoutStack.append(f)
    view.setNeedsLayout()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !doAfterLayoutStack.isEmpty {
      doAfterLayoutStack.removeLast()()
    }
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
    // Note: Should wait textField.textInputView rendering before update curosr
    if textField.textInputView.frame.width
      < textField.attributedText?.boundingRect(with: .zero, options: [], context: nil).width ?? 0.0
    {
      callAfterLayout { [weak self] in self?.updateCursor() }
      return
    }
    if let start = textField.selectedTextRange?.start,
      let end = textField.selectedTextRange?.end
    {
      let rect = textField.caretRect(for: start).union(textField.caretRect(for: end))
      let inputOrigin = textField.textInputView.convert(
        textField.textInputView.frame,
        to: textField
      ).origin
      textMarker.view.frame = scrollView.convert(
        rect.applying(
          .identity.translatedBy(x: inputOrigin.x / 2, y: inputOrigin.y / 2)
        ),
        from: textField
      )
      // Notes: √ change line height.
      textMarker.view.frame.origin.y = 3.0
      textMarker.view.frame.size.height = 22.0
      textMarker.rootView = .init(flushing: start == end)
      scrollView.scrollRectToVisible(
        textMarker.view.frame.inset(by: .init(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)),
        animated: false
      )
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
  }

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    false
  }

  func textFieldDidChangeSelection(_ textField: UITextField) {
    callAfterLayout { [weak self] in self?.updateCursor() }
    delegate?.inputFieldDidChangeSelection?(self)
  }

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    true
  }
}
