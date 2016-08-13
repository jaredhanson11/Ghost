//
//  Cache.swift
//  ghost
//
//  Created by John Clarke on 7/12/16.
//  Copyright © 2016 hck. All rights reserved.
//

import Foundation

class Cache {
    
    var convosCache: [String:AnyObject] = [:]
    var messagesCache: [String:AnyObject] = [:]
    var contactsCache: [String:AnyObject] = [:]
    
    //------------------------------------START: ADD METHODS------------------------------------
    
    func addContactToCache(contactID: String, contactUsername: String, isContact: String) {
        let data = ["contact_username" : contactUsername, "is_contact" : isContact]
        self.contactsCache.updateValue(data, forKey: contactID)
    }
    
    func addConvoToCache(convoID: String, convoName: String, members: String) {
        let convo = ["convo_name" : convoName, "members" : members]
        self.convosCache.updateValue(convo, forKey: convoID)
    }
    
    // add message to cache will be implemented when we have push notifications
    
    //------------------------------------END: ADD METHODS------------------------------------
    
    //------------------------------------START: DELETE METHODS------------------------------------
    
    func deleteContactFromCache(contactID: String) {
        self.contactsCache.removeValueForKey(contactID)
    }
    
    func deleteConvoFromCache(convoID: String) {
        self.convosCache.removeValueForKey(convoID)
    }
    
    func deleteMessageFromCache(convoID: String, messageID: String) {
        var messages = self.messagesCache[convoID] as! [[String:AnyObject]]
        //print(messages)
        if (!messages.isEmpty) {
            for i in 0...(messages.count-1) {
                let messageIDFromCache = String(messages[i]["message_id"]!)
                if (messageIDFromCache == messageID) {
                    messages.removeAtIndex(i)
                    self.messagesCache.removeValueForKey(convoID)
                    self.messagesCache.updateValue(messages, forKey: convoID)
                    break
                }
            }
        }
    }

    // REMOVE CONTACTS WHERE IS_CONTACT=0
    func getRealContacts(contacts: [String:AnyObject]) -> [String:AnyObject] {
        var contactsMutable = contacts
        let contactIDs = Array(contactsMutable.keys)
        if (!contactIDs.isEmpty) {
            for i in 0...(contactIDs.count-1) {
                let key = contactIDs[i]
                let data = contactsMutable[key] as! [String:AnyObject]
                let isContact = String(data["is_contact"]!) // swift infers this as int so string constructor must be used instead of casting operation
                if (isContact == "0") {
                    contactsMutable.removeValueForKey(key)
                }
            }
        }
        return contactsMutable
    }
    
    //------------------------------------END: DELETE METHODS------------------------------------
    
    //------------------------------------START: GET METHODS------------------------------------
    
    func getContactUsernameFromCache(contactID: String) -> String {
        return self.contactsCache[contactID]!["contact_username"] as! String
    }
    
    //------------------------------------END: GET METHODS------------------------------------
    
    static let sharedInstance = Cache()
}

//func saveMessageBatch(convoID: Int, userID: Int, message: String) {
//    saveUserConvo(convoID, userID: userID)
//    saveMessage(convoID, userID: userID, message: message)
//}
//
//func saveUserConvo(convoID: Int, userID: Int) {
//    // SAVE convo to Cache.sharedInstance.userConvosCache
//    //userConvoObject.setValue(convoID, forKey: "convo_id")
//    //userConvoObject.setValue(userID, forKey: "user_id")
//}
//
//func saveMessage(convoID: Int, userID: Int, message: String) {
//    // Save to messageCache
//    //messageObject.setValue(convoID, forKey: "convo_id")
//    //messageObject.setValue(userID, forKey: "user_id")
//    //messageObject.setValue(message, forKey: "message")
//}
//
//// add, delete, change methods implemented