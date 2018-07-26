//
//  JXBottomSheetTableView.swift
//  Swift测试
//
//  Created by jiaxin on 2018/7/24.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

public enum JXBottomSheetTableViewState {
    case maxDisplay
    case minDisplay
}

open class JXBottomSheetTableView: UITableView {
    //默认最小内容高度，当contentSize.height更小时，会更新mininumDisplayHeight值
    public var defaultMininumDisplayHeight: CGFloat = 100 {
        didSet {
            mininumDisplayHeight = defaultMininumDisplayHeight
        }
    }
    //默认最大内容高度，当contentSize.height更小时，会更新maxinumDisplayHeight值
    public var defaultMaxinumDisplayHeight: CGFloat = 300 {
        didSet {
            maxinumDisplayHeight = defaultMaxinumDisplayHeight
        }
    }
    public var displayState: JXBottomSheetTableViewState = .minDisplay
    public var triggerDistance: CGFloat = 10    //滚动多少距离，可以触发展开和收缩状态切换
    public var isTriggerImmediately = false    //当达到触发距离时，是否立即触发。否则就等到用户结束拖拽时触发。
    fileprivate var mininumDisplayHeight: CGFloat = 100
    fileprivate var maxinumDisplayHeight: CGFloat = 300
    fileprivate var displayLink: CADisplayLink!
    fileprivate var isLastTracking = false
    fileprivate var isLayouted = false

    override public init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)

        initializeView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initializeView()
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview == nil {
            displayLink.invalidate()
            self.removeObserver(self, forKeyPath: "contentSize")
        }else {
            self.contentInset = UIEdgeInsets(top: maxinumDisplayHeight - mininumDisplayHeight, left: 0, bottom: 0, right: 0)
        }
    }

    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if point.y < 0 {
            return nil
        }
        return super.hitTest(point, with: event)
    }

    func initializeView() {
        backgroundColor = UIColor.clear
        bounces = false

        displayLink = CADisplayLink(target: self, selector: #selector(startDisplayLink))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)

        self.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }

    open override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        assertionFailure("Please use reloadData")
    }

    open override func insertSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        assertionFailure("Please use reloadData")
    }

    open override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        assertionFailure("Please use reloadData")
    }

    open override func deleteSections(_ sections: IndexSet, with animation: UITableViewRowAnimation) {
        assertionFailure("Please use reloadData")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if !isLayouted {
            isLayouted = true
            refreshStateByContentSize()
        }
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" && isLayouted {
            refreshStateByContentSize()
        }
    }

    func refreshStateByContentSize() {
        maxinumDisplayHeight = min(defaultMaxinumDisplayHeight, contentSize.height)
        mininumDisplayHeight = min(defaultMininumDisplayHeight, contentSize.height)
        self.frame = CGRect(x: 0, y: self.superview!.bounds.size.height - self.maxinumDisplayHeight, width: self.superview!.bounds.size.width, height: self.maxinumDisplayHeight)
        if displayState == .maxDisplay {
            displayMax(animated: false)
        }else {
            displayMin(animated: false)
        }
    }

    public func displayMax(animated: Bool) {
        self.setContentOffset(CGPoint.zero, animated: animated)
        self.displayState = .maxDisplay
    }

    public func displayMin(animated: Bool) {
        self.setContentOffset(CGPoint(x: 0, y: mininumDisplayHeight - maxinumDisplayHeight), animated: animated)
        self.displayState = .minDisplay
    }

    @objc fileprivate func startDisplayLink()  {
        if self.isTracking {
            isLastTracking = true
            didTracking()
        }else {
            if isLastTracking {
                isLastTracking = false
                didEndTracking()
            }else {
                if displayState == .maxDisplay && self.isDragging && contentOffset.y < 0 {
                    contentOffset = CGPoint.zero
                }
            }
        }
    }

    fileprivate func didTracking() {
        if isTriggerImmediately && couldTrigger() {
            didEndTracking()
            return
        }
    }

    fileprivate func didEndTracking() {
        if displayState == .minDisplay {
            if couldTrigger() {
                if contentOffset.y < 0 {
                    displayMax(animated: true)
                }
                displayState = .maxDisplay
            }else {
                displayMin(animated: true)
            }
        }else {
            if couldTrigger() {
                displayMin(animated: true)
            }else {
                if contentOffset.y < 0 {
                    displayMax(animated: true)
                }
                displayState = .maxDisplay
            }
        }
    }

    fileprivate func couldTrigger() -> Bool {
        if displayState == .minDisplay {
            let minContentOffsetY = mininumDisplayHeight - maxinumDisplayHeight
            if contentOffset.y - minContentOffsetY >= triggerDistance {
                return true
            }
        }else {
            if -self.contentOffset.y >= triggerDistance {
                return true
            }
        }
        return false
    }

}
