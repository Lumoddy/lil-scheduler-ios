//
//  TextInputPage.swift
//  Lil' Scheduler
//
//  Created by 13878 on 1/8/2025.
//

import UIKit

public class TextInputPage
    : UITableViewController,
    UIValueReceiver,
    UIValueResponder {

    public static let VIEW_ID = "TextFieldPage"
    
    typealias Value = String?

    @IBOutlet private var textField: UITextField!
    
    private var callback: ((String??) -> ())? = nil
    
    @IBAction private func textDidChange() {
        callback?(textField.text)
    }
    
    func send(value: String?) -> ()? {
        //textField.text = value
        return ()
    }
    
    func listenFor(completion callback: @escaping (String??) -> ()) -> ()? {
        self.callback = callback
        return ()
    }
}
