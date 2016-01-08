//
//  MasterViewController.swift
//  Assignment 9
//
//  Created by Jason Michael Miletta on 4/15/15.
//  Copyright (c) 2015 Jason Michael Miletta. All rights reserved.
//

import UIKit

class Story {
    var id: Int
    var title: String
    var author: String
    var score: Int
    var url: String
    var submitted: Int
    var topLevel: [Int]
    
    init(id: Int, title: String, author: String,
        score: Int, url: String, submitted: Int, topLevel: [Int]) {
            self.id = id
            self.title = title
            self.author = author
            self.score = score
            self.url = url
            self.submitted = submitted
            self.topLevel = topLevel
    }
}

class Comment {
    var id: Int
    var type: String
    var by: String
    var kids: [Int]
    var text: String
    var time: Int
    
    init(id: Int, type: String, by: String, kids: [Int], text: String, time: Int){
        self.id = id
        self.type = type
        self.by = by
        self.kids = kids
        self.text = text
        self.time = time
    }
    
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Story]()

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let control = UIRefreshControl()
        control.backgroundColor = UIColor.orangeColor()
        
        control.addTarget(self, action: "loadStories", forControlEvents: UIControlEvents.ValueChanged)
        
        self.refreshControl = control
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        let backgroundLabel: UILabel! = UILabel()
        backgroundLabel.text = "Pull down to Update"
        backgroundLabel.numberOfLines = 0
        backgroundLabel.textAlignment = NSTextAlignment.Center
        self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        self.tableView.backgroundView = backgroundLabel
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func loadStories() {
        let urlPath1 = "https://hacker-news.firebaseio.com/v0/topstories.json"
        let urlPath2 = "https://hacker-news.firebaseio.com/v0/item"
        
        objects = []
        
        makeRequest(urlPath1) { (topstories: [Int]) -> Void in
            for i in topstories {
                makeRequest("\(urlPath2)/\(i).json") { (data: [String: AnyObject]) -> Void in
                    
                    let id = data["id"] as! Int
                    let score = data["score"] as! Int
                    let title = data["title"] as! String
                    let author = data["by"] as! String
                    let submitted = data["time"] as! Int
                    
                    var comments = [Int]()
                    var url = ""
                    
                    if let topLevel = data["kids"] as? [Int] {
                        comments = topLevel
                    }
                    
                    if let link = data["url"] as? String {
                        url = link
                    }
                    
                    let s = Story(id: id, title: title, author: author, score: score, url: url, submitted: submitted, topLevel: comments)
                    
                    self.objects.append(s)
                    
                    if (self.objects.count == topstories.count) {
                        self.objects.sortInPlace { (a: Story, b: Story) -> Bool in
                            topstories.indexOf(a.id) < topstories.indexOf(b.id)
                        }
                        
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    }
                }
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as Story
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if objects.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        }
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let object = objects[indexPath.row] as Story
        let by = "By " + object.author
        let score = String(object.score) + " Points"
        let comments = String(object.topLevel.count) + " comments"
        let detail = by + " - " + score + " - " + comments
        cell.textLabel!.text = object.title
        cell.detailTextLabel!.text = detail
        cell.textLabel!.font = UIFont(name: "Helvetica", size: 12)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

