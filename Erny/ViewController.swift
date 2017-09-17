//
//  ViewController.swift
//  Erny
//
//  Created by Admin on 9/16/17.
//  Copyright © 2017 AAkash. All rights reserved.
//

import UIKit
import EasyPeasy
import Alamofire

class ViewController: UIViewController {
    
    let screenBounds = UIScreen.main.bounds
    
    lazy var searchTextView : UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.yellow
        textView.font = UIFont(name: "", size: 26)
        return textView
    }()
    
    lazy var submitButton : UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(getAnswer), for: .touchUpInside)
        button.backgroundColor = .green
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
    }
    
    private func setup() {
    
        self.view.addSubview(searchTextView)
        self.view.addSubview(submitButton)
        
        searchTextView <- [
            Top(100),
            Left(50),
            Right(50),
            Bottom(100)
        ]
        
        submitButton <- [
            Top(0).to(searchTextView),
            Left(50),
            Right(50),
            Height(50)
        ]
    }
    
    func getAnswer() {
        
        print("Test")
        
        let url = URL(string: "http://127.0.0.1:8000/api/Batman/")
        
        Alamofire.request("http://127.0.0.1:8000/api/Batman/").responseJSON { response in
            debugPrint(response)
            
            if let json = response.result.value as? [[String: Any]] {
                if let first = json.first {
                    let answer = first["answer"] as? String
                    self.searchTextView.text = answer ?? "Sorry, can't find your question"
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

