//
//  SSPageViewController.swift
//  SSPageViewController
//
//  Created by Shuqy on 2021/7/10.
//

import UIKit

public protocol SSPageHeaderDelegate {
    func scrollDistanceFromTop(distance: CGFloat)
}

public extension SSPageHeaderDelegate {
    func scrollDistanceFromTop(distance: CGFloat) {
        
    }
}


public typealias SSPageSelectEvent = (Int) -> Void
public protocol SSPageTabSelectedDelegate {
    func selectTab(index: Int)
    var currentIndex: Int { get set }
    var tabSelectedTrigger: SSPageSelectEvent? { get set }
    func dragProgressDidChange(progress: CGFloat)
    mutating func selectedTrigger(_ selected: @escaping SSPageSelectEvent)
}

private var tabSelectedTriggerKey: Int8 = 0
private var currentKey: Int8 = 0

public extension SSPageTabSelectedDelegate {
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


public protocol SSPageChildDelegate {
    func childContainerView() -> UIScrollView?
}

private class PageHeaderContainerView: UIView {
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
}


open class SSPageViewController: UIViewController {

    private lazy var pageViewController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.delegate = self
        pageController.dataSource = self
        return pageController
    }()
    
    private lazy var headerContainerView: PageHeaderContainerView = {
        let headerView = PageHeaderContainerView()
        return headerView
    }()
    
    
    private var tabView: (UIView & SSPageTabSelectedDelegate)?
    private lazy var headerView: UIView? = nil
    private var currentViewControllers: [UIViewController]? = nil
    private var willTransitionToViewController: UIViewController? = nil
    private var isSelectedTranslate = false
    private var contentOffsets = [Int:CGFloat]()
    /// 支持下拉刷新
    public var isSupportHeaderRefresh: Bool = false
    private(set) var selectedPageNum: Int = -1 {
        didSet {
            if selectedPageNum != oldValue {
                self.tabView?.currentIndex = selectedPageNum
                tabView?.selectTab(index: selectedPageNum)
                willTransitionToViewController = nil
                if let currentViewController = self.currentViewController {
                    if let childViewControlelr = currentViewController as? SSPageChildDelegate, let scrollView = childViewControlelr.childContainerView() {
                        self.headerContainerView.panGestureScrollView = scrollView
                    }
                }
            }
        }
    }
    public var currentViewController: UIViewController? {
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
  

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        var topMargin: CGFloat = 0
        if let headerView = self.headerView  {
            headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: headerView.frame.height)
            topMargin = headerView.frame.maxY
        }
        if let tabView = self.tabView {
            tabView.frame = CGRect(x: 0, y: topMargin, width: view.frame.width, height: tabView.frame.height)
            topMargin = tabView.frame.maxY
        }
        headerContainerView.frame = CGRect(x: 0, y: self.navigationBarAndStatusBarHeight, width: view.frame.width, height: topMargin)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    private func makeUI() {
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        view.addSubview(pageViewController.view)
        view.addSubview(headerContainerView)
        if let headerView = self.headerView {
            headerContainerView.addSubview(headerView)
        }
        if let tabView = self.tabView {
            headerContainerView.addSubview(tabView)
        }
        
        if  let scrollView = pageScrollView {
            if let panGestureRecognizer = self.navigationController?.interactivePopGestureRecognizer {
                scrollView.panGestureRecognizer.require(toFail: panGestureRecognizer)
                scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
            }
        }
        
        (self.currentViewControllers ?? []).forEach { viewController in
            configChildViewControlelr(viewController: viewController)
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? UIScrollView? == pageScrollView {
            if keyPath == "contentOffset" {
                if let newOffset = change?[.newKey] as? CGPoint, let OldOffset = change?[.oldKey] as? CGPoint, !isSelectedTranslate {
                    if newOffset.x != OldOffset.x  {
                        if let currentViewController = currentViewController {
                            if let superView = currentViewController.view.superview {
                                let convertFrame = superView.convert(currentViewController.view.frame, to: view)
                                if convertFrame.minX != 0 {
                                    let progress = -convertFrame.minX / view.bounds.width
                                    tabView?.dragProgressDidChange(progress: progress)
                                }
                            }
                            
                        }
                    }
                }
                
            }
            
        } else {
            if keyPath == "contentOffset" {
                if let newOffset = change?[.newKey] as? CGPoint {
                    if let scrollView = object as? UIScrollView, scrollView == ((willTransitionToViewController ?? currentViewController) as? SSPageChildDelegate)?.childContainerView() {
//                        print(newOffset.y)
                        self.contentOffsets[selectedPageNum] = newOffset.y
                        let topMargin = (tabView?.frame.height ?? 0) + (headerView?.frame.height ?? 0) + navigationBarAndStatusBarHeight
                        let scrollDistance = newOffset.y + topMargin
                        let frame = self.headerContainerView.frame
                        if self.headerView != nil && self.tabView != nil {
                            if let headerView = self.headerView as? SSPageHeaderDelegate {
                                headerView.scrollDistanceFromTop(distance: abs(min(0, scrollDistance)))
                            }
                            
                            if scrollView.isDragging || scrollView.isDecelerating {
                                if isSupportHeaderRefresh, scrollDistance < 0 {
                                    self.headerContainerView.ss_y = self.navigationBarAndStatusBarHeight
                                } else {
                                    if scrollDistance >= frame.height - self.tabView!.frame.height  {
                                        self.headerContainerView.ss_y = self.navigationBarAndStatusBarHeight - (frame.height - self.tabView!.frame.height)
                                        self.headerView?.isHidden = true
                                    } else {
                                        self.headerContainerView.ss_y = self.navigationBarAndStatusBarHeight - scrollDistance
                                        self.headerView?.isHidden = false
                                    }
                                   
                                }
                                if scrollDistance >= 0 {
                                    (self.currentViewControllers ?? []).filter({$0 != (willTransitionToViewController ?? currentViewController)}).forEach { [weak self] viewController in guard let self = self else { return }
                                        self.refreshScrollViewPosition(scrollView: (viewController as? SSPageChildDelegate)?.childContainerView())
                                    }
                                }
                              
                                
                            } else {
                                if scrollDistance >= 0 {
                                    refreshScrollViewPosition(scrollView: ((willTransitionToViewController ?? currentViewController) as? SSPageChildDelegate)?.childContainerView())
                                }
                               
                            }
                            
                        }
                       
                    }
                }
                
            }
        }
      
    }
    
    private func refreshScrollViewPosition(scrollView: UIScrollView?) {
        /// 切换vc时,重新设置contentOffset
        guard let scrollView = scrollView else {
            return
        }
        let topMargin = (tabView?.frame.height ?? 0) + (headerView?.frame.height ?? 0) + navigationBarAndStatusBarHeight
        let scrollDistance = scrollView.contentOffset.y + topMargin
        let minY = self.navigationBarAndStatusBarHeight - (self.headerContainerView.frame.height - self.tabView!.frame.height)
        if  self.headerContainerView.ss_y <= self.navigationBarAndStatusBarHeight,
            (self.headerContainerView.ss_y > minY || scrollDistance < self.headerContainerView.frame.height - self.tabView!.frame.height) {
            let lastPosition = abs(self.headerContainerView.ss_y - self.navigationBarAndStatusBarHeight)
            let topMargin = (tabView?.frame.height ?? 0) + (headerView?.frame.height ?? 0) + self.navigationBarAndStatusBarHeight
            
            let newContentOffsetY = -topMargin + lastPosition
            if Int(scrollView.contentOffset.y) !=  Int(newContentOffsetY) {
                scrollView.contentOffset = CGPoint(x: 0, y: newContentOffsetY)
            }
//                                    print(lastPosition, distance, newContentOffsetY, scrollView.topMargin)
           
        }
    }
    
    public func setViewControllers(viewControllers: [SSPageChildDelegate],
                            titles: [String],
                            headerView: UIView? = nil) {
        let pageTab = SSDefaultPageTabView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        pageTab.titles = titles
        setViewControllers(viewControllers: viewControllers, tabView: pageTab, headerView: headerView)
    }
    
    public func setViewControllers(viewControllers: [SSPageChildDelegate], tabView: UIView & SSPageTabSelectedDelegate, headerView: UIView? = nil) {
        self.headerView = headerView
        self.tabView = tabView
        self.currentViewControllers = viewControllers as? [UIViewController]
        tabView.selectTab(index: 0)
        makeUI()
        if viewControllers.count > 0 {
            let toViewController = viewControllers.first! as! UIViewController
            willTransitionToViewController = toViewController
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
                    self.willTransitionToViewController = toViewController
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
    
    func configChildViewControlelr(viewController: UIViewController?) {
        if let viewController = viewController as? SSPageChildDelegate & UIViewController {
            let topMargin = (tabView?.frame.height ?? 0) + (headerView?.frame.height ?? 0)
            if let scrollView = viewController.childContainerView() {
                scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.old, .new], context: nil)
                
            }
            if #available(iOS 11.0, *) {
                viewController.additionalSafeAreaInsets = viewController.view.safeAreaInsets
                viewController.additionalSafeAreaInsets = UIEdgeInsets(top: topMargin , left: 0, bottom: 0, right: 0)
            } else {
                viewController.topLayoutGuide.heightAnchor.constraint(equalToConstant: topMargin).isActive = true
            }
        }
    }
    
  
    deinit {
        if let scrollView = self.pageScrollView {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
        }
        (currentViewControllers ?? []).forEach { viewControlelr in
            if let childController = viewControlelr as? SSPageChildDelegate {
                if let tableView = childController.childContainerView() {
                    tableView.removeObserver(self, forKeyPath: "contentOffset")
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

extension UIViewController {
    var navigationBarAndStatusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height ?? 0)
    }
}

private extension UIView {
    var ss_y: CGFloat {
        get {
            self.frame.origin.y
        }
        set {
            var frame = self.frame
            var orgin = frame.origin
            orgin.y = newValue
            frame.origin = orgin
            self.frame = frame
        }
    }
}


