//
//  File.swift
//
//
//  Created by tarunon on 2021/09/26.
//

import SwiftUI

public struct CalcEditorView: View {
  @State var text: String = ""

  public init() {}

  public var body: some View {
    VStack(spacing: 0.0) {
      ZStack(alignment: .topTrailing) {
        CalcTextView(text: $text)
        Button {
          text = ""
        } label: {
          Text("×").bold()
            .frame(width: 44.0, height: 44.0)
        }
        .foregroundColor(.primary)
        .zIndex(1)
      }
    }
  }
}
