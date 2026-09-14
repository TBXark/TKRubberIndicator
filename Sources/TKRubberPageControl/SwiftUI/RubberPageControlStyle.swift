//
//  RubberPageControlStyle.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015 TBXark. All rights reserved.
//

import SwiftUI

/// Visual style of `RubberPageControl`.
///
/// The default values match `TKRubberPageControlConfig`, so the SwiftUI control
/// looks the same as the UIKit one out of the box.
public struct RubberPageControlStyle: Equatable {
  /// Diameter of the unselected small bubbles.
  public var smallBubbleSize: CGFloat
  /// Diameter of the circular bump behind the selected bubble.
  public var mainBubbleSize: CGFloat
  /// Horizontal spacing between bubbles.
  public var bubbleSpacing: CGFloat
  /// Vertical padding of the bar.
  public var verticalPadding: CGFloat
  /// Duration of a page change animation.
  public var animationDuration: Double
  /// Bar and bump background color.
  public var barColor: Color
  /// Small bubble color.
  public var smallBubbleColor: Color
  /// Big bubble color.
  public var bigBubbleColor: Color

  public init(
    smallBubbleSize: CGFloat = 16,
    mainBubbleSize: CGFloat = 40,
    bubbleSpacing: CGFloat = 12,
    verticalPadding: CGFloat = 8,
    animationDuration: Double = 0.2,
    barColor: Color = Color(red: 0.357, green: 0.196, blue: 0.337),
    smallBubbleColor: Color = Color(red: 0.961, green: 0.561, blue: 0.518),
    bigBubbleColor: Color = Color(red: 0.788, green: 0.216, blue: 0.337)
  ) {
    self.smallBubbleSize = smallBubbleSize
    self.mainBubbleSize = mainBubbleSize
    self.bubbleSpacing = bubbleSpacing
    self.verticalPadding = verticalPadding
    self.animationDuration = animationDuration
    self.barColor = barColor
    self.smallBubbleColor = smallBubbleColor
    self.bigBubbleColor = bigBubbleColor
  }

  /// Animation applied to a page change.
  var animation: Animation {
    .easeInOut(duration: animationDuration)
  }
}

extension RubberPageControlMetrics {
  init(style: RubberPageControlStyle, pageCount: Int) {
    self.init(
      pageCount: pageCount,
      smallBubbleSize: style.smallBubbleSize,
      mainBubbleSize: style.mainBubbleSize,
      bubbleSpacing: style.bubbleSpacing,
      verticalPadding: style.verticalPadding
    )
  }
}
