//
//  Util.swift
//  HackerNews
// TODO fix data unwrapping of optional value

import UIKit

func makeRequest<T>(urlPath: String, handler: T -> Void) {
    let url = NSURL(string: urlPath)
    let request = NSURLRequest(URL: url!)
    let queue = NSOperationQueue.currentQueue()
    
    NSURLConnection.sendAsynchronousRequest(request, queue: queue!) { (_, data, error) -> Void in
        if error != nil {
            print(error!.localizedDescription)
        }
        
        if let data = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as? T {
            handler(data)
        }
    }
}
