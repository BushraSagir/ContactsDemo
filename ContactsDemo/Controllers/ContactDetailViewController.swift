//
//  ContactDetailViewController.swift
//  ContactsDemo
//
//  Created by Bushra-Sagir on 17/12/17.
//  Copyright © 2017 Diaspark. All rights reserved.
//

import UIKit
import MessageUI

class ContactDetailViewController: UIViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblOrganisation: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    var person:Person = Person()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setContactInfo()
    }
    
    func setupUI() {
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        else {
            print("3D Touch Not Available")
        }
        
        self.navigationController?.navigationItem.title = "Contact Detail"
        
        lblFirstName.layer.borderWidth = 1
        lblFirstName.layer.cornerRadius = 8
        lblFirstName.layer.borderColor = UIColor.lightGray.cgColor
        
        lblLastName.layer.borderWidth = 1
        lblLastName.layer.cornerRadius = 8
        lblLastName.layer.borderColor = UIColor.lightGray.cgColor
        
        lblOrganisation.layer.borderWidth = 1
        lblOrganisation.layer.cornerRadius = 8
        lblOrganisation.layer.borderColor = UIColor.lightGray.cgColor
        
        lblEmail.layer.borderWidth = 1
        lblEmail.layer.cornerRadius = 8
        lblEmail.layer.borderColor = UIColor.lightGray.cgColor
        
        lblNotes.layer.borderWidth = 1
        lblNotes.layer.cornerRadius = 8
        lblNotes.layer.borderColor = UIColor.lightGray.cgColor
        
        lblNumber.layer.borderWidth = 1
        lblNumber.layer.cornerRadius = 8
        lblNumber.layer.borderColor = UIColor.lightGray.cgColor
        
        lblAddress.layer.borderWidth = 1
        lblAddress.layer.cornerRadius = 8
        lblAddress.layer.borderColor = UIColor.lightGray.cgColor
        
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width / 2
        self.imgProfile.layer.masksToBounds = true;
        self.imgProfile.clipsToBounds = true;
        self.imgProfile.layer.borderWidth = 1
        self.imgProfile.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setContactInfo() {
         self.lblFirstName.text = self.person.firstName
         self.lblLastName.text = self.person.lastName
         self.lblOrganisation.text = self.person.organisation
         self.lblEmail.text = self.person.email
         self.lblNotes.text = self.person.notes
         self.lblNumber.text = self.person.phoneNumber
         self.lblAddress.text = self.person.street + " " +  self.person.city + " " +  self.person.state
        let fileManager = FileManager.default
        let path = Bundle.main.resourcePath!+"/"+self.person.profileImage
        let data = fileManager.contents(atPath: path)
        if let data_ = data {
            let image = UIImage(data:data_)
            self.imgProfile.image = image
        }
    }
}

extension ContactDetailViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let convertedLocation = view.convert(location, to: self.imgProfile)
        if self.imgProfile.bounds.contains(convertedLocation) {
            let otherViewController = self.storyboard?.instantiateViewController(withIdentifier: "PrewingViewController") as? PreviewingViewController
            otherViewController?.preferredContentSize = CGSize(width: 0.0, height: 300)
            otherViewController?.image = self.imgProfile.image
            previewingContext.sourceRect = self.imgProfile.frame
            return otherViewController
        }
        else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //show(viewControllerToCommit, sender: self)
       // present(viewControllerToCommit, animated: true)
    }
}

extension ContactDetailViewController: MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate {

    @IBAction func sendEmailButtonTapped(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients([person.email])
        mailComposerVC.setSubject("Sending you an in-app e-mail...")
        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: UIAlertControllerStyle.alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(sendMailErrorAlert, animated: true, completion: nil)
       }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    @IBAction func callButtonTapped(sender: AnyObject) {
        if let url = URL(string: "tel://\(person.phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        else {
            let sendMailErrorAlert = UIAlertController(title: "Could Not CAll", message: "Your device could not call.", preferredStyle: UIAlertControllerStyle.alert)
            sendMailErrorAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }

    @IBAction func sendText(sender: UIButton) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Message Body"
            controller.recipients = [person.phoneNumber]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }

}
