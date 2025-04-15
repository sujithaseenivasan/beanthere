//
//  AddReviewViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/18/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PhotosUI

let db = Firestore.firestore()

class AddReviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var ratingTextLabel: UILabel!
    
    @IBOutlet weak var tagsTextLabel: UILabel!
    
    @IBOutlet weak var notesTextLabel: UILabel!
    @IBOutlet weak var photosTextLabel: UILabel!
    
    @IBOutlet weak var uploadPhotoButton: UIButton!
    
    @IBOutlet weak var submitReviewButton: UIButton!
    
    @IBOutlet var ratingButtons: [UIButton]!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var cafeId: String?
    
    var currentRating = 0
    
    var tags = ["Local Favorite", "Cozy", "Pet-friendly", "Great Study Spot", "Outdoor Seating", "WiFi", "Other"]
    var selectedTags: [String: UIColor] = [:]
    let colors: [UIColor] = [
        UIColor(named: "TagColor1") ?? .red,
        UIColor(named: "TagColor2") ?? .blue,
        UIColor(named: "TagColor3") ?? .green,
        UIColor(named: "TagColor4") ?? .orange,
        UIColor(named: "TagColor5") ?? .purple
    ]
    
    var selectedImages: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        ratingTextLabel.font = UIFont(name: "Lora-Bold", size: 20)
        tagsTextLabel.font = UIFont(name: "Lora-Bold", size: 20)
        notesTextLabel.font = UIFont(name: "Lora-Bold", size: 20)
        photosTextLabel.font = UIFont(name: "Lora-Bold", size: 20)
        uploadPhotoButton.titleLabel?.font = UIFont(name: "Lora-SemiBold", size: 16)
        submitReviewButton.titleLabel?.font = UIFont(name: "Lora-Bold", size: 20)
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        
        updateCollectionViewHeight()
        updateButtonImages()
        styleTextView()
        stylePhotoCollectionView()
    }
    
    func stylePhotoCollectionView() {
        photoCollectionView.layer.cornerRadius = 10
        photoCollectionView.layer.masksToBounds = true
        photoCollectionView.layer.borderWidth = 1
        photoCollectionView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func styleTextView() {
        notesTextView.layer.cornerRadius = 10
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.lightGray.cgColor
        notesTextView.clipsToBounds = true
    }
    
    @IBAction func ratingButtonTapped(_ sender: UIButton) {
        if let index = ratingButtons.firstIndex(of: sender) {
            currentRating = index + 1
            updateButtonImages()
        }
    }
    
    func updateButtonImages() {
        for (index, button) in ratingButtons.enumerated() {
            let imageName = index < currentRating ? "filled_bean" : "unfilled_bean"
            button.setImage(UIImage(named: imageName), for: .normal)
        }
    }

    
    func updateCollectionViewHeight() {
        let totalItems = tags.count
        let numberOfRows = (totalItems / 3) + (totalItems % 3 == 0 ? 0 : 1)
        
        let itemHeight: CGFloat = 35
        let rowSpacing: CGFloat = 10
        let totalHeight = CGFloat(numberOfRows + 1) * (itemHeight + rowSpacing)
        var frame = tagCollectionView.frame
        frame.size.height = totalHeight
        tagCollectionView.frame = frame
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagCollectionView {
            return tags.count
        } else if collectionView == photoCollectionView {
            return selectedImages.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == tagCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
            let tag = tags[indexPath.item]
            let isSelected = selectedTags[tag] != nil
            let color = selectedTags[tag] ?? .lightGray
            cell.configure(tag: tag, isSelected: isSelected, color: color)
            return cell
        } else if collectionView == photoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
            cell.imageView.image = selectedImages[indexPath.item]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let tag = tags[indexPath.item]

            if tag == "Other" {
                showTagInput()
            } else {
                if selectedTags[tag] != nil {
                    selectedTags.removeValue(forKey: tag)
                } else {
                    let availableColor = colors[selectedTags.count % colors.count]
                    selectedTags[tag] = availableColor
                }
                
                reorderTags()
                collectionView.reloadData()
            }
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tagCollectionView {
            let tag = tags[indexPath.item]
            let isSelected = selectedTags[tag] != nil
            let font = UIFont.systemFont(ofSize: 14)
            let textWidth = (isSelected ? tag : "+ " + tag).size(withAttributes: [.font: font]).width
            let padding: CGFloat = 30
            return CGSize(width: textWidth + padding, height: 35)
        } else if collectionView == photoCollectionView {
            let width = (collectionView.frame.width - 10) / 3
            return CGSize(width: width, height: width)
        }
        return CGSize(width: 50, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == photoCollectionView {
            return 0
        }
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == photoCollectionView {
            return 0
        }
        return 10
    }


    
    func showTagInput() {
        let alert = UIAlertController(title: "Add Custom Tag", message: "Enter a tag", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Tag name"
        }
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            if let tagName = alert.textFields?.first?.text, !tagName.isEmpty {
                let availableColor = self.colors[self.selectedTags.count % self.colors.count]
                self.selectedTags[tagName] = availableColor

                if let otherIndex = self.tags.firstIndex(of: "Other") {
                    self.tags.insert(tagName, at: otherIndex)
                }

                self.reorderTags()
                self.tagCollectionView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }



    func reorderTags() {
        let selected = tags.filter { selectedTags[$0] != nil }
        let unselected = tags.filter { selectedTags[$0] == nil }
        tags = selected + unselected
    }
    
    
    @IBAction func uploadPictureButtonPressed(_ sender: Any) {
        var config = PHPickerConfiguration()
               config.selectionLimit = 5
               config.filter = .images
               
               let picker = PHPickerViewController(configuration: config)
               picker.delegate = self
               present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                    guard let self = self, let image = image as? UIImage else { return }
                    DispatchQueue.main.async {
                        self.selectedImages.append(image)
                        self.photoCollectionView.reloadData()
                    }
                }
            }
        }
    
    
    func uploadImagesToStorage(reviewID: String, completion: @escaping ([String]) -> Void) {
        guard !selectedImages.isEmpty else {
            completion([])
            return
        }
        
        let storageRef = Storage.storage().reference().child("review_images/\(reviewID)")
        var uploadedImageURLs: [String] = []
        
        let dispatchGroup = DispatchGroup()
        
        for (index, image) in selectedImages.enumerated() {
            dispatchGroup.enter()
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let imageRef = storageRef.child("\(index).jpg")
                
                imageRef.putData(imageData, metadata: nil) { _, error in
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    imageRef.downloadURL { url, error in
                        if let url = url {
                            uploadedImageURLs.append(url.absoluteString)
                        }
                        dispatchGroup.leave()
                    }
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(uploadedImageURLs)
        }
    }

    @IBAction func submitReviewButtonPressed(_ sender: Any) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let coffeeShopID = cafeId
        let reviewsCollection = db.collection("reviews")

        let newReviewRef = reviewsCollection.document()
        let reviewID = newReviewRef.documentID
        
        uploadImagesToStorage(reviewID: reviewID) { imageURLs in
            
            let reviewData: [String: Any] = [
                "coffeeShopID": coffeeShopID ?? "not_found",
                "comment": self.notesTextView.text ?? "",
                "rating": self.currentRating,
                "tags": Array(self.selectedTags.keys),
                "timestamp": Timestamp(date: Date()),
                "userID": userID,
                "imageURLs": imageURLs,
                "friendsComment": [],
                "friendsLikes": Int(),
                "friendsCommentsArr" : [[String]]()
            ]

            newReviewRef.setData(reviewData) { error in
                if let error = error {
                    print("Error saving review: \(error.localizedDescription)")
                } else {
                    print("Review successfully saved with images!")
                    let coffeeShopRef = db.collection("coffeeShops").document(coffeeShopID!)
                    let userRef = db.collection("users").document(userID)

                    let updateData: [String: Any] = ["reviews": FieldValue.arrayUnion([reviewID])]

                    coffeeShopRef.updateData(updateData) { error in
                        if let error = error {
                            print("Error updating coffee shop reviews: \(error.localizedDescription)")
                        } else {
                            print("Review ID added to coffee shop's reviews array")
                        }
                    }

                    userRef.updateData(updateData) { error in
                        if let error = error {
                            print("Error updating user reviews: \(error.localizedDescription)")
                        } else {
                            print("Review ID added to user's reviews array")
                        }
                    }
                    
                    //logic to check if coffee shop exists in "Want to Try" list, and if so remove it
                    userRef.getDocument(){ (document, error) in
                        if let document = document, document.exists {
                            var wantToTry = document.data()?["wantToTry"] as? [String] ?? []
                            //get coffeeshopID we are trying to add and check if its in our
                            //wantToTry list
                            if let shopID = coffeeShopID,
                               let index = wantToTry.firstIndex(of: shopID) {
                                wantToTry.remove(at: index)
                                
                                userRef.updateData(["wantToTry": wantToTry]) { error in
                                    if let error = error {
                                        print("Error removing shop from wantToTry: \(error.localizedDescription)")
                                    } else {
                                        print("Successfully removed shop from wantToTry list.")
                                    }
                                }
                            }
                        } else {
                            print("User document not found or error fetching it.")
                        }
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}
