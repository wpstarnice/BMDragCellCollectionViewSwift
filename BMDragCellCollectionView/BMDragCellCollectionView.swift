//
//  BMDragCellCollectionView.swift
//  BMDragCellCollectionViewDemo-Swift
//
//  Copyright © 2017年 https://github.com/asiosldh/BMDragCellCollectionViewSwift/ All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import UIKit

/// 拖拽超出屏幕时需要自动滚动的方向
///
/// - none: 未超出屏幕
/// - left: left
/// - right: right
/// - up: up
/// - down: down
enum BMDragCellCollectionViewScrollDirection {
    case none, left, right, up, down
}

extension UICollectionView {
    func BMDragCellCollectionView_rectForSection(_ section: Int) -> CGRect {
        let sectionNum = self.dataSource?.collectionView(self, numberOfItemsInSection: section)
        if sectionNum! <= 0 {
            return CGRect();
        } else {
            let firstRect = self.BMDragCellCollectionView_rectForRowAtIndexPath(IndexPath.init(item: 0, section: section))
            let lastRect = self.BMDragCellCollectionView_rectForRowAtIndexPath(IndexPath.init(item: sectionNum!-1, section: section))
            return CGRect.init(x: 0, y: firstRect.minY, width: self.frame.width, height: lastRect.maxY - firstRect.midY)
        }
    }

    func BMDragCellCollectionView_rectForRowAtIndexPath(_ indexPath: IndexPath) -> CGRect {
        return (self.layoutAttributesForItem(at: indexPath)?.frame)!
    }
}

/// BMDragCellCollectionViewDelegate
@objc protocol BMDragCellCollectionViewDelegate : UICollectionViewDelegateFlowLayout {

    /// 数据与那更新时，触发外面的使用者更新数据源
    ///
    /// - Parameters:
    ///   - dragCellCollectionView: dragCellCollectionView
    ///   - newDataArray: newDataArray
    /// - Returns: Returns
    @objc func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView, newDataArray: Array<Any>) -> Void
    
    /// 将要开始拖拽时，询问此位置的Cell是否可以拖拽
    ///
    /// - Parameters:
    ///   - dragCellCollectionView: dragCellCollectionView
    ///   - indexPath: indexPath
    /// - Returns: Returns
    @objc optional func dragCellCollectionViewShouldBeginMove(_ dragCellCollectionView: BMDragCellCollectionView, indexPath: IndexPath) -> Bool
    
    /// 将要交换时，询问是否可以交换
    ///
    /// - Parameters:
    ///   - dragCellCollectionView: dragCellCollectionView
    ///   - sourceIndexPath: sourceIndexPath
    ///   - destinationIndexPath: destinationIndexPath
    /// - Returns: Returns
    @objc optional func dragCellCollectionViewShouldBeginExchange(_ dragCellCollectionView: BMDragCellCollectionView, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) -> Bool
    
    /// 重排完成时
    ///
    /// - Parameter dragCellCollectionView: dragCellCollectionView
    /// - Returns: Returns
    @objc optional func dragCellCollectionViewDidEndDrag(_ dragCellCollectionView: BMDragCellCollectionView) -> Void
    
    /// 开始拖拽时
    ///
    /// - Parameters:
    ///   - dragCellCollectionView: dragCellCollectionView
    ///   - beganDragAtPoint: beganDragAtPoint
    ///   - indexPath: indexPath
    /// - Returns: Returns
    @objc optional func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView, beganDragAtPoint:CGPoint, indexPath: IndexPath) -> Void
    
    /// 拖拽改变时
    ///
    /// - Parameters:
    ///   - dragCellCollectionView: dragCellCollectionView
    ///   - changedDragAtPoint: changedDragAtPoint
    ///   - indexPath: indexPath
    /// - Returns: Returns
    @objc optional func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView, changedDragAtPoint: CGPoint, indexPath: IndexPath) -> Void
    
    ///  结束拖拽时
    ///
    /// - Parameters:
    ///   - dragCellCollectionView: dragCellCollectionView
    ///   - endedDragAtPoint: endedDragAtPoint
    ///   - indexPath: indexPath
    /// - Returns: Returns
    @objc optional func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView, endedDragAtPoint:CGPoint, indexPath: IndexPath) -> Void
    

    /// 结束拖拽时时是否内部自动处理
    ///
    /// - Parameters:
    ///   - dragCellCollectionView: dragCellCollectionView
    ///   - endedDragAutomaticOperationAtPoint: endedDragAutomaticOperationAtPoint
    ///   - section: section
    ///   - indexPath: indexPath
    /// - Returns: Returns
    @objc optional func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView, endedDragAutomaticOperationAtPoint: CGPoint, section: Int, indexPath: IndexPath) -> Bool
}

