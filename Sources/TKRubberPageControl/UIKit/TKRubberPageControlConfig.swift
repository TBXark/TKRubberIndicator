//
//  TKRubberPageControlConfig.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import UIKit

/// Style configuration for `TKRubberPageControl`.
///
/// The fields and default values are identical to the 1.x releases.
public struct TKRubberPageControlConfig: Equatable {
  /// Diameter of the unselected small bubbles.
  public var smallBubbleSize: CGFloat
  /// Diameter of the circular bump behind the selected bubble.
  public var mainBubbleSize: CGFloat
  /// Horizontal spacing between bubbles.
  public var bubbleXOffsetSpace: CGFloat
  /// Vertical padding of the bar.
  public var bubbleYOffsetSpace: CGFloat
  /// Duration of a page change animation.
  public var animationDuration: CFTimeInterval
  /// Distance between the centers of two adjacent bubbles.
  public var smallBubbleMoveRadius: CGFloat {
    smallBubbleSize + bubbleXOffsetSpace
  }
  /// Bar and bump background color.
  public var backgroundColor: UIColor
  /// Small bubble color.
  public var smallBubbleColor: UIColor
  /// Big bubble color.
  public var bigBubbleColor: UIColor

  public init(
    smallBubbleSize: CGFloat = 16,
    mainBubbleSize: CGFloat = 40,
    bubbleXOffsetSpace: CGFloat = 12,
    bubbleYOffsetSpace: CGFloat = 8,
    animationDuration: CFTimeInterval = 0.2,
    backgroundColor: UIColor = UIColor(red: 0.357, green: 0.196, blue: 0.337, alpha: 1.000),
    smallBubbleColor: UIColor = UIColor(red: 0.961, green: 0.561, blue: 0.518, alpha: 1.000),
    bigBubbleColor: UIColor = UIColor(red: 0.788, green: 0.216, blue: 0.337, alpha: 1.000)
  ) {
    self.smallBubbleSize = smallBubbleSize
    self.mainBubbleSize = mainBubbleSize
    self.bubbleXOffsetSpace = bubbleXOffsetSpace
    self.bubbleYOffsetSpace = bubbleYOffsetSpace
    self.animationDuration = animationDuration
    self.backgroundColor = backgroundColor
    self.smallBubbleColor = smallBubbleColor
    self.bigBubbleColor = bigBubbleColor
  }
}

extension TKRubberPageControlConfig {
  /// Shared layout model for the given number of pages.
  func metrics(pageCount: Int) -> RubberPageControlMetrics {
    RubberPageControlMetrics(
      pageCount: pageCount,
      smallBubbleSize: smallBubbleSize,
      mainBubbleSize: mainBubbleSize,
      bubbleSpacing: bubbleXOffsetSpace,
      verticalPadding: bubbleYOffsetSpace
    )
  }
}
