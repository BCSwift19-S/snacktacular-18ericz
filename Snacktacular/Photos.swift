//
//  Photos.swift
//  Snacktacular
//
//  Created by 18ericz on 4/15/19.
//  Copyright © 2019 Eric Zhou. All rights reserved.
//

import Foundation
import Firebase

class Photos {
    var photoArray: [Photo] = []
    var db: Firestore!
    
    
    
    init() {
        db = Firestore.firestore()
        
    }
    
    func loadData(spot: Spot, completed: @escaping () -> ()){
        
        guard spot.documentID != "" else {
            return
        }
        let storage = Storage.storage()
        db.collection("spots").document(spot.documentID).collection("photos") .addSnapshotListener{ (querySnapshot, error) in
            guard error == nil else {
                print("**** THERE IS AN ERROR ADDING SNPSHOT")
                return completed()
            }
            self.photoArray = []
            var loadAttempts = 0
            let storageRef = storage.reference().child(spot.documentID)
            for document in querySnapshot!.documents {
                let photo = Photo(dictionary: document.data())
                photo.documentUUID = document.documentID
                self.photoArray.append(photo)
                
                let photoRef = storageRef.child(photo.documentUUID)
                photoRef.getData(maxSize: 25*1025*1025) { data, error in
                    if let error = error {
                        print("ERROR")
                        loadAttempts+=1
                        if loadAttempts >= (querySnapshot! .count) {
                            return completed()
                        }
                    } else{
                        let image = UIImage(data: data!)
                        photo.image = image!
                        if loadAttempts >= (querySnapshot! .count) {
                            return completed()
                        }
                }
                }
            }
            completed()
        }
    }
}
