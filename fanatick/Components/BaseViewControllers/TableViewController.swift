//
//  TableViewController.swift
//  fanatick
//
//  Created by Vincent Ngo on 4/8/19.
//  Copyright © 2019 Fanatick. All rights reserved.
//

import Foundation
import UIKit
import Cartography


class TableViewController: ViewController {
    let tableView = UITableView.init(frame: .zero, style: .grouped)
    
    override func setupSubviews() {
        super.setupSubviews()
        tableView.delegate = self
        tableView.backgroundColor = UIColor.clear
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = K.Dimen.cell
        tableView.contentInset = defaultTableViewInsets
        tableView.clipsToBounds = true
        view.addSubview(tableView)
    }
    
    var defaultTableViewInsets: UIEdgeInsets {
        return .zero
    }
    
    var defaultSeparatorInset: UIEdgeInsets {
        return .zero
    }
    
    func applyDefaultConstrain() {
        constrain(tableView, car_bottomLayoutGuide) { (view, layout) in
            view.top == view.superview!.top
            view.bottom == layout.bottom
            view.leading == view.superview!.leading
            view.trailing == view.superview!.trailing
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeHeaderToFit()
    }
    
    @objc
    override func keyboardWillShow(_ notification: NSNotification) {
        var keyboardSize: CGSize = .zero
        if let info = (notification as NSNotification?)?.userInfo {
            //  Getting UIKeyboardSize.
            if let kbFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                
                let intersectRect = kbFrame.intersection(tableView.frame)
                
                
                if intersectRect.isNull {
                    keyboardSize = CGSize(width: tableView.frame.size.width, height: 0)
                } else {
                    keyboardSize = intersectRect.size
                }
            }
        }
        let inset =  UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        tableView.contentInset = inset
        tableView.scrollIndicatorInsets = inset
    }
    
    @objc
    override func keyboardWillHide(_ notification: NSNotification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
}

extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension UIScrollView {
    func  isNearBottomEdge(edgeOffset: CGFloat = 20.0) -> Bool {
        return contentOffset.y + frame.size.height + edgeOffset > contentSize.height
    }
}

extension UITableView {
    func sizeHeaderToFit() {
        if let headerView = tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            tableHeaderView = headerView
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
        }
    }
}
