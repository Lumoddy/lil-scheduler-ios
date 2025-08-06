//
//  TestViewController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 5/8/2025.
//

import UIKit

public class TestViewController : UITableViewController {
    
    public override func numberOfSections(
        in tableView: UITableView
    ) -> Int {
        return 1
    }
    
    public override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return 3
    }
    
    private var test1Text = "Test Value"
    private var test2Text = "Test Value"
    private var test3Value: IndexPath? = nil
    private let test3Selections: [SelectionFieldPageTableViewCell.Section] = [
        .init(
            header: "header1",
            rows: [
                .value(label: "first"),
                .value(label: "second"),
                .value(label: "third"),
                .inner(label: "rest", content: [
                    .init(
                        header: "header2",
                        rows: [
                            .value(label: "inner-first"),
                            .value(label: "inner-second"),
                            .value(label: "inner-third"),
                        ],
                        footer: "footer2"),
                    .init(
                        header: "header3",
                        rows: [
                            .value(label: "other-first"),
                            .value(label: "other-second"),
                            .value(label: "other-third"),
                        ],
                        footer: "footer3"),
                ]),
            ],
            footer: "footer1"),
    ]
    
    public override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "Test1",
                    for: indexPath) as! TextFieldPageTableViewCell
                cell.title = "Test Title"
                cell.label = "Test Label"
                cell.placeholder = "Test Placeholder"
                cell.value = self.test1Text
                cell.listen(
                    forKey: UIValueResponderDefaultResultKey(),
                    listener: { (value: String) in
                        self.test1Text = value
                        print("Test1 = \(value)")
                        tableView.reloadData()
                    });
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "Test2",
                    for: indexPath) as! TextFieldTableViewCell
                cell.label = "Test Label"
                cell.placeholder = "Test Placeholder"
                cell.value = self.test2Text
                cell.listen(
                    forKey: UIValueResponderDefaultResultKey(),
                    listener: { (value: String) in
                        self.test2Text = value
                        print("Test2 = \(value)")
                        tableView.reloadData()
                    });
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "Test3",
                    for: indexPath) as! SelectionFieldPageTableViewCell
                cell.title = "Test Title"
                cell.label = "Test Label"
                cell.value = self.test3Value
                cell.selections = self.test3Selections
                cell.listen(
                    forKey: UIValueResponderDefaultResultKey(),
                    listener: { (value: IndexPath) in
                        self.test3Value = value
                        print("Test3 = \(String(describing: value))")
                        tableView.reloadData()
                    });
                return cell
            default:
                preconditionFailure()
            }
        default:
            preconditionFailure()
        }
    }
    
    public override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView
                    .cellForRow(at: indexPath) as! TextFieldPageTableViewCell
                self.navigationController!.pushViewController(
                    cell.instantiatePageView(),
                    animated: true)
                break
            case 1:
                break
            case 2:
                let cell = tableView
                    .cellForRow(at: indexPath) as! SelectionFieldPageTableViewCell
                self.navigationController!.pushViewController(
                    cell.instantiatePageView(),
                    animated: true)
                break
            default:
                preconditionFailure()
            }
        default:
            preconditionFailure()
        }
    }
}
