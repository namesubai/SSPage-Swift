//
//  SSPageViewController.swift
//  SSPageViewController
//
//  Created by Shuqy on 2021/7/10.
//

import UIKit

protocol SSPageHeaderDelegate {
    func scrollDistanceFromTop(distance: CGFloat)
}

extension SSPageHeaderDelegate {
    func scrollDistanceFromTop(distance: CGFloat) {
        
    }
}


typealias SSPageSelectEvent = (Int) -> Void
protocol SSPageTabSelectedDelegate {
    func selectTab(index: Int)
    var currentIndex: Int { get set }
    var tabSelectedTrigger: SSPageSelectEvent? { get set }
    func dragProgressDidChange(progress: CGFloat)
    mutating func selectedTrigger(_ selected: @escaping SSPageSelectEvent)
}

private var tabSelectedTriggerKey: Int8 = 0
private var currentKey: Int8 = 0

extension SSPageTabSelectedDelegate {
    mutating func selectedTrigger(_ selected: @escaping SSPageSelectEvent) {
        self.tabSelectedTrigger = selected
    }
    var tabSelectedTrigger: SSPageSelectEvent? {
        get {
            objc_getAssociatedObject(self, &tabSelectedTriggerKey) as? SSPageSelectEvent
        }
        set {
            objc_setAssociatedObject(self, &tabSelectedTriggerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var currentIndex: Int {
        get {
            objc_getAssociatedObject(self, &currentKey) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &currentKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    func dragProgressDidChange(progress: CGFloat) {
        
    }
}


private class SSDefaultPageTabView: UIView, SSPageTabSelectedDelegate {
    private let leftMargin: CGFloat = 16
    private let rightMargin: CGFloat = 16
    private let space: CGFloat = 18
    private let progressIndicatorHeight: CGFloat = 2
    private let progressIndicatorWidth: CGFloat = 30
    
    private lazy var progressIndicator: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: progressIndicatorWidth, height: progressIndicatorHeight))
        view.backgroundColor = UIColor.systemBlue
        view.layer.cornerRadius = progressIndicatorHeight / 2
        return view
    }()
    
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private var bgView: UIToolbar = {
        let bar = UIToolbar()
        bar.layer.masksToBounds = true
        return bar
    }()
    
    var titles: [String]? {
        didSet {
            if titles?.count ?? 0 > 0 {
                subviews.forEach({$0.removeFromSuperview()})
                makeUI()
            }
        }
    }
    private var buttons = [UIButton]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        scrollView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        var totalX = leftMargin
        buttons.forEach { button in
            let titleWidth = button.titleLabel!.sizeThatFits(CGSize(width: CGFloat(MAXFLOAT), height: 20)).width
            button.frame = CGRect(x: totalX + (totalX > leftMargin ? space : 0), y: 0, width: titleWidth, height: bounds.height)
            totalX = button.frame.maxX
        }
        totalX += rightMargin
        scrollView.contentSize = CGSize(width: totalX, height: bounds.height)
    }
    
    func makeUI() {
//        backgroundColor = .white
        addSubview(bgView)
        addSubview(scrollView)
        scrollView.addSubview(progressIndicator)
        buttons = [UIButton]()
        titles?.forEach { (title) in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.setTitleColor(UIColor.systemGray, for: .normal)
            button.setTitleColor(UIColor.systemBlue, for: .selected)
            button.tag = titles!.firstIndex(of: title) ?? -1
            button.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
            scrollView.addSubview(button)
            buttons.append(button)
        }
        
    }
    
    @objc
    private func buttonClick(button: UIButton) {
        guard button.tag != -1 else {
            return
        }
        guard !button.isSelected else {
            return
        }
        buttons.forEach { (bt) in
            if bt == button {
                bt.isSelected = true
            } else {
                bt.isSelected = false
            }
        }
        
        if let index = buttons.firstIndex(of: button) {
            layoutIfNeeded()
            let nextButton =  index + 1 < buttons.count ? buttons[index + 1] : button
            let frame = nextButton.superview!.convert(nextButton.frame, to: self)
            if frame.maxX >= scrollView.bounds.width - rightMargin {
                scrollView.scrollRectToVisible(nextButton.frame.offsetBy(dx: rightMargin, dy: 0), animated: true)
            }
            
            let previousButton = index == 0 ? button : buttons[index - 1]
            let previousframe = previousButton.superview!.convert(previousButton.frame, to: self)
            if previousframe.minX <= leftMargin {
                scrollView.scrollRectToVisible(previousButton.frame.offsetBy(dx: -leftMargin, dy: 0), animated: true)
            }
        }
        
        if let index = buttons.firstIndex(of: button)
        {
            if let tabSelectedTrigger = tabSelectedTrigger {
                tabSelectedTrigger(index)
            }
        }
    }
    
    func selectTab(index: Int) {
        if buttons.count > index{
            let button = buttons[index]
            buttons.forEach { (bt) in
                if bt == button {
                    bt.isSelected = true
                } else {
                    bt.isSelected = false
                }
            }
        }
        
        if index != buttons.count - 1 {
            layoutIfNeeded()
            let nextButton = buttons[index + 1]
            let frame = nextButton.superview!.convert(nextButton.frame, to: self)
            if frame.maxX >= scrollView.bounds.width - rightMargin {
                scrollView.scrollRectToVisible(nextButton.frame.offsetBy(dx: rightMargin, dy: 0), animated: true)
            }
            if index != 0 {
                let previousButton = buttons[index - 1]
                let frame = previousButton.superview!.convert(previousButton.frame, to: self)
                if frame.minX <= leftMargin {
                    scrollView.scrollRectToVisible(previousButton.frame.offsetBy(dx: -leftMargin, dy: 0), animated: true)
                }
            }
        }
        if buttons.count > self.currentIndex {
            let button = buttons[self.currentIndex]
            let toCenter = CGPoint(x: button.frame.minX + button.frame.width / 2, y: button.frame.maxY - progressIndicator.frame.height / 2)
            UIView.animate(withDuration: 0.1) {
                self.progressIndicator.center = toCenter
            }
        }
    }
    
    func dragProgressDidChange(progress: CGFloat) {
        if progress > 0 {
            if currentIndex + 1 < buttons.count {
                let nextIndex = currentIndex + 1
                let currentButton = buttons[currentIndex]
                let nextButton = buttons[nextIndex]
                let distance = nextButton.center.x - currentButton.center.x
                self.progressIndicator.center = CGPoint(x: currentButton.center.x + distance * progress, y: self.progressIndicator.center.y)
            }
        } else {
            if currentIndex - 1 >= 0 {
                let previousIndex = currentIndex - 1
                let currentButton = buttons[currentIndex]
                let previousButton = buttons[previousIndex]
                let distance = currentButton.center.x - previousButton.center.x
                self.progressIndicator.center = CGPoint(x: currentButton.center.x + distance * progress, y: self.progressIndicator.center.y)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


protocol SSPageChildDelegate {
    func childContainerView() -> UIScrollView?
    /// 滑动到底部触发，当isSupportContainerScrollFooterRefresh = true 会回调
    func containerScrollFooterRefresh()
    /// 滑动到底部触发，控制刷新的开启和结束，只有结束时才可以开始
    func containerScrollFooterIsCanRefresh() -> Bool
}
extension SSPageChildDelegate {
   
    func containerScrollFooterRefresh() {
        
    }
    
    func containerScrollFooterIsCanRefresh() -> Bool {
        return false
    }

}

typealias SSPageChildViewController = UIViewController & SSPageChildDelegate


class SSPageContainerScrollView: UIScrollView, UIGestureRecognizerDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        panGestureRecognizer.delegate = self
//        showsVerticalScrollIndicator = false
//        panGestureRecognizer.cancelsTouchesInView = false
//        panGestureRecognizer.delaysTouchesBegan = false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}


open class SSPageViewController: UIViewController {
    
    private(set) lazy var containerScrollView: SSPageContainerScrollView = {
        let scrollView = SSPageContainerScrollView()
//        scrollView.backgroundColor = .yellow
        return scrollView
    }()
    
    private lazy var pageViewController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.delegate = self
        pageController.dataSource = self
        return pageController
    }()
    
    
    private var tabView: (UIView & SSPageTabSelectedDelegate)?
    private lazy var headerView: UIView? = nil
    private var currentViewControllers: [UIViewController]? = nil
    private var willTransitionToViewController: UIViewController? = nil
    private var lastContainerScrollViewOffsetY: CGFloat = 0
    private var isSelectedTranslate = false
    private var observerRecords = [Int:Int?]()
    private(set) var selectedPageNum: Int = -1 {
        didSet {
            if selectedPageNum != oldValue {
                self.tabView?.currentIndex = selectedPageNum
                tabView?.selectTab(index: selectedPageNum)
                if let currentViewController = currentViewController as? SSPageChildViewController {
                    if let scrollView = currentViewController.childContainerView() {
                        
                        if observerRecords[selectedPageNum] == 1 {
                            scrollView.removeObserver(self, forKeyPath: "contentOffset")
                            scrollView.removeObserver(self, forKeyPath: "contentSize")
                            observerRecords[selectedPageNum] = 0
                        }
                        
                        scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
                        scrollView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
                        observerRecords[selectedPageNum] = 1
                        scrollView.contentSize = scrollView.contentSize
                    }
                }
            }
        }
    }
    var currentViewController: UIViewController? {
        if let currentViewControllers = currentViewControllers {
            if currentViewControllers.count > selectedPageNum && selectedPageNum !=  -1 {
                return currentViewControllers[selectedPageNum]
            }
        }
        
        return nil
    }
    private var _pageScrollView: UIScrollView?
    
    private var pageScrollView: UIScrollView? {
        if _pageScrollView == nil {
            _pageScrollView = self.findScrollView(superView: pageViewController.view)
            return _pageScrollView
        }
        return _pageScrollView
    }
    /// 支持下拉刷新
    var isSupportHeaderRefresh: Bool = false
    /// 支持滑动底部触发刷新
    var isSupportContainerScrollFooterRefresh: Bool = false
    /// 滑动底部触发刷新距离
    var supportContainerScrollFooterRefreshDistance: CGFloat = 2

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        var topMargin: CGFloat = 0
        if let tabView = self.tabView {
            tabView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: tabView.frame.height)
            topMargin = tabView.frame.maxY
        }
        if let headerView = self.headerView  {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: headerView.frame.height)
            tabView?.center = CGPoint(x: headerView.center.x, y: headerView.frame.maxY + (tabView?.frame.height ?? 0) / 2)
            topMargin = tabView?.frame.maxY ?? 0
        }
        containerScrollView.scrollIndicatorInsets = UIEdgeInsets(top: topMargin, left: 0, bottom: 0, right: 0)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height + (headerView?.frame.height ?? 0) - containerScrollView.topMargin)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        containerScrollView.backgroundColor = .yellow
        view.addSubview(containerScrollView)
        containerScrollView.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        containerScrollView.addSubview(pageViewController.view)
        
        if  let scrollView = pageScrollView {
            if let panGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
                scrollView.panGestureRecognizer.require(toFail: panGestureRecognizer)
                scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (object as? SSPageContainerScrollView) != nil {
            if keyPath == "contentOffset" {
                
                let topY = (headerView?.frame.height ?? 0) - containerScrollView.topMargin
                if let newOffset = change?[.newKey] as? CGPoint, let OldOffset = change?[.oldKey] as? CGPoint {
                    if let headerView = self.headerView as? SSPageHeaderDelegate, newOffset.y < -containerScrollView.topMargin {
                        headerView.scrollDistanceFromTop(distance: abs(newOffset.y) - containerScrollView.topMargin)
                    }
                    
                    
                    if newOffset.y != OldOffset.y {
                        if newOffset.y >= OldOffset.y  {
                           
                            
                            if newOffset.y >= topY {
                                if let tabView = tabView {
                                    tabView.frame = CGRect(x: 0, y: newOffset.y + containerScrollView.topMargin, width: tabView.frame.width, height: tabView.frame.height)
                                }
                            }
                            
                            /// 当子视图滑动到底部，containerscrollview不动
                            if let currentViewController = currentViewController as? SSPageChildViewController {
                                if let scrollView = currentViewController.childContainerView() {
                                    if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height && self.headerView != nil  {
                                        containerScrollView.contentOffset = CGPoint(x: 0, y: containerScrollView.contentSize.height - containerScrollView.frame.height + containerScrollView.bottomMargin)
                                    }
                                    
                                    
                                }
                            }
                            
                            if containerScrollView.contentOffset.y > (containerScrollView.contentSize.height - containerScrollView.frame.height + containerScrollView.bottomMargin) + 1 && isSupportContainerScrollFooterRefresh {
                                if let currentViewController = currentViewController as? SSPageChildViewController {
                                    if currentViewController.containerScrollFooterIsCanRefresh() {
                                        currentViewController.containerScrollFooterRefresh()
                                        if let scrollView = currentViewController.childContainerView() {
                                            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.frame.height + 50), animated: true)
                                        }
                                    }
                                }
                            }
                            
                        } else {
                            
                            
                            if newOffset.y < topY  {
                                if let tabView = tabView {
                                    tabView.frame = CGRect(x: 0, y: topY + containerScrollView.topMargin, width: tabView.frame.width, height: tabView.frame.height)
                                }
                            } else {
                                if let tabView = tabView {
                                    tabView.frame = CGRect(x: 0, y: newOffset.y + containerScrollView.topMargin, width: tabView.frame.width, height: tabView.frame.height)
                                }
                            }
                            if (isSupportHeaderRefresh || self.headerView == nil) &&  containerScrollView.contentOffset.y < -containerScrollView.topMargin  {
                                
                                containerScrollView.contentOffset = CGPoint(x: 0, y: -containerScrollView.topMargin)
                            }
                            
                        }
                    }
                    
                    
                }
            }
            
        } else if object as? UIScrollView? == pageScrollView {
            if keyPath == "contentOffset" {
                if let newOffset = change?[.newKey] as? CGPoint, let OldOffset = change?[.oldKey] as? CGPoint, !isSelectedTranslate {
                    if newOffset.x != OldOffset.x  {
                        if let currentViewController = currentViewController {
                            let convertFrame = currentViewController.view.superview!.convert(currentViewController.view.frame, to: view)
                            if convertFrame.minX != 0 {
                                let progress = -convertFrame.minX / view.bounds.width
                                tabView?.dragProgressDidChange(progress: progress)
                            }
                        }
                    }
                }
                
            }
            
        } else {
            if keyPath == "contentOffset" {
                if let newOffset = change?[.newKey] as? CGPoint, let OldOffset = change?[.oldKey] as? CGPoint {
                    let topY = (headerView?.frame.height ?? 0) - containerScrollView.topMargin
                    if newOffset.y != OldOffset.y {
                        if newOffset.y < OldOffset.y {
                            if containerScrollView.contentOffset.y != 0 {
                                if let currentViewController = currentViewController as? SSPageChildViewController {
                                    if let scrollView = currentViewController.childContainerView() {
                                        if scrollView.contentOffset.y < -scrollView.contentInset.top && !isSupportHeaderRefresh {
                                            scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
                                        }
                                        
                                    }
                                }
                            }
                            
                        } else {
                            if containerScrollView.contentOffset.y < topY {
                                if let currentViewController = currentViewController as? SSPageChildViewController {
                                    if let scrollView = currentViewController.childContainerView() {
                                        if newOffset.y > -scrollView.contentInset.top {
                                            scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
                                        }
                                        
                                    }
                                }
                            }
                           
                        }
                    }
                    
                }
                
            }
            
            
            if keyPath == "contentSize" {
                if let newSize = change?[.newKey] as? CGSize {
                    let topHeight = (headerView?.frame.height ?? 0) + (tabView?.frame.height ?? 0)
                    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.width, height: newSize.height + topHeight)
                    var frame = pageViewController.view.frame
                    var size = frame.size
                    size.height = containerScrollView.contentSize.height
                    frame.size = size
                    pageViewController.view.frame = frame
                    if let currentViewController = currentViewController as? SSPageChildViewController {
                        if let scrollView = currentViewController.childContainerView() {
                            var frame = scrollView.frame
                            var size = frame.size
                            size.height = containerScrollView.contentSize.height
                            frame.size = size
                            scrollView.frame = frame
                        }
                    }
                }
                
            }

        }
        
    }
 
    
    func setViewControllers(viewControllers: [SSPageChildViewController],
                            titles: [String],
                            headerView: UIView? = nil) {
        let pageTab = SSDefaultPageTabView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        pageTab.titles = titles
        setViewControllers(viewControllers: viewControllers, tabView: pageTab, headerView: headerView)
    }
    
    func setViewControllers(viewControllers: [SSPageChildViewController], tabView: UIView & SSPageTabSelectedDelegate, headerView: UIView? = nil) {
        if let headerView = headerView {
            containerScrollView.addSubview(headerView)
            self.headerView = headerView
        } else {
            isSupportHeaderRefresh = true
        }
        containerScrollView.addSubview(tabView)
        self.tabView = tabView
        self.currentViewControllers = viewControllers
        tabView.selectTab(index: 0)
        
        if viewControllers.count > 0 {
            let toViewController = viewControllers.first!
            self.resetChildViewArea(viewController: toViewController)
            self.pageViewController.setViewControllers([toViewController], direction: .forward, animated: true) { [weak self] (finish) in
                guard let self = self else { return }
                self.pageViewController.view.layoutIfNeeded()
                self.selectedPageNum = 0
            }
           
        }
        self.tabView?.selectedTrigger { [weak self] (index) in
            guard let self = self else { return }
            self.isSelectedTranslate = true
            if let viewControllers = self.currentViewControllers {
                if viewControllers.count > index {
                    let toViewController = viewControllers[index]
                    self.resetChildViewArea(viewController: toViewController)
                    let vcs = [toViewController]
                    if index > self.selectedPageNum {
                        self.pageViewController.setViewControllers(vcs, direction: .forward, animated: true) { (finish) in
                            if finish {
                                self.selectedPageNum = index
                                self.isSelectedTranslate = false
                            }
                        }
                    } else {
                        self.pageViewController.setViewControllers(vcs, direction: .reverse, animated: true) { (finish) in
                            if finish {
                                self.selectedPageNum = index
                                self.isSelectedTranslate = false
                            }
                        }
                    }
                    
                }
            }
            
        }
    }
    
    private func findScrollView(superView: UIView) -> UIScrollView? {
        for view in superView.subviews {
            if NSStringFromClass(view.self.classForCoder) == "_UIQueuingScrollView" {
                if let scrollView = view as? UIScrollView {
                    return scrollView
                }
            } else {
                if let scrollView = findScrollView(superView: view) {
                    return scrollView
                }
            }
            
        }
        return nil
    }
    
    func resetChildViewArea(viewController: UIViewController?) {
        if let viewController = viewController as? SSPageChildViewController {
            let topMargin = (tabView?.frame.height ?? 0) + (headerView?.frame.height ?? 0)
            if let scrollView = viewController.childContainerView() {
                if #available(iOS 11.0, *) {
                    scrollView.contentInsetAdjustmentBehavior = .never
                } else {
                    viewController.automaticallyAdjustsScrollViewInsets = false
                }
                scrollView.contentInset = UIEdgeInsets(top: topMargin, left: scrollView.contentInset.left, bottom: scrollView.contentInset.bottom, right: scrollView.contentInset.right)
                scrollView.layoutIfNeeded()
                scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
            } else {
                if #available(iOS 11.0, *) {
                    viewController.additionalSafeAreaInsets = viewController.view.safeAreaInsets
                    viewController.additionalSafeAreaInsets = UIEdgeInsets(top: topMargin - viewController.view.safeAreaInsets.top , left: 0, bottom: 0, right: 0)
                } else {
                    viewController.topLayoutGuide.heightAnchor.constraint(equalToConstant: topMargin).isActive = true
                }
            }
        }
    }
    
  
    deinit {
        if let scrollView = self.pageScrollView {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
        containerScrollView.removeObserver(self, forKeyPath: "contentOffset")
        observerRecords.forEach { (index, value) in
            if let viewController = currentViewControllers?[index] as? SSPageChildViewController {
                if value == 1 {
                    if let tableView = viewController.childContainerView() {
                        tableView.removeObserver(self, forKeyPath: "contentOffset")
                        tableView.removeObserver(self, forKeyPath: "contentSize")
                    }
                }
                
            }
        }
       
    }
    
    
}


