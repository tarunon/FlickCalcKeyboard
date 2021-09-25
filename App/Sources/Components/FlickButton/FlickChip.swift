//
//  FlickChip.swift
//
//
//  Created by tarunon on 2021/09/23.
//

import SwiftUI

@MainActor
struct FlickChip: View {
  var direction: FlickButton.Direction
  var geometry: GeometryProxy
  var title: String

  var body: some View {
    ZStack {
      Path { path in
        path.move(to: .init(x: geometry.size.width / 2, y: geometry.size.height / 2))
        switch direction {
        case .up:
          path.addLine(to: .init(x: 0.0, y: 0.0))
          path.addLine(to: .init(x: geometry.size.width, y: 0.0))
        case .down:
          path.addLine(to: .init(x: geometry.size.width, y: geometry.size.height))
          path.addLine(to: .init(x: geometry.size.width, y: geometry.size.height + 1.0))
          path.addLine(to: .init(x: 0.0, y: geometry.size.height + 1.0))
          path.addLine(to: .init(x: 0.0, y: geometry.size.height))
        case .left:
          path.addLine(to: .init(x: 0.0, y: 0.0))
          path.addLine(to: .init(x: 0.0, y: geometry.size.height))
        case .right:
          path.addLine(to: .init(x: geometry.size.width, y: geometry.size.height))
          path.addLine(to: .init(x: geometry.size.width + 1.0, y: geometry.size.height))
          path.addLine(to: .init(x: geometry.size.width + 1.0, y: 0.0))
          path.addLine(to: .init(x: geometry.size.width, y: 0.0))
        }
        path.addLine(to: .init(x: geometry.size.width / 2, y: geometry.size.height / 2))
        path.closeSubpath()
      }
      .fill(Color.blue)
      Text(title)
        .bold()
        .foregroundColor(.primary)
        .dynamicTypeSize(DynamicTypeSize.xSmall...DynamicTypeSize.xLarge)
        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        .background(Color.blue)
        .position(direction.buttonLocation(on: geometry))
    }
  }
}
