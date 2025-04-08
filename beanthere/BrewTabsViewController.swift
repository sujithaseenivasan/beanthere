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
    //TODO: need to make variable for recs when i make that screen
    var currentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "UserSetting", bundle: nil)
        //load the VCs programatically
        beenVC = storyboard.instantiateViewController(withIdentifier: "BeenViewController") as? BrewLogViewController
        print("ENTERED BREWTAB3 ")
        wantToTryVC = storyboard.instantiateViewController(withIdentifier: "WantToTryViewController") as? WantToTryViewController
        
        switchToVC(beenVC)
        
        
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                switchToVC(beenVC)
            case 1:
                switchToVC(wantToTryVC)
            case 2:
                print("Not created yet")
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
