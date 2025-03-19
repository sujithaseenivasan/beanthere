//
//  AddReviewViewController.swift
//  beanthere
//
//  Created by Sujitha Seenivasan on 3/18/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

let db = Firestore.firestore()

class AddReviewViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var ratingButtons: [UIButton]!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var notesTextView: UITextView!
    
    var currentRating = 0
    var cafeId: String?
    
    var tags = ["Local Favorite", "Cozy", "Pet-friendly", "Great Study Spot", "Outdoor Seating", "WiFi", "Other"]
    

    var selectedTags: [String: UIColor] = [:]
    let colors: [UIColor] = [
        UIColor(named: "TagColor1") ?? .red,
        UIColor(named: "TagColor2") ?? .blue,
        UIColor(named: "TagColor3") ?? .green,
        UIColor(named: "TagColor4") ?? .orange,
        UIColor(named: "TagColor5") ?? .purple
    ]
  

    override func viewDidLoad() {
        super.viewDidLoad()
        tagCollectionView.delegate = self
        tagCollectionView.dataSource = self
        
        updateCollectionViewHeight()
        updateButtonImages()
        styleTextView()
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
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
                let tag = tags[indexPath.item]
                let isSelected = selectedTags[tag] != nil
                let color = selectedTags[tag] ?? .lightGray
                
                cell.configure(tag: tag, isSelected: isSelected, color: color)
                return cell
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
        let tag = tags[indexPath.item]
        let isSelected = selectedTags[tag] != nil
        
        let font = UIFont.systemFont(ofSize: 14)
        let textWidth = (isSelected ? tag : "+ " + tag).size(withAttributes: [.font: font]).width
        let padding: CGFloat = 30
        let totalWidth = textWidth + padding
        let height: CGFloat = 35
        return CGSize(width: totalWidth, height: height)
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
    
    

    
    @IBAction func submitReviewButtonPressed(_ sender: Any) {
        guard let userID = Auth.auth().currentUser?.uid else {
                print("User not logged in")
                return
            }

        let coffeeShopID = cafeId
    
        let reviewsCollection = db.collection("reviews")

        let reviewData: [String: Any] = [
            "coffeeShopID": coffeeShopID ?? "not_found",
            "comment": notesTextView.text ?? "",
            "rating": currentRating,
            "tags": Array(selectedTags.keys),
            "timestamp": Timestamp(date: Date()),
            "userID": userID
        ]

        reviewsCollection.addDocument(data: reviewData) { error in
            if let error = error {
                print("Error saving review: \(error.localizedDescription)")
            } else {
                print("Review successfully saved!")
                self.navigationController?.popViewController(animated: true)

            }
        }
    }
    
}
