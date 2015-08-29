//
//  MoviesViewController.swift
//  rotten tomatoes
//
//  Created by iKreb Retina on 8/27/15.
//  Copyright (c) 2015 krze. All rights reserved.
//

import UIKit
import SwiftSpinner

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let tomatoesMoviesURL = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
//        let request = NSURLRequest(URL: tomatoesMoviesURL)
//        
//        SwiftSpinner.show("Loading movies...")
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
//            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
//            
//            if let json = json {
//                self.movies = json["movies"] as? [NSDictionary]
//                self.tableView.reloadData()
//            }
//        }
//        SwiftSpinner.hide()
        refresh(self)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        
        // Pull to Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
    }
    
    func showSpinner(spinnerText: String){
        SwiftSpinner.show(spinnerText)
    }
    func hideSpinner() {
        SwiftSpinner.hide()
    }
    
    func refresh(sender:AnyObject) {
        let tomatoesMoviesURL = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
        let request = NSURLRequest(URL: tomatoesMoviesURL)
        
        showSpinner("Loading movies...")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
            
            if let json = json {
                self.movies = json["movies"] as? [NSDictionary]
                // For the sake of demonstrating the spinner, this timer sleeps for 1 second to emulate downloading network data before reloading the table data. Comment out this line and uncomment the hideSpinner() after it to remove the demo.
                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "hideSpinner", userInfo: nil, repeats: false)
                //hideSpinner()
                self.tableView.reloadData()
            }
        }

        
        self.refreshControl?.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        var navigationController = self.navigationController
        var navigationBar = navigationController?.navigationBar
        
        // Navbar Apearance Properties
        navigationBar?.barStyle = UIBarStyle.Black
        navigationBar?.tintColor = UIColor.orangeColor()
        navigationBar?.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir-Heavy", size:20)!]
        
        // Navbar Behavior Properties
        navigationController?.hidesBarsOnSwipe = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
            
        } else {
            return 0
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterView.setImageWithURL(url)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        let movie = movies![indexPath.row]
        
        let moviesDetailViewController = segue.destinationViewController as! MovieDetailsViewController
        
        moviesDetailViewController.movie = movie

    }

}
