//
//  WebViewController.swift
//  Assignment 9
//
//  Created by Jason Michael Miletta on 4/15/15.
//  Copyright (c) 2015 Jason Michael Miletta. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var urlString: String?
    
    func configureView() {
        // Update the user interface for the detail item.
        if let url = urlString{
            webView.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
