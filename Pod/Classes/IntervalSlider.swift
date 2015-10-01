//
//  SplitSlider.swift
//  IntervalSlider
//
//  Created by shushutochako on 9/3/15.
//  Copyright © 2015 shushutochako. All rights reserved.
//

import UIKit

public protocol IntervalSliderDelegate {
  func confirmValue(slider: IntervalSlider, validValue: Float)
}

public class IntervalSliderSource {
  private var validValue: Float
  private var appearanceValue: Float
  private var label: UILabel?
  
  /**
  Initialize IntervalSliderSource
  
  - parameter validValue: The value set is valid
  - parameter appearanceValue: The value is used to represent the position of validValue
  - parameter label: label to be displayed at the top of the appearanceValue
  */
  public init(validValue: Float, appearanceValue: Float, label: UILabel) {
    self.validValue = validValue
    self.appearanceValue = appearanceValue
    self.label = label
  }
}

public enum IntervalSliderOption {
  case MinimumTrackTintColor(UIColor)
  case MinimumValue(Float) // can set a value greater than 0
  case MaximumValue(Float) // can set a value less than 100
  case LabelBottomPadding(CGFloat)
  case DefaultValue(Float)
  case AddMark(Bool)
  case ThumbImage(UIImage)
}

public class IntervalSlider: UIView {
  
  private class TapSlider: UISlider {
    override init(frame: CGRect) {
      super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
      return true
    }
  }
  
  public var delegate: IntervalSliderDelegate?
  private var slider: TapSlider!
  private var sources = [IntervalSliderSource]()
  private var labels = [UILabel]()
  private var marks = [UIView]()
  
