//
//  TKRubberIndicator.swift
//  TKRubberIndicator
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015年 TBXark. All rights reserved.
//

import UIKit


let kTKSmallBubbleSize       :CGFloat = 16
let kTKMainBubbleSize        :CGFloat = 40
let kTKBubbleXOffsetSpace    :CGFloat = 12
let kTKBubbleYOffsetSpace    :CGFloat = 8
let kTKAnimationDuration     :CFTimeInterval  = 1
let kTKSmallBubbleMoveRadius :CGFloat = kTKSmallBubbleSize + kTKBubbleXOffsetSpace

let kTKBackgroundColor  : UIColor = UIColor(red:0.357,  green:0.196,  blue:0.337, alpha:1)
let kTKSmallBubbleColor : UIColor = UIColor(red:0.961,  green:0.561,  blue:0.518, alpha:1)
let kTKBigBubbleColor   : UIColor = UIColor(red:0.788,  green:0.216,  blue:0.337, alpha:1)

// MARK:MoveDorection
enum TKMoveDirection{
    case left
    case right
    func toBool() -> Bool{
        switch self{
            case .left:
                return true
            case .right:
                return false
        }
    }
}

extension UIView{
    var w : CGFloat{
        return self.bounds.width
    }
    var h : CGFloat{
        return self.bounds.height
    }
}

// MARK: PageControl
class TKRubberIndicator : UIControl {
    
//    var isAnimate     = false
    var numberOfpage :Int  = 5
    var canShowArrow :Bool = false
    
    var mainBubble    = TKMainBubble()
    var smallBubbles  = Array<TKBubbleCell>()
    var backLineLayer = CAShapeLayer()
    var currentIndex  = 0
    
    
    var xPointbegin  : CGFloat = 0
    var xPointEnd    : CGFloat = 0
    var yPointbegin  : CGFloat = 0
    var yPointEnd    : CGFloat = 0
    
    
    init(frame: CGRect,count:Int) {
        numberOfpage = count
        super.init(frame:frame)
        self.setUpView()
        assert(numberOfpage > 0, "Count should not be 0")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpView()
        assert(numberOfpage > 0, "Count should not be 0")
    }
    
    func setUpView(){
        
        let y = (self.h - (kTKSmallBubbleSize + 2 * kTKBubbleYOffsetSpace))/2
        let w = CGFloat(numberOfpage - 1) * kTKSmallBubbleSize + kTKMainBubbleSize + CGFloat(numberOfpage + 1) * kTKBubbleXOffsetSpace
        let h = kTKSmallBubbleSize + kTKBubbleYOffsetSpace * 2
        let x = (self.w - w)/2
        
        xPointbegin  = x
        xPointEnd    = x + w
        yPointbegin  = y
        yPointEnd    = y + h
        
        let lineFrame = CGRectMake(x,y,w,h)
        backLineLayer.path = UIBezierPath(roundedRect:lineFrame, cornerRadius:h/2).CGPath
        backLineLayer.fillColor = kTKBackgroundColor.CGColor
        self.layer.addSublayer(backLineLayer)
        
        mainBubble.frame = CGRectMake(x, y - (kTKMainBubbleSize - h)/2, kTKMainBubbleSize, kTKMainBubbleSize)
        self.layer.addSublayer(mainBubble)

        let bubbleOffset = kTKSmallBubbleSize + kTKBubbleXOffsetSpace
        var bubbleFrame = CGRectMake(x + kTKBubbleXOffsetSpace + bubbleOffset , y + kTKBubbleYOffsetSpace, kTKSmallBubbleSize, kTKSmallBubbleSize)
        for _ in 0..<numberOfpage{
            let smallBubble = TKBubbleCell()
            smallBubble.frame = bubbleFrame
            self.layer.addSublayer(smallBubble)
            smallBubbles.append(smallBubble)
            bubbleFrame.origin.x += bubbleOffset
//            smallBubble.zPosition = 1
        }
//        mainBubble.bubbleLayer.zPosition = 10
        
        let tap = UITapGestureRecognizer(target: self, action: "tapValueChange:")
        self.addGestureRecognizer(tap)
    }
    
    
    func tapValueChange(ges:UITapGestureRecognizer){
        let point = ges.locationInView(self)
        if point.y > yPointbegin && point.y < yPointEnd && point.x > xPointbegin && point.x < xPointEnd{
            let index = Int(point.x - xPointbegin) / Int(kTKSmallBubbleMoveRadius)
            if index == currentIndex{
                return
            }
            let direction = (currentIndex > index) ? TKMoveDirection.right : TKMoveDirection.left
            let point = CGPointMake(xPointbegin + kTKSmallBubbleMoveRadius * CGFloat(index) + kTKMainBubbleSize/2, yPointbegin - kTKBubbleYOffsetSpace/2)
            let range = (currentIndex < index) ? (currentIndex+1)...index : index...(currentIndex-1)
            
//            //PS:当小球运动数大于1时,轮流运动,但是效果不好,所以改成一起运动,但是保留这个接口
//            let bubbleOffSet = abs(currentIndex - index)
//            let cellTime = kTKAnimationDuration / Double(bubbleOffSet)
//            var count = 0
            for index in range{
                let smallBubbleIndex = (direction.toBool()) ? (index - 1) : (index)
                let smallBubble = smallBubbles[smallBubbleIndex]
//                let beginTime = CACurrentMediaTime() + (Double(count) * cellTime)
//                smallBubble.positionChange(direction, radius: kTKSmallBubbleMoveRadius / 2, duration: cellTime,beginTime:beginTime)
//                count++
                 smallBubble.positionChange(direction, radius: kTKSmallBubbleMoveRadius / 2, duration:kTKAnimationDuration,beginTime:CACurrentMediaTime())
            }
            mainBubble.positionChange(direction, point: point, duration: kTKAnimationDuration)
            currentIndex = index
            print(index)
        }
    }
    
    
}




