//
//  MovieDetailsViewController.swift
//  rotten tomatoes
//
//  Created by iKreb Retina on 8/29/15.
//  Copyright (c) 2015 krze. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"]  as? String
        
//        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
//        backgroundImageView.setImageWithURL(url)
        
        // Image downloading block
        // Initial variables. Uncomment the gibberish thumbImageURL and comment the working thumbImageURL to test failure state.
        //        let thumbImageURL = NSURL(string: "http://www.skjdhghdsljkfghdsljkfghsldkjfghieusr.com/dkfgjhsdkjfg.jpg")!
        let thumbImageURL = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        var hiResImageURL = NSURL(string: movie.valueForKeyPath("posters.original") as! String)!
        
        // hack to actually get the hiResImage
        var hackhiResImageURL = "\(hiResImageURL)"
        var range = hackhiResImageURL.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            hackhiResImageURL = hackhiResImageURL.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
            hiResImageURL = NSURL(string: hackhiResImageURL)!
        }
        
        let thumbImageURLRequest = NSURLRequest(URL: thumbImageURL)
        let hiResImageURLRequest = NSURLRequest(URL: hiResImageURL)
        
        let placeholderImage = UIImage(named: "placeholder_image")
        
        // Start of the request. This will initially set the posterview with the existing placeholder.
        backgroundImageView.setImageWithURLRequest(thumbImageURLRequest, placeholderImage: placeholderImage, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
            // If the request for the thumbnail is successful, sets the downloaded image as the poster view. Holds the image in a variable for the subsequent request to download the hi-res image
            let downloadedThumbImage = image
            self.backgroundImageView.image = downloadedThumbImage
            // Initiates another request to get the full image once the thumbnail is downloaded
            self.backgroundImageView.setImageWithURLRequest(hiResImageURLRequest, placeholderImage: downloadedThumbImage, success: { (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
                // If the request for the full image is successful, sets the downloaded full image as the poster view.
                let downloadedHiResImage = image
                self.backgroundImageView.image = downloadedHiResImage
                }, failure: { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                    // If the request for the full image fails, it sets the poster image back as the cached thumbnail
                    self.backgroundImageView.image = downloadedThumbImage
            })
            
            }) { (request: NSURLRequest!, response: NSHTTPURLResponse!, error: NSError!) -> Void in
                // If the request for the thumbnail fails, set it as the loading image placeholder
                self.backgroundImageView.image = placeholderImage
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
