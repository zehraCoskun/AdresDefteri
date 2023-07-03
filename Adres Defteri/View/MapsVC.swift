//
//  MapsVC.swift
//  Adres Defteri
//
//  Created by Zehra Coşkun on 9.06.2023.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore
import SDWebImage

class MapsVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var personName: UITextField!
    @IBOutlet weak var locationName: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!
    
    var locationManager = CLLocationManager()
    var selectedLatitude = Double()
    var selectedLongitude = Double()
    
    var selectedName = ""
    var selectedId = ""
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: "resimSec")
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //kullanıcının konumu en iyi belirleme
        locationManager.requestWhenInUseAuthorization() //kullanıcadan izin alma-info'dan izni seçmek de gerekiyor
        locationManager.startUpdatingLocation() //konumu almaya başlar ve uygulama çalıştığı sürece durdurmazsan durmaz
        
        // Kaydetme işlemi tamamlandığında yakalayarak MapsVC'yi yenilemek için NotificationCenter kullanıyoruz
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NSNotification.Name("saved"), object: nil)
        
        
        //boş bir yere tıklayınca klavyeyi kapatma
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(turnOffKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        //görsele tıklayınca albümü açma
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
        
        cellSelected()
    }
    
    //görsel seçmek için albümü açma
    @objc func pickImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    //seçilen görseli kaydetme ve albümü kapatma
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            imageView.image = editedImage
            }
        self.dismiss(animated: true)
    }

    @objc func turnOffKeyboard(){
        view.endEditing(true)
    }
    // Yenileme işlemi için kullanılan fonksiyon
    @objc func refreshData() {
        // Verileri temizleme
        imageView.image = UIImage(named: "resimSec")
        personName.text = ""
        locationName.text = ""
        mapView.removeAnnotations(mapView.annotations)
        
        // Konum güncellemesi
        locationManager.startUpdatingLocation()
    }
    //kullanıcının konumu ve hangi uzaklıktan görüleceği
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude,
                                              longitude: locations[0].coordinate.longitude)
        //        let location = CLLocationCoordinate2D(latitude: self.selectedLatitude,
        //                                              longitude: self.selectedLongitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    //tıkladığımız cell'in verileri getiriliyor
    func cellSelected() {
        if selectedId != "" {
            saveButton.isHidden = true //görüntüleme sayfası olarak açıldığı için kaydet butonunu gizledim
            imageView.isUserInteractionEnabled = false //görsel seçme izni kaldırıldı
            locationName.isUserInteractionEnabled = false //textFieldları kullanıcı etkileşimine kapattım
            personName.isUserInteractionEnabled = false
            let db = Firestore.firestore()
            db.collection("persons").document(selectedId).getDocument { (document, error) in // selectedId'yi doğrudan belirtilen dokümana gönderir
                if let document = document, document.exists {
                    let data = document.data()
                    self.personName.text = data?["personName"] as? String ?? "isiim"
                    self.locationName.text = data?["locationName"] as? String ?? "yer ismii"
                    let imageURL = data?["personImage"] as? String ?? "resimSec"
                    self.imageView.sd_setImage(with: URL(string: imageURL))
                    
                    let annotation = MKPointAnnotation()
                    self.annotationTitle = data?["personName"] as? String ?? "isim?"
                    annotation.title = self.annotationTitle
                    self.annotationSubtitle = data?["locationName"] as? String ?? "yerismi?"
                    annotation.subtitle = self.annotationSubtitle
                    self.annotationLatitude = data?["latitude"] as? Double ?? 39.925054
                    self.annotationLongitude = data?["longitude"] as? Double ?? 32.834369
                    let coordinate = CLLocationCoordinate2D(latitude: self.annotationLatitude, longitude: self.annotationLongitude)
                    //aldığımız konumu merkez alarak haritayı açma
                    self.locationManager.stopUpdatingLocation()
                    let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    let region = MKCoordinateRegion(center: coordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                    annotation.coordinate = coordinate
                    self.mapView.addAnnotation(annotation)
                } else {
                    print("Document does not exist")
                }
            }
        } else {
            let mapGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectLoc))
            mapGestureRecognizer.minimumPressDuration = 0.5
            mapView.addGestureRecognizer(mapGestureRecognizer)
        }
    }
    //üzerine uzun tıklayarak konum işaretleme
    @objc func selectLoc(mapGestureRecognizer : UILongPressGestureRecognizer){
        if mapGestureRecognizer.state == .began {
            let touchSpot = mapGestureRecognizer.location(in: mapView)
            let touchLoc = mapView.convert(touchSpot, toCoordinateFrom: mapView)
            
            selectedLongitude = touchLoc.longitude
            selectedLatitude = touchLoc.latitude
            
            let annonation = MKPointAnnotation()
            annonation.coordinate = touchLoc
            annonation.title = personName.text
            annonation.subtitle = locationName.text
            mapView.addAnnotation(annonation)
        }
        //ekleme işleminden sonra yeniden ekleme yapabilmek için etkilişimleri açtım
        saveButton.isHidden = false
        imageView.isUserInteractionEnabled = true
    }
    //iğneli gösterim ve buton ekleme
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{ return nil }
        let reuseID = "reuseID"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.tintColor = .blue
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    //iğneye eklenen butonun bize haritaları açıp yol tarif etmesi
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if selectedId != "" {
            let location = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(location) { placemarkArr, err in
                if let placemarkArr = placemarkArr {
                    if placemarkArr.count > 0 {
                        let placemark = MKPlacemark(placemark: placemarkArr[0])
                        let item = MKMapItem(placemark: placemark)
                        item.name = self.annotationTitle
                        let launchOpt = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOpt)
                    }
                }
            }
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let uuid = UUID().uuidString
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolder = storageRef.child("post")
        saveButton.isEnabled = false
        mapView.isUserInteractionEnabled = false
        let personName = self.personName.text ?? ""
        let locationName = self.locationName.text ?? ""
        let db = Firestore.firestore()
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            let imageRef = mediaFolder.child("\(uuid).jpeg")
            imageRef.putData(data) { storageMetadata, error in
                if error != nil {
                    self.errorMessage(title: "Opps!", message: error?.localizedDescription ?? "hay aksi")
                } else {
                    imageRef.downloadURL { url, error in
                        let imageURL = url?.absoluteString
                        if let imageURL = imageURL {
                            db.collection("persons").document().setData([
                                "locationName" : locationName,
                                "personName" : personName,
                                "personImage" : imageURL,
                                "latitude" : self.selectedLatitude,
                                "longitude" : self.selectedLongitude
                            ])
                            { err in
                                if let err = err {
                                    print("Error writing document: \(err)")
                                } else {
                                    print("Document successfully written!")
                                }
                            }
                        } else{
                            print(error?.localizedDescription ?? "hay aksi")
                        }
                    }
                }
            }
        } else {
            errorMessage(title: "Opss!", message: "fotoğraf seçmeyi unuttun!")
            saveButton.isEnabled = true
        }
        //kayıt işleminin yapıldığının bildirilmesi - homevc içinde de kontrol edilmeli
        NotificationCenter.default.post(name: NSNotification.Name("saved"), object: nil)
        navigationController?.popViewController(animated: true)
        refreshData()
        //kayıt işleminden sonra kaydet butonu ve map etkileşimi açılmalı
        saveButton.isEnabled = true
        mapView.isUserInteractionEnabled = true
    }
    
    func errorMessage (title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let button = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(button)
        self.present(alert, animated: true)
    }
    
}
