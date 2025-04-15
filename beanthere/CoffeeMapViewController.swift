//
//  CoffeeMapViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 4/15/25.
//

import UIKit
import MapKit
import FirebaseFirestore

class CoffeeMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var coffeeMapView: MKMapView!
    
    let db = Firestore.firestore()
    let segueIdentifier = "mapToCafeProfileSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coffeeMapView.delegate = self
        fetchCoffeeShops()
        let austinCenter = CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431)
        let region = MKCoordinateRegion(center: austinCenter,
                                        span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07))
        coffeeMapView.setRegion(region, animated: true)

    }
    
    func fetchCoffeeShops() {
        db.collection("coffeeShops").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching coffee shops: \(error?.localizedDescription ?? "")")
                return
            }

            for document in documents {
                let data = document.data()
                guard let name = data["name"] as? String,
                      let address = data["address"] as? String else { continue }

                let cafeID = document.documentID

                let geocoder = CLGeocoder()
                geocoder.geocodeAddressString(address) { placemarks, error in
                    if let placemark = placemarks?.first,
                       let location = placemark.location {
                        let annotation = MKPointAnnotation()
                        annotation.title = name
                        annotation.subtitle = cafeID
                        annotation.coordinate = location.coordinate
                        self.coffeeMapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = "CoffeeShopPin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let cafeID = view.annotation?.subtitle else { return }
        performSegue(withIdentifier: segueIdentifier, sender: cafeID)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier,
           let destination = segue.destination as? CafeProfileViewController,
           let cafeID = sender as? String {
            destination.cafeId = cafeID
        }
    }


}
