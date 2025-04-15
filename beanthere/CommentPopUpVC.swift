//
//  CommentPopUpVC.swift
//  beanthere
//
//  Created by Yrone Umutesi on 4/13/25.
//

import UIKit

class CommentPopUpVC: UIViewController {

   
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var commenterName: UILabel!
    
    @IBOutlet weak var comment: UILabel!
    
    var reviewID: String?
    
    var delegate: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
