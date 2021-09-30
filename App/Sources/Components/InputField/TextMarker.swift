//
//  TextMarker.swift
//
//
//  Created by tarunon on 2021/09/22.
//

import SwiftUI

struct TextMarker: View {
  final class Blink: ObservableObject {
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

#if DEBUG

  public struct TextMarker_Preview: PreviewProvider {
    public static var previews: some View {
      Group {
        TextMarker(flushing: false)
          .frame(width: 40.0, height: 20.0, alignment: .center)

        TextMarker(flushing: true)
          .frame(width: 2.0, height: 20.0, alignment: .center)
      }
      .previewLayout(.fixed(width: 40.0, height: 20.0))
    }
  }

#endif
