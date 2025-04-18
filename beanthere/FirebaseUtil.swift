//
//  FirebaseUtil.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 4/13/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class FirebaseUtil {
    static let db = Firestore.firestore()

    static func loadProfileImage(userId: String, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference().child("images/\(userId)_file.png")
        ref.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(nil)
                return
            }
            downloadImage(from: url, completion: completion)
        }
    }

    static func loadReviewImage(reviewId: String, completion: @escaping ([UIImage]?) -> Void) {
        let storageRef = Storage.storage().reference().child("review_images/\(reviewId)/")

        storageRef.listAll { (result, error) in
            if let error = error {
                print("Error listing images for review \(reviewId): \(error.localizedDescription)")
                completion(nil)
                return
            }

            let dispatchGroup = DispatchGroup()

            let sortedItems = result!.items.sorted(by: { $0.name < $1.name })
            var images: [UIImage?] = Array(repeating: nil, count: sortedItems.count)

            for (index, item) in sortedItems.enumerated() {
                dispatchGroup.enter()
                item.downloadURL { url, error in
                    if let url = url {
                        downloadImage(from: url) { image in
                            images[index] = image
                            dispatchGroup.leave()
                        }
                    } else {
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                let filtered = images.compactMap { $0 }
                completion(filtered.isEmpty ? nil : filtered)
            }

        }
    }

    static func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    static func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }
    }

    static func formatTimestamp(_ timestamp: Any?) -> String {
        if let ts = timestamp as? Timestamp {
            let date = ts.dateValue()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return ""
    }
}
