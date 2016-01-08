//
//  ViewController.swift
//  ActiveLabelDemo
//
//  Created by Johannes Schickling on 9/4/15.
//  Copyright © 2015 Optonaut. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let label = ActiveLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        label.username = "ButregenyoYavrusu"
        label.usernameEnabled = true
        label.usernameAsTitle = false
        
        let 😁 = [(code:"100" , event_doc_id:"768788872"),(code:"430" , event_doc_id:"52023405234")]
        
        label.eventCodeEnabled = true
        label.eventArray = 😁
        
        label.text = "This is a post with #multiple #hashtags and a @userhandle. £1003 £100 101 £430 665 Links are also supported like this one: http://optonaut.co."
        label.numberOfLines = 0
        label.lineSpacing = 4
        
        label.textColor = UIColor(red: 102.0/255, green: 117.0/255, blue: 127.0/255, alpha: 1)
        label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
        label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
        label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
        
        label.handleMentionTap { self.alert("Mention", message: $0) }
        label.handleHashtagTap { self.alert("Hashtag", message: $0) }
        label.handleURLTap { self.alert("URL", message: $0.description) }
        label.handleUsernameTap { self.alert("Username", message: $0) }
        label.handleEventCodeTap { self.alert("Selected Event's Doc ID:", message: $0.event_doc_id) }
        
        label.frame = CGRect(x: 20, y: 40, width: view.frame.width - 40, height: 300)
        view.addSubview(label)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alert(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        vc.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(vc, animated: true, completion: nil)
    }

}

