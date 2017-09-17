//
//  ElasticOvalView.swift
//  Contactis_Challenge
//
//  Created by ARKALYK AKASH on 7/29/17.
//  Copyright © 2017 ARKALYK AKASH. All rights reserved.
//
import UIKit
import Neon
import KMPlaceholderTextView

protocol ElasticOvalViewDelegate: AnyObject {
    func didCollapse(elasticView: ElasticOvalView)
}

class ElasticOvalView: UIView {
    //MARK: - Properties
    weak var delegate: ElasticOvalViewDelegate?
    
    lazy var elasticShapeLayer : CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.customPink.cgColor
        return layer
    }()
    
    lazy var controlPointView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var leftPointView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var rightPointView : UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var expressionLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "Carlito", size: 18)
        return label
    }()
    
    lazy var resultView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0.0
        return view
    }()
    
    private lazy var resultLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.backgroundColor = .clear
        return label
    }()
    
    lazy var searchTextView : KMPlaceholderTextView = {
        let textView = KMPlaceholderTextView()
        textView.backgroundColor = UIColor.clear
        textView.textAlignment = .center
        textView.font = UIFont(name: "", size: 26)
        textView.placeholder = "What are you looking for?"
        textView.font = UIFont(name: "Carlito", size: 40)
        return textView
    }()
    
    lazy var displayLink : CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(bounceLayer))
        displayLink.add(to: .current, forMode: .commonModes)
        return displayLink
    }()
    
    lazy var pan : UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handle(pan:)))
        return pan
    }()
    
    var expressionText : String?{
        didSet{
            if let text = expressionText{
                expressionLabel.text = text
            }
        }
    }
    
    var resultText : String?{
        didSet{
            if let text = resultText{
                resultLabel.text = text
            }
        }
    }
    
    var isExpanded = false
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        self.addGestureRecognizer(pan)
        self.backgroundColor = .clear
        self.clipsToBounds = false
        
        layer.addSublayer(elasticShapeLayer)
        elasticShapeLayer.fillColor = UIColor.customPink.cgColor
        self.addSubview(controlPointView)
        self.addSubview(expressionLabel)
        self.addSubview(resultView)
        resultView.addSubview(resultLabel)
        resultView.addSubview(searchTextView)
        
        updateConstraints()
    }
    
    //MARK: - Constraints
    override func updateConstraints() {
        super.updateConstraints()
        positionControlPoint()
        elasticShapeLayer.path = pathForElasticShapeFor(controlPoint: controlPointView.center)
        expressionLabel.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: Sizes.compressedViewHeight)
        resultView.align(.underCentered, relativeTo: expressionLabel, padding: -Sizes.controlAndSidePointDifference, width: self.frame.size.width-20, height: Sizes.expandedViewHeight - Sizes.compressedViewHeight)
        searchTextView.fillSuperview()
    }
    
    func positionControlPoint(){
        let sidePointY = Sizes.compressedViewHeight - Sizes.controlAndSidePointDifference
        leftPointView.center = CGPoint(x: 0, y: sidePointY)
        rightPointView.center = CGPoint(x: self.frame.maxX, y: sidePointY)
        controlPointView.center = CGPoint(x: self.frame.midX, y: Sizes.compressedViewHeight)
    }
    
    //MARK: - Drawing
    func pathForElasticShapeFor(controlPoint : CGPoint) -> CGPath{
        let myBezier = UIBezierPath()
        let rect = self.bounds.size
        myBezier.move(to: leftPointView.center)
        myBezier.addQuadCurve(to: rightPointView.center, controlPoint: controlPoint)
        myBezier.addLine(to: CGPoint(x: rect.width, y: 0))
        myBezier.addLine(to: CGPoint(x: 0, y: 0))
        myBezier.close()
        return myBezier.cgPath
    }
    
    //MARK: - Gestures
    func handle(pan : UIPanGestureRecognizer){
        startBouncing()
        let translation = pan.translation(in: self)
        controlPointView.center.x += translation.x
        controlPointView.center.y += translation.y
        pan.setTranslation(.zero, in: self)
        if pan.state == .ended && pan.direction! == Direction.Up {
            compressView()
        } else if pan.state == .ended && pan.direction! == Direction.Down {
            expandView()
        }
    }
}
extension ElasticOvalView{
    //MARK: - Animations
    func compressView(){
        startBouncing()
        self.isUserInteractionEnabled = false
        let y : CGFloat = 10.0
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            self.controlPointView.center.y += y
            self.resultView.alpha = 0.0
        }) { (_) in
            UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 0.15, initialSpringVelocity: 5.5, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                self.positionControlPoint()
            }, completion: { (_) in
                if self.isExpanded{
                    if let delegate = self.delegate{
                        delegate.didCollapse(elasticView: self)
                    }
                }
                self.isExpanded = false
                self.stopBouncing()
                self.isUserInteractionEnabled = true
                self.pan.isEnabled = true
                self.updateHeight()
            })
        }
    }
    
    func expandView(){
        startBouncing()
        self.isUserInteractionEnabled = false
        let y : CGFloat = 30.0
        let controlHeight = Sizes.expandedViewHeight
        let sideHeight = controlHeight - Sizes.controlAndSidePointDifference
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
            self.controlPointView.center.y = controlHeight + y
            self.controlPointView.center.x = self.frame.midX
            self.leftPointView.center.y = !self.isExpanded ? (sideHeight + y) : sideHeight
            self.rightPointView.center.y = !self.isExpanded ? (sideHeight + y) : sideHeight
            self.resultView.alpha = 1.0
        }) { (_) in
            UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 0.15, initialSpringVelocity: 5.5, options: UIViewAnimationOptions.allowAnimatedContent, animations: {
                self.controlPointView.center.y -= y
                self.leftPointView.center.y -= !self.isExpanded ? y : 0
                self.rightPointView.center.y -= !self.isExpanded ? y : 0
            }, completion: { (_) in
                self.isExpanded = true
                self.stopBouncing()
                self.isUserInteractionEnabled = true
                self.pan.isEnabled = true
                self.updateHeight()
            })
        }
    }
    
    //MARK: - Helper methods
    func bounceLayer(){
        elasticShapeLayer.path = pathForElasticShapeFor(controlPoint: (controlPointView.layer.presentation()?.position)!)
    }
    
    func startBouncing(){
        displayLink.isPaused = false
    }
    
    func stopBouncing(){
        displayLink.isPaused = true
    }
    
    private func updateHeight(){
        var frame = self.frame
        frame.size.height = controlPointView.frame.maxY
        self.frame = frame
    }
}
