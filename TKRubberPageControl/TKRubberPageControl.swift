//
//  TKRubberPageControl.swift
//  TKRubberPageControl
//
//  Created by Tbxark on 15/10/26.
//  Copyright © 2015年 TBXark. All rights reserved.
//

import UIKit


// MARK: - MoveDorection
// 运动方向
private enum TKMoveDirection{
    case left
    case right
    func toLeft() -> Bool{
        switch self{
        case .left: 
            return true
        case .right: 
            return false
        }
    }
}


// MARK: - TKRubberPageControlConfig
// 样式配置 (含默认配置)

public struct TKRubberPageControlConfig {
    public var smallBubbleSize: CGFloat     // 小球尺寸
    public var mainBubbleSize: CGFloat    // 大球尺寸
    public var bubbleXOffsetSpace: CGFloat     // 小球间距
    public var bubbleYOffsetSpace: CGFloat     // 纵向间距
    public var animationDuration: CFTimeInterval     // 动画时长
    public var smallBubbleMoveRadius: CGFloat { return smallBubbleSize + bubbleXOffsetSpace}    // 小球运动半径
    public var backgroundColor: UIColor     // 横条背景颜色
    public var smallBubbleColor: UIColor    // 小球颜色
    public var bigBubbleColor: UIColor      // 大球颜色
    
