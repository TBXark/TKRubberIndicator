//
//  TKRubberIndicator.swift
//  TKRubberIndicator
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015年 TBXark. All rights reserved.
//

import UIKit


// ValueChange
typealias UIControlValueChangeClosure = (Any) -> Void

// 快速获得 W 和 H
extension UIView{
    var w : CGFloat{
        return self.bounds.width
    }
    var h : CGFloat{
        return self.bounds.height
    }
}


// MARK: - MoveDorection
// 运动方向

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

// MARK: - TKRubberIndicatorConfig
// 样式配置 (含默认配置)

struct TKRubberIndicatorConfig {
    // 小球尺寸
    var smallBubbleSize       :CGFloat        = 16
    // 大球尺寸
    var mainBubbleSize        :CGFloat        = 40
    // 小球间距
    var bubbleXOffsetSpace    :CGFloat        = 12
    // 纵向间距
    var bubbleYOffsetSpace    :CGFloat        = 8
    // 动画时长
    var animationDuration     :CFTimeInterval = 0.2
    // 小球运动半径
    var smallBubbleMoveRadius : CGFloat {return smallBubbleSize + bubbleXOffsetSpace}
    
    // 横条背景颜色
    var backgroundColor  : UIColor = UIColor(red:0.357,  green:0.196,  blue:0.337, alpha:1)
    // 小球颜色
    var smallBubbleColor : UIColor = UIColor(red:0.961,  green:0.561,  blue:0.518, alpha:1)
    // 大球颜色
    var bigBubbleColor   : UIColor = UIColor(red:0.788,  green:0.216,  blue:0.337, alpha:1)
}




// MARK: PageControl
class TKRubberIndicator : UIControl {
    
    // 页数
    var numberOfpage : Int  = 5{
        didSet{
            if oldValue != numberOfpage{
                resetRubberIndicator()
            }
        }
    }
    
    // 当前 Index
    var currentIndex  = 0
    
    // 事件闭包
    var valueChange  : UIControlValueChangeClosure?
    // 样式配置
    var styleConfig  : TKRubberIndicatorConfig!
    
    //手势
    var indexTap     : UITapGestureRecognizer!
    
    
    // 所有图层
    var smallBubbles    = Array<TKBubbleCell>()
    var backgroundLayer = CAShapeLayer()
    var mainBubble      = CAShapeLayer()
    var backLineLayer   = CAShapeLayer()
    
    // 大球缩放比例
    let bubbleScale  :CGFloat  = 1/3.0
    
    // 存储计算用的
    var xPointbegin  : CGFloat = 0
    var xPointEnd    : CGFloat = 0
    var yPointbegin  : CGFloat = 0
    var yPointEnd    : CGFloat = 0
    
    
    init(frame: CGRect,count:Int,config:TKRubberIndicatorConfig = TKRubberIndicatorConfig()) {
        numberOfpage = count
        styleConfig = config
        super.init(frame:frame)
        self.setUpView()
        assert(numberOfpage > 1, "Page count should larger than 1")
    }
    
    required init?(coder aDecoder: NSCoder) {
        styleConfig = TKRubberIndicatorConfig()
        super.init(coder: aDecoder)
        self.setUpView()
        assert(numberOfpage > 1, "Page count should larger than 1")
    }
    
