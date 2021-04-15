//
//  CustomViewController.swift
//  Stripe
//
//  Created by Adsum MAC 1 on 14/04/21.
//

import UIKit
import Stripe
class CustomViewController: UIViewController {
    
    @IBOutlet weak var CardHolderTXT: UITextField!
    @IBOutlet weak var CardNumberTXT: UITextField!
    @IBOutlet weak var ExpiryTXT: UITextField!
    @IBOutlet weak var CVVTXT: UITextField!
    @IBOutlet weak var payBTN: UIButton!
    @IBOutlet weak var descriptionTXT: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        payBTN.layer.cornerRadius = 10
        ExpiryTXT.setInputViewDatePicker(target: self, selector: #selector(tapDone))
        self.title = "Custom"
        self.descriptionTXT.text = "Payment Details Will Be Here After Do Payment..."
    }
    @objc func tapDone() {
        if let datePicker = self.ExpiryTXT.inputView as? UIDatePicker {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "MM/yy"
            self.ExpiryTXT.text = dateformatter.string(from: datePicker.date)
        }
        self.ExpiryTXT.resignFirstResponder()
    }
    @IBAction func payBtnClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        let com = ExpiryTXT.text?.components(separatedBy: "/")
        let f = UInt(com!.first!)
        let l =  UInt(com!.last!)
        
        let CardParameters = STPCardParams()
        CardParameters.name = CardHolderTXT.text
        CardParameters.number = CardNumberTXT.text
        CardParameters.cvc = CVVTXT.text
        CardParameters.expMonth = f!
        CardParameters.expYear = l!
        
        STPAPIClient.shared.createToken(withCard: CardParameters) { (token, err) in
            guard err == nil else{
                self.descriptionTXT.textColor = .red
                self.descriptionTXT.text = err!.localizedDescription
                return
            }
            guard token != nil else{
                print("Token is Nil")
                return
            }
            print("Printing Stripe Response :- \(token!.allResponseFields)")
            print("Printing Stripe Token :- \(token!.tokenId)")
            self.descriptionTXT.textColor = .green
            self.descriptionTXT.text = "Transaction Success! \n\nHere is The Token : \(token!.tokenId) \nCard Type : \((token!.card?.funding.rawValue)!) \n\nSend This Token or Detail To Your Backend Server to Complete This Payment"
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
extension UITextField {
    
    func setInputViewDatePicker(target: Any, selector: Selector) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .date //2
        // iOS 14 and above
        if #available(iOS 14, *) {// Added condition for iOS 14
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        self.inputView = datePicker //3
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0)) //4
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //5
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel)) // 6
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector) //7
        toolBar.setItems([cancel, flexible, barButton], animated: false) //8
        self.inputAccessoryView = toolBar //9
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
    
}
