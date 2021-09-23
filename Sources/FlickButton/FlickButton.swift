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

    func buttonLocation(on geometry: GeometryProxy) -> CGPoint {
      let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
      switch self {
      case .up:
        return center.applying(.identity.translatedBy(x: 0, y: -geometry.size.height))
      case .down:
        return center.applying(.identity.translatedBy(x: 0, y: geometry.size.height))
      case .left:
        return center.applying(.identity.translatedBy(x: -geometry.size.width, y: 0))
      case .right:
        return center.applying(.identity.translatedBy(x: geometry.size.width, y: 0))
      }
    }

    func voiceOverMessage(title: String) -> String {
      switch self {
      case .up:
        return NSLocalizedString(
          "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_up",
          comment: ""
        ) + title
      case .down:
        return NSLocalizedString(
          "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_down",
          comment: ""
        ) + title
      case .left:
        return NSLocalizedString(
          "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_left",
          comment: ""
        ) + title
      case .right:
        return NSLocalizedString(
          "com.tarunon.flickcalckeyboard.voice_over.navigate.flick_to_right",
          comment: ""
        ) + title
      }
    }
  }

  private var title: String
  private var subtitle: String?
  private var voiceOverTitle: String
  private var action: () -> Void
  private var onDrag: () -> Void
  private var backgroundColor: Color
  private var actionWhilePressing: Bool
  private var actionTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  private var directions: [Direction: (title: String, voiceOverTitle: String, action: () -> Void)]

  @State private var isDragging: Bool = false
  @State private var currentDirection: Direction? = nil
  @State private var directionsWhilePressing: [Direction?] = []

  public init(
    title: String,
    subtitle: String? = nil,
    voiceOverTitle: String,
    action: @escaping () -> Void,
    actionWhilePressing: Bool = false,
    onDrag: @escaping () -> Void,
    backgroundColor: Color = .white,
    directions: [Direction: (title: String, voiceOverTitle: String, action: () -> Void)]
  ) {
    self.title = title
    self.subtitle = subtitle
    self.voiceOverTitle = voiceOverTitle
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

  func sendVoiceOver(announcement: String) {
    UIAccessibility.post(notification: .announcement, argument: announcement)
  }

  public var body: some View {
    GeometryReader { geometry in
      ZStack {
        backgroundColor
        if isDragging && (currentDirection == nil || directions[currentDirection!] != nil) {
          Color.primary
            .opacity(0.2)
        }
        if !isDragging || currentDirection.flatMap { directions[$0] } == nil {
          Text(title)
            .bold()
            .foregroundColor(.primary)
            .dynamicTypeSize(DynamicTypeSize.xSmall...DynamicTypeSize.xLarge)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          if let subtitle = subtitle {
            Text(subtitle)
              .bold()
              .foregroundColor(.secondary)
              .font(.caption2)
              .dynamicTypeSize(DynamicTypeSize.xSmall...DynamicTypeSize.xLarge)
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
            if let currentDirection = currentDirection {
              if let target = directions[currentDirection] {
                target.action()
                sendVoiceOver(announcement: target.voiceOverTitle)
              }
            } else {
              action()
              sendVoiceOver(announcement: voiceOverTitle)
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
      if let direction = currentDirection, let title = directions[direction]?.title {
        FlickChip(direction: direction, geometry: geometry, title: title)
      }
    }.zIndex(isDragging ? 1 : 0)
      .accessibilityElement()
      .accessibilityLabel(voiceOverTitle)
      .accessibilityHint(
        directions.map { (key, value) in
          key.voiceOverMessage(title: value.voiceOverTitle)
        }.joined(separator: ". ")
      )
      .accessibilityAddTraits(.isButton)
  }
}
