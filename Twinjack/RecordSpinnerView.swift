//
// RecordSpinnerView.swift
// Generated by Core Animator version 1.1 on 6/19/15.
//
// DO NOT MODIFY THIS FILE. IT IS AUTO-GENERATED AND WILL BE OVERWRITTEN
//

import AppKit
import QuartzCore

@IBDesignable
class RecordSpinnerView : NSView {

	var layersByName: [String : CALayer]!
	var viewsByName: [String : NSView]!

	// - MARK: Life Cycle

	convenience init() {
		self.init(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupHierarchy()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.setupHierarchy()
	}

	override var flipped:Bool {
		get {
			return true
		}
	}


	// - MARK: Scaling

	func frameDidChange(notification: NSNotification) {
		if let scalingView = self.layersByName["__scaling__"] {
			var xScale = self.bounds.size.width / scalingView.bounds.size.width
			var yScale = self.bounds.size.height / scalingView.bounds.size.height
			let scale = min(xScale, yScale)
			xScale = scale
			yScale = scale
			CATransaction.begin()
			CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
			scalingView.transform = CATransform3DMakeScale(xScale, yScale, 1.0)
			scalingView.position = CGPoint(x:CGRectGetMidX(self.bounds), y:CGRectGetMidY(self.bounds))
			CATransaction.commit()
		}
	}

	// - MARK: Setup

	func setupHierarchy() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "frameDidChange:", name: NSViewFrameDidChangeNotification, object: self)
		self.wantsLayer = true
		var layersByName: [String : CALayer] = [:]
		var viewsByName: [String : NSView] = [:]
		let bundle = NSBundle(forClass:self.dynamicType)
		let __scaling__ = CALayer()
		__scaling__.bounds = CGRect(x:0, y:0, width:400, height:400)
		__scaling__.position = CGPoint(x:200.0, y:200.0)
		self.layer?.addSublayer(__scaling__)
		layersByName["__scaling__"] = __scaling__

		let _45rpm = CALayer()
		_45rpm.name = "45rpm"
		_45rpm.bounds = CGRect(x:0, y:0, width:300.0, height:297.0)
		var img45rpm: NSImage!
		if let imagePath = bundle.pathForImageResource("45rpm") {
			img45rpm = NSImage(contentsOfFile:imagePath)
		}
		_45rpm.contents = img45rpm
		_45rpm.position = CGPoint(x:200.000, y:200.000)
		__scaling__.addSublayer(_45rpm)
		layersByName["45rpm"] = _45rpm

		self.layersByName = layersByName
		self.viewsByName = viewsByName
	}

	// - MARK: rotate

	func addRotateAnimation() {
		addRotateAnimationWithBeginTime(0, fillMode: kCAFillModeBoth, removedOnCompletion: false)
	}

	func addRotateAnimation(#removedOnCompletion: Bool) {
		addRotateAnimationWithBeginTime(0, fillMode: removedOnCompletion ? kCAFillModeRemoved : kCAFillModeBoth, removedOnCompletion: removedOnCompletion)
	}

	func addRotateAnimationWithBeginTime(beginTime: CFTimeInterval, fillMode: String, removedOnCompletion: Bool) {
		let linearTiming = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)

		let _45rpmRotationAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
		_45rpmRotationAnimation.duration = 0.870
		_45rpmRotationAnimation.values = [0.000 as Float, 6.281 as Float]
		_45rpmRotationAnimation.keyTimes = [0.000 as Float, 1.000 as Float]
		_45rpmRotationAnimation.timingFunctions = [linearTiming]
		_45rpmRotationAnimation.repeatCount = HUGE
		_45rpmRotationAnimation.beginTime = beginTime
		_45rpmRotationAnimation.fillMode = fillMode
		_45rpmRotationAnimation.removedOnCompletion = removedOnCompletion
		self.layersByName["45rpm"]?.addAnimation(_45rpmRotationAnimation, forKey:"rotate_Rotation")
	}

	func removeRotateAnimation() {
		self.layersByName["45rpm"]?.removeAnimationForKey("rotate_Rotation")
	}

	func removeAllAnimations() {
		for subview in viewsByName.values {
			subview.layer!.removeAllAnimations()
		}
	}
}