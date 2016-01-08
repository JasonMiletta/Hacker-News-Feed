//
//  DetailViewController.swift
//  Assignment 9
//
//  Created by Jason Michael Miletta on 4/15/15.
//  Copyright (c) 2015 Jason Michael Miletta. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var webViewController: WebViewController? = nil
    var comments = [Comment]()
    
    var detailItem: Story? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: Story = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.title
            }
            loadComments()
        }
    }
    
    func loadComments() {
        let urlPath2 = "https://hacker-news.firebaseio.com/v0/item"
        
        let storyComments = detailItem?.topLevel
        comments = []
        
            for i in storyComments! {
                makeRequest("\(urlPath2)/\(i).json") { (data: [String: AnyObject]) -> Void in
                    
                    let id = data["id"] as! Int
                    let type = data["type"] as! String
                    
                    if let by = data["by"] as? String {
                    
                        if let text = data["text"] as? String{
                    
                            let time = data["time"] as! Int
                    
                            var comments = [Int]()
                            var url = ""
                    
                            if let topLevel = data["kids"] as? [Int] {
                                comments = topLevel
                            }
                    
                            if let link = data["url"] as? String {
                                url = link
                            }
                    
                            let c = Comment(id: id, type: type, by: by, kids: comments, text: (text + "\nBy: " + by), time: time)
                    
                            self.comments.append(c)
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                }
            }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let backgroundLabel: UILabel! = UILabel()
        backgroundLabel.text = "No Comments"
        backgroundLabel.numberOfLines = 0
        backgroundLabel.textAlignment = NSTextAlignment.Center
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.tableView.backgroundView = backgroundLabel
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.title = detailItem?.title
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loadWebPage(sender: UIBarButtonItem) {
        if let _ = detailItem?.url{
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWebView" {
            if let urlString = detailItem?.url {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! WebViewController
                controller.urlString = urlString
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
        return comments.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as UITableViewCell
        
        let object = comments[indexPath.row] as Comment
        cell.textLabel!.text = object.text
        cell.textLabel!.numberOfLines = 25
        cell.textLabel!.sizeToFit()
        
        cell.textLabel!.font = UIFont(name: "Helvetica", size: 8)
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            comments.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

