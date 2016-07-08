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
    
    // Core Data persistence array
    var contactsCache = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        print(contactsCache.count)
        
        // LOGIC: check if there's data stored in cache
        // if so, that means the app was loaded and all the data is in the cache
        // if not, perform HTTP request
        // UNLOAD CONTACTS FROM CACHE
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Contact")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            contactsCache = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
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
    
    func doTableRefresh() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.tableView.reloadData()
        }
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
            }
            
            if (message.characters.count > 0) {
                let addContactIssue = UIAlertController(title: "Add Contact Issue", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                addContactIssue.addAction(action)
                self.presentViewController(addContactIssue, animated: true, completion: nil)
            } else {
                // SAVE TO SERVER
                let resource: String = self.userID + "/contact"
                let http = HTTPRequests(host: "localhost", port: "5000", resource: resource, params: ["username" : username])
                http.POST({ (json) -> Void in
                    let success = json["success"] as! Int
                    let data = json["data"] as! [String:AnyObject]
                    if success == 1 {
                        // SAVE TO CACHE
                        let contact_id = Int(Array(data.keys)[0])!
                        self.saveContact(username, contactID: contact_id)
                        
                        let message: String = "You successfully added " + username + "!"
                        let contactAddSuccess = UIAlertController(title: "Add Contact Success", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        contactAddSuccess.addAction(action)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.presentViewController(contactAddSuccess, animated: true, completion: { () -> Void in
                                self.tableView.reloadData()
                            })
                        }
                    } else {
                        let error = data["error"] as! String
                        // issue
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
    
    func saveContact(contactUsername: String, contactID: Int) {
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Contact",
                                                        inManagedObjectContext:managedContext)
        let contact = NSManagedObject(entity: entity!,
                                     insertIntoManagedObjectContext: managedContext)
        contact.setValue(contactUsername, forKey: "contact_username")
        contact.setValue(contactID, forKey: "contact_id")
        do {
            try managedContext.save()
            contactsCache.append(contact)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.contactsCache.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contact-cell", forIndexPath: indexPath)
        // Configure the cell...
        cell.textLabel?.text = self.contactsCache[indexPath.item].valueForKey("contact_username") as? String
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