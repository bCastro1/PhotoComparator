//
//  TextMessageComposer.swift
//  PhotoComparator
//
//  Created by Brendan Castro on 11/1/19.
//  Copyright © 2019 Brendan Castro. All rights reserved.
//

import Foundation
import MessageUI


class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    let messageRecipients = [String()]
    
    //Check to see if users device can send message
    func canSendSms() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    //configure MFMessageCompose instance
    func configureMessageCompostitionInstance() -> MFMessageComposeViewController{
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self
        messageComposeVC.recipients = messageRecipients
        
        //MARK: Insert Sharing link for message body here
        messageComposeVC.body = "Check out this progress picture I made using Brendan's super cool app!"
        return messageComposeVC
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
