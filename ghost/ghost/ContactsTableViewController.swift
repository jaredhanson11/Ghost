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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "to-add-contact" {
            let destination = segue.destinationViewController as! AddContactViewController
            destination.userID = self.userID
        }
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
