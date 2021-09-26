//
//  Main.swift
//  App
//
//  Created by tarunon on 2021/05/15.
//

import SwiftUI
import CalcEditorView

@main @MainActor
struct CalcApp: App {
  var body: some Scene {
    WindowGroup {
      CalcEditorView()
    }
  }
}