/// BMDragCellCollectionViewDataSource
@objc protocol BMDragCellCollectionViewDataSource : UICollectionViewDataSource {

    /// 将要交换时获取数据源
    ///
    /// - Parameter dragCellCollectionView: dragCellCollectionView
    /// - Returns: 获取的数据源
    @objc func dragCellCollectionView(_ dragCellCollectionView: BMDragCellCollectionView) -> Array<Any>
}

/// BMDragCellCollectionView
class BMDragCellCollectionView: UICollectionView {

    /// dragDelegate,用此代理代替delegate 暂未找到同OC的处理方案
    weak open var dragDelegate: BMDragCellCollectionViewDelegate? {
        get {
            return super.delegate as? BMDragCellCollectionViewDelegate
        } set {
            super.delegate = newValue
        }
    }

    /// dragDataSource,用此代理代替dataSource 暂未找到同OC的处理方案
    weak open var dragDataSource: BMDragCellCollectionViewDataSource? {
        get {
            return super.dataSource as? BMDragCellCollectionViewDataSource
        } set {
            super.dataSource = newValue
        }
    }
    
    private var snapedView: UIView?
    private var oldIndexPath: IndexPath?
    private var currentIndexPath: IndexPath?
    private var oldPoint: CGPoint?
    private var lastPoint: CGPoint?
    private var isEndDrag = false
    lazy private var longGesture: UILongPressGestureRecognizer = {
        let longGesture = UILongPressGestureRecognizer.init(target: self, action: #selector(handlelongGesture(_:)))
        longGesture.minimumPressDuration = 0.5
        return longGesture
    }()
    
    private var edgeTimer : CADisplayLink?

    override func awakeFromNib() {
        super.awakeFromNib()
        initConfiguration()
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.initConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func initConfiguration() -> Void {
        self.addGestureRecognizer(self.longGesture)
    }

    @objc private func edgeScroll() -> Void {
        let scrollDirection = self.setScrollDirection()
        switch scrollDirection {
        case .left:
            self.setContentOffset(CGPoint.init(x: self.contentOffset.x - 4, y: self.contentOffset.y), animated: false)
            self.snapedView?.center = CGPoint.init(x: (snapedView?.center.x)! - 4, y: (snapedView?.center.y)!)
            lastPoint?.x -= 4;
        case .right:
            self.setContentOffset(CGPoint.init(x: self.contentOffset.x - 4, y: self.contentOffset.y), animated: false)
            self.snapedView?.center = CGPoint.init(x: (snapedView?.center.x)! - 4, y: (snapedView?.center.y)!)
            lastPoint?.x += 4
        case .up:
            self.setContentOffset(CGPoint.init(x: self.contentOffset.x, y: self.contentOffset.y - 4), animated: false)
            self.snapedView?.center = CGPoint.init(x: (snapedView?.center.x)!, y: (snapedView?.center.y)! - 4)
            lastPoint?.y -= 4;
        case .down:
            self.setContentOffset(CGPoint.init(x: self.contentOffset.x, y: self.contentOffset.y + 4), animated: false)
            self.snapedView?.center = CGPoint.init(x: (snapedView?.center.x)!, y: (snapedView?.center.y)! + 4)
            lastPoint?.y += 4;
            break
        default: break
        }
        if (scrollDirection == .none) {
            return
        }

        // 如果Cell 拖拽到了边沿时
        // 截图视图位置移动
        UIView.animate(withDuration: 0.1) {
            self.snapedView?.center = self.lastPoint!
        }
        
        // 获取应该交换的Cell的位置
        let idnex1 = self.getChangedIndexPath()
        if ((idnex1 == nil)) {
            return
        }

        if (self.dragDelegate != nil) && (self.dragDelegate?.responds(to: #selector(self.dragDelegate?.self.dragCellCollectionViewShouldBeginExchange(_:sourceIndexPath:destinationIndexPath:))))! {
            if !(self.dragDelegate?.dragCellCollectionViewShouldBeginExchange!(self, sourceIndexPath: oldIndexPath!, destinationIndexPath: idnex1!))! {
                return;
            }
        }

        currentIndexPath = idnex1;

        self.oldPoint = self.cellForItem(at: currentIndexPath!)?.center
        // 操作数据
        self.updateSourceData()
        
        // 移动 会调用willMoveToIndexPath方法更新数据源
        self.moveItem(at: self.oldIndexPath!, to: self.currentIndexPath!)
        
        self.oldIndexPath = currentIndexPath
        // 为了防止在缓存池取出的Cell已隐藏,
        // 以后可以优化
        self.reloadItems(at: [oldIndexPath!])
    }
    
    private func setScrollDirection() -> BMDragCellCollectionViewScrollDirection {
        if self.bounds.size.height + self.contentOffset.y - (snapedView?.center.y)! < (snapedView?.bounds.size.height)! / 2 && self.bounds.size.height + self.contentOffset.y < self.contentSize.height {
            return .down;
        }
        if ((snapedView?.center.y)! - self.contentOffset.y < (snapedView?.bounds.size.height)! / 2 && self.contentOffset.y > 0) {
            return .up;
        }
        if (self.bounds.size.width + self.contentOffset.x - (snapedView?.center.x)! < (snapedView?.bounds.size.width)! / 2 && self.bounds.size.width + self.contentOffset.x < self.contentSize.width) {
            return .right;
        }
        if ((snapedView?.center.x)! - self.contentOffset.x < (snapedView?.bounds.size.width)! / 2 && self.contentOffset.x > 0) {
            return .left;
        }
        return .none;
    }

    @objc private func handlelongGesture(_ longGesture: UILongPressGestureRecognizer) -> Void {
        let point = longGesture.location(in: self)
        let indexPath = self.indexPathForItem(at: point);
        switch longGesture.state {
        case .began:

            if (self.dragDelegate != nil) && (self.dragDelegate?.responds(to: #selector(self.dragDelegate?.self.dragCellCollectionView(_:beganDragAtPoint:indexPath:))))! {
                self.dragDelegate?.dragCellCollectionView!(self, beganDragAtPoint: point, indexPath: indexPath!)
            }
            
            // 手势开始
            // 判断手势落点位置是否在Item上
            if (indexPath == nil) {
                self.longGesture.isEnabled = false
                Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: { (time) in
                    self.longGesture.isEnabled = true
                })
                break;
            }

            
            if (self.dragDelegate != nil) && (self.dragDelegate?.responds(to: #selector(self.dragDelegate?.self.dragCellCollectionViewShouldBeginMove(_:indexPath:))))! {
                if !(self.dragDelegate?.dragCellCollectionViewShouldBeginMove!(self, indexPath: indexPath!))! {
                    oldIndexPath = nil;
                    self.longGesture.isEnabled = false
                    Timer.scheduledTimer(withTimeInterval: 0.25, repeats: false, block: { (time) in
                        self.longGesture.isEnabled = true;
                    })
                    break
                }
            }

            oldIndexPath = indexPath!
            
            self.isEndDrag = false;
            
            // 取出正在长按的cell
            let cell = self.cellForItem(at: oldIndexPath!)
            self.oldPoint = cell?.center;
            
            // 使用系统截图功能，得到cell的快照view
            snapedView = cell?.snapshotView(afterScreenUpdates: false)
            
            // 设置frame
            snapedView?.frame = (cell?.frame)!;

            // 添加到 collectionView 不然无法显示
            self.addSubview(snapedView!)

            //截图后隐藏当前cell
            cell?.isHidden = true;

            // 获取当前触摸的中心点
            let currentPoint = point;

            // 动画放大和移动到触摸点下面
            UIView.animate(withDuration: 0.25, animations: {
                self.snapedView?.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                self.snapedView?.center = CGPoint.init(x: currentPoint.x, y: currentPoint.y)
                self.snapedView?.alpha = 1.0;
            })

            // 开启collectionView的边缘自动滚动检测
            setEdgeTimer()
            break
        case .changed:

            if (self.dragDelegate != nil) && (self.dragDelegate?.responds(to: #selector(self.dragDelegate?.self.dragCellCollectionView(_:changedDragAtPoint:indexPath:))))! {
                self.dragDelegate?.dragCellCollectionView!(self, changedDragAtPoint: point, indexPath: indexPath!)
            }

            // 当前手指位置
            lastPoint = point;

            // 截图视图位置移动
            UIView.animate(withDuration: 0.25, animations: {
                self.snapedView?.center = self.lastPoint!;
            })

            // 获取应该交换的cell
            let idnex1 = self.getChangedIndexPath()

            // 没有取到或者距离隐藏的最近时就返回
            if (idnex1 == nil) {
                break;
            }

            if (self.dragDelegate != nil) && (self.dragDelegate?.responds(to: #selector(self.dragDelegate?.self.dragCellCollectionViewShouldBeginExchange(_:sourceIndexPath:destinationIndexPath:))))! {
                if !(self.dragDelegate?.dragCellCollectionViewShouldBeginExchange!(self, sourceIndexPath: oldIndexPath!, destinationIndexPath: idnex1!))! {
                    break;
                }
            }

            currentIndexPath = idnex1;
            oldPoint = self.cellForItem(at: currentIndexPath!)?.center

            // 操作数据
            self.updateSourceData()

            // 移动 会调用willMoveToIndexPath方法更新数据源
            self.moveItem(at: oldIndexPath!, to: currentIndexPath!)
            // 设置移动后的起始indexPath
            oldIndexPath = currentIndexPath
            
            self.reloadItems(at: [oldIndexPath!])
            break
        default:
            self.isEndDrag = true;

            if (self.dragDelegate != nil) && (self.dragDelegate?.responds(to: #selector(self.dragDelegate?.self.dragCellCollectionView(_:endedDragAtPoint:indexPath:))))! {
                self.dragDelegate?.dragCellCollectionView!(self, endedDragAtPoint: point, indexPath: indexPath!)
            }

            if (self.dragDelegate != nil) && (self.dragDelegate?.responds(to: #selector(self.dragDelegate?.self.dragCellCollectionView(_:endedDragAutomaticOperationAtPoint:section:indexPath:))))! {
                var section = -1
                let sec = self.dragDataSource?.numberOfSections!(in: self)
                for i in 0..<sec! {
                    let rect = self.BMDragCellCollectionView_rectForSection(i)
                    if (point.x > rect.origin.x
                        && point.x < rect.origin.x + rect.size.width
                        && point.y > rect.origin.y
                        && point.y < rect.origin.y + rect.size.height) {
                        section = i;
                        break;
                    }
                }
                if (self.dragDelegate?.dragCellCollectionView!(self, endedDragAutomaticOperationAtPoint: point, section: section, indexPath: indexPath!))! {
                    return;
                }
            }
            if self.oldIndexPath == nil {
                return
            }
            let cell = self.cellForItem(at: oldIndexPath!)
            self.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.25, animations: {
                if cell == nil {
                    self.snapedView?.center = self.oldPoint!;
                } else {
                    self.snapedView?.center = (cell?.center)!;
                }
                self.snapedView?.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                self.snapedView?.alpha = 1.0;
            }, completion: { (an) in
                self.snapedView?.removeFromSuperview()
                cell?.isHidden = false
                self.isUserInteractionEnabled = true
                if (self.dragDelegate != nil) && (self.dragDelegate?.responds(to: #selector(self.dragDelegate?.self.dragCellCollectionViewDidEndDrag(_:))))! {
                    self.dragDelegate?.dragCellCollectionViewDidEndDrag!(self)
                }
            })
            endEdgeTimer()
            break
        }
    }

    private func setEdgeTimer() -> Void {
        self.edgeTimer = CADisplayLink.init(target: self, selector: #selector(edgeScroll))
        self.edgeTimer?.add(to: RunLoop.main, forMode: .commonModes)
    }

    private func endEdgeTimer() -> Void {
        self.edgeTimer?.invalidate()
        self.edgeTimer = nil;
    }

    /// 取出应该交换的index
    ///
    /// - Returns: index
    private func getChangedIndexPath() -> IndexPath? {
        var index1: IndexPath? = nil
        let point = self.longGesture.location(in: self)

        // 遍历是否移动到cell上
        for cell in self.visibleCells {
            if (point.x > cell.frame.origin.x
                && point.x < cell.frame.origin.x + cell.frame.size.width
                && point.y > cell.frame.origin.y
                && point.y < cell.frame.origin.y + cell.frame.size.height) {
                index1 = self.indexPath(for: cell)
                break;
            }
        }

        // 是在cell上
        if index1 != nil {
            // 如果是当前的cell就返回nil
            if (index1?.item == self.oldIndexPath?.item) && (index1?.section == self.oldIndexPath?.section) {
                return nil
            }
            // 不是当前的cell
            return index1;
        }

        // 获取最应该交换的Cell
        var width : CGFloat = CGFloat(MAXFLOAT)
        for cell in self.visibleCells {
            let p1 = self.snapedView?.center
            let p2 = cell.center
            let distance = sqrt((pow(((p1?.x)! - p2.x), 2) + pow(((p1?.y)! - p2.y), 2)))
            if (distance < width) {
                width = distance
                index1 = self.indexPath(for: cell)
            }
        }

        if ((index1 == nil)) {
            return nil;
        }
        if ((index1?.item == self.oldIndexPath?.item) && (index1?.row == self.oldIndexPath?.row)) {
            // 最近的就是隐藏的Cell时,return nil
            return nil;
        }
        return index1;
    }

    private func updateSourceData() -> Void {
        var array = self.dragDataSource?.dragCellCollectionView(self)

        let dataTypeCheck = (self.numberOfSections != 1) || ((self.numberOfSections == 1) && array?[0] is Array<Any>)
        if dataTypeCheck {
            for (i, obj) in (array?.enumerated())! {
                array?[i] = (obj as! NSArray).mutableCopy() as! [Any]
            }
        }

        if self.currentIndexPath?.section == self.oldIndexPath?.section {
            var arr1 = [Any]()
            if dataTypeCheck {
                arr1 = array?[(self.oldIndexPath?.section)!] as! [Any]
            } else {
                arr1 = array!
            }
            if (self.currentIndexPath?.item)! > (self.oldIndexPath?.item)! {
                for i in (oldIndexPath?.item)!..<(currentIndexPath?.item)! {
                    let obj1 = arr1[i]
                    arr1[i] = arr1[i + 1] 
                    arr1[i + 1] = obj1 
                }
            } else {
                var i = (oldIndexPath?.item)!
                while i > (currentIndexPath?.item)! {
                    let obj1 = arr1[i]
                    arr1[i] = arr1[i - 1] 
                    arr1[i - 1] = obj1 
                    i -= 1
                }
            }
            if dataTypeCheck {
                array?[(self.oldIndexPath?.section)!] = arr1
            } else {
                array = arr1
            }
        } else {
            var orignalSection = array?[(oldIndexPath?.section)!] as! Array<Any>
            var currentSection = array?[(currentIndexPath?.section)!] as! Array<Any>
            currentSection.insert(orignalSection[(oldIndexPath?.item)!], at: (currentIndexPath?.item)!)
            orignalSection.remove(at: (oldIndexPath?.item)!)
            array?[(oldIndexPath?.section)!] = orignalSection
            array?[(currentIndexPath?.section)!] = currentSection
        }
        self.dragDelegate?.dragCellCollectionView(self, newDataArray: array!)
    }

    internal override func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        if isEndDrag {
            cell.isHidden = false
            return cell
        }
        cell.isHidden = (oldPoint != nil) && oldIndexPath?.item == indexPath.item && oldIndexPath?.section == indexPath.section
        return cell
    }
}
