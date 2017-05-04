//
//  ViewController.swift
//  LongPressTableViewReordering
//
//  Created by Daniel Saidi on 09/08/2016.
//  Copyright (c) 2016 Daniel Saidi. All rights reserved.
//

import UIKit
import LongPressTableViewReordering

class ViewController: UIViewController {

    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            reorderer.enableLongPressReordering(for: tableView)
        }
    }
    
    
    // MARK: - Properties
    
    fileprivate lazy var reorderer: LongPressTableViewReorderer = {
        let reorderer = LongPressTableViewReorderer()
        reorderer.delegate = self
        return reorderer
    }()
    
}


extension ViewController: LongPressTableViewReorderDelegate {
    
    func longPressReorderingDidBegin(in tableView: UITableView) {
        print("Reordering did begin")
    }
    
    func longPressReorderingDidEnd(in tableView: UITableView) {
        print("Reordering did end")
    }
}



// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell = cell ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Test Cell"
        return cell
    }
}
