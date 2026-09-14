//
//  RubberPageControl.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import Foundation
import SwiftUI

/// A rubber-animation page control.
///
/// The control is fully declarative: the selected page lives in the bound
/// value, and every bubble position is derived from it. Changing the binding
/// animates the bubbles, and tapping the control writes back to the binding.
///
/// ```swift
/// struct ContentView: View {
///     @State private var page = 0
///
///     var body: some View {
///         RubberPageControl(selection: $page, pageCount: 5)
///     }
/// }
/// ```
///
/// On iOS 15 and later, changes made from outside the control are animated
/// automatically. On iOS 13 and 14 wrap the assignment in `withAnimation` to
/// animate it.
public struct RubberPageControl: View {

  @Binding private var selection: Int
  /// The page the current transition started from. Every moving part normalises
  /// its squash against this, so a multi-page jump squashes once instead of
  /// once per page crossed, matching the UIKit implementation.
  @State private var transitionOrigin: Int
  private let pageCount: Int
  private let style: RubberPageControlStyle

  public init(
    selection: Binding<Int>,
    pageCount: Int,
    style: RubberPageControlStyle = RubberPageControlStyle()
  ) {
    _selection = selection
    _transitionOrigin = State(initialValue: selection.wrappedValue)
    self.pageCount = max(1, pageCount)
    self.style = style
  }

  public var body: some View {
    let layout = Layout(
      metrics: RubberPageControlMetrics(style: style, pageCount: pageCount),
      style: style
    )
    let selected = layout.metrics.clamp(selection)
    // On iOS 13 there is no `onChange`, so the transition origin cannot be
    // tracked. Passing the destination as both ends makes the motion fall back
    // to a per-page squash, which still animates correctly.
    let origin = transitionStart(layout: layout, selected: selected)

    return content(layout: layout, selected: selected, origin: origin)
      .frame(width: layout.size.width, height: layout.size.height)
      .contentShape(Rectangle())
      .gesture(selectionGesture(layout: layout))
      .modifier(
        TransitionTracker(
          selection: selection,
          origin: $transitionOrigin
        )
      )
      .modifier(SelectionAnimation(animation: style.animation, selection: selection))
      .modifier(ControlAccessibility(selected: selected, pageCount: pageCount))
      .accessibilityAdjustableAction { direction in
        adjustment(for: direction, selected: selected, layout: layout)
      }
  }

  private func transitionStart(layout: Layout, selected: Int) -> Int {
    if #available(iOS 14.0, *) {
      return layout.metrics.clamp(transitionOrigin)
    }
    return selected
  }

  @ViewBuilder
  private func content(layout: Layout, selected: Int, origin: Int) -> some View {
    ZStack {
      bar(layout: layout)
      bump(layout: layout, selected: selected, origin: origin)
      smallBubbles(layout: layout, selected: selected, origin: origin)
      bigBubble(layout: layout, selected: selected, origin: origin)
    }
  }

  private func bar(layout: Layout) -> some View {
    Capsule(style: .continuous)
      .fill(style.barColor)
      .frame(width: layout.metrics.barWidth, height: layout.metrics.barHeight)
  }

  private func bump(layout: Layout, selected: Int, origin: Int) -> some View {
    Circle()
      .fill(style.barColor)
      .frame(width: style.mainBubbleSize, height: style.mainBubbleSize)
      .modifier(
        PageMotion(
          page: CGFloat(selected),
          from: CGFloat(origin),
          to: CGFloat(selected),
          spacing: layout.metrics.pageSpacing,
          baseX: layout.baseX,
          baseY: layout.baseY
        )
      )
  }

  private func bigBubble(layout: Layout, selected: Int, origin: Int) -> some View {
    Circle()
      .fill(style.bigBubbleColor)
      .frame(width: layout.metrics.bigBubbleDiameter, height: layout.metrics.bigBubbleDiameter)
      .modifier(
        PageMotion(
          page: CGFloat(selected),
          from: CGFloat(origin),
          to: CGFloat(selected),
          spacing: layout.metrics.pageSpacing,
          baseX: layout.baseX,
          baseY: layout.baseY,
          squashX: 1 / 3,
          squashY: 1 / 3
        )
      )
  }

  @ViewBuilder
  private func smallBubbles(layout: Layout, selected: Int, origin: Int) -> some View {
    let slots = layout.metrics.bubbleSlots(forSelection: selected)
    let previousSlots = layout.metrics.bubbleSlots(forSelection: origin)
    ForEach(0..<(pageCount - 1), id: \.self) { index in
      smallBubble(layout: layout, from: previousSlots[index], to: slots[index])
    }
  }

  private func smallBubble(layout: Layout, from: Int, to: Int) -> some View {
    Circle()
      .fill(style.smallBubbleColor)
      .overlay(bubbleBorder)
      .frame(width: style.smallBubbleSize, height: style.smallBubbleSize)
      .modifier(
        PageMotion(
          page: CGFloat(to),
          from: CGFloat(from),
          to: CGFloat(to),
          spacing: layout.metrics.pageSpacing,
          baseX: layout.baseX,
          baseY: layout.baseY,
          squashY: 0.5,
          dip: layout.metrics.pageSpacing / 2
        )
      )
  }

  private var bubbleBorder: some View {
    Circle().strokeBorder(style.barColor, lineWidth: max(1, style.bubbleSpacing / 8))
  }

  private func selectionGesture(layout: Layout) -> some Gesture {
    DragGesture(minimumDistance: 0).onEnded { value in
      if let page = layout.metrics.page(atX: value.location.x, in: layout.size) {
        select(page, layout: layout)
      }
    }
  }

  private func adjustment(
    for direction: AccessibilityAdjustmentDirection,
    selected: Int,
    layout: Layout
  ) {
    switch direction {
    case .increment:
      select(selected + 1, layout: layout)
    case .decrement:
      select(selected - 1, layout: layout)
    @unknown default:
      break
    }
  }

  private func select(_ page: Int, layout: Layout) {
    let target = layout.metrics.clamp(page)
    guard target != selection else { return }
    withAnimation(style.animation) {
      selection = target
    }
  }

  /// Precomputed geometry, so the view body stays cheap to type-check.
  private struct Layout {
    let metrics: RubberPageControlMetrics
    let size: CGSize
    let baseX: CGFloat
    let baseY: CGFloat

    init(metrics: RubberPageControlMetrics, style: RubberPageControlStyle) {
      let size = metrics.intrinsicSize
      let origin = metrics.center(ofPage: 0, in: size)
      self.metrics = metrics
      self.size = size
      self.baseX = origin.x - size.width / 2
      self.baseY = origin.y - size.height / 2
    }
  }
}

