//
//  ContactsTableViewController.swift
//  ghost
//
//  Created by John Clarke on 7/6/16.
//  Copyright © 2016 hck. All rights reserved.
//

import UIKit

class ContactsTableViewController: UITableViewController {
    
    var userID: String = ""
    
    // This list stores all the contacts for which is_contact = 1 and whose usernames
    // should thus be displayed in the tableview
    var contactsIsContact = Cache.sharedInstance.contactsCache
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        // get real contacts: is_contact = 1
        contactsIsContact = Cache.sharedInstance.getRealContacts(contactsIsContact)
        print(contactsIsContact.count)
        doTableRefresh()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        print("Contacts Table View Controller: " + userID)
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------START: ADD CONTACT---------------------------------------------------
    
    @IBAction func addContact(sender: AnyObject) {
        let addAlert = UIAlertController(title: "Add Contact", message: "Enter a username to add to you contacts list", preferredStyle: .Alert)
        let action = UIAlertAction(title: "Submit", style: .Default, handler: { (action:UIAlertAction) -> Void in
            let username = (addAlert.textFields!.first?.text)!
            
            // username range: 5-20 characters
            // password range: 8-20 characters
            let uLo = 5
            let uHi = 20
            
            var message = ""
            
            if (!Validation.isAlphaNumeric(username) || !Validation.isInRange(username, lo: uLo, hi: uHi)) {
                message += "Please be sure the username is alphanumeric and within 5 and 20 characters.\n"
            }
            
            if (message.characters.count > 0) {
                let addContactIssue = UIAlertController(title: "Add Contact Issue", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                addContactIssue.addAction(action)
                self.presentViewController(addContactIssue, animated: true, completion: nil)
            } else {
                // save to server: contact
                let resource: String = self.userID + "/contact"
                let http = HTTPRequests(host: "localhost", port: "5000", resource: resource, params: ["username" : username])
                http.POST({ (json) -> Void in
                    let success = json["success"] as! Int
                    let data = json["data"] as! [String:AnyObject]
                    if (success == 1) {
                        // save to cache: contact
                        let contact_id = data.keys.first!
                        let contactDict = data[contact_id] as! [String:AnyObject]
                        let isContact = String(contactDict["is_contact"]!) // by definition = 1
                        Cache.sharedInstance.addContactToCache(contact_id, contactUsername: username, isContact: isContact)
                        
                        let data = ["contact_username" : username, "is_contact" : isContact]
                        self.contactsIsContact.updateValue(data, forKey: contact_id)
                        
                        let message: String = "You successfully added " + username + "!"
                        let contactAddSuccess = UIAlertController(title: "Add Contact Success", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        contactAddSuccess.addAction(action)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.presentViewController(contactAddSuccess, animated: true, completion: { () -> Void in
                                self.doTableRefresh()
                            })
                        }
                    } else {
                        let error = data["error"] as! String
                        let contactAddIssue = UIAlertController(title: "Add Contact Issue", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        contactAddIssue.addAction(action)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
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
  
    
    //------------------------------END: ADD CONTACT---------------------------------------------------
    
    
    //------------------------------START: MISCELLANEOUS METHODS---------------------------------------------------
    
    // TODO: implement a UIAlertController class
    func addTextFieldToAlert(alert: UIAlertController, placeholder: String) {
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
            textField.placeholder = placeholder
        }
    }
    
    //------------------------------END: MISCELLANEOUS METHODS---------------------------------------------------
    
    
    //------------------------------START: TABLE METHODS---------------------------------------------------
    
    func doTableRefresh() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.tableView.reloadData()
        }
    }
    
    //------------------------------END: TABLE METHODS---------------------------------------------------
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsIsContact.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contact-cell", forIndexPath: indexPath)
        // Configure the cell...
        let key = Array(contactsIsContact.keys)[indexPath.item]
        let data = contactsIsContact[key] as! [String:AnyObject]
        let username = data["contact_username"] as! String
        cell.textLabel?.text = username
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            tableView.beginUpdates()
            let key = Array(Cache.sharedInstance.contactsCache.keys)[indexPath.row]
            // delete from both the virtual cache and the contacts array where is_contact=1 for all contacts
            Cache.sharedInstance.deleteContactFromCache(key)
            contactsIsContact.removeValueForKey(Array(contactsIsContact.keys)[indexPath.row])
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.endUpdates()
            let data = ["contact_id" : key]
            CoreDataController.sharedInstance.saveToCoreData("Contacts", data: data)
        }
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