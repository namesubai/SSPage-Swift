//
//  ViewController.swift
//  SSPageViewController
//
//  Created by Shuqy on 2021/7/10.
//

import UIKit

class ViewController: UITableViewController {

    private var demos = [(String, Selector)]()
    override func viewDidLoad() {
        super.viewDidLoad()
        demos = [("没有header默认Tab", #selector(noHeaderDefaultTabs)),
                 ("默认Tab", #selector(defaultTabs)),
                 ("自定义Tab", #selector(customTabs)),
                 ("支持下拉刷新", #selector(refresh)),
                 ("头部图片扩大", #selector(headerViewScale)),
                 ("没有header，没有Tab", #selector(noHeaderNoTab))]
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(type(of: UITableViewCell.self))")
        // Do any additional setup after loading the view.
    }
    
    @objc func noHeaderDefaultTabs() {
        let vc = CustomPageViewController(tabType: .noHeader)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func defaultTabs() {
        let vc = CustomPageViewController(tabType: .default)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func customTabs() {
        let vc = CustomPageViewController(tabType: .custom)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func refresh() {
        let vc = CustomPageViewController(tabType: .refresh)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func headerViewScale() {
        let vc = CustomPageViewController(tabType: .headerScale)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func noHeaderNoTab() {
        let vc = CustomPageViewController(tabType: .noTab)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(type(of: UITableViewCell.self))")!
        cell.textLabel?.text = demos[indexPath.row].0
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return demos.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selector = demos[indexPath.row].1
        self.perform(selector)
    }
}

