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
    
    var userID: String = ""
    var newMessage: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Conversations"
        
        //CoreDataController.sharedInstance.clearCoreData(["Messages"])
        
        let messageIDsToDelete = CoreDataController.sharedInstance.fetchEntitiesToDelete("Messages")
        let contactIDsToDelete = CoreDataController.sharedInstance.fetchEntitiesToDelete("Contacts")
        let convoIDsToDelete = CoreDataController.sharedInstance.fetchEntitiesToDelete("Convos")
        print("message ids to delete: \(messageIDsToDelete)")
        print("contact ids to delete: \(contactIDsToDelete)")
        print("convo ids to delete: \(convoIDsToDelete)")
        // load data from server into virtual cache
        self.mainPage(messageIDsToDelete, contactIDsToDelete: contactIDsToDelete, convoIDsToDelete: convoIDsToDelete)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        print("Main Table View Controller: " + userID)
        if (self.newMessage) {
            print("yeyeyeye")
            self.mainPageReload()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //------------------------------START: ADD CONVERSATION-----------------------------------------------------
    
    @IBAction func addConvo(sender: AnyObject) {
        let addConvoAlert = UIAlertController(title: "Start a Conversation", message: "Enter a username to add to you contacts list", preferredStyle: .Alert)
        let addConvoAction = UIAlertAction(title: "Submit", style: .Default, handler: {(alert: UIAlertAction) -> Void in
            let usersString = addConvoAlert.textFields![0].text!
            let usersList = usersString.characters.split(",").map(String.init)
            let convoName = addConvoAlert.textFields![1].text!
            let message = addConvoAlert.textFields![2].text!
            
            var _message = ""
            if (Validation.isInRange(usersString, lo: 0, hi: 0)) {
                _message += "Please enter a non-zero number usernames (separated by commas).\n"
            }
            if (Validation.isInRange(convoName, lo: 0, hi: 0) || !Validation.isAlphaNumeric(convoName)) {
                _message += "Please enter an alphanumeric conversation name"
            }
            if (Validation.isInRange(message, lo: 0, hi: 0)) {
                _message += "Please enter a message."
            }
            
            var usersIDString: String? = ""
            if (_message.characters.count > 0) {
                let convoAlertController = UIAlertController(title: "Conversation Issue", message: _message, preferredStyle: UIAlertControllerStyle.Alert)
                let convoAlertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                convoAlertController.addAction(convoAlertAction)
                self.presentViewController(convoAlertController, animated: true, completion: { () -> Void in
                    addConvoAlert.textFields![0].text = ""
                    addConvoAlert.textFields![1].text = ""
                    addConvoAlert.textFields![2].text = ""
                })
            } else {
                usersIDString = self.getUserIDs(usersList)
                if (usersIDString == nil) {
                    let addConvoIssue = UIAlertController(title: "Conversation Issue", message: "Please be sure all users exist and are in your contacts list.", preferredStyle: .Alert)
                    let addConvoIssueAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    addConvoIssue.addAction(addConvoIssueAction)
                    self.presentViewController(addConvoIssue, animated: true, completion: nil)
                } else {
                    // SAVE TO SERVER: CONVO
                    let resource: String = self.userID + "/message"
                    let http = HTTPRequests(host: "localhost", port: "5000", resource: resource, params: ["convo_name" : convoName, "message" : message, "recipients": usersIDString!])
                    http.POST({ (json) -> Void in
                        let success = json["success"] as! Int
                        let data = json["data"] as! [String:AnyObject]
                        if success == 1 {
                            // SAVE TO CACHE: CONVO
                            let convo_id = String(data["convo_id"]!)
                            Cache.sharedInstance.addConvoToCache(convo_id, convoName: convoName, members: usersIDString!)
                            var alertMessage: String = "Conversation: \(convoName) started with"
                            for i in 0...(usersList.count-1) {
                                if (i == usersList.count-1) {
                                    alertMessage += " \(usersList[i])."
                                } else {
                                    alertMessage += " \(usersList[i]),"
                                }
                            }
                            let convoAddSuccess = UIAlertController(title: "Conversation Started", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
                            let convoAddAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            convoAddSuccess.addAction(convoAddAction)
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.presentViewController(convoAddSuccess, animated: true, completion: { () -> Void in
                                    self.tableView.reloadData()
                                    // SAVE TO CACHE: MESSAGE
                                    //self.saveMessageBatch(convo_id, userID: Int(self.userID)!, message: message)
                                })
                            }
                        } else {
                            // TODO: IMPLEMENT SERVERSIDE AN ERROR
                            //let error = String(data["error"])
                            let contactAddIssue = UIAlertController(title: "Add Contact Issue",     message: "Error", preferredStyle: UIAlertControllerStyle.Alert)
                            let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            contactAddIssue.addAction(action)
                            NSOperationQueue.mainQueue().addOperationWithBlock {
                                self.presentViewController(contactAddIssue, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        })
        addTextFieldToAlert(addConvoAlert, placeholder: "Enter users...")
        addTextFieldToAlert(addConvoAlert, placeholder: "Enter conversation name...")
        addTextFieldToAlert(addConvoAlert, placeholder: "Enter message...")
        addConvoAlert.addAction(addConvoAction)
        self.presentViewController(addConvoAlert, animated: true, completion: nil)
    }
    
    //------------------------------END: ADD CONVERSATION-----------------------------------------------------
    
    //------------------------------START: MISCELLANEOUS METHODS---------------------------------------------------
    
    func addTextFieldToAlert(alert: UIAlertController, placeholder: String) {
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
            textField.placeholder = placeholder
        }
    }
    
    func doTableRefresh() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.tableView.reloadData()
        }
    }
    
    func getUserIDs(usersList: [String]) -> String? {
        var usersIDList: [String] = [String]()
        for i in 0...(usersList.count-1) {
            let user = usersList[i]
            let contactIDs = Array(Cache.sharedInstance.contactsCache.keys)
            for id in contactIDs {
                let contactUsername = Cache.sharedInstance.contactsCache[id]!["contact_username"] as! String
                if (user == contactUsername) {
                    usersIDList.append(id)
                }
            }
        }
        
        // Check if all contacts could be translated into their contactIDs
        var usersIDString = ""
        if (usersList.count == usersIDList.count) {
            usersIDString = usersIDList.joinWithSeparator(",")
            return usersIDString
        } else {
            return nil
        }
    }
    
    @IBAction func quit(sender: AnyObject) {
        // since this view is in the chain of the navigation controler, use POPVIEWCONTROLLER
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    //------------------------------END: MISCELLANEOUS METHODS---------------------------------------------------
    
    //------------------------------START: SENDING DATA-----------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "to-contacts" {
            // load userID into viewcontroller property
            let destination = segue.destinationViewController as! ContactsTableViewController
            destination.userID = self.userID
        }
        else if segue.identifier == "to-convo" {
            let destination = segue.destinationViewController as! ConversationTableViewController
            destination.userID = self.userID
            let indexPathSelect = self.tableView.indexPathForSelectedRow!
            let convoID = Array(Cache.sharedInstance.convosCache.keys)[indexPathSelect.item]
            destination.convoID = convoID
        }
    }
    
    //------------------------------END: SENDING DATA-----------------------------------------------------
    
    // TODO: make these calls more modular
    
    //------------------------------START: SAVE TO CACHE-----------------------------------------------------
    
    func mainPageReload() -> Void {
        let messageIDsToDelete = CoreDataController.sharedInstance.fetchEntitiesToDelete("Messages")
        let contactIDsToDelete = CoreDataController.sharedInstance.fetchEntitiesToDelete("Contacts")
        let convoIDsToDelete = CoreDataController.sharedInstance.fetchEntitiesToDelete("Convos")
        print("message ids to delete: \(messageIDsToDelete)")
        print("contact ids to delete: \(contactIDsToDelete)")
        print("convo ids to delete: \(convoIDsToDelete)")
        // load data from server into virtual cache
        self.mainPage(messageIDsToDelete, contactIDsToDelete: contactIDsToDelete, convoIDsToDelete: convoIDsToDelete)
    }
    
    func mainPage(messageIDsToDelete: String, contactIDsToDelete: String, convoIDsToDelete: String) -> Void {
        let resource: String = self.userID + "/" + "main_page"
        let params: [String:String] = ["message_ids_to_delete" : messageIDsToDelete, "convo_ids_to_delete" : convoIDsToDelete, "contact_ids_to_delete" : contactIDsToDelete]
        let http = HTTPRequests(host: "localhost", port: "5000", resource: resource, params: params)
        http.POST({ (json) -> Void in
            let data = json["success"] as! [String:AnyObject]
            if !data.isEmpty {
                let contacts = data["contacts"] as! [String:AnyObject]
                let convos = data["convos"] as! [String:AnyObject]
                let messages = data["messages"] as! [String:AnyObject]
                let messagesDeleted = data["messages_deleted"] as! String
                let contactsDeleted = data["contacts_deleted"] as! String
                let convosDeleted = data["convos_deleted"] as! String
                print("deleted messages: \(messagesDeleted)")
                print("deleted contacts: \(contactsDeleted)")
                print("deleted convos: \(convosDeleted)")
                Cache.sharedInstance.contactsCache = contacts
                Cache.sharedInstance.convosCache = convos
                Cache.sharedInstance.messagesCache = messages
                CoreDataController.sharedInstance.clearCoreData(["Messages","Convos","Contacts"])
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.tableView.reloadData()
                }
            } else {
                let data = json["data"] as! [String:AnyObject]
                let error = data["error"] as! String
                print(error)
            }
        })
    }
    
    //------------------------------END: SAVE TO CACHE-----------------------------------------------------
    
    //------------------------------START: DELETE READ MESSAGES FROM SERVER-----------------------------------------------------
    
//    func deleteMessages(messageIDs: String) -> Void {
//        if (messageIDs != "") {
//            let resource: String = self.userID + "/message"
//            let http = HTTPRequests(host: "localhost", port: "5000", resource: resource, params: ["message_ids":messageIDs])
//            http.PUT({ (json) -> Void in
//                let data = json["data"] as! [String:AnyObject]
//                let messageIDs: String = data["message_ids"] as! String
//                let success = String(json["success"]!)
//                if (success == "1") {
//                    CoreDataController.sharedInstance.deleteFromCoreData("Messages")
//                    print("Delete messages: \(messageIDs)")
//                } else {
//                    print("messages not successfully deleted from the server")
//                }
//            })
//        }
//    }
    
    //------------------------------END: DELETE READ MESSAGES FROM SERVER-----------------------------------------------------
    
    //------------------------------START: TABLE METHODS-----------------------------------------------------
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("to-convo", sender: self)
    }
    
    //------------------------------END: TABLE METHODS-----------------------------------------------------
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Cache.sharedInstance.convosCache.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("convo", forIndexPath: indexPath)
        // Configure the cell...
        cell.textLabel!.text = (Array(Cache.sharedInstance.convosCache.values)[indexPath.item] as! [String:String])["convo_name"]
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete) {
            tableView.beginUpdates()
            let key = Array(Cache.sharedInstance.convosCache.keys)[indexPath.row]
            // delete from the virtual cache
            Cache.sharedInstance.deleteConvoFromCache(key)
            // Note that indexPath is wrapped in an array:  [indexPath]
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.endUpdates()
            let data = ["convo_id" : key]
            CoreDataController.sharedInstance.saveToCoreData("Convos", data: data)
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
