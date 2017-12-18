//
//  ViewController.swift
//  ContactsDemo
//
//  Created by Bushra-Sagir on 16/12/17.
//  Copyright © 2017 Diaspark. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    var manager = ContactManager()
    let realm = ContactManager.cnRealm()
    var people:Results<Person>?

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationItem.title = "All Contacts"
        if manager.hasPermission() {
            LoadingOverlay.shared.showOverlay(self.view)
            self.beginFetch()
        }
        else {
            manager.requestAuthorization{ [weak self](isGranted) -> () in
                if isGranted {
                    self?.beginFetch()
                }
            }
        }
    }

    private func beginFetch(){
        manager.getContacts(success: { [weak self]() -> () in
            print(self?.people ?? "")
            self?.fetchingAndRefreshingView()
            }, failure: { (message: String) -> () in
        })
    }
    
    func fetchingAndRefreshingView() {
        DispatchQueue.main.async {
            LoadingOverlay.shared.showOverlay(self.view)
            ContactManager.assignProfilePicture(self.realm)
            self.people = self.realm.objects(Person.self).sorted(byKeyPath: "firstName", ascending: true)
            self.tableView.reloadData()
            LoadingOverlay.shared.hideOverlayView()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UITableViewDataSource,UITableViewDelegate {
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //@Abstract        : This is datasource method of tableview return number of rows in section
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return (people?.count ?? 0)
        
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //@Abstract        : This is datasource method of tableview return height for row in section
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //@Abstract        : This is datasource method of tableview return cell
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for : indexPath) as! ContactsCell
        let person = people?[indexPath.row] ?? Person()
        cell.fullNameLabel.text = person.firstName + " " + person.lastName
        cell.phoneNumberLabel.text = person.phoneNumber
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let person = self.people?[indexPath.row] ?? Person()
        
            let editAction1 = UITableViewRowAction(style: .normal, title: "Unfavourite") { (rowAction, indexPath) in
                try! self.realm.write {
                    person.favourite = false
                }
                try? self.realm.commitWrite()
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
            editAction1.backgroundColor = .blue

            let editAction2 = UITableViewRowAction(style: .normal, title: "Favourite") { (rowAction, indexPath) in
                try! self.realm.write {
                    person.favourite = true
                }
                try? self.realm.commitWrite()
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)

            }
            editAction2.backgroundColor = .blue
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            let person = self.people?[indexPath.row] ?? Person()
            try! self.realm.write {
                self.realm.delete(person)
            }
             self.fetchingAndRefreshingView()
        }
        deleteAction.backgroundColor = .red
        if person.favourite == true {
            return [editAction1,deleteAction]

        }
        else {
            return [editAction2,deleteAction]

        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            print(editButtonItem)
        }
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
        let contactViewController = mainStoryboard.instantiateViewController(withIdentifier: "ContactDetailViewController") as! ContactDetailViewController
        contactViewController.person = self.people![indexPath.row] as Person
        self.navigationController?.pushViewController(contactViewController, animated: true)
    }
   

    
}

extension ViewController : UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchContactData(searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.fetchingAndRefreshingView()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchContactData(_ searchText : String) {
        let searchText = searchText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if searchText.count  < 3 {
            return
        }
        let searchPredicate = NSPredicate(format: "firstName CONTAINS[c] %@ OR  lastName CONTAINS[c] %@ OR  email CONTAINS[c] %@ OR  phoneNumber CONTAINS[c] %@ OR notes CONTAINS[c] %@ OR organisation CONTAINS[c] %@ OR city CONTAINS[c] %@ OR  state CONTAINS[c] %@ OR street CONTAINS[c] %@", searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText)
        let searchResults = realm.objects(Person.self).filter(searchPredicate)
        self.people = searchResults
        self.tableView.reloadData()
    }
    
}
