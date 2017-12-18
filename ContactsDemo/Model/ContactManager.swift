//
//  ContactManager.swift
//  ContactsDemo
//
//  Created by Bushra-Sagir on 16/12/17.
//  Copyright © 2017 Diaspark. All rights reserved.
//

import UIKit
import Contacts
import RealmSwift

class ContactManager: NSObject {

    var ab = RHAddressBook()
    
    func hasPermission() -> Bool {
        return RHAddressBook.authorizationStatus() == RHAuthorizationStatus.authorized
    }
    
    func getContacts(success:(()->())?, failure:((_ message: String)->())?) {
        if hasPermission() {
                let backgroundRealm = ContactManager.cnRealm()
                let people = self.ab?.peopleOrderedByUsersPreference as! [RHPerson]
                try! backgroundRealm.write({ () -> Void in
                    for rhPerson in people {
                        self.writeRecord(realm: backgroundRealm, rhPerson)
                    }
                    success?()
                })
        }
        else {
                failure?("no permission")
            }
    }
    private func writeRecord(realm: Realm, _ rhPerson: RHPerson) {
        let rhPhoneNumbers = rhPerson.phoneNumbers.values as Array?

        var rlmPhoneNumbers : [String] = []
        if (rhPhoneNumbers?.count ?? 0) > 0 {
            for rhNumber in rhPhoneNumbers! {
                let number = rhNumber as? String ?? ""
                rlmPhoneNumbers.append(number)
            }
        }
        let ostPerson = Person()
        ostPerson.recordID = rhPerson.recordID
        ostPerson.firstName = rhPerson.firstName != nil ? rhPerson.firstName : ""
        ostPerson.lastName = rhPerson.lastName != nil ? rhPerson.lastName : ""
        if rhPerson.emails.count > 0 {
            ostPerson.email = rhPerson.emails.values[0] as? String ?? ""
        }
        ostPerson.notes = rhPerson.note != nil ? rhPerson.note : ""
        ostPerson.organisation = rhPerson.organization != nil ? rhPerson.organization : ""
        ostPerson.city = (rhPerson.addresses.value(at: 0) as? [String:String])?["City"] ?? ""
        ostPerson.state = (rhPerson.addresses.value(at: 0) as? [String:String])?["State"] ?? ""
        ostPerson.street = (rhPerson.addresses.value(at: 0) as? [String:String])?["Street"] ?? ""
        if rlmPhoneNumbers.count > 0{
            ostPerson.phoneNumber = rlmPhoneNumbers[0]
        }
        realm.add(ostPerson, update: true)
    }
    
    func requestAuthorization(completion:@escaping (_ isGranted: Bool)->()) {
        ab?.requestAuthorization { (granted, error) -> Void in
            completion(granted);
        }
    }
    
    class func cnRealm() -> Realm {
        return try! Realm()
    }
    
    class func assignProfilePicture(_ realm:Realm) {
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try? fileManager.contentsOfDirectory(atPath: path)
        var pictures:[String] = []
        if let items_ = items {
            if items_.count > 0 {
                pictures = items_.filter{$0.hasSuffix("jpeg")}
            }
        }
        let count = pictures.count
        if count > 0 {
            let people = realm.objects(Person.self).sorted(byKeyPath: "recordID", ascending: true)
            for i in 0..<people.count {
                try! realm.write {
                    people[i].profileImage = i < count ? pictures[i] : pictures[(i%count)]
                }
                try? realm.commitWrite()
            }
        }
    }
}
