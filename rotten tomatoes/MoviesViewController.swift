//
//  MoviesViewController.swift
//  rotten tomatoes
//
//  Created by iKreb Retina on 8/27/15.
//  Copyright (c) 2015 krze. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
    @IBOutlet weak var refreshErrorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshErrorView.alpha = 0.0
        
        // Set up pull to refresh and refresh on load
        setupRefreshControl()
        refresh(self)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func setupRefreshControl() {
        // Pull to Refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: [NSFontAttributeName: UIFont(name: "Avenir", size:12)!])
        self.refreshControl.tintColor = UIColor.orangeColor()
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)

    }
    
    func displayRefreshError() {
        UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: { self.refreshErrorView.alpha = 1.0 }, completion: {(finished: Bool) -> Void in
            UIView.animateWithDuration(0.5, delay: 3.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { self.refreshErrorView.alpha = 0.0 }, completion: nil)
        })
    }
    
    func refresh(sender:AnyObject) {
        let tomatoesMoviesURL = NSURL(string: "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json")!
//        let tomatoesMoviesURL = NSURL(string: "https://www.dfkljghsdflkghdsflkgjsdfgsdf.com")!
        let request = NSURLRequest(URL: tomatoesMoviesURL)
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
//            println("Response: \(response)\n" + "Data: \(data)\n" + "Error: \(error)\n")
            
            if error != nil {
                self.refreshControl?.endRefreshing()
                self.displayRefreshError()
            } else {
                println("No errors here!")
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }

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
        
        let thumbImageURL = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
//        let thumbImageURL = NSURL(string: "http://www.skjdhghdsljkfghdsljkfghsldkjfghieusr.com/dkfgjhsdkjfg.jpg")!
        let thumbImageURLRequest = NSURLRequest(URL: thumbImageURL)
        let loadingImage = UIImage(named: "LoadingPhoto")
//        cell.posterView.setImageWithURL(url)
        cell.posterView.setImageWithURLRequest(thumbImageURLRequest, placeholderImage: loadingImage, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
            cell.posterView.image = image
            println("Success!")
            println(response)
            }) { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
            cell.posterView.image = loadingImage
            println("Failure!!")
            println("\(error)\n")
            println(response)
        }
        
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
