//
//  PaymentViewController.swift
//  StripePay
//
//  Created by Adsum MAC 1 on 15/04/21.
//

import UIKit
import Stripe
import PassKit

class PaymentViewController: UIViewController {

    var customerContext:STPCustomerContext?
    var paymentContext:STPPaymentContext?
    var isSetShipping = true
    
    
    @IBOutlet weak var detail: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Make Complete Payment"
        LatestCustomerId = UserDefaults.standard.string(forKey: "CustId") ?? ""
        lastCustomerDetail = UserDefaults.standard.string(forKey: "CustDetail") ?? ""
        self.detail.text = lastCustomerDetail
        self.detail.isScrollEnabled = false
        
        let configration = STPPaymentConfiguration.shared
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
        self.paymentContext?.pushPaymentOptionsViewController()
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
        print(error.localizedDescription)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        print(paymentResult)
        MyAPIClient.createPaymentIntent(amount: Double(paymentContext.paymentAmount + Int(paymentContext.selectedShippingMethod!.amount)), currency: "usd", customerId: LatestCustomerId) { (res) in
            switch res{
            case .success(let clientSecret):
                //Assemble The Payment Intent Params
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
                paymentIntentParams.paymentMethodParams = paymentResult.paymentMethodParams
                
                //Confirm The Payment Intent
                STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: paymentContext) { (status, intent, error) in
                    switch status{
                    case .succeeded:
                        completion(.success,nil)
                    case .failed:
                        completion(.error,nil)
                    case .canceled:
                        completion(.userCancellation,nil)
                    }
                }
            case .failure(let error):
                completion(.error,error)
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        print(status)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        isSetShipping = false
        debugPrint(paymentContext.selectedShippingMethod as Any)
        debugPrint(paymentContext.shippingAddress as Any)
        
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 Working Days"
        upsGround.identifier = "ups_ground"
        
        let fedEx = PKShippingMethod()
        fedEx.amount = 3.33
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives Tommorrow"
        fedEx.identifier = "fedex"
        
        if address.country == "US"{
            completion(.valid,nil,[],upsGround)
        }else{
            completion(.invalid,nil,nil,nil )
        }
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
