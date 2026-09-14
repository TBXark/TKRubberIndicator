//
//  TKBubbleCell.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import UIKit

/// One small bubble.
///
/// The outer layer travels along the arc path (and rotates with it), while the
/// inner layer carries the squash and the landing shake, so both transforms can
/// be stacked without cancelling each other.
final class TKBubbleCell: CAShapeLayer {

  /// Inner layer that carries the squash and shake animations.
  private(set) var bubbleLayer = CAShapeLayer()
  private let bubbleScale: CGFloat = 0.5

  init(style: TKRubberPageControlConfig) {
    super.init()
    setUp(style: style)
  }

  override init(layer: Any) {
    super.init(layer: layer)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  private func setUp(style: TKRubberPageControlConfig) {
    frame = CGRect(x: 0, y: 0, width: style.smallBubbleSize, height: style.smallBubbleSize)

    bubbleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
    bubbleLayer.fillColor = style.smallBubbleColor.cgColor
    bubbleLayer.strokeColor = style.backgroundColor.cgColor
    bubbleLayer.lineWidth = style.bubbleXOffsetSpace / 8
    addSublayer(bubbleLayer)
  }

  /// Animates the bubble from `from` to `to` (absolute points in the
  /// superlayer) along a half circle under the bar.
  ///
  /// The model position is already `to`; the animation is additive and purely
  /// visual, so it is always safe to remove it.
  func addArcMovement(from: CGPoint, to: CGPoint, duration: CFTimeInterval) {
    let deltaX = from.x - to.x
    guard deltaX != 0 else { return }
    let radius = abs(deltaX) / 2

    // Arc in additive (delta) space: starts at (deltaX, 0), ends at
    // (0, 0), passing under the bar.
    let movePath = UIBezierPath()
    let arcCenter = CGPoint(x: deltaX / 2, y: 0)
    if deltaX > 0 {
      movePath.addArc(
        withCenter: arcCenter,
        radius: radius,
        startAngle: 0,
        endAngle: .pi,
        clockwise: true
      )
    } else {
      movePath.addArc(
        withCenter: arcCenter,
        radius: radius,
        startAngle: .pi,
        endAngle: 0,
        clockwise: false
      )
    }

    let positionAnimation = CAKeyframeAnimation(keyPath: "position")
    positionAnimation.duration = duration
    positionAnimation.isAdditive = true
    positionAnimation.calculationMode = .paced
    positionAnimation.rotationMode = .rotateAuto
    positionAnimation.path = movePath.cgPath
    add(positionAnimation, forKey: "TKPosition")

    // Squash on the Y axis while flying, applied to the inner layer so it
    // stacks with the outer layer's path rotation.
    let bubbleTransformAnim = CAKeyframeAnimation(keyPath: "transform")
    bubbleTransformAnim.values = [
      NSValue(caTransform3D: CATransform3DIdentity),
      NSValue(caTransform3D: CATransform3DMakeScale(1, bubbleScale, 1)),
      NSValue(caTransform3D: CATransform3DIdentity),
    ]
    bubbleTransformAnim.keyTimes = [0, 0.5, 1]
    bubbleTransformAnim.duration = duration
    bubbleLayer.add(bubbleTransformAnim, forKey: "TKScale")

    // A little shake when the bubble lands.
    let bubbleShakeAnim = CAKeyframeAnimation(keyPath: "position")
    bubbleShakeAnim.beginTime = CACurrentMediaTime() + duration + 0.05
    bubbleShakeAnim.duration = 0.02
    bubbleShakeAnim.values = [
      NSValue(cgPoint: CGPoint(x: 0, y: 0)),
      NSValue(cgPoint: CGPoint(x: 0, y: 3)),
      NSValue(cgPoint: CGPoint(x: 0, y: -3)),
      NSValue(cgPoint: CGPoint(x: 0, y: 0)),
    ]
    bubbleShakeAnim.repeatCount = 6
    bubbleShakeAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    bubbleLayer.add(bubbleShakeAnim, forKey: "TKShake")
  }
}
