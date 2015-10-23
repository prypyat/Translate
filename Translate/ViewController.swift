//
//  ViewController.swift
//  Translate
//
//  Created by Robert O'Connor on 16/10/2015.
//  Copyright © 2015 WIT. All rights reserved.
//  Kivilcim Celik
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textToTranslate: UITextView!
    @IBOutlet weak var translatedText: UITextView!
    let PLACEHOLDER = "<Text to Translate>"
    
    //var data = NSMutableData()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        placeholder(textToTranslate!, placeholder: PLACEHOLDER)

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func translate(sender: AnyObject)
    {
        
        let str = textToTranslate.text
        let escapedStr = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let langStr = ("en|fr").stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let urlStr:String = ("http://api.mymemory.translated.net/get?q="+escapedStr!+"&langpair="+langStr!)
        
        let url = NSURL(string: urlStr)
        
        let request = NSURLRequest(URL: url!)// Creating Http Request
        
        //var data = NSMutableData()var data = NSMutableData()
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        var result = "<Translation Error>"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
        {
                response, data, error in
            
            indicator.stopAnimating()
            
            if let httpResponse = response as? NSHTTPURLResponse
            {
                if(httpResponse.statusCode == 200)
                {
                    
                    let jsonDict: NSDictionary!=(try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    
                    if(jsonDict.valueForKey("responseStatus") as! NSNumber == 200)
                    {
                        let responseData: NSDictionary = jsonDict.objectForKey("responseData") as! NSDictionary
                        
                        result = responseData.objectForKey("translatedText") as! String
                    }
                }
                
                self.translatedText.text = result
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        if textView == textToTranslate && textView.text == PLACEHOLDER
        {
            killPlaceholder(textView)
        }
        return true
    }
    
    func killPlaceholder(textView: UITextView)
    {
        dispatch_async(dispatch_get_main_queue(),
                       {textView.selectedRange = NSMakeRange(0, 0);}
                      )
    }
    
    func placeholder (textView: UITextView, placeholder: String)
    {
        textView.textColor = UIColor.lightGrayColor()
        textView.text = placeholder
    }
    
    func actualText(textView: UITextView)
    {
        textView.textColor = UIColor.darkTextColor()
        textView.alpha = 1.0
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    {
    
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        
        if newLength > 0
        {
            if textView == textToTranslate && textView.text == PLACEHOLDER
            {
                if text.utf16.count == 0
                {
                    return false
                }
                
                actualText(textView)
                textView.text = ""
            }
            return true
        }
       
        else
        {
            placeholder(textView, placeholder: PLACEHOLDER)
            killPlaceholder(textView)
            return false
        }
    }
    
}

