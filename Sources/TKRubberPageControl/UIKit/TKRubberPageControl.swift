//
//  TKRubberPageControl.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import UIKit

/// A rubber-animation page control.
///
/// The public API is source compatible with the 1.x releases, while the
/// implementation has been rewritten:
///
/// - Assigning `currentIndex` animates and fires the `valueChanged` action and
///   the `valueChange` closure (it previously did nothing).
/// - Bubble positions are always derived from the current index, so rapid taps
///   or interrupted animations can no longer make bubbles drift out of place.
/// - The layout adapts to frame changes (e.g. rotation).
open class TKRubberPageControl: UIControl {

  // MARK: - Public API

  /// Number of pages. Changing it rebuilds the indicator and resets
  /// `currentIndex` to `0`.
  open var numberOfPage: Int {
    get { storedPageCount }
    set {
      let count = max(1, newValue)
      guard count != storedPageCount else { return }
      storedPageCount = count
      reset()
    }
  }

  /// The currently selected page.
  ///
  /// Assigning a new value animates the rubber animation and fires the
  /// `valueChanged` action and the `valueChange` closure. Values outside
  /// `0...(numberOfPage - 1)` are clamped.
  open var currentIndex: Int {
    get { storedIndex }
    set { setIndex(newValue, animated: true) }
  }

  /// Closure based change listener.
  open var valueChange: ((Int) -> Void)?

  /// Style configuration. Assigning a new value rebuilds the indicator and
  /// resets `currentIndex` to `0`.
  open var styleConfig: TKRubberPageControlConfig {
    didSet {
      guard oldValue != styleConfig else { return }
      reset()
    }
  }

  /// Rebuilds the indicator with the current `numberOfPage` and `styleConfig`
  /// and resets `currentIndex` to `0`.
  open func resetRubberIndicator() {
    reset()
  }

  // MARK: - Initialization

  public init(
    frame: CGRect,
    count: Int,
    config: TKRubberPageControlConfig = TKRubberPageControlConfig()
  ) {
    storedPageCount = max(1, count)
    styleConfig = config
    super.init(frame: frame)
    rebuildLayers()
    setUpInteraction()
  }

  public required init?(coder aDecoder: NSCoder) {
    storedPageCount = 5
    styleConfig = TKRubberPageControlConfig()
    super.init(coder: aDecoder)
    rebuildLayers()
    setUpInteraction()
  }

  private func setUpInteraction() {
    let tap = UITapGestureRecognizer(
      target: self, action: #selector(handleTapGestureRecognizer(_:)))
    addGestureRecognizer(tap)

    isAccessibilityElement = true
    accessibilityTraits = .adjustable
    updateAccessibilityValue()
  }

  // MARK: - Private state

  private var storedPageCount: Int = 5
  private var storedIndex: Int = 0

  private var smallBubbles = [TKBubbleCell]()
  /// Page slot each small bubble currently occupies. Together with
  /// `storedIndex` this is the single source of truth for bubble positions,
  /// which is what keeps the layout consistent when animations are
  /// interrupted mid-flight.
  private var smallBubbleSlots = [Int]()

  private let barLayer = CAShapeLayer()
  private let bumpLayer = CAShapeLayer()
  private let bigBubbleLayer = CAShapeLayer()

  /// Scale of the big bubble at the middle of a page change.
  private let bigBubbleSquashScale: CGFloat = 1 / 3
  private var lastLayoutSize: CGSize = .zero

  private var metrics: RubberPageControlMetrics {
    styleConfig.metrics(pageCount: storedPageCount)
  }

  // MARK: - Build

  private func reset() {
    let previousIndex = storedIndex
    storedIndex = 0
    rebuildLayers()
    if previousIndex != 0 {
      sendActions(for: .valueChanged)
      valueChange?(0)
    }
  }

  private func rebuildLayers() {
    for bubble in smallBubbles {
      bubble.removeFromSuperlayer()
    }
    smallBubbles.removeAll()
    barLayer.removeFromSuperlayer()
    bumpLayer.removeFromSuperlayer()
    bigBubbleLayer.removeFromSuperlayer()

    smallBubbleSlots = metrics.bubbleSlots(forSelection: 0)

    barLayer.fillColor = styleConfig.backgroundColor.cgColor
    barLayer.zPosition = 0
    layer.addSublayer(barLayer)

    let bumpSize = CGSize(width: styleConfig.mainBubbleSize, height: styleConfig.mainBubbleSize)
    bumpLayer.path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: bumpSize)).cgPath
    bumpLayer.bounds = CGRect(origin: .zero, size: bumpSize)
    bumpLayer.fillColor = styleConfig.backgroundColor.cgColor
    bumpLayer.zPosition = -1
    layer.addSublayer(bumpLayer)

    let bubbleDiameter = metrics.bigBubbleDiameter
    let bubbleBounds = CGRect(x: 0, y: 0, width: bubbleDiameter, height: bubbleDiameter)
    bigBubbleLayer.path = UIBezierPath(ovalIn: bubbleBounds).cgPath
    bigBubbleLayer.bounds = bubbleBounds
    bigBubbleLayer.fillColor = styleConfig.bigBubbleColor.cgColor
    bigBubbleLayer.zPosition = 100
    layer.addSublayer(bigBubbleLayer)

    for _ in smallBubbleSlots {
      let bubble = TKBubbleCell(style: styleConfig)
      bubble.zPosition = 1
      layer.addSublayer(bubble)
      smallBubbles.append(bubble)
    }

