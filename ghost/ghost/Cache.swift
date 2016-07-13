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
    
    func addContactToCache(contactID: String, contactUsername: String) {
        self.contactsCache.updateValue(contactUsername, forKey: contactID)
    }
    
    func addConvoToCache(convoID: String, convoName: String, members: String) {
        let convo = ["convo_name" : convoName, "members" : members]
        self.convosCache.updateValue(convo, forKey: convoID)
    }
    
 
    //------------------------------------END: ADD METHODS------------------------------------
    
    //------------------------------------START: DELETE METHODS------------------------------------
    
    func deleteContactFromCache(contactID: String) {
        self.contactsCache.removeValueForKey(contactID)
    }
    
    //------------------------------------END: DELETE METHODS------------------------------------
    
    //------------------------------------START: GET METHODS------------------------------------
    
    func getContactFromCache(contactID: String) -> String {
        return self.contactsCache[contactID] as! String
    }
    
    //------------------------------------END: GET METHODS------------------------------------
    
    static let sharedInstance = Cache()
}

func saveMessageBatch(convoID: Int, userID: Int, message: String) {
    saveUserConvo(convoID, userID: userID)
    saveMessage(convoID, userID: userID, message: message)
}

func saveUserConvo(convoID: Int, userID: Int) {
    // SAVE convo to Cache.sharedInstance.userConvosCache
    //userConvoObject.setValue(convoID, forKey: "convo_id")
    //userConvoObject.setValue(userID, forKey: "user_id")
}

func saveMessage(convoID: Int, userID: Int, message: String) {
    // Save to messageCache
    //messageObject.setValue(convoID, forKey: "convo_id")
    //messageObject.setValue(userID, forKey: "user_id")
    //messageObject.setValue(message, forKey: "message")
}

// add, delete, change methods implemented