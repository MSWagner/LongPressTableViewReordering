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
    var longPressReorderInitialIndexPath : NSIndexPath! { get set }
    
    func longPressReorderingDidFinishInTableView(tableView: UITableView)
}


public extension LongPressTableViewReorderer {
    
    
    // MARK: - Public functions
    
    public func enableLongPressReorderingForTableView(view: UITableView, withGestureTarget target: AnyObject?, action: Selector) {
        let longPress = UILongPressGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(longPress)
    }
    
    public func longPressReorderGestureChanged(gesture: UILongPressGestureRecognizer) {
        guard let view = gesture.view as? UITableView else { return }
        let location = gesture.locationInView(view)
        let indexPath = view.indexPathForRowAtPoint(location)
        let cell = indexPath != nil ? view.cellForRowAtIndexPath(indexPath!) : nil
        
        switch gesture.state {
        case .Began: beginReorderingCell(cell, atIndexPath: indexPath, inView: view, location: location)
        case .Changed: reorderCell(cell, atIndexPath: indexPath, inView: view, location: location)
        default: finishReorderCell(cell, inView: view)
        }
    }
    
    
    
    // MARK: - Private functions
    
    private func beginReorderingCell(cell: UITableViewCell?, atIndexPath indexPath: NSIndexPath?, inView view: UITableView, location: CGPoint) {
        guard cell != nil else { return }
        guard indexPath != nil else { return }
        guard tableView!(view, canMoveRowAtIndexPath: indexPath!) else { return }
        
        longPressReorderInitialIndexPath = indexPath
        longPressReorderSnapshot = snapshopOfView(cell!)
        var center = cell!.center
        longPressReorderSnapshot.center = center
        longPressReorderSnapshot.alpha = 0.0
        view.addSubview(longPressReorderSnapshot)
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            center.y = location.y
            self.longPressReorderSnapshot.center = center
            self.longPressReorderSnapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
            self.longPressReorderSnapshot.alpha = 0.98
            cell!.alpha = 0.0
            
        }) { finished in
            if finished {
                cell!.hidden = true
            }
        }
    }
    
    private func reorderCell(cell: UITableViewCell?, atIndexPath indexPath: NSIndexPath?, inView view: UITableView, location: CGPoint) {
        guard cell != nil else { return }
        guard indexPath != nil else { return }
        
        var center = longPressReorderSnapshot.center
        center.y = location.y
        longPressReorderSnapshot.center = center
        
        if (indexPath != longPressReorderInitialIndexPath) {
            tableView!(view, moveRowAtIndexPath: longPressReorderInitialIndexPath, toIndexPath: indexPath!)
            view.moveRowAtIndexPath(longPressReorderInitialIndexPath, toIndexPath: indexPath!)
            longPressReorderInitialIndexPath = indexPath
        }
    }
    
    private func finishReorderCell(cell: UITableViewCell?, inView view: UITableView) {
        guard let initPath = longPressReorderInitialIndexPath else { return }
        guard let endCell = cell ?? view.cellForRowAtIndexPath(initPath) else { return }
        
        UIView.animateWithDuration(0.25, animations: {initPath
            self.longPressReorderSnapshot.center = endCell.center
            self.longPressReorderSnapshot.transform = CGAffineTransformIdentity
            
            }, completion: { (finished) -> Void in
                if finished {
                    endCell.alpha = 1.0
                    endCell.hidden = false
                    self.longPressReorderInitialIndexPath = nil
                    self.longPressReorderSnapshot.removeFromSuperview()
                    self.longPressReorderSnapshot = nil
                    self.longPressReorderingDidFinishInTableView(view)
                }
        })
    }
    
    private func snapshopOfView(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIView() }
        inputView.layer.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}