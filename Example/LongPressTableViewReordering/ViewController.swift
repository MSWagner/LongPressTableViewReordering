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

    
    // MARK: - Properties
    
    var longPressReorderSnapshot: UIView!
    
    var longPressReorderInitialIndexPath: IndexPath!
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            let action = #selector(handleLongPressReorderGesture(_:))
            enableLongPressReordering(for: tableView, target: self, action: action)
        }
    }
    
    func longPressReorderingDidFinish(in tableView: UITableView) {
        print("BABOOM")
    }
    
    func handleLongPressReorderGesture(_ gesture: UILongPressGestureRecognizer) {
        longPressReorderGestureChanged(gesture)
    }
}



// MARK: - LongPressTableViewReorderer

extension ViewController: LongPressTableViewReorderer {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = "Test Cell"
        return cell
    }
}



// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }
}