    snapToModel()
    updateAccessibilityValue()
    invalidateIntrinsicContentSize()
    setNeedsLayout()
  }

  // MARK: - Layout

  open override func layoutSubviews() {
    super.layoutSubviews()
    guard lastLayoutSize != bounds.size else { return }
    lastLayoutSize = bounds.size
    guard barLayer.superlayer === layer else { return }
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    applyGeometry()
    CATransaction.commit()
  }

  /// Snaps every layer to the position dictated by `storedIndex` and the
  /// recorded bubble slots.
  private func snapToModel() {
    removeLayerAnimations()
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    applyGeometry()
    CATransaction.commit()
  }

  private func applyGeometry() {
    let size = bounds.size
    let bar = metrics.barRect(in: size)
    barLayer.path = UIBezierPath(roundedRect: bar, cornerRadius: bar.height / 2).cgPath
    barLayer.frame = bounds

    let bigCenter = metrics.center(ofPage: storedIndex, in: size)
    bumpLayer.position = bigCenter
    bigBubbleLayer.position = bigCenter
    for (bubble, slot) in zip(smallBubbles, smallBubbleSlots) {
      bubble.position = metrics.center(ofPage: slot, in: size)
    }
  }

  private func removeLayerAnimations() {
    barLayer.removeAllAnimations()
    bumpLayer.removeAllAnimations()
    bigBubbleLayer.removeAllAnimations()
    for bubble in smallBubbles {
      bubble.removeAllAnimations()
      bubble.bubbleLayer.removeAllAnimations()
    }
  }

  // MARK: - Selection

  private func setIndex(_ newIndex: Int, animated: Bool) {
    let index = metrics.clamp(newIndex)
    guard index != storedIndex else { return }
    let previousIndex = storedIndex
    storedIndex = index
    if animated, storedPageCount > 1 {
      animateSelection(from: previousIndex, to: index)
    } else {
      snapToModel()
    }
    sendActions(for: .valueChanged)
    valueChange?(index)
    updateAccessibilityValue()
  }

  private func animateSelection(from previousIndex: Int, to index: Int) {
    // Drop in-flight animations first: the model positions applied below are
    // the final ones, so removing the old presentation values is safe.
    removeLayerAnimations()

    // Small bubbles follow the big bubble like a queue: moving to a higher
    // page shifts the bubbles in between one slot left, moving back shifts
    // them one slot right.
    let isMovingForward = index > previousIndex
    let movingRange = isMovingForward ? previousIndex..<index : index..<previousIndex

    var movedBubbles: [(bubble: TKBubbleCell, from: CGPoint, to: CGPoint)] = []
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    let size = bounds.size
    for bubbleIndex in movingRange {
      guard smallBubbles.indices.contains(bubbleIndex) else { continue }
      let fromSlot = smallBubbleSlots[bubbleIndex]
      let toSlot = isMovingForward ? fromSlot - 1 : fromSlot + 1
      smallBubbleSlots[bubbleIndex] = toSlot
      let fromCenter = metrics.center(ofPage: fromSlot, in: size)
      let toCenter = metrics.center(ofPage: toSlot, in: size)
      smallBubbles[bubbleIndex].position = toCenter
      movedBubbles.append((smallBubbles[bubbleIndex], fromCenter, toCenter))
    }
    CATransaction.commit()

    // Big bubble and its background bump slide to the new page with the
    // implicit transaction animation.
    let duration = styleConfig.animationDuration
    let bigCenter = metrics.center(ofPage: index, in: size)
    CATransaction.begin()
    CATransaction.setAnimationDuration(duration)
    bigBubbleLayer.position = bigCenter
    bumpLayer.position = bigCenter
    CATransaction.commit()

    // Big bubble squash: shrink to `bigBubbleSquashScale` and grow back.
    let bubbleTransformAnim = CAKeyframeAnimation(keyPath: "transform")
    bubbleTransformAnim.values = [
      NSValue(caTransform3D: CATransform3DIdentity),
      NSValue(caTransform3D: CATransform3DMakeScale(bigBubbleSquashScale, bigBubbleSquashScale, 1)),
      NSValue(caTransform3D: CATransform3DIdentity),
    ]
    bubbleTransformAnim.keyTimes = [0, 0.5, 1]
    bubbleTransformAnim.duration = duration
    bigBubbleLayer.add(bubbleTransformAnim, forKey: "TKScale")

    // Small bubbles hop along a half circle under the bar.
    for item in movedBubbles {
      item.bubble.addArcMovement(from: item.from, to: item.to, duration: duration)
    }
  }

  // MARK: - Interaction

  @objc private func handleTapGestureRecognizer(_ gesture: UITapGestureRecognizer) {
    selectPage(at: gesture.location(in: self))
  }

  /// Selects the page nearest to a point in the control's coordinate space.
  func selectPage(at point: CGPoint) {
    guard let page = metrics.page(atX: point.x, in: bounds.size) else { return }
    setIndex(page, animated: true)
  }

  // MARK: - Sizing

  open override var intrinsicContentSize: CGSize {
    metrics.intrinsicSize
  }

  // MARK: - Accessibility

  private func updateAccessibilityValue() {
    accessibilityValue = "Page \(storedIndex + 1) of \(storedPageCount)"
  }

  open override func accessibilityIncrement() {
    setIndex(storedIndex + 1, animated: true)
  }

  open override func accessibilityDecrement() {
    setIndex(storedIndex - 1, animated: true)
  }
}