extension SSPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        ///向前
        guard let viewControllers = self.currentViewControllers else {
            return nil
        }
        if let index = viewControllers.firstIndex(of: viewController) {
            if index == 0 {
                return nil
            } else {
                return viewControllers[index - 1]
            }
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        ///向后
        guard let viewControllers = self.currentViewControllers else {
            return nil
        }
        if let index = viewControllers.firstIndex(of: viewController) {
            if index + 1  == viewControllers.count {
                return nil
            } else {
                return viewControllers[index + 1]
            }
        }
        return nil
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let willTransitionToViewController = willTransitionToViewController, completed == true {
            if let index = currentViewControllers?.firstIndex(of: willTransitionToViewController), willTransitionToViewController != previousViewControllers.first {
                selectedPageNum = index
            }
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        willTransitionToViewController = pendingViewControllers.first
        resetChildViewArea(viewController: willTransitionToViewController)
    }
    
}

extension UIScrollView {
    var topMargin: CGFloat {
        var topMargin = contentInset.top
        if #available(iOS 11.0, *) {
            topMargin = adjustedContentInset.top
        }
        return topMargin
    }
    
    var bottomMargin: CGFloat {
        var topMargin = contentInset.bottom
        if #available(iOS 11.0, *) {
            topMargin = adjustedContentInset.bottom
        }
        return topMargin
    }
}


