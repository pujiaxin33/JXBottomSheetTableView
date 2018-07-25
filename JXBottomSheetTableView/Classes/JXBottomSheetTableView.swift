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
            if self.displayState == .minDisplay {
                self.frame = CGRect(x: 0, y: newSuperview!.bounds.size.height - mininumDisplayHeight, width: newSuperview!.bounds.size.width, height: maxinumDisplayHeight)
            }else {
                self.frame = CGRect(x: 0, y: newSuperview!.bounds.size.height - maxinumDisplayHeight, width: newSuperview!.bounds.size.width, height: maxinumDisplayHeight)
            }
        }
    }

    func initializeView() {
        backgroundColor = UIColor.clear

        displayLink = CADisplayLink(target: self, selector: #selector(startDisplayLink))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)

        self.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        if !isLayouted {
            isLayouted = true
            refreshFrameByContentSize()
        }
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" && isLayouted {
            refreshFrameByContentSize()
        }
    }

    public func displayMax() {
        guard self.frame.origin.y != self.superview!.bounds.size.height - self.maxinumDisplayHeight else {
            self.displayState = .maxDisplay
            return
        }

        self.setContentOffset(CGPoint.zero, animated: true)
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            var frame = self.frame
            frame.origin.y = self.superview!.bounds.size.height - self.maxinumDisplayHeight
            self.frame = frame
        }) { (finished) in
            self.isUserInteractionEnabled = true
            self.displayState = .maxDisplay
        }
    }

    public func displayMin() {
        guard frame.origin.y != self.superview!.bounds.size.height - self.mininumDisplayHeight else {
            self.displayState = .minDisplay
            return
        }
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.25, animations: {
            var frame = self.frame
            frame.origin.y = self.superview!.bounds.size.height - self.mininumDisplayHeight
            self.frame = frame
        }) { (finished) in
            self.isUserInteractionEnabled = true
            self.displayState = .minDisplay
        }
    }


    fileprivate func refreshFrameByContentSize() {
        maxinumDisplayHeight = min(defaultMaxinumDisplayHeight, contentSize.height)
        mininumDisplayHeight = min(defaultMininumDisplayHeight, contentSize.height)
        if self.frame.size.height != maxinumDisplayHeight {
            var frame = self.frame
            frame.size.height = maxinumDisplayHeight
            self.frame = frame
        }
        if displayState == .maxDisplay {
            displayMax()
        }else {
            displayMin()
        }
    }

    @objc fileprivate func startDisplayLink()  {
        //用isTracking而不是isDragging，类似这种情况：https://stackoverflow.com/questions/22778832/uiscrollview-isdragging-returns-yes-when-no-scrollview-is-decelerating/22779303，有时候明明没有拖拽了，但isDragging依然是true
        if self.isTracking {
            isLastTracking = true
            didTracking()
        }else {
            if isLastTracking {
                isLastTracking = false
                didEndTracking()
            }
        }
    }

    fileprivate func didTracking() {
        if isTriggerImmediately && couldTrigger() {
            didEndTracking()
            return
        }
        let isInScrollableRange = (self.frame.origin.y > superview!.bounds.size.height - maxinumDisplayHeight) && (self.frame.origin.y <= superview!.bounds.size.height - mininumDisplayHeight)
        let isScrollUp = self.contentOffset.y >= 0
        if isInScrollableRange && isScrollUp {
            var frame = self.frame
            frame.origin.y -= self.contentOffset.y
            let minY = self.superview!.bounds.size.height - self.maxinumDisplayHeight
            let maxY = self.superview!.bounds.size.height - self.mininumDisplayHeight
            frame.origin.y = max(minY, min(maxY, frame.origin.y))
            self.frame = frame
            if self.contentOffset.y != 0 {
                self.setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }

    fileprivate func didEndTracking() {
        if displayState == .minDisplay {
            if couldTrigger() {
                displayMax()
            }else {
                displayMin()
            }
        }else {
            if couldTrigger() {
                displayMin()
            }else {
                displayMax()
            }
        }
    }

    fileprivate func couldTrigger() -> Bool {
        if displayState == .minDisplay {
            let minOriginalY = superview!.bounds.size.height - mininumDisplayHeight
            if minOriginalY - frame.origin.y >= triggerDistance {
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
