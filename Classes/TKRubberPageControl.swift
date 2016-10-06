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
    func toBool() -> Bool{
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
    var smallBubbleSize: CGFloat = 16     // 小球尺寸
    var mainBubbleSize: CGFloat = 40    // 大球尺寸
    var bubbleXOffsetSpace: CGFloat = 12    // 小球间距
    var bubbleYOffsetSpace: CGFloat = 8    // 纵向间距
    var animationDuration: CFTimeInterval = 0.2    // 动画时长
    var smallBubbleMoveRadius: CGFloat {return smallBubbleSize + bubbleXOffsetSpace}    // 小球运动半径
    var backgroundColor: UIColor = UIColor(red: 0.357, green: 0.196, blue: 0.337, alpha: 1)    // 横条背景颜色
    var smallBubbleColor: UIColor = UIColor(red: 0.961, green: 0.561, blue: 0.518, alpha: 1)    // 小球颜色
    var bigBubbleColor: UIColor = UIColor(red: 0.788, green: 0.216, blue: 0.337, alpha: 1)    // 大球颜色
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
    
    //手势
    fileprivate var indexTap     : UITapGestureRecognizer?
    // 所有图层
    fileprivate var smallBubbles    = [TKBubbleCell]()
    fileprivate var backgroundLayer = CAShapeLayer()
    fileprivate var mainBubble      = CAShapeLayer()
    fileprivate var backLineLayer   = CAShapeLayer()
    
    // 大球缩放比例
    fileprivate let bubbleScale  : CGFloat  = 1/3.0
    
    // 存储计算用的
    fileprivate var xPointbegin  : CGFloat = 0
    fileprivate var xPointEnd    : CGFloat = 0
    fileprivate var yPointbegin  : CGFloat = 0
    fileprivate var yPointEnd    : CGFloat = 0
    
    
    public init(frame: CGRect, count: Int, config: TKRubberPageControlConfig = TKRubberPageControlConfig()) {
        numberOfpage = count
        styleConfig = config
        super.init(frame: frame)
        self.setUpView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        styleConfig = TKRubberPageControlConfig()
        super.init(coder: aDecoder)
        self.setUpView()
    }
    
    fileprivate func setUpView(){
        
        // 一些奇怪的位置计算
        
        let y = (bounds.height - (styleConfig.smallBubbleSize + 2 * styleConfig.bubbleYOffsetSpace))/2
        let w = CGFloat(numberOfpage - 2) * styleConfig.smallBubbleSize + styleConfig.mainBubbleSize + CGFloat(numberOfpage) * styleConfig.bubbleXOffsetSpace
        let h = styleConfig.smallBubbleSize + styleConfig.bubbleYOffsetSpace * 2
        let x = (bounds.width - w)/2
        if w > bounds.width || h > bounds.height {
            print("Draw UI control out off rect")
        }
        
        xPointbegin  = x
        xPointEnd    = x + w
        yPointbegin  = y
        yPointEnd    = y + h
        
        let lineFrame = CGRect(x: x, y: y, width: w, height: h)
        let frame     = CGRect(x: x, y: y - (styleConfig.mainBubbleSize - h)/2, width: styleConfig.mainBubbleSize, height: styleConfig.mainBubbleSize)
        var layerFrame = frame.insetBy(dx: styleConfig.bubbleYOffsetSpace , dy: styleConfig.bubbleYOffsetSpace)
        
        
        // 背景的横线
        backLineLayer.path      = UIBezierPath(roundedRect: lineFrame, cornerRadius: h/2).cgPath
        backLineLayer.fillColor = styleConfig.backgroundColor.cgColor
        self.layer.addSublayer(backLineLayer)
        
        
        // 大球背景的圈
        backgroundLayer.path      = UIBezierPath(ovalIn: frame).cgPath
        backgroundLayer.fillColor = styleConfig.backgroundColor.cgColor
        backgroundLayer.zPosition = -1
        self.layer.addSublayer(backgroundLayer)
        
        
        
        // 大球
        let origin           = layerFrame.origin
        layerFrame.origin    = CGPoint.zero
        mainBubble.path      = UIBezierPath(ovalIn: layerFrame).cgPath
        mainBubble.fillColor = styleConfig.bigBubbleColor.cgColor
        layerFrame.origin    = origin
        mainBubble.frame     = layerFrame
        mainBubble.zPosition = 100
        self.layer.addSublayer(mainBubble)
        
        
        // 生成小球
        let bubbleOffset = styleConfig.smallBubbleSize + styleConfig.bubbleXOffsetSpace
        var bubbleFrame  = CGRect(x: x + styleConfig.bubbleXOffsetSpace + bubbleOffset , y: y + styleConfig.bubbleYOffsetSpace, width: styleConfig.smallBubbleSize, height: styleConfig.smallBubbleSize)
        for _ in 0..<(numberOfpage-1){
            let smallBubble       = TKBubbleCell(style: styleConfig)
            smallBubble.frame     = bubbleFrame
            self.layer.addSublayer(smallBubble)
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
        smallBubbles.forEach {$0.removeFromSuperlayer()}
        smallBubbles.removeAll()
        setUpView()
    }
    
    
    
    // 手势事件
    @objc fileprivate func tapValueChange(_ ges: UITapGestureRecognizer){
        let point = ges.location(in: self)
        if point.y > yPointbegin && point.y < yPointEnd && point.x > xPointbegin && point.x < xPointEnd{
            let index = Int(point.x - xPointbegin) / Int(styleConfig.smallBubbleMoveRadius)
            changIndexToValue(index)
        }
    }
    
    // Index值变化
    fileprivate func changIndexToValue(_ valueIndex: Int){
        var index = valueIndex
        if index >= numberOfpage{index = numberOfpage - 1}
        if index < 0{index = 0}
        if index == currentIndex {return}
        
        let direction = (currentIndex > index) ? TKMoveDirection.right : TKMoveDirection.left
        let point     = CGPoint(x: xPointbegin + styleConfig.smallBubbleMoveRadius * CGFloat(index) + styleConfig.mainBubbleSize/2, y: yPointbegin - styleConfig.bubbleYOffsetSpace/2)
        let range     = (currentIndex < index) ? (currentIndex+1)...index : index...(currentIndex-1)
        
        for index in range{
            let smallBubbleIndex = (direction.toBool()) ? (index - 1) : (index)
            let smallBubble      = smallBubbles[smallBubbleIndex]
            smallBubble.positionChange(direction, radius: styleConfig.smallBubbleMoveRadius / 2, duration: styleConfig.animationDuration, beginTime: CACurrentMediaTime())
        }
        currentIndex = index
        mainBubblePositionChange(direction, position: point, duration: styleConfig.animationDuration)
        
        // 可以使用 Target-Action 监听事件
        sendActions(for: UIControlEvents.valueChanged)
        // 也可以使用 闭包 监听事件
        valueChange?(currentIndex)
        
    }
    
    // 大球动画
    fileprivate func mainBubblePositionChange(_ direction: TKMoveDirection, position: CGPoint, duration: Double){
        var point = position
        // 大球缩放动画
        let bubbleTransformAnim      = CAKeyframeAnimation(keyPath: "transform")
        bubbleTransformAnim.values   = [NSValue(caTransform3D: CATransform3DIdentity), 
            NSValue(caTransform3D: CATransform3DMakeScale(bubbleScale, bubbleScale, 1)), 
            NSValue(caTransform3D: CATransform3DIdentity)]
        bubbleTransformAnim.keyTimes = [0, 0.5, 1]
        bubbleTransformAnim.duration = duration
        
        
        // 大球移动动画, 用隐式动画大球的位置会真正的改变
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        point.y += styleConfig.mainBubbleSize/2
        mainBubble.position = point

        point.y = 0
        point.x = (xPointEnd - xPointbegin - styleConfig.bubbleXOffsetSpace/2) / CGFloat(numberOfpage) * CGFloat(currentIndex) - (styleConfig.bubbleYOffsetSpace / 4)
        backgroundLayer.position = point
        CATransaction.commit()
        
        mainBubble.add(bubbleTransformAnim, forKey: "Scale")
    }
}







// MARK: - Small Bubble
private class TKBubbleCell: CAShapeLayer, CAAnimationDelegate {
    
    fileprivate var bubbleLayer = CAShapeLayer()
    fileprivate let bubbleScale   : CGFloat  = 0.5
    fileprivate var lastDirection : TKMoveDirection!
    fileprivate var styleConfig   : TKRubberPageControlConfig
    fileprivate var cachePosition = CGPoint.zero
    
    override init(layer: Any) {
        styleConfig = TKRubberPageControlConfig()
        super.init(layer: layer)
        setupLayer()
    }
    
    init(style: TKRubberPageControlConfig) {
        styleConfig = style
        super.init()
        setupLayer()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        styleConfig = TKRubberPageControlConfig()
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    fileprivate func setupLayer(){
        self.frame = CGRect(x: 0, y: 0, width: styleConfig.smallBubbleSize, height: styleConfig.smallBubbleSize)
        
        bubbleLayer.path        = UIBezierPath(ovalIn: self.bounds).cgPath
        bubbleLayer.fillColor   = styleConfig.smallBubbleColor.cgColor
        bubbleLayer.strokeColor = styleConfig.backgroundColor.cgColor
        bubbleLayer.lineWidth   = styleConfig.bubbleXOffsetSpace / 8
        
        self.addSublayer(bubbleLayer)
    }
    
    // beginTime 本来是留给小球轮播用的, 但是效果不好就没用了
    func positionChange(_ direction: TKMoveDirection, radius: CGFloat, duration: CFTimeInterval, beginTime: CFTimeInterval){
        
        let toLeft = direction.toBool()
        let movePath = UIBezierPath()
        var center = CGPoint.zero
        let startAngle = toLeft ? 0 : CGFloat(M_PI)
        let endAngle   = toLeft ? CGFloat(M_PI) : 0
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
        cachePosition = self.position
        
        // 小球变形动画, 小球变形实际上只是 Y 轴上的 Scale
        let bubbleTransformAnim      = CAKeyframeAnimation(keyPath: "transform")
        bubbleTransformAnim.values   = [NSValue(caTransform3D: CATransform3DIdentity), 
            NSValue(caTransform3D: CATransform3DMakeScale(1, bubbleScale, 1)), 
            NSValue(caTransform3D: CATransform3DIdentity)]
        bubbleTransformAnim.keyTimes = [0, 0.5, 1]
        bubbleTransformAnim.duration = duration
        bubbleTransformAnim.beginTime = beginTime


        bubbleLayer.add(bubbleTransformAnim, forKey: "Scale")
        self.add(positionAnimation, forKey: "Position")
        
        
        
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
        self.bubbleLayer.add(bubbleShakeAnim, forKey: "Shake")
    }
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let animate = anim as? CAKeyframeAnimation{
            if animate.keyPath == "position"{
                removeAnimation(forKey: "Position")
                CATransaction.begin()
                // 改变小球实际的位置
                CATransaction.setAnimationDuration(0) 
                CATransaction.setDisableActions(true)
//                self.opacity = 0
                var point = self.cachePosition
                point.x += (styleConfig.smallBubbleSize + styleConfig.bubbleXOffsetSpace) * CGFloat(lastDirection.toBool() ? -1 : 1)
//                print(point)
                self.position = point
                self.opacity = 1
                CATransaction.commit()
            }
        }
    }
    
}
