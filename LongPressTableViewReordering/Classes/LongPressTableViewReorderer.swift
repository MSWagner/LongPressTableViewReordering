//
//  LongPressTableViewReorderer.swift
//  LongPressTableViewReordering
//
//  Created by Saidi Daniel on 2016-09-07.
//  Copyright © 2016 Daniel Saidi. All rights reserved.
//

import UIKit


public protocol LongPressTableViewReorderDelegate: class, UITableViewDataSource {
    
    func longPressReorderingDidBegin(in tableView: UITableView)
    func longPressReorderingDidFinish(in tableView: UITableView)
}


public class LongPressTableViewReorderer: NSObject {
    
    
    // MARK: - Properties
    
    public weak var delegate: LongPressTableViewReorderDelegate?
    
    fileprivate var longPressReorderSnapshot: UIView?
    fileprivate var longPressReorderInitialIndexPath: IndexPath?
}


// MARK: - Actions

extension LongPressTableViewReorderer {
    
    func reorderGestureDidChange(_ gesture: UILongPressGestureRecognizer) {
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
}



// MARK: - Public Functions

public extension LongPressTableViewReorderer {
    
    public func enableLongPressReordering(for view: UITableView) {
        let action = #selector(reorderGestureDidChange(_:))
        let longPress = UILongPressGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(longPress)
    }
}



// MARK: - Private Functions

fileprivate extension LongPressTableViewReorderer {
    
    fileprivate func beginReordering(_ cell: UITableViewCell?, at indexPath: IndexPath?, in view: UITableView, location: CGPoint) {
        guard
            let delegate = delegate,
            let cell = cell,
            let indexPath = indexPath,
            delegate.tableView!(view, canMoveRowAt: indexPath)
            else { return }
        
        
        delegate.longPressReorderingDidBegin(in: view)
        
        longPressReorderInitialIndexPath = indexPath
        
        let snapShot = takeSnapshot(of: cell)
        var center = cell.center
        snapShot.center = center
        snapShot.alpha = 0.0
        view.addSubview(snapShot)
        
        let animation = {
            center.y = location.y
            snapShot.center = center
            snapShot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            snapShot.alpha = 0.98
            cell.alpha = 0.0
        }
        
        longPressReorderSnapshot = snapShot
        
        UIView.animate(withDuration: 0.25, animations: animation) { finished in
            guard finished else { return }
            cell.isHidden = true
        }
    }
    
    fileprivate func reorderCell(at indexPath: IndexPath?, in view: UITableView, location: CGPoint) {
        guard
            let delegate = delegate,
            let initialIndexPath = longPressReorderInitialIndexPath,
            let indexPath = indexPath,
            let snapshot = longPressReorderSnapshot
            else { return }
        
        var center = snapshot.center
        center.y = location.y
        snapshot.center = center
        
        if indexPath != longPressReorderInitialIndexPath {
            delegate.tableView!(view, moveRowAt: initialIndexPath, to: indexPath)
            view.moveRow(at: initialIndexPath, to: indexPath)
            longPressReorderInitialIndexPath = indexPath
        }
    }
    
    fileprivate func endReordering(_ cell: UITableViewCell?, in view: UITableView) {
        guard
            let delegate = delegate,
            let initialIndexPath = longPressReorderInitialIndexPath,
            let snapshot = longPressReorderSnapshot,
            let endCell = cell ?? view.cellForRow(at: initialIndexPath)
            else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            snapshot.center = endCell.center
            snapshot.transform = CGAffineTransform.identity
            
        }, completion: { (finished) -> Void in
            if finished {
                endCell.alpha = 1.0
                endCell.isHidden = false
                snapshot.removeFromSuperview()
                self.longPressReorderInitialIndexPath = nil
                self.longPressReorderSnapshot = nil
                delegate.longPressReorderingDidFinish(in: view)
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
