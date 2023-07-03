//
//  HomeVC.swift
//  Adres Defteri
//
//  Created by Zehra Coşkun on 9.06.2023.
//

import UIKit
import Firebase
import SDWebImage //görselleri indirip görüntülemek için paketi indirdim

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var list = [Location]()
    var locID = ""
    var locName = ""
    var favLabelText = ""
    private var locationTableVM : LocationTableVM!
    
    //tableview'i daha sonradan çağırıyoruz ki list boş gelmesin, boş gelirse cell oluşturamaz
    override func viewDidAppear(_ animated: Bool) {
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        tableView.allowsMultipleSelectionDuringEditing = true //sağa sola kaydırarak seçme işlemi için
        self.tableView.backgroundColor = UIColor(named: "acikgri")
    }
    //yeni veri eklendiğinde ana sayfanın güncellenmesini sağlar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("saved"), object: nil)
        getData()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = UIColor(named: "gri")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count //LocationTableVM == nil ? 0 : LocationTableVM.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let selectedLocation = self.list[indexPath.row]
        cell.locationName.text = selectedLocation.locationName
        cell.personName.text = selectedLocation.personName
        cell.personImage.sd_setImage(with: URL(string: selectedLocation.personImage ))
        cell.favLabel.text = favLabelText
        return cell
    }
    @objc func getData() {
        let db = Firestore.firestore()
        db.collection("persons").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                       self.list = snapshot.documents.map
                        { d in
                            return Location(id: d.documentID,
                                            personName: d["personName"] as? String ?? "",
                                            locationName: d["locationName"] as? String ?? "",
                                            personImage: d["personImage"] as? String ?? "https://www.flickr.com/images/buddyicon.gif")
                        }
                        self.locationTableVM = LocationTableVM(locations: self.list)
                        self.tableView.reloadData()
                    }
                }
            }else {
                print(error?.localizedDescription as Any)
            }
        }
    }

    //sola kaydırarak silme
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { action, _, _ in
            let deletedLoc = self.list[indexPath.row]
            self.locID = deletedLoc.id
            let db = Firestore.firestore()
            db.collection("persons").document(self.locID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    self.getData()
                }
            }
        }
        deleteAction.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config

    }
    /*sağa kaydırarak favorilere ekleme
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favAction = UIContextualAction(style: .destructive, title: "Favorilere ekle") { _, _, _ in
            let favAction = self.list[indexPath.row]
            self .locID = favAction.id
            print("favorilere eklendi")
        }
        favAction.backgroundColor = .green
        favAction.image = UIImage(systemName: "fav")
        let config = UISwipeActionsConfiguration(actions: [favAction])
        return config
    }
    */

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = list[indexPath.row]
        locID = selectedLocation.id
        //locName = selectedLocation.personName
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! MapsVC
            destinationVC.selectedId = locID
            //destinationVC.selectedName = locName
        }
            
    }
}

