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
    
    var commentCellIdentifier: String = "CommentCellID"
    var reviewID: String?
    var commentsArr: [Comment] = []
    var userName : String?
    var delegate: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //self.innerView.backgroundColor = UIColor.clear
        self.innerView.layer.cornerRadius = 10
        commentTableView.delegate = self
        commentTableView.dataSource = self
        commentTableView.rowHeight = 150
        
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
            
            if let commentsArray = data["friendsCommentsArr"] as? [[String]] {
                for userReview in commentsArray {
                    if userReview.count == 2 {
                        let name = userReview[0]
                        let comment = userReview[1]
                        self.commentsArr.append(Comment(name: name, comment: comment))
                    }
                }
            }
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
