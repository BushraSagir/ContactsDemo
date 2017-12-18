//
//  Person.swift
//  ContactsDemo
//
//  Created by Bushra-Sagir on 16/12/17.
//  Copyright © 2017 Diaspark. All rights reserved.
//

import UIKit
import RealmSwift

class Person: Object {
    
    @objc dynamic var firstName = "firstName"
    @objc dynamic var lastName = "lastName"
    @objc dynamic var email = "email"
    @objc dynamic var phoneNumber = "phoneNumber"
    @objc dynamic var notes = "notes"
    @objc dynamic var organisation = "organisation"
    @objc dynamic var city = "city"
    @objc dynamic var state = "state"
    @objc dynamic var street = "street"
    @objc dynamic var favourite :Bool = false
    @objc dynamic var profileImage : String = ""
    @objc dynamic var recordID:ABRecordID = 0
    
    override class func primaryKey() -> String {
        return "recordID"
    }
}
