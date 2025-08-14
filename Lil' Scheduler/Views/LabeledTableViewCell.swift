//
//  LabeledTableViewCell.swift
//  Lil' Scheduler
//
//  Created by 13878 on 14/8/2025.
//

import UIKit

public class LabeledTableViewCell : UITableViewCell {
    
    @IBOutlet private var _label: UILabel!
    
    public var label: String? {
        get { return self._label.text }
        set { self._label.text = newValue }
    }
}