    public init(smallBubbleSize: CGFloat = 16,
                mainBubbleSize: CGFloat = 40,
                bubbleXOffsetSpace: CGFloat = 12,
                bubbleYOffsetSpace: CGFloat = 8,
                animationDuration: CFTimeInterval = 0.2,
                backgroundColor: UIColor = UIColor(red:0.741,  green:0.945,  blue:0.757, alpha:1),
                smallBubbleColor: UIColor = UIColor(red:1,  green:0.829,  blue:0, alpha:1),
                bigBubbleColor: UIColor = UIColor(red:1,  green:0.668,  blue:0.474, alpha:1)) {
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




// MARK: PageControl
open class TKRubberPageControl : UIControl {
    
    // 页数
    open var numberOfpage : Int  = 5{
        didSet{
            if oldValue != numberOfpage{
                resetRubberIndicator()
            }
        }
    }
    // 当前 Index
    open var currentIndex  = 0 {
        didSet {
            changIndexToValue(currentIndex)
        }
    }
    // 事件闭包
    open var valueChange  : ((Int) -> Void)?
    // 样式配置
    open var styleConfig  : TKRubberPageControlConfig {
        didSet {
            resetRubberIndicator()
        }
    }
    
    // 手势
    private var indexTap     : UITapGestureRecognizer?
    // 所有图层
    private var smallBubbles    = [TKBubbleCell]()
    private var backgroundLayer = CAShapeLayer()
    private var mainBubble      = CAShapeLayer()
    private var backLineLayer   = CAShapeLayer()
    
    // 大球缩放比例
    private let bubbleScale  : CGFloat  = 1/3.0
    
    // 存储计算用的
    private var xPointbegin  : CGFloat = 0
    private var xPointEnd    : CGFloat = 0
    private var yPointbegin  : CGFloat = 0
    private var yPointEnd    : CGFloat = 0
    
    
    public init(frame: CGRect, count: Int, config: TKRubberPageControlConfig = TKRubberPageControlConfig()) {
        numberOfpage = count
        styleConfig = config
        super.init(frame: frame)
        setUpView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        styleConfig = TKRubberPageControlConfig()
        super.init(coder: aDecoder)
        setUpView()
    }
    
    private func setUpView(){
        
        // 一些奇怪的位置计算
        
        let y = (bounds.height - (styleConfig.smallBubbleSize + 2 * styleConfig.bubbleYOffsetSpace))/2
        let w = CGFloat(numberOfpage - 2) * styleConfig.smallBubbleSize + styleConfig.mainBubbleSize + CGFloat(numberOfpage) * styleConfig.bubbleXOffsetSpace
        let h = styleConfig.smallBubbleSize + styleConfig.bubbleYOffsetSpace * 2
        let x = (bounds.width - w)/2
        if w > bounds.width || h > bounds.height {
            let error = NSError(domain: "com.TBXark.TKRubberPageControl",
                                code: 0,
                                userInfo: ["Reason": "Draw UI control out off rect"])
            print(error)
        }
        
        xPointbegin  = x
        xPointEnd    = x + w
        yPointbegin  = y
        yPointEnd    = y + h
        
        let lineFrame = CGRect(x: x, y: y, width: w, height: h)
        let backBubblgFrame = CGRect(x: x, y: y - (styleConfig.mainBubbleSize - h)/2, width: styleConfig.mainBubbleSize, height: styleConfig.mainBubbleSize)
        var bigBubbleFrame = backBubblgFrame.insetBy(dx: styleConfig.bubbleYOffsetSpace , dy: styleConfig.bubbleYOffsetSpace)
        
        
        // 背景的横线
        backLineLayer.path      = UIBezierPath(roundedRect: lineFrame, cornerRadius: h/2).cgPath
        backLineLayer.fillColor = styleConfig.backgroundColor.cgColor
        backLineLayer.frame = bounds
        layer.addSublayer(backLineLayer)
        
        
        // 大球背景的圈
        backgroundLayer.path      = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: backBubblgFrame.size)).cgPath
        backgroundLayer.frame = backBubblgFrame
        backgroundLayer.fillColor = styleConfig.backgroundColor.cgColor
        backgroundLayer.zPosition = -1

        layer.addSublayer(backgroundLayer)
        
        
        
        // 大球
        let origin           = bigBubbleFrame.origin
        mainBubble.path      = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: bigBubbleFrame.size)).cgPath
        mainBubble.fillColor = styleConfig.bigBubbleColor.cgColor
        bigBubbleFrame.origin    = origin
        mainBubble.frame     = bigBubbleFrame
        mainBubble.zPosition = 100
        layer.addSublayer(mainBubble)
        
        
        // 生成小球
        let bubbleOffset = styleConfig.smallBubbleSize + styleConfig.bubbleXOffsetSpace
        var bubbleFrame  = CGRect(x: x + styleConfig.bubbleXOffsetSpace + bubbleOffset , y: y + styleConfig.bubbleYOffsetSpace, width: styleConfig.smallBubbleSize, height: styleConfig.smallBubbleSize)
        for _ in 0..<(numberOfpage-1){
            let smallBubble       = TKBubbleCell(style: styleConfig)
            smallBubble.frame     = bubbleFrame
            layer.addSublayer(smallBubble)
            smallBubbles.append(smallBubble)
            bubbleFrame.origin.x  += bubbleOffset
            smallBubble.zPosition = 1
        }
        
        // 增加点击手势
        if indexTap == nil {
            let tap = UITapGestureRecognizer(target: self, action: #selector(TKRubberPageControl.tapValueChange(_: )))
            addGestureRecognizer(tap)
            indexTap = tap
        }
    }
    
    
     // 重置控件
    open func resetRubberIndicator(){
        changIndexToValue(0)
        smallBubbles.forEach { $0.removeFromSuperlayer() }
        smallBubbles.removeAll()
        setUpView()
    }
    
    
    
    // 手势事件
    @objc private func tapValueChange(_ ges: UITapGestureRecognizer){
        let point = ges.location(in: self)
        if point.y > yPointbegin && point.y < yPointEnd && point.x > xPointbegin && point.x < xPointEnd{
            let index = Int(point.x - xPointbegin) / Int(styleConfig.smallBubbleMoveRadius)
            changIndexToValue(index)
        }
    }
    
    // Index值变化
    private func changIndexToValue(_ valueIndex: Int){
        var index = valueIndex
        if index >= numberOfpage { index = numberOfpage - 1 }
        if index < 0 { index = 0 }
        if index == currentIndex { return }
        
        let direction = (currentIndex > index) ? TKMoveDirection.right : TKMoveDirection.left
        let range     = (currentIndex < index) ? (currentIndex+1)...index : index...(currentIndex-1)
        
        // 小球动画
        for index in range{
            let smallBubbleIndex = (direction.toLeft()) ? (index - 1) : (index)
            let smallBubble      = smallBubbles[smallBubbleIndex]
            smallBubble.positionChange(direction,
                                       radius: styleConfig.smallBubbleMoveRadius / 2,
                                       duration: styleConfig.animationDuration,
                                       beginTime: CACurrentMediaTime())
        }
        currentIndex = index
        
        // 大球缩放动画
        let bubbleTransformAnim      = CAKeyframeAnimation(keyPath: "transform")
        bubbleTransformAnim.values   = [NSValue(caTransform3D: CATransform3DIdentity),
                                        NSValue(caTransform3D: CATransform3DMakeScale(bubbleScale, bubbleScale, 1)),
                                        NSValue(caTransform3D: CATransform3DIdentity)]
        bubbleTransformAnim.keyTimes = [0, 0.5, 1]
        bubbleTransformAnim.duration = styleConfig.animationDuration
        
        // 大球移动动画, 用隐式动画大球的位置会真正的改变
        CATransaction.begin()
        CATransaction.setAnimationDuration(styleConfig.animationDuration)
        let x = xPointbegin + styleConfig.smallBubbleMoveRadius * CGFloat(currentIndex) + styleConfig.mainBubbleSize/2
        mainBubble.position.x = x
        backgroundLayer.position.x = x
        CATransaction.commit()
        
        mainBubble.add(bubbleTransformAnim, forKey: "Scale")

        
        // 可以使用 Target-Action 监听事件
        sendActions(for: UIControlEvents.valueChanged)
        // 也可以使用 闭包 监听事件
        valueChange?(currentIndex)
        
    }
    
}







