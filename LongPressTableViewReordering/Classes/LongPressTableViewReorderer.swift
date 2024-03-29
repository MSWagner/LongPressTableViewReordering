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
    
    fileprivate var currentIndexPath: IndexPath?
    fileprivate var gesture: UILongPressGestureRecognizer?
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
        
        guard let view = gesture.view as? UITableView else { return }
        
        let path = view.indexPathForRow(at: point)
        let cell = path != nil ? view.cellForRow(at: path!) : nil
        
        switch gesture.state {
        case .began: beginReorder(cell, at: path, in: view, point: point)
        case .changed: reorderCell(at: path, in: view, point: point)
        default: endReorder(cell, in: view)
        }
    }
}



// MARK: - Private Reordering Functions

fileprivate extension LongPressTableViewReorderer {
    
    func beginReorder(_ cell: UITableViewCell?, at path: IndexPath?, in view: UITableView, point: CGPoint) {
        guard
            let cell = cell,
            let path = path,
            canMoveCell(at: path, in: view)
            else { return }
        
        currentIndexPath = path
        setupSnapshot(for: cell, in: view, at: point)
        animateInSnapshot(for: cell, at: point)
        delegate?.longPressReorderingDidBegin(in: view)
    }
    
    func reorderCell(at path: IndexPath?, in view: UITableView, point: CGPoint) {
        guard
            let path = path,
            let currentIndexPath = currentIndexPath
            else { return }
        
        moveSnapshot(to: point.y)
        moveRow(from: currentIndexPath, to: path, in: view)
    }
    
    func endReorder(_ cell: UITableViewCell?, in view: UITableView) {
        guard
            let path = currentIndexPath,
            let cell = cell ?? view.cellForRow(at: path)
            else { return }
        
        animateOutSnapshot(for: cell) {
            self.completeReordering(for: cell, in: view)
        }
    }
}



// MARK: - Private Animation Functions

fileprivate extension LongPressTableViewReorderer {
    
    func animateInAnimation(for cell: UITableViewCell, at point: CGPoint) -> () -> () {
        var center = cell.center
        let scale = reorderingScale
        let alpha = reorderingAlpha
        
        return {
            cell.alpha = 0.0
            center.y = point.y
            self.snapshot?.alpha = alpha
            self.snapshot?.center = center
            self.snapshot?.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func animateInSnapshot(for cell: UITableViewCell, at point: CGPoint) {
        let duration = reorderingScaleDuration
        let animation = animateInAnimation(for: cell, at: point)
        UIView.animate(withDuration: duration, animations: animation) { finished in
            guard finished else { return }
            cell.isHidden = true
        }
    }
    
    func animateOutAnimation(for cell: UITableViewCell) -> () -> () {
        return {
            self.snapshot?.center = cell.center
            self.snapshot?.transform = CGAffineTransform.identity
        }
    }
    
    func animateOutSnapshot(for cell: UITableViewCell, completion: @escaping () -> ()) {
        let duration = reorderingScaleDuration
        let animation = animateOutAnimation(for: cell)
        UIView.animate(withDuration: duration, animations: animation) { finished in
            guard finished else { return }
            completion()
        }
    }
}



// MARK: - Private Functions

fileprivate extension LongPressTableViewReorderer {
    
    func canMoveCell(at path: IndexPath, in view: UITableView) -> Bool {
        return delegate?.tableView?(view, canMoveRowAt: path) ?? false
    }
    
    func completeReordering(for cell: UITableViewCell, in view: UITableView) {
        cell.alpha = 1.0
        cell.isHidden = false
        self.currentIndexPath = nil
        self.snapshot?.removeFromSuperview()
        self.snapshot = nil
        self.delegate?.longPressReorderingDidEnd(in: view)
    }
    
    func moveRow(from: IndexPath, to: IndexPath, in view: UITableView) {
        guard from != to else { return }
        delegate?.tableView?(view, moveRowAt: from, to: to)
        view.moveRow(at: from, to: to)
        currentIndexPath = to
    }
    
    func moveSnapshot(to y: CGFloat) {
        guard let snapshot = snapshot else { return }
        var center = snapshot.center
        center.y = y
        snapshot.center = center
    }
    
    func setupSnapshot(for cell: UITableViewCell, in view: UITableView, at point: CGPoint) {
        let snapshot = snapshotView(for: cell)
        view.addSubview(snapshot)
        self.snapshot = snapshot
    }
    
    func snapshotView(for cell: UITableViewCell) -> UIView {
        let snapshot = UIImageView(image: takeSnapshot(of: cell))
        snapshot.alpha = 0.0
        snapshot.center = cell.center
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
