/*
* Copyright 2015 Google Inc. All Rights Reserved.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import Foundation

/**
View for rendering a `BlockLayout`.
*/
@objc(BKYBlockView)
public class BlockView: UIView {
  // MARK: - Properties

  /// Layout object to render
  public var layout: BlockLayout? {
    didSet {
      if layout != oldValue {
        oldValue?.delegate = nil
        layout?.delegate = self
        refresh()
      }
    }
  }

  /// Manager for acquiring and recycling views.
  private let _viewManager = ViewManager.sharedInstance

  /// View for rendering the block's background
  private let _blockBackgroundView: BezierPathView = {
    return ViewManager.sharedInstance.viewForType(BezierPathView.self)
    }()

  /// View for rendering the block's highlight overly
  private lazy var _highlightOverlayView: BezierPathView = {
    return ViewManager.sharedInstance.viewForType(BezierPathView.self)
    }()

  /// Field subviews
  private var _fieldViews = [UIView]()

  // MARK: - Initializers

  public required init() {
    super.init(frame: CGRectZero)

    self.translatesAutoresizingMaskIntoConstraints = false

    // Configure background
    _blockBackgroundView.frame = self.bounds
    _blockBackgroundView.backgroundColor = UIColor.clearColor()
    _blockBackgroundView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    addSubview(_blockBackgroundView)
    sendSubviewToBack(_blockBackgroundView)
  }

  public required init?(coder aDecoder: NSCoder) {
    bky_assertionFailure("Called unsupported initializer")
    super.init(coder: aDecoder)
  }

  // MARK: - Public

  /**
  Refreshes the view based on the current layout.
  */
  public func refresh() {
    // Remove and recycle field subviews
    recycleFieldViews()

    guard let layout = self.layout else {
      self.frame = CGRectZero
      self.backgroundColor = UIColor.clearColor()
      return
    }

    self.frame = layout.viewFrame
    self.layer.zPosition = layout.zPosition

    // TODO:(vicng) Set the colours properly
    _blockBackgroundView.strokeColour = UIColor.grayColor()
    _blockBackgroundView.fillColour = UIColor.blueColor()
    _blockBackgroundView.bezierPath = blockBackgroundBezierPath()

    // TODO:(vicng) Optimize this so this view only needs is created/added when the user
    // highlights the block.
    _highlightOverlayView.strokeColour = UIColor.orangeColor()
    _highlightOverlayView.fillColour = UIColor.orangeColor()
    _highlightOverlayView.frame = self.bounds
    _highlightOverlayView.backgroundColor = UIColor.clearColor()
    _highlightOverlayView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    _highlightOverlayView.bezierPath = blockHighlightBezierPath()
    addSubview(_highlightOverlayView)
    sendSubviewToBack(_highlightOverlayView)

    // Add field views
    for fieldLayout in layout.fieldLayouts {
      if let fieldView = ViewManager.sharedInstance.fieldViewForLayout(fieldLayout) {
        _fieldViews.append(fieldView)

        addSubview(fieldView)
      }
    }
  }
}

// MARK: - Recyclable implementation

extension BlockView: Recyclable {
  public func recycle() {
    self.layout = nil

    recycleFieldViews()

    _blockBackgroundView.removeFromSuperview()
    ViewManager.sharedInstance.recycleView(_blockBackgroundView)

    _highlightOverlayView.removeFromSuperview()
    ViewManager.sharedInstance.recycleView(_highlightOverlayView)
  }

  private func recycleFieldViews() {
    for fieldView in _fieldViews {
      fieldView.removeFromSuperview()

      if fieldView is Recyclable {
        ViewManager.sharedInstance.recycleView(fieldView)
      }
    }
    _fieldViews = []
  }
}

// MARK: - LayoutDelegate implementation

extension BlockView: LayoutDelegate {
  public func layoutDidChange(layout: Layout) {
    refresh()
  }
}

// MARK: - Bezier Path Builders

extension BlockView {
  private func blockBackgroundBezierPath() -> UIBezierPath? {
    guard let layout = self.layout else {
      return nil
    }

    // TODO:(vicng) Construct the block background path properly (the code below is simply test
    // code).
    let bezierPath = WorkspaceBezierPath(layout: layout.workspaceLayout)

    movePathToTopLeftCornerStart(bezierPath)
    addTopLeftCornerToPath(bezierPath)
    addNotchToPath(bezierPath)
    bezierPath.addLineToPoint(100, 0, relative: true)
    bezierPath.addLineToPoint(0, 50, relative: true)
    bezierPath.addLineToPoint(-150, 0, relative: true)
    bezierPath.closePath()

    return bezierPath.viewBezierPath
  }

  private func blockHighlightBezierPath() -> UIBezierPath? {
    guard let layout = self.layout else {
      return nil
    }
    
    // TODO:(vicng) Build highlight bezier path
    return nil
  }
}
