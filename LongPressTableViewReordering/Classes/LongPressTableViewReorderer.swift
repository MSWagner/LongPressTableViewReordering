//
//  LongPressTableViewReorderer.swift
//  LongPressTableViewReordering
//
//  Created by Saidi Daniel on 2016-09-07.
//  Copyright © 2016 Daniel Saidi. All rights reserved.
//

import UIKit


public protocol LongPressTableViewReorderer: class, UITableViewDataSource {
    
    var longPressReorderSnapshot : UIView! { get set }
    var longPressReorderInitialIndexPath : IndexPath! { get set }
    
    func longPressReorderingDidFinish(in tableView: UITableView)
}


public extension LongPressTableViewReorderer {
    
    
    // MARK: - Public functions
    
    public func enableLongPressReordering(for view: UITableView, withTarget target: AnyObject?, action: Selector) {
        let longPress = UILongPressGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(longPress)
    }
    
    public func longPressReorderGestureChanged(_ gesture: UILongPressGestureRecognizer) {
        guard let view = gesture.view as? UITableView else { return }
        let location = gesture.location(in: view)
        let indexPath = view.indexPathForRow(at: location)
        let cell = indexPath != nil ? view.cellForRow(at: indexPath!) : nil
        
        switch gesture.state {
        case .began: beginReordering(of: cell, atIndexPath: indexPath, in: view, location: location)
        case .changed: reorder(cell, atIndexPath: indexPath, in: view, location: location)
        default: finishReordering(of: cell, in: view)
        }
    }
    
    
    
    // MARK: - Private functions
    
    fileprivate func beginReordering(of cell: UITableViewCell?, atIndexPath indexPath: IndexPath?, in view: UITableView, location: CGPoint) {
        let canMove = tableView!(view, canMoveRowAt: indexPath!)
        guard cell != nil, indexPath != nil, canMove else { return }
        
        longPressReorderInitialIndexPath = indexPath
        longPressReorderSnapshot = snapshot(of: cell!)
        var center = cell!.center
        longPressReorderSnapshot.center = center
        longPressReorderSnapshot.alpha = 0.0
        view.addSubview(longPressReorderSnapshot)
        
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            center.y = location.y
            self.longPressReorderSnapshot.center = center
            self.longPressReorderSnapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            self.longPressReorderSnapshot.alpha = 0.98
            cell!.alpha = 0.0
            
        }, completion: { finished in
            if finished {
                cell!.isHidden = true
            }
        }) 
    }
    
    fileprivate func reorder(_ cell: UITableViewCell?, atIndexPath indexPath: IndexPath?, in view: UITableView, location: CGPoint) {
        guard cell != nil else { return }
        guard indexPath != nil else { return }
        
        var center = longPressReorderSnapshot.center
        center.y = location.y
        longPressReorderSnapshot.center = center
        
        if (indexPath != longPressReorderInitialIndexPath) {
            tableView!(view, moveRowAt: longPressReorderInitialIndexPath, to: indexPath!)
            view.moveRow(at: longPressReorderInitialIndexPath, to: indexPath!)
            longPressReorderInitialIndexPath = indexPath
        }
    }
    
    fileprivate func finishReordering(of cell: UITableViewCell?, in view: UITableView) {
        guard let initPath = longPressReorderInitialIndexPath else { return }
        guard let endCell = cell ?? view.cellForRow(at: initPath) else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.longPressReorderSnapshot.center = endCell.center
            self.longPressReorderSnapshot.transform = CGAffineTransform.identity
            
            }, completion: { (finished) -> Void in
                if finished {
                    endCell.alpha = 1.0
                    endCell.isHidden = false
                    self.longPressReorderInitialIndexPath = nil
                    self.longPressReorderSnapshot.removeFromSuperview()
                    self.longPressReorderSnapshot = nil
                    self.longPressReorderingDidFinish(in: view)
                }
        })
    }
    
    fileprivate func snapshot(of inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIView() }
        inputView.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}
