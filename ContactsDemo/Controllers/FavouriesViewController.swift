//
//  FavouriesViewController.swift
//  ContactsDemo
//
//  Created by Bushra-Sagir on 17/12/17.
//  Copyright © 2017 Diaspark. All rights reserved.
//


import UIKit
import RealmSwift

class FavouriesViewController: UIViewController {
    var manager = ContactManager()
    let realm = ContactManager.cnRealm()
    var people:Results<Person>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "All Contacts"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchingAndRefreshingView()
    }
    
    func fetchingAndRefreshingView() {
        DispatchQueue.main.async {
            LoadingOverlay.shared.showOverlay(self.view)
            self.people = self.realm.objects(Person.self).sorted(byKeyPath: "firstName", ascending: true).filter("favourite = true")
            self.tableView.reloadData()
            LoadingOverlay.shared.hideOverlayView()
        }
    }
    
}
extension FavouriesViewController: UITableViewDataSource,UITableViewDelegate {
    
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
        
        let editAction = UITableViewRowAction(style: .normal, title: "Unfavourite") { (rowAction, indexPath) in
            let person = self.people?[indexPath.row] ?? Person()
            try! self.realm.write {
                person.favourite = false
            }
            try? self.realm.commitWrite()
            self.fetchingAndRefreshingView()
        }
        editAction.backgroundColor = .blue
        
        return [editAction]
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

extension FavouriesViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchContactData(searchBar.text!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        self.searchContactData(searchBar.text!)
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
