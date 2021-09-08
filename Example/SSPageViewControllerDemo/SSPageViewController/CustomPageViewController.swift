//
//  CustomPageViewController.swift
//  SSPageViewController
//
//  Created by Shuqy on 2021/7/10.
//

import UIKit
import SSPage_Swift
class CustomPageViewController: SSPageViewController {
    enum TabType {
        case `default`
        case custom
        case refresh
        case headerScale
        case noHeader
        case noTab
    }
    private var tabType: TabType
    private var titles = ["select1", "select2", "select3", "select4", "select5", "select6", "select7", "select8", "select9", "select10", "select11"]
    
    init(tabType: TabType) {
        self.tabType = tabType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 350))
//        headerView.isUserInteractionEnabled = false
        switch tabType {
        case .default:
            let viewControllers = titles.map({
                title -> SSPageChildDelegate in
                let vc = DemoViewController(text: "default: \(title)")
                return vc
            })
            setViewControllers(viewControllers: viewControllers, titles: titles, headerView: headerView)
        case .noHeader:
            let viewControllers = titles.map({
                title -> SSPageChildDelegate in
                let vc = DemoViewController(text: "default: \(title)")
                return vc
            })
            setViewControllers(viewControllers: viewControllers, titles: titles, headerView: nil)
        case .custom:
            let viewControllers = titles.map({
                title -> SSPageChildDelegate in
                let vc = DemoViewController(text: "custom: \(title)")
                return vc
            })
            let tabView = CustomTabView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
            setViewControllers(viewControllers: viewControllers, tabView: tabView,  headerView: headerView)
        case .refresh:
            let viewControllers = titles.map({
                title -> SSPageChildDelegate in
                let vc = DemoViewController(text: "refresh: \(title)", hasRefresh: true)
                return vc
            })
            isSupportHeaderRefresh = true
            setViewControllers(viewControllers: viewControllers, titles: titles, headerView: headerView)
            
        case .headerScale:
            let viewControllers = titles.map({
                title -> SSPageChildDelegate in
                let vc = DemoViewController(text: "headerScale: \(title)")
                return vc
            })
            let headerView = CustomImageHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 350))
            setViewControllers(viewControllers: viewControllers, titles: titles, headerView: headerView)
            
        case .noTab:
            let viewControllers = titles.map({
                title -> SSPageChildDelegate in
                let vc = DemoViewController(text: "headerScale: \(title)")
                return vc
            })
            isAddTabViewToSuperView = false
            setViewControllers(viewControllers: viewControllers, titles: titles, headerView: nil)
            
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class CustomHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.random
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


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
        for index in 0..<11 {
            segmentedControl.insertSegment(withTitle: "\(index)", at: index, animated: true)
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


