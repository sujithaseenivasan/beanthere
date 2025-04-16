//
//  CommentPopUpVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/13/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct Comment {
    var name: String
    var comment: String
}


class CommentPopUpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let db = Firestore.firestore()
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var writtenComment: UITextField!
    
    var commentCellIdentifier: String = "CommentCellID"
    var reviewID: String?
    var commentsArr: [Comment] = []
    var userName : String?
    @IBOutlet var outsideView: UIView!
    var delegate: UIViewController?
    override func viewDidLoad() {
        print ("ENTERED COMMENT POP UP")
        print ("ENTERED COMMENT POP UP REVIEW ID: \(reviewID!)")
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //self.innerView.backgroundColor = UIColor.clear
        self.innerView.layer.cornerRadius = 10
        self.commentTableView.layer.cornerRadius = 10
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.rowHeight = 75
        
        //create a tap action
        let vcTap = UITapGestureRecognizer(target: self, action: #selector(vcTapRecognizer))
        outsideView.isUserInteractionEnabled = true
        outsideView.addGestureRecognizer(vcTap)
        
    }
    
    //In will appear that is where we load every instance of coments of the reviews in the table
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let group = DispatchGroup()
        group.enter()
        db.collection("reviews").document(reviewID!).getDocument { (document, error) in
            // Document doesn't exist or there's an error
            guard let document = document, document.exists, let data = document.data() else {
                group.leave()
                return
            }
            
            if let commentsArray = data["friendsComment"] as? [String]{
                for userReview in commentsArray {
                    self.commentsArr.append( self.makeComment(userReview) )
                    self.commentTableView.reloadData()
                    
                }
            }
        }
        
    }
    
    @objc func vcTapRecognizer() {
        dismiss(animated: true, completion: nil)
    }
    
    
    // function that inputs a string does string interpolation on it and the ouputs a comment
    func makeComment(_ comment: String) -> Comment {
        // Split into lines
        let lines = comment.components(separatedBy: .newlines)
        // Assign parts
        let username = lines.first ?? ""
        print("ENTERED MAKE COMMENT FROM FIREBASE FIRST LINE IS: \(username)")
        let commentText = lines.dropFirst().joined(separator: "\n")
        print("ENTERED MAKE COMMENT FROM FIREBASE 2ND LINE IS: \(commentText)")
        //put it in a comment
        var commentObj =  Comment(name: username, comment: commentText)
        
        return commentObj
    }
    
    //if the comment is valid put the comment back to the database and also update the tableView
    @IBAction func sendButton(_ sender: Any) {
        if let commentText = writtenComment.text {
            let reviewRef = db.collection("reviews").document(self.reviewID!)
            
            reviewRef.getDocument { document, error in
                if let document = document, document.exists {
                    var currentComments = document.data()?["friendsComment"] as? [String] ?? []
                    
                    // Append the new comment [name, comment]
                    currentComments.append(" \(self.userName!) \n \(commentText)" )
                    
                    
                    // Write the updated array back to Firestore
                    reviewRef.updateData(["friendsComment": currentComments]) { err in
                        if let err = err {
                            print("Error updating comments array: \(err)")
                        } else {
                            print("Successfully updated friendsComment")
                        }
                    }
                } else {
                    print("Document not found or error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
            commentsArr.append(Comment(name: userName!, comment: commentText))
            commentTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userComment = commentsArr[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: commentCellIdentifier, for: indexPath) as! CommentCell
        if (commentsArr.count > 0){
            cell.commenterName.text = userComment.name
            cell.userComment.text = userComment.comment
        }
        return cell
    }

}

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var commenterName: UILabel!
    
    @IBOutlet weak var userComment: UILabel!
    
    
}
