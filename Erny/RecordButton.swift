//
//  RecordButton.swift
//  Contactis_Challenge
//
//  Created by ARKALYK AKASH on 7/30/17.
//  Copyright © 2017 ARKALYK AKASH. All rights reserved.
//
import UIKit

class RecordButton: UIButton {
    
    //MARK: - Properties
    lazy var backgroundView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.customGray
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var shadowView : UIView = {
        let view = UIView()
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.customGray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        view.layer.shadowRadius = 2
        view.isUserInteractionEnabled = false
        return view
    }()
    
    lazy var iconImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "mic")
        return imageView
    }()
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup(){
        self.tintColor = .white
        self.clipsToBounds = false
        self.addSubview(shadowView)
        shadowView.addSubview(backgroundView)
        backgroundView.addSubview(iconImageView)
        updateConstraints()
    }
    
    //MARK: - Setter methods
    override func setImage(_ image: UIImage?, for state: UIControlState) {
        iconImageView.image = UIImage(named: "1")
    }
    
    //MARK: - Constraints
    override func updateConstraints() {
        super.updateConstraints()
        shadowView.fillSuperview()
        backgroundView.fillSuperview(left: 2, right: 2, top: 2, bottom: 2)
        backgroundView.layer.cornerRadius = backgroundView.frame.size.height/2.0
        iconImageView.anchorInCenter(width: 24, height: 24)
    }
}
