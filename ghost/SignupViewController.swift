//
//  SignupViewController.swift
//  ghost
//
//  Created by John Clarke on 6/1/16.
//  Copyright © 2016 hck. All rights reserved.
//

import UIKit

protocol SignupControllerDelegate: class {
    func grabUserID(id: String)
}

class SignupViewController: UIViewController {
    
    var delegate: SignupControllerDelegate?
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Signup"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signup(sender: AnyObject) {
        //  DATA VALIDATION
        let validator = Validation() // in swift you don't have to import user-made classes
        
        let usernameText: String = username.text!
        let passwordText: String = password.text!
        
        // username range: 5-20 characters
        // password range: 8-20 characters
        let pLo = 8
        let pHi = 20
        let uLo = 5
        let uHi = 20
        
        // in the event of a validation failure, a UIAlertAction will present itself and clear the username and password fields
        var message = ""
        
        if (!validator.isAlphaNumeric(usernameText) || !validator.isInRange(usernameText, lo: uLo, hi: uHi)) {
            message += "Please be sure your username is alphanumeric and within 5 and 20 characters.\n"
        }
        
        if (!validator.isAlphaNumeric(passwordText) || !validator.isInRange(passwordText, lo: pLo, hi: pHi)) {
            message += "Please be sure your password is alphanumeric and within 8 and 20 characters.\n"
        }
        
        if (message.characters.count > 0) {
            username.text = ""
            password.text = ""
            let signupIssue = UIAlertController(title: "Signup Issue", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            signupIssue.addAction(action)
            self.presentViewController(signupIssue, animated: true, completion: nil)
        } else {
            let http = HTTPRequests(host: "localhost", port: "5000", resource: "signup", params: ["username": usernameText, "password" : passwordText])
            // Critical importance: pass callbacks to asychronous tasks to gather the data
            http.POST({ (json) -> Void in
                // ISSUE: in success = 0 I have to cast anyobject ostring, but in success = 1, I convert to string
                // essentially why is the type inference different for what is essentially the same thing returned by api?
                let success = json["success"] as! Int
                let data = json["data"] as! [String:AnyObject]
                if success == 1 {
                    let userID = (data["user_id"]?.stringValue)!
                    self.delegate!.grabUserID(userID)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let username = data["username"] as! String
                        let message: String = "Successful signup with \(username)!"
                        let signupSuccessAlert = UIAlertController(title: "Signup Success", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let signupSuccessAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        signupSuccessAlert.addAction(signupSuccessAction)
                        self.presentViewController(signupSuccessAlert, animated: true, completion: nil)
                        // ADD with a race condition, literally need to delay this a split sec
                        // self.navigationController?.popViewControllerAnimated(true)
                    }
                } else {
                    let error = data["error"] as! String
                    // issue
                    let signupIssue = UIAlertController(title: "Signup Issue", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    signupIssue.addAction(action)
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.presentViewController(signupIssue, animated: true, completion: nil)
                    }
                }
            })
            
        }
    }
}
