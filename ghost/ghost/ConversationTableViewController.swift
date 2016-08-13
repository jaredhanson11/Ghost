//
//  ConversationTableViewController.swift
//  ghost
//
//  Created by John Clarke on 7/12/16.
//  Copyright © 2016 hck. All rights reserved.
//

import UIKit
import CoreData

class ConversationTableViewController: UITableViewController {
    
    var userID: String = ""
    var convoID: String = ""
    
    // store the user facing store of messages
    // after a message is viewed (from cellForRowAtIndexPath), we delete from the Cache
    // the user still sees the messages when on the page, but going to another, then coming back, the messages will have been delete from the cache and thus not displayed
    
    var messagesFromCache = Cache.sharedInstance.messagesCache
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        let sendMessageAlert = UIAlertController(title: "Send Message", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let sendMessageAction = UIAlertAction(title: "Send", style: .Default, handler: { (alert: UIAlertAction) -> Void in
            let message = sendMessageAlert.textFields![0].text!
            if (message != "") {
                // save to server: convo
                let resource: String = self.userID + "/message"
                let http = HTTPRequests(host: "localhost", port: "5000", resource: resource, params: ["message": message, "convo_id": self.convoID])
                //print(["message": message, "convo_id": self.convoID])
                http.POST({ (json) -> Void in
                    let success = json["success"] as! Int
                    if success == 1 {
                        // save to cache: convo
                        let messageSentSuccess = UIAlertController(title: "Message Sent", message: message, preferredStyle: UIAlertControllerStyle.Alert)
                        let messageSentAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        messageSentSuccess.addAction(messageSentAction)
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            self.presentViewController(messageSentSuccess, animated: true, completion: nil)
                        }
                    } else {
                        // TODO: implement a serverside error
                        //let error = String(data["error"])
                        //let contactAddIssue = UIAlertController(title: "Add Contact Issue", message: "Error", preferredStyle: UIAlertControllerStyle.Alert)
                        //let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        //contactAddIssue.addAction(action)
                        //NSOperationQueue.mainQueue().addOperationWithBlock {
                        //    self.presentViewController(contactAddIssue, animated: true, completion: nil)
                        //}
                    }
                })
            } else {
                let sendMessageIssue = UIAlertController(title: "Send Message", message: "please enter a message.", preferredStyle: UIAlertControllerStyle.Alert)
                let sendMessageIssueAction = UIAlertAction(title: "Send", style: .Default, handler: nil)
                sendMessageIssue.addAction(sendMessageIssueAction)
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(sendMessageIssue, animated: true, completion: nil)
                }
            }
        })
        
        sendMessageAlert.addAction(sendMessageAction)
        addTextFieldToAlert(sendMessageAlert, placeholder: "Enter users...")
        self.presentViewController(sendMessageAlert, animated: true, completion: nil)
        
    }
    
    // TODO: create a UIAlertController class
    func addTextFieldToAlert(alert: UIAlertController, placeholder: String) {
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
            textField.placeholder = placeholder
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (Cache.sharedInstance.messagesCache.keys.contains(self.convoID)) {
            return (Cache.sharedInstance.messagesCache[self.convoID]!).count
        } else {
            return 0
        }
    }
    
    // to preserve memory, iOS recycles the cells (doesn't populate all of them at once)
    // thus when the user scrolls, the new cells that appear are actually just recycled cells that fell out of frame
    // so when a cell runs through this method, we know it was in view and, reasonably, it was viewed
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //print("size of the message cache: " + String((messagesFromCache[self.convoID] as! [AnyObject]).count))
        //print("the index trying to be accessed: " + String(indexPath.row))
        let cell = tableView.dequeueReusableCellWithIdentifier("message", forIndexPath: indexPath)
        let messageLabel = cell.viewWithTag(11) as! UILabel
        let usernameLabel = cell.viewWithTag(12) as! UILabel
        let message = (messagesFromCache[self.convoID]![indexPath.item] as! [String:AnyObject])["message"] as? String
        let messageID = String((messagesFromCache[self.convoID]![indexPath.item] as! [String:AnyObject])["message_id"]!)
        let userID = String((messagesFromCache[self.convoID]![indexPath.item] as! [String:AnyObject])["user_id"]!)
        let username = Cache.sharedInstance.contactsCache[userID]!["contact_username"] as! String
        
        // only display the message if the user was a recipient, the API handles who receives messages
        if (Cache.sharedInstance.messagesCache.keys.contains(self.convoID)) {
            messageLabel.text = message
            usernameLabel.text = username
        }
        
        // remove from virtual cache
        Cache.sharedInstance.deleteMessageFromCache(self.convoID, messageID: messageID)
        
        // add to core data for deletion on next load
        let data = ["message_id": messageID]
        CoreDataController.sharedInstance.saveToCoreData("Messages", data: data)
        
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
