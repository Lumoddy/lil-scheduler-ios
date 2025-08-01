//
//  SwitchTableCell.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

import UIKit

public class TextInputTableCell : UITableViewCell {
    
    @IBOutlet private var labelView: UILabel!
    @IBOutlet private var valueView: UILabel!
    
    public var value: String? {
        get { return self.valueView.text }
        set { self.valueView.text = newValue }
    }
    public var labelText: String? {
        get { return self.labelView.text }
        set { self.labelView.text = newValue }
    }
    
    override public func prepareForReuse() {
        self.labelView.text = nil
        self.valueView.text = nil
    }
}
