//
//  LongPressTableViewReorderer.swift
//  LongPressTableViewReordering
//
//  Created by Saidi Daniel on 2016-09-07.
//  Copyright © 2016 Daniel Saidi. All rights reserved.
//

/*
 
 Call `enableLongPressReordering(for:)` to enable this
 reordering behavior for a certain table view.
 
 UITableViewDataSources that are used as delegates for
 this class, must implement `tableView(canMoveRowAt:)`
 and `tableView(moveRowAt:to:)`.
 
 */

import UIKit


// MARK: - LongPressTableViewReorderDelegate

public protocol LongPressTableViewReorderDelegate: class, UITableViewDataSource {
    
    func longPressReorderingDidBegin(in tableView: UITableView)
    func longPressReorderingDidEnd(in tableView: UITableView)
}



// MARK: - LongPressTableViewReorderer

public class LongPressTableViewReorderer: NSObject {
    
    public weak var delegate: LongPressTableViewReorderDelegate?
    
    public var reorderingAlpha: CGFloat = 0.95
    public var reorderingScale: CGFloat = 1.05
    public var reorderingScaleDuration  = 0.25
    
    fileprivate var gesture: UILongPressGestureRecognizer?
    fileprivate var initialIndexPath: IndexPath?
    fileprivate var snapshot: UIView?
}



// MARK: - Public Functions

public extension LongPressTableViewReorderer {
    
    public func disableLongPressReordering(for view: UITableView) {
        guard let gestures = view.gestureRecognizers else { return }
        guard let gesture = (gestures.first { $0 == gesture }) else { return }
        view.removeGestureRecognizer(gesture)
        self.gesture = nil
    }
    
    public func enableLongPressReordering(for view: UITableView) {
        let action = #selector(reorderGestureDidChange(_:))
        let gesture = UILongPressGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(gesture)
        self.gesture = gesture
    }
}



// MARK: - Actions

extension LongPressTableViewReorderer {
    
    func reorderGestureDidChange(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: gesture.view)
        
        guard
            let view = gesture.view as? UITableView,
            let path = view.indexPathForRow(at: point),
            let cell = view.cellForRow(at: path)
            else { return }
        
        switch gesture.state {
        case .began: beginReordering(cell, at: path, in: view, point: point)
        case .changed: reorderCell(at: path, in: view, point: point)
        default: endReordering(cell, in: view)
        }
    }
}



// MARK: - Private Reordering Functions

fileprivate extension LongPressTableViewReorderer {
    
    func beginReordering(_ cell: UITableViewCell, at path: IndexPath, in view: UITableView, point: CGPoint) {
        let canMove = delegate?.tableView?(view, canMoveRowAt: path) ?? false
        guard canMove else { return }
        
        delegate?.longPressReorderingDidBegin(in: view)
        
        initialIndexPath = path
        
        let snapshot = getSnapshotView(for: cell)
        view.addSubview(snapshot)
        self.snapshot = snapshot
        animateInSnapshot(for: cell, at: point)
    }
    
    func reorderCell(at path: IndexPath, in view: UITableView, point: CGPoint) {
        guard
            let initialIndexPath = initialIndexPath,
            let snapshot = snapshot
            else { return }
        
        var center = snapshot.center
        center.y = point.y
        snapshot.center = center
        
        guard path != initialIndexPath else { return }
        delegate?.tableView?(view, moveRowAt: initialIndexPath, to: path)
        view.moveRow(at: initialIndexPath, to: path)
        self.initialIndexPath = path
    }
    
    func endReordering(_ cell: UITableViewCell?, in view: UITableView) {
        guard
            let initialIndexPath = initialIndexPath,
            let snapshot = snapshot,
            let endCell = cell ?? view.cellForRow(at: initialIndexPath)
            else { return }
        
        UIView.animate(withDuration: 0.25, animations: {
            snapshot.center = endCell.center
            snapshot.transform = CGAffineTransform.identity
            
        }, completion: { finished in
            if finished {
                endCell.alpha = 1.0
                endCell.isHidden = false
                snapshot.removeFromSuperview()
                self.initialIndexPath = nil
                self.snapshot = nil
                self.delegate?.longPressReorderingDidEnd(in: view)
            }
        })
    }
}



// MARK: - Private Functions

fileprivate extension LongPressTableViewReorderer {
    
    func animateInSnapshot(for cell: UITableViewCell, at point: CGPoint) {
        guard let snapshot = snapshot else { return }
        
        var center = cell.center
        let scale = reorderingScale
        let duration = reorderingScaleDuration
        let alpha = reorderingAlpha
        
        snapshot.alpha = 0.0
        snapshot.center = center
        
        let animation = {
            cell.alpha = 0.0
            center.y = point.y
            snapshot.alpha = alpha
            snapshot.center = center
            snapshot.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        UIView.animate(withDuration: duration, animations: animation) { finished in
            guard finished else { return }
            cell.isHidden = true
        }
    }
    
    func getSnapshotView(for cell: UITableViewCell) -> UIView {
        let snapshot = UIImageView(image: takeSnapshot(of: cell))
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        return snapshot
    }
    
    func takeSnapshot(of cell: UITableViewCell) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(cell.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        cell.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        return image
    }
}
