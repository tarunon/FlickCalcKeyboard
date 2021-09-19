//
//  ContentView.swift
//  App
//
//  Created by tarunon on 2021/05/15.
//

import CalcKeyboard
import SwiftUI

struct ContentView: View {
  @State var text: String = ""
  var body: some View {
    VStack {
      if #available(iOS 15.0, *) {
        TextField("", text: $text, prompt: nil)
      } else {
        TextField("", text: $text).lineLimit(nil).frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      CalcKeyboardView()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

class CalcViewController: UIViewController, UITextViewDelegate {
  let textView = UITextView()
  let keyboard = UIHostingController(rootView: CalcKeyboardView())

  override func loadView() {
    view = textView
    textView.delegate = self
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

  }

  func textViewDidBeginEditing(_ textView: UITextView) {
    textView.inputViewController?.addChild(keyboard)
    textView.inputView = keyboard.view
    keyboard.didMove(toParent: textView.inputViewController)
  }
}