    private func setUpView(){
        
        // 一些奇怪的位置计算
        
        let y = (self.h - (styleConfig.smallBubbleSize + 2 * styleConfig.bubbleYOffsetSpace))/2
        let w = CGFloat(numberOfpage - 2) * styleConfig.smallBubbleSize + styleConfig.mainBubbleSize + CGFloat(numberOfpage) * styleConfig.bubbleXOffsetSpace
        let h = styleConfig.smallBubbleSize + styleConfig.bubbleYOffsetSpace * 2
        let x = (self.w - w)/2
        
        xPointbegin  = x
        xPointEnd    = x + w
        yPointbegin  = y
        yPointEnd    = y + h
        
        let lineFrame = CGRectMake(x,y,w,h)
        let frame     = CGRectMake(x, y - (styleConfig.mainBubbleSize - h)/2, styleConfig.mainBubbleSize, styleConfig.mainBubbleSize)
        var layerFrame = CGRectInset(frame, styleConfig.bubbleYOffsetSpace , styleConfig.bubbleYOffsetSpace)
        
        
        // 背景的横线
        backLineLayer.path      = UIBezierPath(roundedRect:lineFrame, cornerRadius:h/2).CGPath
        backLineLayer.fillColor = styleConfig.backgroundColor.CGColor
        self.layer.addSublayer(backLineLayer)
        
        
        // 大球背景的圈
        backgroundLayer.path      = UIBezierPath(ovalInRect: frame).CGPath
        backgroundLayer.fillColor = styleConfig.backgroundColor.CGColor
        backgroundLayer.zPosition = -1
        self.layer.addSublayer(backgroundLayer)
        
        
        
        // 大球
        let origin           = layerFrame.origin
        layerFrame.origin    = CGPointZero
        mainBubble.path      = UIBezierPath(ovalInRect: layerFrame).CGPath
        mainBubble.fillColor = styleConfig.bigBubbleColor.CGColor
        layerFrame.origin    = origin
        mainBubble.frame     = layerFrame
        mainBubble.zPosition = 100
        self.layer.addSublayer(mainBubble)
        
        
        // 生成小球
        let bubbleOffset = styleConfig.smallBubbleSize + styleConfig.bubbleXOffsetSpace
        var bubbleFrame  = CGRectMake(x + styleConfig.bubbleXOffsetSpace + bubbleOffset , y + styleConfig.bubbleYOffsetSpace, styleConfig.smallBubbleSize, styleConfig.smallBubbleSize)
        for _ in 0..<(numberOfpage-1){
            let smallBubble       = TKBubbleCell(style: styleConfig)
            smallBubble.frame     = bubbleFrame
            self.layer.addSublayer(smallBubble)
            smallBubbles.append(smallBubble)
            bubbleFrame.origin.x  += bubbleOffset
            smallBubble.zPosition = 1
        }
        
        // 增加点击手势
        indexTap = UITapGestureRecognizer(target: self, action: "tapValueChange:")
        self.addGestureRecognizer(indexTap)
    }
    
    
     // 重置控件
    func resetRubberIndicator(){
        changIndexToValue(0)
        smallBubbles.forEach {$0.removeFromSuperlayer()}
        smallBubbles.removeAll()
        removeGestureRecognizer(indexTap)
        setUpView()
    }
    
    
    
    // 手势事件
    func tapValueChange(ges:UITapGestureRecognizer){
        let point = ges.locationInView(self)
        if point.y > yPointbegin && point.y < yPointEnd && point.x > xPointbegin && point.x < xPointEnd{
            let index = Int(point.x - xPointbegin) / Int(styleConfig.smallBubbleMoveRadius)
            changIndexToValue(index)
        }
    }
    
    // Index值变化
    func changIndexToValue(var index:Int){
        
        if index >= numberOfpage{index = numberOfpage - 1}
        if index < 0{index = 0}
        if index == currentIndex {return}
        
        let direction = (currentIndex > index) ? TKMoveDirection.right : TKMoveDirection.left
        let point     = CGPointMake(xPointbegin + styleConfig.smallBubbleMoveRadius * CGFloat(index) + styleConfig.mainBubbleSize/2, yPointbegin - styleConfig.bubbleYOffsetSpace/2)
        let range     = (currentIndex < index) ? (currentIndex+1)...index : index...(currentIndex-1)
        
        for index in range{
            let smallBubbleIndex = (direction.toBool()) ? (index - 1) : (index)
            let smallBubble      = smallBubbles[smallBubbleIndex]
            smallBubble.positionChange(direction, radius: styleConfig.smallBubbleMoveRadius / 2, duration:styleConfig.animationDuration,beginTime:CACurrentMediaTime())
        }
        currentIndex = index
        mainBubblePositionChange(direction, point: point, duration: styleConfig.animationDuration)
        
        // 可以使用 Target-Action 监听事件
        sendActionsForControlEvents(UIControlEvents.ValueChanged)
        // 也可以使用 闭包 监听事件
        valueChange?(currentIndex)
        
    }
    
