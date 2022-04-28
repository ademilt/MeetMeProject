//
//  NewFriendViewController.swift
//  MeetMe
//
//  Created by Annie DeMilt on 4/25/22.
//

import UIKit
import CoreLocation
import GooglePlaces
import MapKit
import Contacts
import FirebaseAuth
import FirebaseAuthUI

class NewFriendViewController: UIViewController {
   
    @IBOutlet weak var friendTextField: UITextField!
    @IBOutlet weak var friendLookupButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    
    var adventure: FriendLocation!
    //var currentUser: AdventureUser!
    //var person: PersonalLocation!
    
    let regionDistance: CLLocationDegrees = 750.0
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    //var myName: String!
    
    override func viewDidLoad() {
        //adventure = AdventureUser(user: adventure)
        //adventure = Adventure()
        super.viewDidLoad()
        
        adventure = FriendLocation()
        //currentUser = currentUser.documentID
        
        //hide keyboard if we tap outside of a field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        getLocation()
        if adventure == nil {
            adventure = FriendLocation()
        } else {
            disableTextEditing()
            //cancelBarButton.hide()
            // saveBarButton.hide()
            navigationController?.setToolbarHidden(true, animated: true)
        }
        setUpMapView()
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if adventure.documentID != "" {
            self.navigationController?.setToolbarHidden(true, animated: true)
        }
    }
    
    func setUpMapView() {
        let region = MKCoordinateRegion(center: adventure.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
    }
    
    func updateUserInterface() {
        locationLabel.text = adventure.name
        addressLabel.text = adventure.address
        friendTextField.text =  adventure.friendName
        updateMap()
    }
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(adventure)
        mapView.setCenter(adventure.coordinate, animated: true)
    }
    
    func disableTextEditing() {
        //mylocationLabel.isEnabled = false
        locationLabel.isEnabled = false
        addressLabel.isEnabled = false
        //mylocationLabel.backgroundColor = .clear
        locationLabel.backgroundColor = .clear
        addressLabel.backgroundColor = .clear
        //mylocationLabel.borderStyle = .none
       // locationLabel.borderStyle = .none
       // addressLabel.borderStyle = .none
    }
    
    func updateFromInterface() {
        adventure.name = locationLabel.text!
        adventure.address = addressLabel.text!
        adventure.friendName = friendTextField.text!
    }
    
    func leaveViewController(){
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode{
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func lookupButtonPressed(_ sender: UIButton) {
        updateFromInterface()
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        // Display the autocomplete view controller
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    
//    @IBAction func nextButtonPressed(_ sender: UIBarButtonItem) {
//        self.updateFromInterface()
//        self.performSegue(withIdentifier: "nextMeet", sender: nil)
//    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        adventure.saveData() { success in
            if success {
                //self.leaveViewController()
                self.performSegue(withIdentifier: "findMidpoint", sender: nil)
            } else {
                //ERROR during save occured
                self.oneButtonAlert(title: "Save Failed", message: "For some reason the data would not save to the cloud")
            }
        }
    }
}
extension NewFriendViewController: CLLocationManagerDelegate {
    
    func getLocation() {
        // Creating a CLLocationManager will automatically check authorization
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("👮‍♀️👮‍♀️ Checking authentication status.")
        handleAuthenticationStatus(status: status)
    }
    
    func handleAuthenticationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            self.oneButtonAlert(title: "Location services denied", message: "It may be that parental controls are restricting location use in this app.")
        case .denied:
            showAlertToPrivacySettings(title: "User has not authorized location services", message: "Select 'Settings' below to open device settings and enable location services for this app.")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            print("DEVELOPER ALERT: Unknown case of status in handleAuthnticationStatus\(status)")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            print("Something went wrong getting the UIApplication.openSettingsURLString")
            return
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let currentLocation = locations.last ?? CLLocation()
        print("🗺 Current location is \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        var name = ""
        var address = ""
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
            if error != nil {
                print("ERROR: retrieving place. \(error!.localizedDescription)")
            }
            if placemarks != nil {
                // get the first placemark
                let placemark = placemarks?.last
                // assign placemark to locationName
                name = placemark?.name ?? "Name Unknown"
                if let postalAddress = placemark?.postalAddress {
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            } else {
                print("ERROR: retrieving placemark.")
                
            }
            // if there is no location data, make device location the location
            if self.adventure.name == "" && self.adventure.address == "" {
                self.adventure.name = name
                self.adventure.address = address
                self.adventure.coordinate = currentLocation.coordinate
            }
            self.mapView.userLocation.title = name
            self.mapView.userLocation.subtitle = address.replacingOccurrences(of: "\n", with: ", ")
            self.updateUserInterface()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error.localizedDescription). Failed to get device location.")
    }
}

extension NewFriendViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
      adventure.name = place.name ?? "Unknown Place"
      adventure.address = place.formattedAddress ?? "Unknown Address"
      adventure.coordinate = place.coordinate
    updateUserInterface()
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }
}