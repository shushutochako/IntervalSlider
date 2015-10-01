//
//  ViewController.swift
//  IntervalSlider
//
//  Created by shushutochako on 10/01/2015.
//  Copyright (c) 2015 shushutochako. All rights reserved.
//

import UIKit
import IntervalSlider

class ViewController: UIViewController {
  @IBOutlet weak var sliderView1: UIView!
  @IBOutlet weak var sliderView2: UIView!
  @IBOutlet weak var valueLabel1: UILabel!
  @IBOutlet weak var valueLabel2: UILabel!
  
  private var intervalSlider1: IntervalSlider! {
    didSet {
      self.intervalSlider1.tag = 1
      self.sliderView1.addSubview(self.intervalSlider1)
      self.intervalSlider1.delegate = self
    }
  }
  private var intervalSlider2: IntervalSlider! {
    didSet {
      self.intervalSlider2.tag = 2
      self.sliderView2.addSubview(self.intervalSlider2)
      self.intervalSlider2.delegate = self
    }
  }
  private var data1: [Float] {
    return [0, 100, 200 , 300, 400]
  }
  private var data2: [Float] {
    return [0, 1, 2, 3]
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.intervalSlider1 = IntervalSlider(frame: self.sliderView1.bounds, sources: self.createSources())
    let result = self.createSources2()
    self.intervalSlider2 = IntervalSlider(frame: self.sliderView2.bounds, sources: result.sources, options: result.options)
  }
  
  private func createSources() -> [IntervalSliderSource] {
    // Sample of equally inttervals
    var sources = [IntervalSliderSource]()
    var appearanceValue: Float = 0
    
    for data in self.data1 {
      let label = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
      label.text = "\(Int(data))"
      label.font = UIFont.systemFontOfSize(CGFloat(12))
      label.textColor = UIColor.redColor()
      label.textAlignment = .Center
      let source = IntervalSliderSource(validValue: data, appearanceValue: appearanceValue, label: label)
      sources.append(source)
      appearanceValue += 25
    }
    return sources
  }
  
  private func createSources2() -> (sources: [IntervalSliderSource], options: [IntervalSliderOption]) {
    // Sample of irregular inttervals
    var sources = [IntervalSliderSource]()
    var appearanceValue: Float = 0
    let data = self.data2
    
    let minLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
    minLabel.text = "Min"
    minLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    minLabel.textColor = UIColor.grayColor()
    minLabel.textAlignment = .Center
    let minSource = IntervalSliderSource(validValue: data[0], appearanceValue: appearanceValue, label: minLabel)
    sources.append(minSource)
    appearanceValue += 15
    
    let shortLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
    shortLabel.text = "Short"
    shortLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    shortLabel.textColor = UIColor.grayColor()
    shortLabel.textAlignment = .Center
    let shortSource = IntervalSliderSource(validValue: data[1], appearanceValue: appearanceValue, label: shortLabel)
    sources.append(shortSource)
    appearanceValue += 35
    
    let longLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
    longLabel.text = "Long"
    longLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    longLabel.textColor = UIColor.grayColor()
    longLabel.textAlignment = .Center
    let longSource = IntervalSliderSource(validValue: data[2], appearanceValue: appearanceValue, label: longLabel)
    sources.append(longSource)
    appearanceValue += 15
    
    let maxLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 20))
    maxLabel.text = "Max"
    maxLabel.font = UIFont.systemFontOfSize(CGFloat(12))
    maxLabel.textColor = UIColor.grayColor()
    maxLabel.textAlignment = .Center
    let maxSource = IntervalSliderSource(validValue: data[3], appearanceValue: appearanceValue, label: maxLabel)
    sources.append(maxSource)
    
    let options: [IntervalSliderOption] = [
      .MaximumValue(appearanceValue),
      .MinimumValue(0),
      .AddMark(true),
      .LabelBottomPadding(1),
      .MinimumTrackTintColor(UIColor.redColor())
    ]
    return (sources, options)
  }
}

extension ViewController: IntervalSliderDelegate {
  func confirmValue(slider: IntervalSlider, validValue: Float) {
    switch slider.tag {
    case 1:
      self.valueLabel1.text = "\(Int(validValue))"
    case 2:
      self.valueLabel2.text = "\(Int(validValue))"
    default:
      break
    }
  }
}

