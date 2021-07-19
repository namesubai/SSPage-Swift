//
//  DemoViewController.swift
//  SSPageViewController
//
//  Created by Shuqy on 2021/7/10.
//

import UIKit
import MJRefresh

class DemoViewController: UITableViewController {
    private var text: String
    private var hasRefresh: Bool

    init(text: String, hasRefresh: Bool = false) {
        self.text = text
        self.hasRefresh = hasRefresh
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(type(of: UITableViewCell.self))")
        if hasRefresh {
            tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.tableView.mj_footer?.endRefreshing()
                }
            })
            tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.tableView.mj_header?.endRefreshing()
                }
            })
        }
        
        tableView.mj_header?.beginRefreshing()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(type(of: UITableViewCell.self))")!
        cell.textLabel?.text = "\(text ) row:\(indexPath.row)"
        cell.contentView.backgroundColor = UIColor.random
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int.random(in: 20...40)
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

extension DemoViewController: SSPageChildDelegate {
    
    func childContainerView() -> UIScrollView? {
        return tableView
    }
    
    func containerScrollFooterRefresh() {
        print("底部触发")
        tableView.mj_footer?.beginRefreshing()
    }
    
    func containerScrollFooterIsCanRefresh() -> Bool {
        return tableView.mj_footer!.state == .refreshing ? false : true
    }
}