// MARK: - Main Bubble
class TKMainBubble : CAShapeLayer {
    
    var backgroundLayer = CAShapeLayer()
    var bubbleLayer     = CAShapeLayer()

    let bubbleScale  :CGFloat  = 1/3.0
    
    
    override init() {
        super.init()
        setupLayer()
    }
    
    override init(layer: AnyObject) {
        super.init(layer:layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    private func setupLayer(){
        
        self.frame = CGRectMake(0, 0, kTKMainBubbleSize, kTKMainBubbleSize)

        backgroundLayer.path = UIBezierPath(ovalInRect: self.bounds).CGPath
        backgroundLayer.fillColor = kTKBackgroundColor.CGColor
        self.addSublayer(backgroundLayer)
        
        var frame = CGRectInset(self.bounds, kTKBubbleYOffsetSpace , kTKBubbleYOffsetSpace)
        let origin = frame.origin
        frame.origin = CGPointZero
        bubbleLayer.path = UIBezierPath(ovalInRect: frame).CGPath
        bubbleLayer.fillColor = kTKBigBubbleColor.CGColor
        frame.origin = origin
        bubbleLayer.frame = frame
        self.addSublayer(bubbleLayer)
    }
    
    func positionChange(direction:TKMoveDirection,var point:CGPoint,duration:Double){
        
        
        point.y += self.bounds.height/2
        
        let bubbleTransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        bubbleTransformAnim.values   = [NSValue(CATransform3D: CATransform3DIdentity),
                                        NSValue(CATransform3D: CATransform3DMakeScale(bubbleScale, bubbleScale, 1)),
                                        NSValue(CATransform3D: CATransform3DIdentity)]
        bubbleTransformAnim.keyTimes = [0, 0.5, 1]
        bubbleTransformAnim.duration = duration
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        self.position = point
        CATransaction.commit()
        
        bubbleLayer.addAnimation(bubbleTransformAnim, forKey: "Scale")
    }
    
}




// MARK: - Small Bubble
class TKBubbleCell: CAShapeLayer {
    
    
    var bubbleLayer = CAShapeLayer()
    let bubbleScale   :CGFloat  = 0.5
    var lastDirection : TKMoveDirection!
    
    override init() {
        super.init()
        setupLayer()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    private func setupLayer(){
        self.frame = CGRectMake(0, 0, kTKSmallBubbleSize, kTKSmallBubbleSize)
        bubbleLayer.path = UIBezierPath(ovalInRect: self.bounds).CGPath
        bubbleLayer.fillColor = kTKSmallBubbleColor.CGColor
        bubbleLayer.strokeColor = kTKBackgroundColor.CGColor
        bubbleLayer.lineWidth = kTKBubbleXOffsetSpace / 8
        self.addSublayer(bubbleLayer)
    }
    
    func positionChange(direction:TKMoveDirection,radius:CGFloat,duration:CFTimeInterval,beginTime:CFTimeInterval){
        let toLeft = direction.toBool()
        let movePath = UIBezierPath()
        var center = CGPointZero
        let startAngle = toLeft ? 0 : CGFloat(M_PI)
        let endAngle   = toLeft ? CGFloat(M_PI) : 0
        center.x += radius * (toLeft ? -1 : 1)
        lastDirection = direction
        
        movePath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: toLeft)
        
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.duration = duration
        positionAnimation.beginTime = beginTime
        positionAnimation.additive = true;
        positionAnimation.calculationMode = kCAAnimationPaced;
        positionAnimation.rotationMode = kCAAnimationRotateAuto;
        positionAnimation.path = movePath.CGPath
        positionAnimation.fillMode = kCAFillModeBoth
        positionAnimation.delegate = self
        
        let bubbleTransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        bubbleTransformAnim.values   = [NSValue(CATransform3D: CATransform3DIdentity),
                                        NSValue(CATransform3D: CATransform3DMakeScale(1,bubbleScale, 1)),
                                        NSValue(CATransform3D: CATransform3DIdentity)]
        bubbleTransformAnim.keyTimes = [0, 0.5, 1]
        bubbleTransformAnim.duration = duration
        bubbleTransformAnim.beginTime = beginTime
        
        bubbleLayer.addAnimation(bubbleTransformAnim, forKey: "Scale")
        self.addAnimation(positionAnimation, forKey: "Position")
    }
    
    func shakeAnimate(){
        // TODO: 未解决,闪屏问题
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.opacity = 0
        var point = self.position
        point.x += (kTKSmallBubbleSize + kTKBubbleXOffsetSpace) * CGFloat(lastDirection.toBool() ? -1 : 1)
        self.position = point
        self.opacity = 1
        CATransaction.commit()

        let bubbleShakeAnim = CAKeyframeAnimation(keyPath: "position")
        bubbleShakeAnim.duration = 0.01
        bubbleShakeAnim.values = [NSValue(CGPoint: CGPointMake(0, 0)),
                                  NSValue(CGPoint: CGPointMake(0, 4)),
                                  NSValue(CGPoint: CGPointMake(0, 0)),
                                  NSValue(CGPoint: CGPointMake(0,-4)),
                                  NSValue(CGPoint: CGPointMake(0, 0)),]
        bubbleShakeAnim.repeatCount = 10
        self.bubbleLayer.addAnimation(bubbleShakeAnim, forKey: "Shake")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let animate = anim as? CAKeyframeAnimation{
            if animate.keyPath == "position"{
                shakeAnimate()
            }
        }
    }
    
    
}