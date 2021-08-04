# SSPage-Swift
使用UIPageViewController实现的简单易用的分页左右切换组件，非常容易自定义tab和header，自带默认tab
# 特性 
- header部分可以滑动，延续滑动～
- 有毛玻璃穿透效果
- 自定义tab，tab悬浮
- 可以根据tab滑动百分比回调自定义动画，例如菜单左右拖拽底部横条跟随动画
- 自定义头部header
- 可以根据头部滑动距离百分比回调自定义动画，例如头部图片放大效果
- 下拉上拉刷新
# 原理部分
1. 分页左右切换效果（类似微博、twitter个人主页），目前有好多开源的组件都有实现这种功能，例如使用比较多的：[JXPagingView](https://github.com/pujiaxin33/JXPagingView)。
大概原理是使用多个scrollView嵌套，然后scrollView的shouldRecognizeSimultaneouslyWith处理手势冲突，然后通过scrollView的contentOffset来控制其他的scrollView的contentOffset来实现对应的效果
2. 本人想到既然vc分页切换，系统自动UIPageViewController就可以实现,但是要有头部headerview还需要花点功夫去思考实现方案。 我想到的方案非常简单，pageViewController放在下面，headerview放在上面，然后重新设置pageViewController子控制器的内容显示在header以下，通过监听pageViewController子控制器scrollView的contentOffset来控制headerView和tab的位置，但还有两个难点需要解决：
- 在header区域可以滑动pageViewController子控制器scrollView
- 控制每一个子控制器scrollView的位置，因为当前滑动的scrollView位置变化后，headerView也变化了，相应其他的子控制器scrollView也要相对应的变化。

第二个问题比较容易解决，只是逻辑稍微复杂点，第一个问题先想到的方案时在headerView的hitTest里返回当前滑动的scrollView,这样时可以滑动，但是headerView上点击事件响应就需要一个一个去判断控制，这样很繁琐，也不适合后面headerView的自定义。有没有一次又能滑动又能不影响点击事件的方法呢？有的，通过以下代码控制scrollView的滑动手势作用的view就行：
```
 weak var panGestureScrollView: UIScrollView?
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if let panGestureScrollView = panGestureScrollView {
            if self.point(inside: point, with: event), let view = view {
                panGestureScrollView.panGestureRecognizer.delaysTouchesBegan = true
                if (view.gestureRecognizers ?? []).contains(panGestureScrollView.panGestureRecognizer) == false  {
                    view.addGestureRecognizer(panGestureScrollView.panGestureRecognizer)
                }
            } else {
                if (panGestureScrollView.gestureRecognizers ?? []).contains(panGestureScrollView.panGestureRecognizer) == false  {
                    panGestureScrollView.addGestureRecognizer(panGestureScrollView.panGestureRecognizer)
                }
                
            }
        }
        
        return view
    }
```
以上就是大概的实现原理，因为是使用UIPageViewController实现的没有嵌套scrollView那些繁琐的逻辑

# 效果
<img src="https://github.com/namesubai/SSPageViewController/blob/main/不带header.gif" width = 20% height = 20% /> <img src="https://github.com/namesubai/SSPageViewController/blob/main/默认tab.gif" width = 20% height = 20% /><img src="https://github.com/namesubai/SSPageViewController/blob/main/自定义tab.gif" width = 20% height = 20% /><img src="https://github.com/namesubai/SSPageViewController/blob/main/上下拉刷新.gif" width = 20% height = 20% /><img src="https://github.com/namesubai/SSPageViewController/blob/main/头部图片放大.gif" width = 20% height = 20% />
# 使用
### 1. 导入SSPageViewController或者pod 'SSPage-Swift' ，
### 2. 继承SSPageViewController,添加子控制器
遵循SSPageChildDelegate
```
extension DemoViewController: SSPageChildDelegate {
    
    func childContainerView() -> UIScrollView? {
        return tableView
    }
}
```
### 1.默认自带tab
```

let viewControllers = titles.map({
                title -> SSPageChildViewController in
                let vc = DemoViewController(text: "default: \(title)")
                return vc
            })
setViewControllers(viewControllers: viewControllers, titles: titles, headerView: headerView)
```
headerView是可选参数，可以不传

### 2. 自定义tab， 自定义header
```
let viewControllers = titles.map({
                title -> SSPageChildViewController in
                let vc = DemoViewController(text: "custom: \(title)")
                return vc
            })
 let tabView = CustomTabView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
 setViewControllers(viewControllers: viewControllers, tabView: tabView,  headerView: headerView)
 ```
 
 自定义tab，必须实现SSPageTabSelectedDelegate协议和tabSelectedTrigger触发
 ```
 class CustomTabView: UIView, SSPageTabSelectedDelegate {
    func selectTab(index: Int) {
        segmentedControl.selectedSegmentIndex = index
    }
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(frame:.zero)
        return segmentedControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(segmentedControl)
        segmentedControl.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        for index in 0..<4 {
            segmentedControl.insertSegment(withTitle: "seleted\(index)", at: index, animated: true)
        }
        segmentedControl.addTarget(self, action: #selector(segmentedAction(segmented:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    @objc private func segmentedAction(segmented: UISegmentedControl) {
        if let tabSelectedTrigger = tabSelectedTrigger {
            tabSelectedTrigger(segmented.selectedSegmentIndex)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
 
```

### 2. 刷新
支持下拉刷新，这时候头部滑动是没弹性效果的
``` 
isSupportHeaderRefresh = true 
```

### 2. 头部图片放大

自定义header, 实现SSPageHeaderDelegate，在回调方法scrollDistanceFromTop控制图片变化
```
class CustomImageHeaderView: UIView, SSPageHeaderDelegate {
    
    private lazy var bgImageView: UIImageView = {
        let imageV = UIImageView()
        imageV.image = UIImage(named: "image")
        imageV.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        imageV.contentMode = .scaleAspectFill
        imageV.layer.masksToBounds = true
        return imageV
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bgImageView)
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("点击", for: .normal)
        addSubview(button)
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        button.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
        button.addTarget(self, action: #selector(clickAction(button:)), for: .touchUpInside)
    }
    
    @objc
    private func clickAction(button: UIButton) {
        print("点击了")
    }
    
    func scrollDistanceFromTop(distance: CGFloat) {
        let scale = distance / frame.height
        bgImageView.transform = CGAffineTransform(scaleX: scale + 1, y: scale + 1)
        bgImageView.center = CGPoint(x: frame.width / 2, y: frame.height / 2 - distance / 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

```
觉得好用给个star ❤️




