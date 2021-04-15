//
//  MyAPIClient.swift
//  StripePay
//
//  Created by Adsum MAC 1 on 14/04/21.
//

import Stripe
import Alamofire
var LatestCustomerId = String()
var lastCustomerDetail = String()
class MyAPIClient:NSObject,STPCustomerEphemeralKeyProvider{
    
    //First :- Create Customer
    class func CreateCustomer(Name:String,Mobile:String,Email:String,txtView:UITextView,vc:UIViewController){
        for v in vc.view.subviews {
            v.isHidden = true
        }
        LoadingOverlay.shared.showOverlay(view: vc.view)
       
        let CustometDetail = ["email":Email,"phone":Mobile,"name":Name]
        guard let reqUrl = URL(string: "http://localhost:8888/StripeBackend/createCustomer.php") else {
            print("Invalid URL")
            return
        }
        
        AF.request(reqUrl, method: .post, parameters: CustometDetail, encoding: URLEncoding.default, headers: nil).responseJSON{ (response) in
            print(response)
            switch response.result{
            case .success(_):
                print(response.data!)
                let resultValue = response.value as? [String:Any]
                LatestCustomerId = resultValue!["id"] as! String
                lastCustomerDetail = "Pay With \nCustomer Id : \(LatestCustomerId) \nName : \(resultValue!["name"] as! String) \nEmail Id : \(resultValue!["email"] as! String) \nMobile Number : \(resultValue!["phone"] as! String)"
                txtView.text = lastCustomerDetail
                
                LoadingOverlay.shared.hideOverlayView()
                for v in vc.view.subviews {
                    v.isHidden = false
                }
                vc.messagePopup(msg: "Customer Added Successfully")

            case .failure(_):
                print(response.error!)
            }
        }
    }

    //Second :- Api Call To Generate Ephemeral Key
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        let param = ["api_version":apiVersion]
        guard let reqUrl = URL(string: "http://localhost:8888/StripeBackend/empheralkey.php") else {
            print("Invalid URL")
            return
        }
        
        AF.request(reqUrl, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON{ (response) in
            print(response)
            switch response.result{
            case .success(_):
                print(response.data!)
                let resultValue = response.value as? [String:Any]
                print(resultValue!)
            case .failure(_):
                print(response.error!)
            }
        }
    }
    
    //Third :- Create Payment Intent
    class func createPaymentIntent(amount:String,currency:String,customerId:String,completion:@escaping(Result<Any, Error>)->Void){
        
        let param = ["amount":amount,"currency":currency,"customerId":customerId]
        guard let reqUrl = URL(string: "http://localhost:8888/StripeBackend/createpaymentintent.php") else {
            print("Invalid URL")
            return
        }
        
        AF.request(reqUrl, method: .post, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON{ (response) in
            print(response)
            switch response.result{
            case .success(_):
                print(response.data!)
                let resultValue = response.value as? [String:Any]
                print(resultValue!)
            case .failure(_):
                print(response.error!)
            }
        }
    }
}
