//
//  StandardViewController.swift
//  Stripe
//
//  Created by Adsum MAC 1 on 14/04/21.
//

import UIKit
import Stripe
class StandardViewController: UIViewController,STPAddCardViewControllerDelegate {
   
    

    @IBOutlet weak var pay: UIButton!
    @IBOutlet weak var msgBox: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pay.layer.cornerRadius = 10
        self.title = "Standard"
        self.msgBox.text = "Payment Details Will Be Here"
        
    }
    
    @IBAction func payBtn(_ sender: UIButton) {
        let addCardVC = STPAddCardViewController()
        addCardVC.delegate = self
        let nav = UINavigationController(rootViewController: addCardVC)
        present(nav, animated: true, completion: nil)
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreatePaymentMethod paymentMethod: STPPaymentMethod, completion: @escaping STPErrorBlock) {
        dismiss(animated: true, completion: nil)
        print("Printing Stripe Response :- \(paymentMethod.allResponseFields)")
        print("Printing Stripe Token :- \(paymentMethod.stripeId)")
        self.msgBox.textColor = .green
        self.msgBox.text = "Transaction Success! \n\nHere is The Token : \(paymentMethod.stripeId) \nCard Type : \((paymentMethod.card?.funding)!) \n\nSend This Token or Detail To Your Backend Server to Complete This Payment"
    }

}
