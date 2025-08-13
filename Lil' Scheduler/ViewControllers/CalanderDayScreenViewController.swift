//
//  CalanderDayScreenViewController.swift
//  Lil' Scheduler
//
//  Created by 13878 on 8/8/2025.
//

import UIKit

/// ### Receives:
/// * `"day"` or nil : `Date`
/// * `"refresh"` or nil : `()`
public class CalanderDayScreenViewController
    : UITableViewController,
    GenericValueInterface {
    
    private var _day: Date = Date.now
    
    func getGeneric<Value>(
        named label: String?,
        _ type: Value.Type
    ) -> Value? {
        switch label {
        case "day" where type == Date.self,
            nil where type == Date.self:
            return self._day as! Value?
        default:
            return nil
        }
    }

    func setGeneric<Value>(
        named label: String?,
        _ value: Value
    ) -> GenericSetResponse {
        switch (label, value) {
        case ("day", let value as Date),
            (nil, let value as Date):
            self._day = value
            self.tableView.reloadData()
            return .effect
        case ("refresh", let value as ()),
            (nil, let value as ()):
            self.tableView.reloadData()
            return .caught
        default:
            return .noEffect
        }
    }
}

public class CalanderDayScreenTableViewCell
    : UITableViewCell {
    
    @IBOutlet private var _time: UILabel!
    @IBOutlet private var _title: UILabel!
    @IBOutlet private var _description: UILabel!
    @IBOutlet private var _attributeList: UILabel!
    
    public override func prepareForReuse() {
        self.time = nil
        self.title = nil
        self.descriptionText = nil
        self.attributeList = nil
    }
    
    public var time: String? {
        get { return self._time.text }
        set { self._time.text = newValue }
    }
    
    public var title: String? {
        get { return self._title.text }
        set { self._title.text = newValue }
    }
    
    public var descriptionText: String? {
        get { return self._description.text }
        set { self._description.text = newValue }
    }
    
    public var attributeList: String? {
        get { return self._attributeList.text }
        set { self._attributeList.text = newValue }
    }
}
