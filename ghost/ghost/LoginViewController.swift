//
//  ViewController.swift
//  ghost
//
//  Created by John Clarke on 6/1/16.
//  Copyright © 2016 hck. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, SignupControllerDelegate {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var userID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        
        // let signup = UIAlertController(title: "Congratulations", message: "Successful signup!", preferredStyle: UIAlertControllerStyle.Alert)
        // let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        // signup.addAction(action)
        //if userID != "" {
        //    self.presentViewController(signup, animated: true, completion: nil)
        //}
    }
    
    override func viewWillAppear(animated: Bool) {
        print("Login View Controller: " + userID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // after entering login parameters, user clicks "login" button
    @IBAction func login(sender: AnyObject) {
        //  DATA VALIDATION
        
        // take in username and password, trim whitespace and newline characters
        let usernameText = username.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        let passwordText = password.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        // username range: 5-20 characters
        // password range: 8-20 characters
        let pLo = 8
        let pHi = 20
        let uLo = 5
        let uHi = 20
        
        // in the event of a validation failure, a UIAlertAction will present itself and clear the username and password fields
        var message = ""
        
        if (!Validation.isAlphaNumeric(usernameText) || !Validation.isInRange(usernameText, lo: uLo, hi: uHi)) {
            message += "Please be sure your username is alphanumeric and within 5 and 20 characters.\n"
        }
        
        if (!Validation.isAlphaNumeric(passwordText) || !Validation.isInRange(passwordText, lo: pLo, hi: pHi)) {
            message += "Please be sure your password is alphanumeric and within 8 and 20 characters.\n"
        }
        
        if (message.characters.count > 0) {
            let loginIssue = UIAlertController(title: "Login Issue", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            loginIssue.addAction(action)
            self.presentViewController(loginIssue, animated: true, completion: { () -> Void in
                self.username.text = ""
                self.password.text = ""
            })
        } else {
            let http = HTTPRequests(host: "localhost", port: "5000", resource: "login", params: ["username": usernameText, "password" : passwordText])
            http.POST({ (json) -> Void in
                // ISSUE: in success = 0 I have to cast anyobject ostring, but in success = 1, I convert to string
                // essentially why is the type inference different for what is essentially the same thing returned by api?
                let success = json["success"] as! Int
                let data = json["data"] as! [String:AnyObject]
                if success == 1 {
                    let userID = (data["user_id"]?.stringValue)!
                    NSOperationQueue.mainQueue().addOperationWithBlock { // must call this on main thread because the callback from http post is running
                        self.userID = userID
                        self.username.text = ""
                        self.password.text = ""
                        self.performSegueWithIdentifier("to-main", sender: self)
                    }
                } else {
                    let error = data["error"] as! String
                    let loginAlert = UIAlertController(title: "Login Issue", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    let loginAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    loginAlert.addAction(loginAction)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.presentViewController(loginAlert, animated: true, completion: { () -> Void in
                            self.username.text = ""
                            self.password.text = ""
                        })
                    }
                }
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "to-main" {
            let destination = segue.destinationViewController as! MainTableViewController
            destination.userID = self.userID
        }
        if segue.identifier == "to-signup" {
            let destination = segue.destinationViewController as! SignupViewController
            destination.delegate = self
        }
    }
    
    func grabUserID(id: String) {
        self.userID = id
    }
}