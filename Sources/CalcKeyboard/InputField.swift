//
//  InputField.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Builder
import SwiftUI
import UIKit

@objc protocol InputFieldControllerDelegate: NSObjectProtocol {
  @objc optional func inputFieldDidChangeSelection(_ controller: InputFieldController)
}

struct TextMarker: View {
  class ViewModel: ObservableObject {
    @Published var hide: Bool = false
    var wait: Bool = true

    func toggle() {
      if wait {
        wait.toggle()
      } else {
        hide.toggle()
      }
    }

    func reset() {
      wait = true
      hide = false
    }
  }

  var flushing: Bool
  private var blinkTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
  @ObservedObject var viewModel = ViewModel()

  init(flushing: Bool) {
    self.flushing = flushing
    self.viewModel.reset()
  }

  var body: some View {
    ZStack(alignment: .trailing) {
      ZStack(alignment: .leading) {
        Color.blue.opacity(0.2).frame(maxWidth: .infinity, maxHeight: .infinity)
        Color.blue.frame(width: 2.0)
      }
      Color.blue.frame(width: 2.0)
    }
    .onReceive(blinkTimer) { _ in
      viewModel.toggle()
    }
    .opacity(flushing && viewModel.hide ? 0.0 : 1.0)
    .animation(Animation.easeInOut(duration: 0.1), value: viewModel.hide)
  }
}

class InputFieldController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
  lazy var textField: UITextField = build {
    let textField = UITextField()
    textField.delegate = self
    textField.borderStyle = .roundedRect
    textField.text = ""
    textField.selectedTextRange = textField.textRange(
      from: textField.beginningOfDocument, to: textField.endOfDocument)
    textField.addGestureRecognizer(self.dragGestureRecognizer)
    return textField
  }

  lazy var textMarker = UIHostingController(
    rootView: TextMarker(
      flushing: false
    ))
  lazy var dragGestureRecognizer: UILongPressGestureRecognizer = build {
    let dragGestureRecognizer = UILongPressGestureRecognizer(
      target: self, action: #selector(self.didDrag(_:)))
    dragGestureRecognizer.minimumPressDuration = 0.0
    dragGestureRecognizer.delegate = self
    return dragGestureRecognizer
  }
  var delegate: InputFieldControllerDelegate?

  override func loadView() {
    view = textField
    addChild(textMarker)
    view.addSubview(textMarker.view)
    textMarker.didMove(toParent: self)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    updateCursor()
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
          from: textField.beginningOfDocument, offset: newValue.lowerBound),
        let end = textField.position(
          from: textField.beginningOfDocument, offset: newValue.upperBound),
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
        textField.textInputView.frame, to: textField
      ).origin
      textMarker.view.frame = rect.applying(
        .identity.translatedBy(x: inputOrigin.x / 2, y: inputOrigin.y / 2))
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

class TextFieldCoordinator: NSObject, InputFieldControllerDelegate {
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

struct InputField: UIViewControllerRepresentable {
  typealias UIViewControllerType = InputFieldController

  var text: String
  @Binding var cursor: NSRange

  func makeCoordinator() -> TextFieldCoordinator {
    TextFieldCoordinator(cursor: $cursor)
  }

  func makeUIViewController(context: Context) -> InputFieldController {
    let controller = InputFieldController()
    controller.delegate = context.coordinator
    controller.cursor = cursor
    return controller
  }

  func updateUIViewController(_ uiViewController: InputFieldController, context: Context) {
    uiViewController.textField.text = text
    uiViewController.cursor = cursor
  }
}
