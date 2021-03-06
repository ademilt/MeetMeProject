////
////  OptionViewController.swift
////  MeetMe
////
////  Created by Annie DeMilt on 4/25/22.
////
//
//import UIKit
//
//class OptionViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//}
//
//
////import MapKit
//import UIKit
//
//class ViewController: UIViewController {
//    @IBOutlet var mapView: MKMapView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        showPointsOfInterest()
//    }
//
//    func showPointsOfInterest() {
//        let searchRequest = MKLocalSearch.Request()
//        // searchRequest.naturalLanguageQuery = "tesla chargers"
//        searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(including: [.bank, .atm]) // or you can use excluding
//        searchRequest.region = mapView.region
//        searchRequest.resultTypes = [.pointOfInterest, .address]
//
//        let search = MKLocalSearch(request: searchRequest)
//        search.start { response, error in
//            guard let response = response else {
//                print("Error: \(error?.localizedDescription ?? "No error specified").")
//                return
//            }
//            // Create annotation for every map item
//            for mapItem in response.mapItems {
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = mapItem.placemark.coordinate
//
//                annotation.title = mapItem.name
//                annotation.subtitle = mapItem.phoneNumber
//
//                self.mapView.addAnnotation(annotation)
//            }
//            self.mapView.setRegion(response.boundingRegion, animated: true)
//        }
//    }
//}
