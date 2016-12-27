//
//  ViewController.swift
//  Cat Gallery
//
//  Created by Steven Hurtado on 12/7/16.
//  Copyright © 2016 Steven Hurtado. All rights reserved.
//

import UIKit

extension UIView
{
    func shake()
    {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

class ViewController: UIViewController
{
    
    @IBOutlet weak var actInd: UIActivityIndicatorView!

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var catLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var grabView: UIView!
    @IBOutlet weak var grabBtn: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.actInd.stopAnimating()
        
        self.titleLabel.layer.masksToBounds = true
        self.titleLabel.layer.cornerRadius = 5
        
        self.grabView.layer.cornerRadius = 5
        self.grabBtn.shake()
    }
    
    @IBAction func grabImage(_ sender: Any)
    {
        setUIEnabled(false)
        
        //animate alpha of image; fade out
        UIView.animate(withDuration: 0.4, animations:
            {
                self.imgView.alpha = 0
        })
        
        self.actInd.startAnimating()
        
        getImageFromFlickr()
    }
    
    private func setUIEnabled(_ enabled: Bool)
    {
        titleLabel.isEnabled = enabled
        grabBtn.isEnabled = enabled
        
        if enabled
        {
            grabBtn.alpha = 1.0
        }
        else
        {
            grabBtn.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
    
    private func getImageFromFlickr()
    {
        
        let methodParameters =
        [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request)
        {
            (data, response, error) in
            
            func displayError(_ error: String)
            {
                print(error)
                print("URL at time of error: \(url)")
                performUIUpdatesOnMain
                {
                    self.setUIEnabled(true)
                }
            }
            
            
            /* GUARD: Was there an error? */
            guard (error == nil)
                else
            {
                displayError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299
                else
            {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data
                else
            {
                displayError("No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do
            {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            }
            catch
            {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus
                else
            {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]]
                else
            {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                return
            }
            
            // select a random photo
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
            let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
            
            /* GUARD: Does our photo have a key for 'url_m'? */
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String
                else
            {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                return
            }
            
            // if an image exists at the url, set the image and title
            let imageURL = URL(string: imageUrlString)
            if let imageData = try? Data(contentsOf: imageURL!)
            {
                performUIUpdatesOnMain
                {
                    self.setUIEnabled(true)
                    
                    self.imgView.image = UIImage(data: imageData)
                    
                    //animate alpha of image; fade out
                    UIView.animate(withDuration: 0.4, animations:
                        {
                            self.imgView.alpha = 1
                    })
                    
                    self.actInd.stopAnimating()
                    self.grabBtn.shake()
                    
                    self.titleLabel.text = photoTitle ?? "(Untitled)"
                }
            }
            else
            {
                displayError("Image does not exist at \(imageURL)")
            }
        }
        
        // start the task!
        task.resume()
    }

    private func escapedParameters(_ parameters: [String:AnyObject]) -> String
    {
        
        if parameters.isEmpty
        {
            return ""
        }
        else
        {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters
            {
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