// MARK: - Animation

/// Animates changes of `selection` that come from outside the control.
///
/// `View.animation(_:value:)` is only available on iOS 15, so on earlier
/// versions callers animate the binding themselves with `withAnimation`.
private struct SelectionAnimation: ViewModifier {
  let animation: Animation
  let selection: Int

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOS 15.0, *) {
      content.animation(animation, value: selection)
    } else {
      content
    }
  }
}

/// Tracks which page the current transition started from.
///
/// The moving parts need both ends of the transition to normalise the squash;
/// the destination is just `selection`, but the origin is the previous
/// selection, which has to be remembered. `onChange` only reports the new value
/// on iOS 14-16, so the previously seen value is cached here.
private struct TransitionTracker: ViewModifier {
  let selection: Int
  @Binding var origin: Int
  @State private var lastSeen: Int?

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOS 14.0, *) {
      content
        .onAppear { lastSeen = selection }
        .onChange(of: selection) { newValue in
          origin = lastSeen ?? newValue
          lastSeen = newValue
        }
    } else {
      // Without `onChange` there is no implicit animation either, so the origin
      // is only ever read at rest, where it does not affect the result.
      content
    }
  }
}

/// Exposes the control as a single adjustable accessibility element.
///
/// The `accessibilityLabel` / `accessibilityValue` modifiers are only available
/// on iOS 14; on iOS 13 the equivalent `accessibility(label:value:)` modifiers
/// are used instead.
private struct ControlAccessibility: ViewModifier {
  let selected: Int
  let pageCount: Int

  @ViewBuilder
  func body(content: Content) -> some View {
    if #available(iOS 14.0, *) {
      content
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Page"))
        .accessibilityValue(Text("\(selected + 1) of \(pageCount)"))
    } else {
      content
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Page"))
        .accessibility(value: Text("\(selected + 1) of \(pageCount)"))
    }
  }
}

/// Places one moving part of the control for a given (possibly fractional)
/// page position.
///
/// `page` interpolates between whole numbers while the selection changes, and
/// the squash is a single lobe over the whole transition — the same shape the
/// UIKit implementation gets from its one-shot keyframe animation, rather than
/// one pulse per page crossed on a multi-page jump.
///
/// The base position is part of the effect on purpose. Applying it as a static
/// `.offset` before the effect makes the squash pivot around the cell's
/// *pre-offset* center, which also scales that base offset and flings the part
/// sideways — the harder it squashes, the further off it lands.
struct PageMotion: GeometryEffect {
  /// Current (possibly fractional) page position.
  var page: CGFloat
  /// Page position the transition started from.
  let from: CGFloat
  /// Page position the transition is heading to.
  let to: CGFloat
  let spacing: CGFloat
  let baseX: CGFloat
  let baseY: CGFloat
  var squashX: CGFloat = 1
  var squashY: CGFloat = 1
  /// How far the part dips below the bar in the middle of the travel.
  var dip: CGFloat = 0

  var animatableData: CGFloat {
    get { page }
    set { page = newValue }
  }

  /// `0` when the transition starts, `1` when it lands.
  ///
  /// When the two ends coincide the transition origin is unknown — that is the
  /// resting state, and also every frame on iOS 13, where the origin cannot be
  /// tracked. In that case the squash falls back to once per page crossed,
  /// which still animates cleanly.
  var progress: CGFloat {
    let distance = to - from
    guard distance != 0 else { return page - page.rounded(.down) }
    return min(max((page - from) / distance, 0), 1)
  }

  func effectValue(size: CGSize) -> ProjectionTransform {
    ProjectionTransform(transform(in: size))
  }

  /// The transform applied to the cell, exposed separately so it can be tested
  /// without going through `ProjectionTransform`.
  func transform(in size: CGSize) -> CGAffineTransform {
    // `0` on a page, `1` half way through the transition.
    let travel = abs(sin(.pi * progress))
    let centerX = size.width / 2
    let centerY = size.height / 2
    let scaleX = 1 - (1 - squashX) * travel
    let scaleY = 1 - (1 - squashY) * travel

    // Squash about the cell's own center, then translate in screen space. The
    // order matters: `translatedBy` on an already-scaled transform is itself
    // scaled, which drags the cell off the bar as it squashes. `concatenating`
    // applies the scale first and the translation in the parent's space.
    let squash = CGAffineTransform(scaleX: scaleX, y: scaleY)
      .concatenating(
        CGAffineTransform(
          translationX: centerX * (1 - scaleX),
          y: centerY * (1 - scaleY)
        )
      )
    let move = CGAffineTransform(
      translationX: baseX + spacing * page,
      y: baseY + dip * travel
    )
    return squash.concatenating(move)
  }
}
