//
//  Review.swift
//  Snacktacular
//
//  Created by 18ericz on 4/15/19.
//  Copyright © 2019 Eric Zhou. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    var dictionary: [String: Any] {
        return ["title": title,"text": text, "rating": rating,"reviewUserID": reviewerUserID,"date": date, "documentID": documentID]
    }
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String){
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
    }
    convenience init(dictionary: [String:Any]){
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["name"] as! String? ?? ""
        let date = dictionary["date"] as! Date? ?? Date()
        self.init(title: title, text: text, rating: rating, reviewerUserID:reviewerUserID, date: date, documentID: "")
        
    }
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        //Grab User ID
        let dataToSave = self.dictionary
        
        if self.documentID != "" {
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) {(error) in
                if let error = error {
                    print("***ERROR UPDATING DOCUMENT in spot \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                }else {
                    print("*** DOCUMENT UPDATED")
                    spot.updateAverageRating {
                        completed(true)
                    }
                }
                
            }
        }else {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data:dataToSave) {error in
                if let error = error {
                    print("***ERROR CREATING DOCUMENT")
                    completed(false)
                }else {
                    print("*** DOCUMENT CREATED")
                    spot.updateAverageRating {
                        completed(true)
                    }
                }
            }
        }
    }
    
    
    func deleteData(spot: Spot, completed: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("reviews").document(documentID).delete()
            {error in
                if let error = error {
                    print("****Error deleting review document ID")
                    completed(false)
                } else{
                    spot.updateAverageRating {
                        completed(true)
                    }
                }
                
        }
    }
}

