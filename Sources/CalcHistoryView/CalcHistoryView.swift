//
//  CalcHistoryView.swift
//
//
//  Created by tarunon on 2021/09/20.
//

import Foundation
import SwiftUI

public struct CalcHistoryView: UIViewRepresentable {
  var text: String

  public init(text: String) {
    self.text = text
  }

  public func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.isEditable = false
    textView.text = text
    textView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
    return textView
  }

  public func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.text = text
    uiView.scrollRangeToVisible(.init(location: text.count - 1, length: 0))
  }
}
