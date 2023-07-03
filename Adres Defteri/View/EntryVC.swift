//
//  EntryVC.swift
//  Adres Defteri
//
//  Created by Zehra Coşkun on 8.06.2023.
//

import UIKit
import Firebase

class EntryVC: UIViewController {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var entryLabel: UILabel!
    
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var signIn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signIn.isHidden = true
        imageView.layer.cornerRadius = 20.0
        
        
        // Do any additional setup after loading the view.
    }


    @IBAction func signInUp(_ sender: Any) {
        if signUp.isHidden {
            signUp.isHidden = false
            switchLabel.text = "Önce bir hesap oluşturalım"
            entryLabel.text = "Mail adresi ve şifeni girebilirsin"
            signIn.isHidden = true
            userNameTextField.isHidden = false
        } else {
            signUp.isHidden = true
            switchLabel.text = "Bir hesabım yok, oluşturalım"
            entryLabel.text = "Şimdi hatırladım, hesabım vardı"
            signIn.isHidden = false
            userNameTextField.isHidden = true
        }
    }
    @IBAction func sigUpButton(_ sender: Any) {
        if mailTextField.text != "" && passwordTextField.text != "" && userNameTextField.text != "" {
           // passwordTextField.passwordRules = UITextInputPasswordRules(descriptor: String)   -şifreye kurallar koymaya yarar
            Auth.auth().createUser(withEmail: mailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                if error != nil {
                    self.errorMessage(title: "Opps!", message: error!.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                }
            }
        } else {
            errorMessage(title: "Opps!", message: "Mail ve şifreni boş bırakmamalısın")
        }
    }
    
    @IBAction func signInButton(_ sender: Any) {
        if mailTextField.text != "" && passwordTextField.text != ""  {
            Auth.auth().signIn(withEmail: mailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                if error != nil {
                    self.errorMessage(title: "Opps!", message: error!.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                }
            }
        }
    }
    
    func errorMessage (title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(okButton)
        self.present(alert, animated: true)
    }
}

