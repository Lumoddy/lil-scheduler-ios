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
    ValueReceiver,
    ValueResponder {
    
    private var _day: Date = Date.now

    func send<Value>(named label: String?, _ value: Value) -> ()? {
        switch (label, value) {
        case ("day", let value as Date),
            (nil, let value as Date):
            self._day = value
            self.tableView.reloadData()
            return ()
        case ("refresh", let value as ()),
            (nil, let value as ()):
            self.tableView.reloadData()
            return ()
        default:
            return nil
        }
    }
    
    func listen<Value>(
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        switch (label, listener) {
        default:
            return nil
        }
    }
}

public class CalanderDayScreenTableViewCell
    : UITableViewCell,
    ValueReceiver,
    ValueResponder {
    
    @IBOutlet private var _title: UILabel?
    @IBOutlet private var _description: UILabel?
    @IBOutlet private var _attributeList: UILabel?
    
    public override func prepareForReuse() {
        self._title!.text = nil
        self._description!.text = nil
        self._attributeList!.text = nil
    }

    func send<Value>(named label: String?, _ value: Value) -> ()? {
        switch (label, value) {
        default:
            return nil
        }
    }
    
    func listen<Value>(
        named label: String?,
        with listener: @escaping (Value) -> ()
    ) -> ()? {
        switch (label, listener) {
        default:
            return nil
        }
    }
}
