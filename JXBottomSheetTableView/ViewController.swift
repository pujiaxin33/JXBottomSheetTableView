//
//  ViewController.swift
//  JXDragTableView
//
//  Created by jiaxin on 2018/7/24.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var tableView: JXBottomSheetTableView!
    var dataSource: [String]!
    var headerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.lightGray

        dataSource = ["回锅肉", "青椒肉丝", "麻婆豆腐", "火锅", "冷串串", "凉粉", "剁椒鱼头", "酸菜鱼", "锅盔", "天蚕土豆", "春卷"]

        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(title: "AddDish", style: .plain, target: self, action: #selector(addDish)),
            UIBarButtonItem(title: "DeleteDish", style: .plain, target: self, action: #selector(deleteDish))
        ]

        self.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "displayMax", style: .plain, target: self, action: #selector(displayMax)),
            UIBarButtonItem(title: "displayMin", style: .plain, target: self, action: #selector(displayMin))
        ]

        self.edgesForExtendedLayout = .left

        let tableView = JXBottomSheetTableView.init(frame: CGRect.zero, style: .plain)
        tableView.displayState = .maxDisplay
        tableView.defaultMininumDisplayHeight = 150
        tableView.defaultMaxinumDisplayHeight = 400
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }else {
            self.automaticallyAdjustsScrollViewInsets = false
        }


        headerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        headerLabel.textAlignment = .center
        headerLabel.textColor = UIColor.white
        headerLabel.backgroundColor = UIColor.darkGray
        headerLabel.text = "Total \(dataSource.count) dishs"
        tableView.tableHeaderView = headerLabel
    }

    @objc func addDish() {
        let dishs = ["回锅肉", "青椒肉丝", "麻婆豆腐", "火锅", "冷串串", "凉粉", "剁椒鱼头", "酸菜鱼", "锅盔", "天蚕土豆", "春卷"]
        let index = Int(arc4random()%UInt32(dishs.count))
        let dish = dishs[index]
        dataSource.insert(dish, at: 0)
        if dataSource.last == "空空如也" {
            dataSource.removeLast()
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }else {
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
        if dataSource.first == "空空如也" {
            headerLabel.text = "There is no dish"
        }else {
            headerLabel.text = "Total \(dataSource.count) dishs"
        }
    }

    @objc func deleteDish() {
        dataSource.removeFirst()
        if dataSource.count == 0 {
            dataSource.append("空空如也")
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }else {
            tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
        if dataSource.first == "空空如也" {
            headerLabel.text = "There is no dish"
        }else {
            headerLabel.text = "Total \(dataSource.count) dishs"
        }
    }

    @objc func displayMax() {
        tableView.displayMax()
    }

    @objc func displayMin() {
        tableView.displayMin()
    }

}

//MARK: UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = dataSource[indexPath.row]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}

