//
//  CalenderTaskView.swift
//  Lil' Scheduler
//
//  Created by 13878 on 28/7/2025.
//

import UIKit

public class CalenderTaskView : UIView {
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var attributeContainer: UIView!
    @IBOutlet private var colorToBack: [UIView]?
    @IBOutlet private var colorToLine: [UIView]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.addSubview(self.loadNib())
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        super.addSubview(self.loadNib())
    }
    
    private func loadNib() -> UIView {
        return Bundle.main.loadNibNamed(
            "CalenderTaskView",
            owner: self)![0] as! UIView
    }
    
    public func set(title text: String) {
        titleLabel.text = text;
    }
    public func set(description text: String) {
        descriptionLabel.text = text;
    }
    public func set(color: RGB) {
        
    }
    public func set(attributes: [CalendarTaskAttribute]?) {
        self.attributeContainer.subviews.forEach { $0.removeFromSuperview() }
        attributes?.forEach { attribute in
            let view = UILabel()
            view.text = String(describing: attribute)
            view.translatesAutoresizingMaskIntoConstraints = false
            self.attributeContainer.addSubview(view)
        }
    }
    
    public func set(to task: CalendarTask) {
        set(title: task.title)
        set(description: task.description)
        set(color: task.color)
        set(attributes: task.attributes)
    }
}
