#  TKRubberIndicator

在 dribbble 上面看到一个很不错的 page control,然后就上 github 上面搜索了一下,发现有 html 版的,和安卓版的(但是我看不懂 java 啊),虽然有个小伙伴建立了一个 Swift 项目但是里面并没有什么东西,然后我就决定自己仿一个.

下面这个是 dribbble 的效果图

<img src="https://d13yacurqjgara.cloudfront.net/users/303234/screenshots/2090803/pageindicator.gif" width="400px" height="300px" />

然后这个是实际效果图

<img src="https://github.com/TBXark/TKRubberIndicator/blob/master/TKRubberIndicator/rubberindicator.gif" />



* Designed by [Valentyn Khenkin](https://dribbble.com/shots/2090803-Rubber-Indicator?list=searches&tag=indicator&offset=7)
* [Web 版](http://codepen.io/machycek/full/eNvyjb/)
* [安卓版](https://github.com/LyndonChin/AndroidRubberIndicator)


ps: 安卓版有超过1000个Star和300多分 fork, 我赵天日不服啊,iOS 的小伙伴们,让我看到你们的双手,给我一个星星吧 



## 使用 

还没有研究怎么搞 Cocoapod, 所以大家只能下载下来把文件 复制到工程里面使用,我把所有的类放到一个文件里面了

	git clone https://github.com/TBXark/TKRubberIndicator.git

##  API

#### 样式配置

|Key | Usage|
|---|---|
|smallBubbleSize|小球尺寸|
|mainBubbleSize|大球尺寸|
|bubbleXOffsetSpace|小球间距|
|bubbleYOffsetSpace|纵向间距|
|animationDuration|动画时长|
|backgroundColor|背景颜色|
|smallBubbleColor|小球颜色|
|bigBubbleColor|大球颜色|

#### 初始化

**纯代码**

    init(frame: CGRect,count:Int,config:TKRubberIndicatorConfig = TKRubberIndicatorConfig())


**XIB**

	xib 的话,我平时很少用,使用 xib 只能用默认样式初始化,但是可以添加 runtime property 来改变 pageCount,如果想用 xib 又想自定义样式的话,要不就直接修改源代码,直接改变TKRubberIndicatorConfig的默认值 :)


#### ValueChange事件
这里提供 闭包和 传统的 Target-Action 两种方式

```

class ViewController: UIViewController {

    let page = TKRubberIndicator(frame: CGRectMake(100, 100, 200, 100), count: 6)

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.view.backgroundColor = UIColor(red:0.553,  green:0.376,  blue:0.549, alpha:1)
        page.center = self.view.center
        page.valueChange = {(num) -> Void in
            print("Closure : Page is \(num)")
        }
        page.addTarget(self, action: "targetActionValueChange:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(page)

        // 可以变化 page 的个数
        page.numberOfpage = 2
    }
    
    @IBAction func pageCountChange(sender: UISegmentedControl) {
        page.numberOfpage = (sender.selectedSegmentIndex + 1) * 2
    }
    func targetActionValueChange(page:TKRubberIndicator){
        print("Target-Action : Page is \(page.currentIndex)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

```

## 注意

当页数为 0 或者 1 的时候, (-,,-)PageControl 是没有意义的,所以我会报一个断言错误


##  关于我

* [weibo](http://weibo.com/tbxark)
* [blog](http://tbxark.github.io)

## 协议

    MIT
