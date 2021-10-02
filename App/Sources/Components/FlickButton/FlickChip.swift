//
//  FlickChip.swift
//
//
//  Created by tarunon on 2021/09/23.
//

import SwiftUI

struct FlickChip: View {
  var direction: FlickButton.Direction
  var buttonSize: CGSize
  var title: String

  var body: some View {
    ZStack {
      Path { path in
        path.move(to: .init(x: buttonSize.width / 2, y: buttonSize.height / 2))
        switch direction {
        case .up:
          path.addLine(to: .init(x: 0.0, y: 0.0))
          path.addLine(to: .init(x: buttonSize.width, y: 0.0))
        case .down:
          path.addLine(to: .init(x: buttonSize.width, y: buttonSize.height))
          path.addLine(to: .init(x: buttonSize.width, y: buttonSize.height + 1.0))
          path.addLine(to: .init(x: 0.0, y: buttonSize.height + 1.0))
          path.addLine(to: .init(x: 0.0, y: buttonSize.height))
        case .left:
          path.addLine(to: .init(x: 0.0, y: 0.0))
          path.addLine(to: .init(x: 0.0, y: buttonSize.height))
        case .right:
          path.addLine(to: .init(x: buttonSize.width, y: buttonSize.height))
          path.addLine(to: .init(x: buttonSize.width + 1.0, y: buttonSize.height))
          path.addLine(to: .init(x: buttonSize.width + 1.0, y: 0.0))
          path.addLine(to: .init(x: buttonSize.width, y: 0.0))
        }
        path.addLine(to: .init(x: buttonSize.width / 2, y: buttonSize.height / 2))
        path.closeSubpath()
      }
      .fill(Color.blue)
      Text(title)
        .bold()
        .foregroundColor(.primary)
        .dynamicTypeSize(DynamicTypeSize.xSmall...DynamicTypeSize.xLarge)
        .frame(width: buttonSize.width, height: buttonSize.height, alignment: .center)
        .background(Color.blue)
        .position(direction.buttonLocation(on: buttonSize))
    }
  }
}

#if DEBUG
  struct FlickChip_Preview: PreviewProvider {
    static var previews: some View {
      Group {
        FlickChip(direction: .up, buttonSize: .init(width: 80.0, height: 80.0), title: "Up")
        FlickChip(direction: .left, buttonSize: .init(width: 80.0, height: 80.0), title: "Left")
        FlickChip(direction: .right, buttonSize: .init(width: 80.0, height: 80.0), title: "Right")
        FlickChip(direction: .down, buttonSize: .init(width: 80.0, height: 80.0), title: "Down")
      }
      .frame(width: 240.0, height: 240.0, alignment: .center)
      .transformEffect(.init(translationX: 80.0, y: 80.0))
      .previewLayout(.fixed(width: 240.0, height: 240.0))
    }
  }

#endif