// MARK: - Small Bubble
private class TKBubbleCell: CAShapeLayer, CAAnimationDelegate {
    
    var bubbleLayer = CAShapeLayer()
    let bubbleScale   : CGFloat  = 0.5
    var lastDirection : TKMoveDirection!
    var styleConfig   : TKRubberPageControlConfig
    var cachePosition = CGPoint.zero
    
    override init(layer: Any) {
        styleConfig = TKRubberPageControlConfig()
        super.init(layer: layer)
        setupLayer()
    }
    
    internal init(style: TKRubberPageControlConfig) {
        styleConfig = style
        super.init()
        setupLayer()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        styleConfig = TKRubberPageControlConfig()
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    private func setupLayer(){
        frame = CGRect(x: 0, y: 0, width: styleConfig.smallBubbleSize, height: styleConfig.smallBubbleSize)
        
        bubbleLayer.path        = UIBezierPath(ovalIn: bounds).cgPath
        bubbleLayer.fillColor   = styleConfig.smallBubbleColor.cgColor
        bubbleLayer.strokeColor = styleConfig.backgroundColor.cgColor
        bubbleLayer.lineWidth   = styleConfig.bubbleXOffsetSpace / 8
        
        addSublayer(bubbleLayer)
    }
    
    // beginTime 本来是留给小球轮播用的, 但是效果不好就没用了
    func positionChange(_ direction: TKMoveDirection, radius: CGFloat, duration: CFTimeInterval, beginTime: CFTimeInterval){
        
        let toLeft = direction.toLeft()
        let movePath = UIBezierPath()
        var center = CGPoint.zero
        let startAngle = toLeft ? 0 : CGFloat.pi
        let endAngle   = toLeft ? CGFloat.pi : 0
        center.x += radius * (toLeft ? -1 : 1)
        lastDirection = direction
        
        movePath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: toLeft)
        
        // 小球整体沿着圆弧运动, 但是当圆弧运动动画合形变动画叠加在一起的时候, 就没有了向心作用, 所以就把形变动画放在子 Layer 里面
        let positionAnimation = CAKeyframeAnimation(keyPath: "position")
        positionAnimation.duration = duration
        positionAnimation.beginTime = beginTime
        positionAnimation.isAdditive = true;
        positionAnimation.calculationMode = kCAAnimationPaced;
        positionAnimation.rotationMode = kCAAnimationRotateAuto;
        positionAnimation.path = movePath.cgPath
        positionAnimation.fillMode = kCAFillModeForwards
        positionAnimation.isRemovedOnCompletion = false
        positionAnimation.delegate = self
        cachePosition = position
        
        // 小球变形动画, 小球变形实际上只是 Y 轴上的 Scale
        let bubbleTransformAnim      = CAKeyframeAnimation(keyPath: "transform")
        bubbleTransformAnim.values   = [NSValue(caTransform3D: CATransform3DIdentity), 
            NSValue(caTransform3D: CATransform3DMakeScale(1, bubbleScale, 1)), 
            NSValue(caTransform3D: CATransform3DIdentity)]
        bubbleTransformAnim.keyTimes = [0, 0.5, 1]
        bubbleTransformAnim.duration = duration
        bubbleTransformAnim.beginTime = beginTime


        bubbleLayer.add(bubbleTransformAnim, forKey: "Scale")
        add(positionAnimation, forKey: "Position")
        
        
        
//        // 最后让小球鬼畜的抖动一下
        let bubbleShakeAnim = CAKeyframeAnimation(keyPath: "position")
        bubbleShakeAnim.beginTime = beginTime + duration + 0.05;
        bubbleShakeAnim.duration = 0.02
        bubbleShakeAnim.values = [NSValue(cgPoint: CGPoint(x: 0, y: 0)),
                                  NSValue(cgPoint: CGPoint(x: 0, y: 3)),
                                  NSValue(cgPoint: CGPoint(x: 0, y: -3)),
                                  NSValue(cgPoint: CGPoint(x: 0, y: 0)), ]
        bubbleShakeAnim.repeatCount = 6
        bubbleShakeAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        bubbleLayer.add(bubbleShakeAnim, forKey: "Shake")
    }
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animate = anim as? CAKeyframeAnimation{
            if animate.keyPath == "position"{
                removeAnimation(forKey: "Position")
                CATransaction.begin()
                // 改变小球实际的位置
                CATransaction.setAnimationDuration(0) 
                CATransaction.setDisableActions(true)
                var point = cachePosition
                point.x += (styleConfig.smallBubbleSize + styleConfig.bubbleXOffsetSpace) * CGFloat(lastDirection.toLeft() ? -1 : 1)
                position = point
                opacity = 1
                CATransaction.commit()
            }
        }
    }
    
}
