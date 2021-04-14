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
    override func viewDidLoad() {
        super.viewDidLoad()
        pay.layer.cornerRadius = 15
        self.title = "Standard"
        
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
    }

}
