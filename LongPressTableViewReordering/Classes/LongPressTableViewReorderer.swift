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
    
    public func enableLongPressReordering(for view: UITableView, target: AnyObject?, action: Selector) {
        let longPress = UILongPressGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(longPress)
    }
    
    public func longPressReorderGestureChanged(_ gesture: UILongPressGestureRecognizer) {
        guard let view = gesture.view as? UITableView else { return }
        let location = gesture.location(in: view)
        let indexPath = view.indexPathForRow(at: location)
        let cell = indexPath != nil ? view.cellForRow(at: indexPath!) : nil
        
        switch gesture.state {
        case .began: beginReordering(cell, at: indexPath, in: view, location: location)
        case .changed: reorderCell(at: indexPath, in: view, location: location)
        default: endReordering(cell, in: view)
        }
    }
    
    
    
    // MARK: - Private functions
    
    fileprivate func beginReordering(_ cell: UITableViewCell?, at indexPath: IndexPath?, in view: UITableView, location: CGPoint) {
        guard let cell = cell, let indexPath = indexPath else { return }
        guard tableView!(view, canMoveRowAt: indexPath) else { return }
        
        longPressReorderInitialIndexPath = indexPath
        
        let snapShot = takeSnapshot(of: cell)
        var center = cell.center
        snapShot.center = center
        snapShot.alpha = 0.0
        
        longPressReorderSnapshot = snapShot
        view.addSubview(longPressReorderSnapshot)
        
        let animation = {
            center.y = location.y
            snapShot.center = center
            snapShot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            snapShot.alpha = 0.98
            cell.alpha = 0.0
        }
        
        UIView.animate(withDuration: 0.25, animations: animation) { finished in
            guard finished else { return }
            cell.isHidden = true
        }
    }
    
    fileprivate func reorderCell(at indexPath: IndexPath?, in view: UITableView, location: CGPoint) {
        guard let indexPath = indexPath else { return }
        
        var center = longPressReorderSnapshot.center
        center.y = location.y
        longPressReorderSnapshot.center = center
        
        if indexPath != longPressReorderInitialIndexPath {
            tableView!(view, moveRowAt: longPressReorderInitialIndexPath, to: indexPath)
            view.moveRow(at: longPressReorderInitialIndexPath, to: indexPath)
            longPressReorderInitialIndexPath = indexPath
        }
    }
    
    fileprivate func endReordering(_ cell: UITableViewCell?, in view: UITableView) {
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
    
    fileprivate func takeSnapshot(of view: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIView() }
        view.layer.render(in: context)
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