    // 大球动画
    private func mainBubblePositionChange(direction:TKMoveDirection,var point:CGPoint,duration:Double){
        
        // 大球缩放动画
        let bubbleTransformAnim      = CAKeyframeAnimation(keyPath:"transform")
        bubbleTransformAnim.values   = [NSValue(CATransform3D: CATransform3DIdentity),
            NSValue(CATransform3D: CATransform3DMakeScale(bubbleScale, bubbleScale, 1)),
            NSValue(CATransform3D: CATransform3DIdentity)]
        bubbleTransformAnim.keyTimes = [0, 0.5, 1]
        bubbleTransformAnim.duration = duration
        
        
        // 大球移动动画,用隐式动画大球的位置会真正的改变
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        point.y += styleConfig.mainBubbleSize/2
        mainBubble.position = point

        point.y = 0
        point.x = (xPointEnd - xPointbegin - styleConfig.bubbleXOffsetSpace/2) / CGFloat(numberOfpage) * CGFloat(currentIndex) - (styleConfig.bubbleYOffsetSpace / 4)
        backgroundLayer.position = point
        CATransaction.commit()
        
        mainBubble.addAnimation(bubbleTransformAnim, forKey: "Scale")
    }
}







// MARK: - Small Bubble
class TKBubbleCell: CAShapeLayer {
    
    
    var bubbleLayer = CAShapeLayer()
    let bubbleScale   :CGFloat  = 0.5
    var lastDirection : TKMoveDirection!
    var styleConfig   : TKRubberIndicatorConfig!
    
    
    init(style:TKRubberIndicatorConfig) {
        styleConfig = style
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
        self.frame = CGRectMake(0, 0, styleConfig.smallBubbleSize, styleConfig.smallBubbleSize)
        
        bubbleLayer.path        = UIBezierPath(ovalInRect: self.bounds).CGPath
        bubbleLayer.fillColor   = styleConfig.smallBubbleColor.CGColor
        bubbleLayer.strokeColor = styleConfig.backgroundColor.CGColor
        bubbleLayer.lineWidth   = styleConfig.bubbleXOffsetSpace / 8
        
        self.addSublayer(bubbleLayer)
    }
    
    // beginTime 本来是留给小球轮播用的,但是效果不好就没用了
    func positionChange(direction:TKMoveDirection,radius:CGFloat,duration:CFTimeInterval,beginTime:CFTimeInterval){
        
        let toLeft = direction.toBool()
        let movePath = UIBezierPath()
        var center = CGPointZero
        let startAngle = toLeft ? 0 : CGFloat(M_PI)
        let endAngle   = toLeft ? CGFloat(M_PI) : 0
        center.x += radius * (toLeft ? -1 : 1)
        lastDirection = direction
        
        movePath.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: toLeft)
        
        // 小球整体沿着圆弧运动,但是当圆弧运动动画合形变动画叠加在一起的时候,就没有了向心作用,所以就把形变动画放在子 Layer 里面
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.duration = duration
        positionAnimation.beginTime = beginTime
        positionAnimation.additive = true;
        positionAnimation.calculationMode = kCAAnimationPaced;
        positionAnimation.rotationMode = kCAAnimationRotateAuto;
        positionAnimation.path = movePath.CGPath
        positionAnimation.fillMode = kCAFillModeBoth
        positionAnimation.delegate = self
        
        
        // 小球变形动画,小球变形实际上只是 Y 轴上的 Scale
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
    
    private func shakeAnimate(){
        // TODO: 未解决,闪烁问题
        // 没找到办法在球做完圆弧运动后保持状态的办法,这里只能关掉隐式动画强行改变位置
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.opacity = 0
        var point = self.position
        point.x += (styleConfig.smallBubbleSize + styleConfig.bubbleXOffsetSpace) * CGFloat(lastDirection.toBool() ? -1 : 1)
        self.position = point
        self.opacity = 1
        CATransaction.commit()
        
        // 最后让小球鬼畜的抖动一下
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