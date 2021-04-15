//
//  PaymentViewController.swift
//  StripePay
//
//  Created by Adsum MAC 1 on 15/04/21.
//

import UIKit
import Stripe
class PaymentViewController: UIViewController {

    var customerContext:STPCustomerContext?
    var paymentContext:STPPaymentContext?
    var isSetShipping = true
    
    
    @IBOutlet weak var detail: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Make Complete Payment"
        
        let configration = STPPaymentConfiguration()
        configration.shippingType = .shipping
        configration.requiredShippingAddressFields = Set<STPContactField>(arrayLiteral: .name,.emailAddress,.phoneNumber,.postalAddress)
        configration.companyName = "MB Testing"
        
        customerContext = STPCustomerContext(keyProvider: MyAPIClient())
        paymentContext = STPPaymentContext(customerContext: customerContext!, configuration: configration, theme: .defaultTheme)
        self.paymentContext?.delegate = self
        self.paymentContext?.hostViewController = self
        self.paymentContext?.paymentAmount = 5000
    }
    
    @IBAction func CreateCustomerClicked(_ sender: UIButton) {
        let popup = UIAlertController(title: "Create Customer", message: "", preferredStyle: .alert)
        popup.addTextField { (name) in
            name.borderStyle = .roundedRect
            name.layer.borderWidth = 0.5
            name.layer.borderColor = UIColor.darkGray.cgColor
            name.placeholder = "Enter Name Here"
        }
        popup.addTextField { (mobile) in
            mobile.borderStyle = .roundedRect
            mobile.layer.borderWidth = 0.5
            mobile.layer.borderColor = UIColor.darkGray.cgColor
            mobile.placeholder = "Enter Mobile Number"
        }
        popup.addTextField { (email) in
            email.borderStyle = .roundedRect
            email.layer.borderWidth = 0.5
            email.layer.borderColor = UIColor.darkGray.cgColor
            email.placeholder = "Enter Email Here"
        }
        popup.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
            let nameTxt = popup.textFields![0]
            let mobileTxt = popup.textFields![1]
            let emailTxt = popup.textFields![2]
            
            if nameTxt.text == nil || nameTxt.text! == "" || mobileTxt.text == nil || mobileTxt.text! == "" || emailTxt.text == nil || emailTxt.text! == ""{
                self.messagePopup(msg: "Fill All Fields Properly")
            }else{
                MyAPIClient.CreateCustomer(Name: nameTxt.text!, Mobile: mobileTxt.text!, Email: emailTxt.text!, txtView: self.detail, vc: self)
//                DispatchQueue.main.async {
//                    self.detail.text = lastCustomerDetail
//                }
            }
           
        }))
        popup.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (cancel) in
            //
        }))
        present(popup, animated: true, completion: nil)
    }

    @IBAction func PayNowClicked(_ sender: UIButton) {
        
    }
    
}

//MARK: - STPPaymentContextDelegate
extension PaymentViewController:STPPaymentContextDelegate{
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        if paymentContext.selectedPaymentOption != nil && isSetShipping{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                paymentContext.presentShippingViewController()
            }
        }
        
        debugPrint(paymentContext.selectedShippingMethod as Any)
        if paymentContext.selectedShippingMethod != nil && !isSetShipping{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                self.paymentContext?.requestPayment()
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        <#code#>
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        <#code#>
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        <#code#>
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        isSetShipping = false
        debugPrint(paymentContext.selectedShippingMethod)
        debugPrint(paymentContext.shippingAddress)
        
        let upsGround = STPKlarnaPaymentMethods()
        upsGround
    }
    
}

//MARK: - Message Popup
extension UIViewController{
    func messagePopup(msg:String){
        let alert = UIAlertController(title: "Message", message: msg, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(dismis), userInfo: nil, repeats: false)
    }
    @objc func dismis(){
        dismiss(animated: true, completion: nil)
    }
}
