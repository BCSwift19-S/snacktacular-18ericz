//
//  Reviews.swift
//  Snacktacular
//
//  Created by 18ericz on 4/15/19.
//  Copyright © 2019 Eric Zhou. All rights reserved.
//

import Foundation
import Firebase

class Reviews {
    var reviewArray: [Review] = []
    var db: Firestore!
    
    
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(spot: Spot, completed: @escaping () -> ()){
        guard spot.documentID != "" else {
            return 
        }
        db.collection("spots").document(spot.documentID).collection("reviews") .addSnapshotListener{ (querySnapshot, error) in
            guard error == nil else {
                print("**** THERE IS AN ERROR ADDING SNPSHOT")
                return completed()
            }
            self.reviewArray = []
            for document in querySnapshot!.documents {
                let review = Review(dictionary: document.data())
                review.documentID = document.documentID
                self.reviewArray.append(review)
            }
            completed()
        }
    }
}
