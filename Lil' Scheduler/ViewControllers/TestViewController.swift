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
        return 2
    }
    
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
                cell.titleText = "Test Title"
                cell.labelText = "Test Label"
                cell.placeholderText = "Test Placeholder"
                cell.valueText = "Test Value"
                cell.listen(
                    forKey: UIValueResponderDefaultResultKey(),
                    listener: { print("Test1 = \($0)") });
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "Test2",
                    for: indexPath) as! TextFieldTableViewCell
                cell.label = "Test Label"
                cell.placeholder = "Test Placeholder"
                cell.value = "Test Value"
                cell.listen(
                    forKey: UIValueResponderDefaultResultKey(),
                    listener: { print("Test2 = \($0)") });
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
            case 1:
                break
            default:
                preconditionFailure()
            }
        default:
            preconditionFailure()
        }
    }
}
