//
//  MainTableViewController.swift
//  ghost
//
//  Created by John Clarke on 6/10/16.
//  Copyright © 2016 hck. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {
    
    // userID string is passed to the Main Page where it can be used to query for data
    var userID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Main"
        
        // SAVE CONTACTS TO CACHE
        let resource: String = userID + "/" + "contact"
        let http = HTTPRequests(host: "localhost", port: "5000", resource: resource)
        http.GET({ (json) -> Void in
            let success = json["success"] as! Int
            if success == 1 {
                let data = json["data"] as! [String:AnyObject]
                let contactDict = data["contacts"] as! [String:String]
                let contactIdList = contactDict.keys
                for contactId in contactIdList {
                    self.saveContact(contactDict[contactId]!, contactID: Int(contactId)!)
                }
            } else {
                // let data = json["data"] as! [String:AnyObject]
                // let error = data["error"] as! String
            }
        })
        
        // TODO: SAVE MESSAGES TO CACHE
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        print("Main Table View Controller: " + userID)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "to-contacts" {
            // load userID into viewcontroller property
            let destination = segue.destinationViewController as! ContactsTableViewController
            destination.userID = self.userID
        }
    }
    
    // likely will make a caching class, but for now standalone methods
    func saveContact(contactUsername: String, contactID: Int) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Contact", inManagedObjectContext:managedContext)
        let contact = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        contact.setValue(contactUsername, forKey: "contact_username")
        contact.setValue(contactID, forKey: "contact_id")
        do {
            try managedContext.save()
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
        return 0
    }
    
    @IBAction func quit(sender: AnyObject) {
        // since this view is in the chain of the navigation controler, use POPVIEWCONTROLLER
        self.navigationController?.popViewControllerAnimated(true)
    }

    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

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
