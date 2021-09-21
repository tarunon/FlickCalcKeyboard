//
//  ContentView.swift
//  App
//
//  Created by tarunon on 2021/05/15.
//

import CalcHistoryView
import CalcKeyboard
import SwiftUI

@MainActor
struct ContentView: View {
  @State var text: String = ""
  var body: some View {
    VStack(spacing: 0.0) {
      ZStack(alignment: .topTrailing) {
        CalcHistoryView(text: $text)
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

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
