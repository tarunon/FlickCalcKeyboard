//
//  FlickButton.swift
//
//
//  Created by tarunon on 2021/09/19.
//

import Combine
import SwiftUI

@MainActor
public struct FlickButton: View {
  public enum Direction: String, Hashable {
    case up
    case down
    case left
    case right
  }

  private var title: String
  private var subtitle: String?
  private var action: () -> Void
  private var onDrag: () -> Void
  private var backgroundColor: Color
  private var actionWhilePressing: Bool
  private var actionTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  private var directions: [Direction: (label: String, action: () -> Void)]

  @State private var isDragging: Bool = false
  @State private var currentDirection: Direction? = nil
  @State private var directionsWhilePressing: [Direction?] = []

  public init(
    title: String,
    subtitle: String? = nil,
    action: @escaping () -> Void,
    actionWhilePressing: Bool = false,
    onDrag: @escaping () -> Void,
    backgroundColor: Color = .white,
    directions: [Direction: (label: String, action: () -> Void)]
  ) {
    self.title = title
    self.subtitle = subtitle
    self.action = action
    self.actionWhilePressing = actionWhilePressing
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
        backgroundColor
          .cornerRadius(8)
          .brightness(isDragging && currentDirection == nil ? -0.2 : 0.0)
        if !isDragging || currentDirection.flatMap { directions[$0] } == nil {
          Text(title)
            .bold()
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          if let subtitle = subtitle {
            Text(subtitle)
              .bold()
              .foregroundColor(.secondary)
              .font(.caption2)
              .position(x: geometry.size.width / 2, y: geometry.size.height * 4 / 5)
          }
        }
      }
      .gesture(
        DragGesture(minimumDistance: 0.0, coordinateSpace: .local)
          .onChanged { value in
            onDrag()
            isDragging = true
            currentDirection = calcDirection(geometry: geometry, value: value)
            if directionsWhilePressing.last != currentDirection {
              directionsWhilePressing = [currentDirection]
            }
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
            directionsWhilePressing = []
          }
      ).onReceive(actionTimer) { _ in
        if isDragging && actionWhilePressing {
          directionsWhilePressing.append(currentDirection)
          if directionsWhilePressing.count > 10 {
            if directionsWhilePressing.allSatisfy({ $0 == nil }) {
              action()
            } else {
              for direction in [Direction.up, .left, .right, .down] {
                if directionsWhilePressing.allSatisfy({ $0 == direction }) {
                  directions[direction]?.action()
                }
              }
            }
          }
        }
      }
      ForEach(directions.map { $0 }, id: \.key) { (direction, value) in
        if currentDirection == direction {
          Text(value.label)
            .bold()
            .foregroundColor(.primary)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            .background(Color.blue)
            .cornerRadius(8)
            .position(buttonLocation(on: geometry, for: direction))
        }
      }
    }.zIndex(isDragging ? 1 : 0)
  }
}
