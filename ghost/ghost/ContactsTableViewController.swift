//
//  ContactsTableViewController.swift
//  ghost
//
//  Created by John Clarke on 7/6/16.
//  Copyright © 2016 hck. All rights reserved.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {
    
    var userID: String = ""
    var contacts: Array<String> = Array <String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        
        // load all the contacts into an array
        let resource: String = userID + "/" + "contact"
        let http = HTTPRequests(host: "localhost", port: "5000", resource: resource)
        http.GET({ (json) -> Void in
            let success = json["success"] as! Int
            if success == 1 {
                let data = json["data"] as! [String:AnyObject]
                let contactsDict = data["contacts"] as! [String:String]
                let contactsList = contactsDict.values
                for contact in contactsList {
                    self.contacts.append(contact)
                }
                self.doTableRefresh()
            } else {
                // let data = json["data"] as! [String:AnyObject]
                // let error = data["error"] as! String
            }
        })
        print(self.contacts)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        print("Contacts Table View Controller: " + userID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doTableRefresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            return
        })
    }
    
    // a function for quitting on the contacts page, if we implement a quit button
    //    @IBAction func quit(sender: AnyObject) {
    //        self.dismissViewControllerAnimated(false, completion: nil)
    //        self.parentViewController?.dismissViewControllerAnimated(false, completion: nil)
    //    }
    
    
    @IBAction func addContact(sender: AnyObject) {
        let addAlert = UIAlertController(title: "Add Contact", message: "Enter a username to add to you contacts list", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Submit", style: .Default, handler: { (action:UIAlertAction) -> Void in
            let username = (addAlert.textFields!.first?.text)!
            let validator = Validation()
            
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
                let signupIssue = UIAlertController(title: "Signup Issue", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                signupIssue.addAction(action)
                self.presentViewController(signupIssue, animated: true, completion: nil)
            } else {
                // Critical importance: pass callbacks to asychronous tasks to gather the data
                let resource: String = self.userID + "/contact"
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
        })
        
        addAlert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        addAlert.addAction(action)
        self.presentViewController(addAlert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.contacts.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(self.contacts)
        let cell = tableView.dequeueReusableCellWithIdentifier("contact-cell", forIndexPath: indexPath)
        // Configure the cell...
        cell.textLabel?.text = self.contacts[indexPath.item]
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}