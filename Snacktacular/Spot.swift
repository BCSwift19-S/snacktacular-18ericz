//
//  Spot.swift
//  Snacktacular
//
//  Created by 18ericz on 3/31/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase
import MapKit

class Spot: NSObject, MKAnnotation {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReview: Int
    var postingUserID: String
    var documentID: String
    
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return address
    }
    var dictionary: [String: Any] {
        return ["name": name,"address": address, "longitude": longitude,"latitude": latitude,"averageRating": averageRating, "numberOfReviews": numberOfReview, "postingUserID": postingUserID]
    }
    
    init(name: String, address: String,coordinate: CLLocationCoordinate2D,averageRating: Double,numberOfReview: Int,postingUserID: String,documentID: String){
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReview = numberOfReview
        self.postingUserID = postingUserID
        self.documentID = documentID
        
    }
    
    override convenience init(){
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReview: 0, postingUserID: "", documentID: "")
    }
    
    convenience init(dictionary: [String:Any]){
        let name = dictionary["name"] as! String? ?? ""
        let address = dictionary["address"] as! String? ?? ""
        let latitutude = dictionary["latitude"] as! CLLocationDegrees ?? 0.0
        let longtitude = dictionary["longtitude"] as! CLLocationDegrees ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitutude, longitude: longtitude)
        let averageRating = dictionary["averageRating"] as! Double? ?? 0.0
        let numberOfReviews = dictionary["numberOfReview"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        
        self.init(name: name, address: address, coordinate: coordinate, averageRating: averageRating, numberOfReview: numberOfReviews, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //Grab User ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else{
            print("**** ERROR COULD NOT SAVE DATA")
            return completed(false)
        }
        self.postingUserID = postingUserID
        let dataToSave = self.dictionary
        
        if self.documentID != "" {
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) {(error) in
                if let error = error {
                    print("***ERROR UPDATING DOCUMENT")
                    completed(false)
                }else {
                    print("*** DOCUMENT UPDATED")
                    completed(true)
                }
                
            }
        }else {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").addDocument(data:dataToSave) {error in
                if let error = error {
                    print("***ERROR CREATING DOCUMENT")
                    completed(false)
                }else {
                    print("*** DOCUMENT CREATED")
                    self.documentID = ref!.documentID
                    completed(true)
                }
            }
        }
    }
    
func updateAverageRating(completed: @escaping ()->()) {
    let db = Firestore.firestore()
    let reviewsRef = db.collection("spots").document(self.documentID).collection("reviews")
    reviewsRef.getDocuments { (querySnapshot, error) in
        guard error == nil else{
            print("*** ERROR: Failed to get Snapshot of reviews")
            return completed()
        }
        var ratingTotal = 0.0
        for document in querySnapshot!.documents {
            let reviewDictionary = document.data()
            let rating = reviewDictionary["rating"] as! Int? ?? 0
            ratingTotal += Double(rating)
        }
        self.averageRating = ratingTotal / Double(querySnapshot!.count)
        self.numberOfReview = querySnapshot!.count
        let dataToSave = self.dictionary
        let spotRef = db.collection("spots").document(self.documentID)
        spotRef.setData(dataToSave) { error in
            guard error == nil else{
                print("ERROR: Error updating document after changing review and average rating")
                return completed()
            }
            print("Document Updated!")
            completed()
        }
    }
}
    
}
