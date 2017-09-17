//
//  SecondViewController.swift
//  Erny
//
//  Created by Admin on 9/17/17.
//  Copyright © 2017 AAkash. All rights reserved.
//

import UIKit
import Speech
import Neon
import Alamofire
import EasyPeasy
import KMPlaceholderTextView

class SecondViewController: UIViewController {
    
    let screenBounds = UIScreen.main.bounds

    lazy var searchTextView : UITextView = {
        let textView = UITextView()
        textView.textAlignment = .center
        textView.font = UIFont(name: "Carlito-Regular", size: 30)
        textView.textColor = UIColor.customGray
        textView.isEditable = false
        textView.text = "Building a better working world"
        textView.isSelectable = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    private lazy var elasticOvalView : ElasticOvalView = {
        let view = ElasticOvalView()
        view.delegate = self
        return view
    }()
    
    private lazy var recordButton : RecordButton = {
        let button = RecordButton()
        button.addTarget(self, action: #selector(recordButtonPressed), for: .touchDown)
        button.addTarget(self, action: #selector(recordButtonReleased), for: .touchUpInside)
        button.addTarget(self, action: #selector(recordButtonReleased), for: .touchUpOutside)
        return button
    }()
    
    lazy var instructionsLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    
    
    lazy var submitButton : SubmitButton = {
        let button = SubmitButton()
        button.setTitle("Submit", for: .normal)
        button.addTarget(self, action: #selector(callAnswer), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "Carlito", size: 20)
        return button
    }()
    
    lazy var picImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "down")
        return imageView
    }()
    
    var isRecording = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateTextFont()
    }
    
    func updateTextFont() {
        if (searchTextView.text.isEmpty || searchTextView.bounds.size.equalTo(CGSize.zero)) {
            return
        }
        
        let textViewSize = searchTextView.frame.size;
        let fixedWidth = textViewSize.width;
        let expectSize = searchTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT)));
        
        var expectFont = searchTextView.font;
        if (expectSize.height > textViewSize.height) {
            while (searchTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height > searchTextView.height) {
                expectFont = searchTextView.font!.withSize(searchTextView.font!.pointSize - 1)
                searchTextView.font = expectFont
            }
        }
        else {
            while (searchTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat(MAXFLOAT))).height < textViewSize.height) {
                expectFont = searchTextView.font;
                searchTextView.font = searchTextView.font!.withSize(searchTextView.font!.pointSize + 1)
            }
            searchTextView.font = expectFont;
        }
    }
    
    //MARK: - Initial setup
    private func setup(){
        self.view.backgroundColor = .white
        requestAccess()
        setupSubviews()
       
        for family: String in UIFont.familyNames
        {
            print("\(family)")
            for names: String in UIFont.fontNames(forFamilyName: family)
            {
                print("== \(names)")
            }
        }
        
        searchTextView <- [
            Top(100),
            Left(20),
            Right(20),
            Bottom(100)
        ]
        
        submitButton <- [
            Top(10).to(searchTextView),
            Left(screenBounds.width*0.1),
            Width(screenBounds.width*0.6),
            Height(50)
        ]
        
        recordButton <- [
            Top(10).to(searchTextView),
            Left(10).to(submitButton),
            Width(50),
            Height(50)
        ]
        
        picImageView <- [
            Top().to(elasticOvalView),
            CenterX().to(view),
            Width(16),
            Height(16)
        ]
        
        updateTextFont()
    }
    
    private func setupSubviews(){
        self.view.addSubview(searchTextView)
        self.view.addSubview(submitButton)
        view.addSubview(instructionsLabel)
        view.addSubview(elasticOvalView)
        view.addSubview(recordButton)
        view.addSubview(picImageView)
        updateViewConstraints()
    }
    
    //MARK: - Constraints
    override func updateViewConstraints() {
        super.updateViewConstraints()
        elasticOvalView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: Sizes.compressedViewHeight)
        elasticOvalView.updateConstraints()
        instructionsLabel.anchorInCenter(width: Sizes.screenWidth - 20.0, height: AutoHeight)
        recordButton.anchorToEdge(.bottom, padding: 20, width: Sizes.recordButtonWidth*0.87, height: Sizes.recordButtonWidth*0.87)
        recordButton.updateConstraints()
        submitButton.anchorToEdge(.bottom, padding: 20, width: screenBounds.width*0.6, height: Sizes.recordButtonWidth*0.87)
        submitButton.updateConstraints()
    }
    
    //MARK: - Button actions
    func recordButtonPressed(){
        self.recordButton.backgroundView.backgroundColor = .customPink
        isRecording = true
        startRecording()
        //elasticOvalView.compressView()
        instructionsLabel.text = Hints.stopInstructionText
        elasticOvalView.expressionText = Hints.expressionRecordingText
    }
    
    func recordButtonReleased(){
        isRecording = false
        self.recordButton.backgroundView.backgroundColor = .customGray
        elasticOvalView.expressionText = Hints.computingText
        instructionsLabel.text = Hints.computingInstructionText
        stopRecording()
        self.recordButton.isEnabled = false
    }
    
    //MARK: - Speech recognition
    private func startRecording(){
        self.elasticOvalView.expandView()
        searchTextView.isHidden = true 
        MySpeechRecognizer.shared.startRecordingWith { (expressionString) in
            OperationQueue.main.addOperation() { [unowned self] in
                if let expression = expressionString{
                    self.elasticOvalView.expressionText = "\(expression) = "
                    self.elasticOvalView.searchTextView.text = expression
                    self.getAnswer(text: expression)
                }else{
                    self.elasticOvalView.compressView()
                    self.searchTextView.isHidden = false
                    self.elasticOvalView.expressionText = Hints.errorText
                    self.instructionsLabel.text = Hints.errorInstructionText
                }
                self.isRecording = false
                self.recordButton.isEnabled = true
            }
        }
    }
    
    func callAnswer() {
        
        if let text = self.elasticOvalView.searchTextView.text {
            elasticOvalView.expressionText = "Processing..."
            getAnswer(text: text)
        }
    }
    
    func getAnswer(text: String) {
        
        let str = text.replacingOccurrences(of: " ", with: "20")
        
        Alamofire.request("http://127.0.0.1:8000/api/\(str)/").responseJSON { response in
            debugPrint(response)
            
            if let json = response.result.value as? [[String: Any]] {
                if let first = json.first {
                    let answer = first["answer"] as? String
                    self.searchTextView.text = answer ?? "Sorry, can't find your question"
                    self.updateTextFont()
                    self.elasticOvalView.expressionText = "Here what we could find for your question"
                    self.elasticOvalView.compressView()
                }
            } else {
                self.searchTextView.text = "Sorry, can't answer your question"
            }
        }
    }
    
    private func stopRecording(){
        MySpeechRecognizer.shared.audioEngine.stop()
        MySpeechRecognizer.shared.recognitionRequest?.endAudio()
    }
    
    func requestAccess(){
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized: break
            case .denied: print("User denied access to speech recognition")
            case .restricted: print("Speech recognition restricted on this device")
            case .notDetermined: print("Speech recognition not yet authorized")
            }
        }
    }
}

//MARK: - ElasticOvalView delegate
extension SecondViewController: ElasticOvalViewDelegate{
    func didCollapse(elasticView: ElasticOvalView) {
        if !isRecording{
            elasticView.expressionText = Hints.expressionPlaceHolderText
            instructionsLabel.text = Hints.recordInstructionText
        }
    }
}
