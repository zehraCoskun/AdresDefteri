//
//  SettingVC.swift
//  Adres Defteri
//
//  Created by Zehra Coşkun on 9.06.2023.
//

import UIKit
import Firebase

class SettingVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print("çıkış yapılırken hata oluştu")
        }
        performSegue(withIdentifier: "toEntryVC", sender: nil)
    }

}
