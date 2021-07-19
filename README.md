# SSPageViewController
使用UIPageViewController实现的简单易用的界面切换组件
# 支持功能
- 自定义tab
- 可以根据tab滑动百分比回调自定义动画
- 自定义头部header
- 可以根据头部滑动距离百分比回调自定义动画
- 下拉上拉刷新
# 效果
<img src="https://github.com/namesubai/SSPageViewController/blob/main/默认tab.gif" width = 20% height = 20% /><img src="https://github.com/namesubai/SSPageViewController/blob/main/自定义tab.gif" width = 20% height = 20% /><img src="https://github.com/namesubai/SSPageViewController/blob/main/上下拉刷新.gif" width = 20% height = 20% /><img src="https://github.com/namesubai/SSPageViewController/blob/main/头部图片放大.gif" width = 20% height = 20% />
# 使用
### 1. 导入SSPageViewController，继承SSPageViewController
### 2. 添加子控制器
初始化子控制器：
extension DemoViewController: SSPageChildDelegate {
    
    func childContainerView() -> UIScrollView? {
        return tableView
    }
    ## 不必须实现方法
    func containerScrollFooterRefresh() {
        print("底部触发")
        tableView.mj_footer?.beginRefreshing()
    }
    ## 不必须实现方法
    func containerScrollFooterIsCanRefresh() -> Bool {
        return tableView.mj_footer!.state == .refreshing ? false : true
    }
}

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
需要支持拖动头部的上拉刷新必须设置，且必须实现相关代理
```
isSupportContainerScrollFooterRefresh = true

class ChildVC: SSPageChildDelegate {
  func containerScrollFooterRefresh() {
        print("底部触发")
        tableView.mj_footer?.beginRefreshing()
    }
    
    func containerScrollFooterIsCanRefresh() -> Bool {
        return tableView.mj_footer!.state == .refreshing ? false : true
    }
}

```

### 2. 头部图片放大

自定义header
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







