//
//  BrewTabsViewController.swift
//  beanthere
//
//  Created by Sarah Neville on 4/7/25.
//

import UIKit

class BrewTabsViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var beenVC: BrewLogViewController!
    var wantToTryVC: WantToTryViewController!
    var recsVC: RecommendationViewController!
    
    var currentVC: UIViewController?
    var defaultTabIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "UserSetting", bundle: nil)
        //load the VCs programatically
        beenVC = storyboard.instantiateViewController(withIdentifier: "BeenViewController") as? BrewLogViewController
        print("ENTERED BREWTAB3 ")
        wantToTryVC = storyboard.instantiateViewController(withIdentifier: "WantToTryViewController") as? WantToTryViewController
        recsVC = storyboard.instantiateViewController(withIdentifier: "RecommendationViewController") as? RecommendationViewController

        
        segmentedControl.selectedSegmentIndex = defaultTabIndex
        segmentChanged(segmentedControl)
        
        
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                switchToVC(beenVC)
            case 1:
                switchToVC(wantToTryVC)
            case 2:
            switchToVC(recsVC)
            default:
                break
            }
    }
    
    func switchToVC(_ vc: UIViewController) {
        //remove current vc
        if let current = currentVC {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        //add the new vc
        addChild(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        //update the current
        currentVC = vc
    }

}
