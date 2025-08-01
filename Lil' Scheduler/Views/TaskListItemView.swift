//
//  TaskListItemView.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

import UIKit

public class TaskListItemView : UITableViewCell {
    
    @IBOutlet private var titleView: UILabel!
    @IBOutlet private var descriptionView: UILabel!
    @IBOutlet private var attributeListView: UILabel!
    
    public func display(task: CalendarTask) {
        self.titleView.text = task.title
        self.descriptionView.text = task.description
        
        if let attributes = task.attributes {
            var stringBuilder = ""
            for attribute in attributes {
                if stringBuilder.count > 0 {
                    stringBuilder += "\n"
                }
                stringBuilder += attribute.description
            }
            self.attributeListView.text = stringBuilder
        }
        else {
            self.attributeListView.text = nil
        }
    }
    
    public override func prepareForReuse() {
        self.titleView.text = nil
        self.descriptionView.text = nil
        self.attributeListView.text = nil
    }
}