  // options
  private var minimumValue: Float = 0 {
    willSet {
      if newValue < 0 || newValue > 100 { fatalError("MinimumValue must be between 0 and 100") }
    }
  }
  private var maximumValue: Float = 100 {
    willSet {
      if newValue < 0 || newValue > 100 { fatalError("MaximumValue must be between 0 and 100") }
    }
  }
  private var minimumTrackTintColor = UIColor.blueColor()
  private var labelBottomPadding: CGFloat = 5
  private var defaultValue: Float = 0
  private var isAddMark: Bool = false
  private var thumbImage: UIImage?
  private var defaultThumbImage: UIImage {
    let thumbView = UIView(frame: CGRectMake(0, 0 , 20, 20))
    thumbView.backgroundColor = UIColor.whiteColor()
    thumbView.layer.cornerRadius = thumbView.bounds.width * 0.5
    thumbView.clipsToBounds = true    
    return self.imageFromViewWithCornerRadius(thumbView)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public init(frame: CGRect, sources: [IntervalSliderSource], options: [IntervalSliderOption]? = nil) {
    super.init(frame: frame)
    self.sources = sources
    self.build(options)
    self.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    self.layout()
  }
  
  private func build(options: [IntervalSliderOption]?) {
    if let options = options {
      for option in options {
        switch option {
        case let .MinimumTrackTintColor(value):
          self.minimumTrackTintColor = value
        case let .MinimumValue(value):
          self.minimumValue = value
        case let .MaximumValue(value):
          self.maximumValue = value
        case let .LabelBottomPadding(value):
          self.labelBottomPadding = value
        case let .DefaultValue(value):
          self.defaultValue = value
        case let .AddMark(value):
          self.isAddMark = value
        case let .ThumbImage(value):
          self.thumbImage = value
        }
      }
    }
    let rect = CGRect(x: 0, y:self.frame.height / 2, width: self.frame.width, height: self.frame.height / 2)
    self.slider = TapSlider(frame: rect)
    self.slider.setThumbImage(self.thumbImage ?? self.defaultThumbImage, forState: .Normal)
    self.addSubview(self.slider)
    self.slider.minimumValue = self.minimumValue
    self.slider.maximumValue = self.maximumValue
    self.slider.minimumTrackTintColor = self.minimumTrackTintColor
    self.slider.addTarget(self, action: Selector("endDrag:"), forControlEvents: .TouchUpInside)
    self.slider.addTarget(self, action: Selector("endDrag:"), forControlEvents: .TouchUpOutside)

    for source in self.sources {
      if let label = source.label {
        label.frame = CGRectMake(0, 0, label.bounds.size.width, label.bounds.size.height)
        self.labels.append(label)
        self.addSubview(label)
      }
      if self.isAddMark {
        let mark = UIView(frame: CGRectMake(0, 0, 1, 8))
        mark.backgroundColor = UIColor.lightGrayColor()
        self.marks.append(mark)
        self.insertSubview(mark, belowSubview:self.slider)
      }
    }
    self.seek(self.adjustSliderValue(self.defaultValue))
  }
  
  private func layout(){
    self.slider.frame = CGRectMake(0, self.frame.height / 2, self.frame.width, self.frame.height / 2)
    var index: Int = 0
    for source in self.sources {
      let label = self.labels[index]
      let center = self.thumbCenter(source.appearanceValue)
      label.frame = CGRectMake(0,
        self.slider.frame.origin.y - (label.bounds.size.height + self.labelBottomPadding),
        label.bounds.size.width,
        label.bounds.size.height)
      label.center = CGPoint(x: center.x, y: label.center.y)
      if self.isAddMark {
        let mark = marks[index]
        mark.center = CGPoint(x: center.x, y: center.y)
      }
      index++
    }
  }
  
  public func endDrag(slider: UISlider) {
    let adjustValue: Float = self.adjustSliderValue(self.slider.value)
    self.seek(adjustValue)
    self.delegate?.confirmValue(self, validValue: self.getValue())
  }
  
  /**
  Return a current validValue
  
  */
  public func getValue() -> Float {
    return self.findValidValue(self.slider.value)
  }
  
  /**
  Set valid value
  If you specify a value not included in the valideValues,
  the value is adjusted to the nearest validValue
  
  - parameter value:   validValue
  */
  public func setValue(value: Float) {
    self.seek(self.findAppearanceValue(value))
  }
  
  private func findValidValue(appearanceValue: Float) -> Float {
    let sources = self.sources.filter({
      $0.appearanceValue == appearanceValue
    })
    return sources[0].validValue
  }
  
  private func findAppearanceValue(validValue: Float) -> Float {
    let sources = self.sources.filter({
      $0.validValue == validValue
    })
    return sources[0].appearanceValue
  }

  private func thumbCenter(value: Float) -> (x: CGFloat, y: CGFloat) {
    let originValue = self.slider.value
    self.seek(value)
    let trackRect = self.slider.trackRectForBounds(self.slider.bounds)
    let thumbRect = self.slider.thumbRectForBounds(self.slider.bounds, trackRect: trackRect, value: self.slider.value)
    self.seek(originValue)
    return (thumbRect.origin.x + (self.slider.currentThumbImage!.size.width / 2),
      self.slider.frame.origin.y + thumbRect.origin.y + (self.slider.currentThumbImage!.size.height / 2))
  }
  
  private func adjustSliderValue(baseValue: Float) -> Float {
    var selectValue = self.sources.first?.appearanceValue
    var leastDifference: Float?
    for sources in self.sources {
      let value = sources.appearanceValue
      let difference = abs(value - baseValue)
      if let comparison = leastDifference {
        if difference < comparison {
          leastDifference = difference
          selectValue = value
        }
      } else {
        leastDifference = difference
      }
    }
    return selectValue!
  }
  
  private func seek(value: Float) {
    UIView.animateWithDuration(0.6, delay: 0,
      usingSpringWithDamping: 0.4,
      initialSpringVelocity: 0,
      options: .CurveEaseInOut,
      animations: {
        self.slider.setValue(value, animated: true)
      },
      completion: nil)
  }
  
  private func imageFromViewWithCornerRadius(view: UIView) -> UIImage {
    // maskImage
    let imageBounds = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)
    let path = UIBezierPath(roundedRect: imageBounds, cornerRadius: view.bounds.size.width * 0.5)
    UIGraphicsBeginImageContextWithOptions(path.bounds.size, false, 0)
    view.backgroundColor?.setFill()
    path.fill()
    let maskImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // drawImge
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    CGContextClipToMask(context, imageBounds, maskImage.CGImage)
    view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image;
  }
}
