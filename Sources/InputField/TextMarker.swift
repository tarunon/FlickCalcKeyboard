//
//  TextMarker.swift
//
//
//  Created by tarunon on 2021/09/22.
//

import SwiftUI

@MainActor
struct TextMarker: View {
  class Blink: ObservableObject {
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
  @ObservedObject var blink = Blink()

  init(flushing: Bool) {
    self.flushing = flushing
    self.blink.reset()
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
      blink.toggle()
    }
    .opacity(flushing && blink.hide ? 0.0 : 1.0)
    .animation(Animation.easeInOut(duration: 0.1), value: blink.hide)
  }
}
