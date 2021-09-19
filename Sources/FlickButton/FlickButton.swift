//
//  FlickButton.swift
//
//
//  Created by tarunon on 2021/09/19.
//

import SwiftUI

public struct FlickButton: View {
  public enum Direction: String, Hashable {
    case up
    case down
    case left
    case right
  }

  private var label: String
  private var action: () -> Void
  private var onDrag: () -> Void
  private var backgroundColor: Color
  private var directions: [Direction: (label: String, action: () -> Void)]

  @State private var isDragging: Bool = false
  @State private var currentDirection: Direction? = nil

  public init(
    label: String,
    action: @escaping () -> Void,
    onDrag: @escaping () -> Void,
    backgroundColor: Color = .white,
    directions: [Direction: (label: String, action: () -> Void)]
  ) {
    self.label = label
    self.action = action
    self.onDrag = onDrag
    self.backgroundColor = backgroundColor
    self.directions = directions
  }

  func calcDirection(geometry: GeometryProxy, value: DragGesture.Value) -> Direction? {
    let up = -min(value.location.y, 0)
    let left = -min(value.location.x, 0)
    let right = max(value.location.x - geometry.size.width, 0)
    let down = max(value.location.y - geometry.size.height, 0)
    let max = max(up, left, right, down)
    switch max {
    case 0:
      return nil
    case up:
      return .up
    case left:
      return .left
    case right:
      return .right
    case down:
      return .down
    default:
      return nil
    }
  }

  func buttonLocation(on geometry: GeometryProxy, for direction: Direction) -> CGPoint {
    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
    switch direction {
    case .up:
      return center.applying(.identity.translatedBy(x: 0, y: -50))
    case .down:
      return center.applying(.identity.translatedBy(x: 0, y: 50))
    case .left:
      return center.applying(.identity.translatedBy(x: -50, y: 0))
    case .right:
      return center.applying(.identity.translatedBy(x: 50, y: 0))
    }
  }

  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        if !isDragging || currentDirection.flatMap { directions[$0] } == nil {
          Text(label)
            .bold()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
              backgroundColor
            )
            .cornerRadius(8)
            .brightness(isDragging && currentDirection == nil ? -0.2 : 0.0)
        }
      }
      .gesture(
        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
          .onChanged { value in
            onDrag()
            isDragging = true
            currentDirection = calcDirection(geometry: geometry, value: value)
          }
          .onEnded { value in
            switch currentDirection {
            case nil:
              action()
            case .up:
              directions[.up]?.action()
            case .down:
              directions[.down]?.action()
            case .right:
              directions[.right]?.action()
            case .left:
              directions[.left]?.action()
            }
            isDragging = false
            currentDirection = nil
          }
      )
      ForEach(directions.map { $0 }, id: \.key) { (direction, value) in
        if currentDirection == direction {
          Text(value.label)
            .bold()
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .background(
              backgroundColor
            )
            .cornerRadius(8)
            .brightness(isDragging ? -0.3 : 0.0)
            .position(buttonLocation(on: geometry, for: direction))
        }
      }
    }.zIndex(isDragging ? 1 : 0)
  }
}
