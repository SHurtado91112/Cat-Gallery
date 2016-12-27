//
//  Constants.swift
//  Cat Gallery
//
//  Created by Steven Hurtado on 12/7/16.
//  Copyright © 2016 Steven Hurtado. All rights reserved.
//

import Foundation

struct Constants
{
    
    // MARK: Flickr
    struct Flickr
    {
        static let APIBaseURL = "https://api.flickr.com/services/rest/"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys
    {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues
    {
        static let APIKey = "a0d784e5452bc9d570155ad413be1949"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "149962325-72157674305034474"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys
    {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues
    {
        static let OKStatus = "ok"
    }
}
