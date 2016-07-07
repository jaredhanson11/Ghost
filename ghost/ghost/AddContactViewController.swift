//
//  AddContactViewController.swift
//  ghost
//
//  Created by John Clarke on 7/6/16.
//  Copyright © 2016 hck. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController {

    var userID: String = ""
    @IBOutlet weak var usernameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        print(self.userID)
    }
    
    @IBAction func submitContact(sender: AnyObject) {
        
        let validator = Validation() // in swift you don't have to import user-made classes

        let username: String = usernameText.text!
        
        // username range: 5-20 characters
        // password range: 8-20 characters
        let uLo = 5
        let uHi = 20
        
        // in the event of a validation failure, a UIAlertAction will present itself and clear the username and password fields
        var message = ""
        
        if (!validator.isAlphaNumeric(username) || !validator.isInRange(username, lo: uLo, hi: uHi)) {
            message += "Please be sure the username is alphanumeric and within 5 and 20 characters.\n"
            print(message)
        }
        
        if (message.characters.count > 0) {
            usernameText.text = ""
            let signupIssue = UIAlertController(title: "Signup Issue", message: message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
            signupIssue.addAction(action)
            self.presentViewController(signupIssue, animated: true, completion: nil)
        } else {
            // Critical importance: pass callbacks to asychronous tasks to gather the data
            let resource: String = userID + "/contact"
            let http = HTTPRequests(host: "localhost", port: "5000", resource: resource, params: ["username" : username])
            http.POST({ (json) -> Void in
                let success = json["success"] as! Int
                let data = json["data"] as! [String:AnyObject]
                if success == 1 {
                    let message: String = "You successfully added " + username + "!"
                    let contactAddSuccess = UIAlertController(title: "Add Contact Success", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    contactAddSuccess.addAction(action)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(contactAddSuccess, animated: true, completion: nil)
                    }
                } else {
                    let error = data["error"] as! String
                    // issue
                    let contactAddIssue = UIAlertController(title: "Add Contact Issue", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    contactAddIssue.addAction(action)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.presentViewController(contactAddIssue, animated: true, completion: nil)
                    }
                }
            })
        }
        
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
