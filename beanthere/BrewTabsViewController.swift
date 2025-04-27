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
    var friendID: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "UserSetting", bundle: nil)
        //load the VCs programatically
        beenVC = storyboard.instantiateViewController(withIdentifier: "BeenViewController") as? BrewLogViewController
        wantToTryVC = storyboard.instantiateViewController(withIdentifier: "WantToTryViewController") as? WantToTryViewController
        recsVC = storyboard.instantiateViewController(withIdentifier: "RecommendationViewController") as? RecommendationViewController
        
        //pass friend ID to each VC
        if let friendID = self.friendID {
            beenVC.friendID = friendID
            wantToTryVC.friendID = friendID
            
            //remove the "Recs" tab if viewing a friend's brewlog
            segmentedControl.removeSegment(at: 2, animated: false)
        }
        
        //customize segmented control
        segmentedControl.removeBorders()
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "TextPrimary")!,
            .font: UIFont(name: "Lora-SemiBold", size: 17)!
        ]
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "TextPrimary")!.withAlphaComponent(0.6),
            .font: UIFont(name: "Lora-SemiBold", size: 17)!
        ]
        segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)

        // Set default tab
        segmentedControl.selectedSegmentIndex = defaultTabIndex
        segmentChanged(segmentedControl)

        // Add underline for selected segment
        addUnderlineForSelectedSegment()

        
    }
    
    private var underlineTag: Int { return 999 }
    
    func addUnderlineForSelectedSegment() {
        // Remove existing underline if any
        segmentedControl.viewWithTag(underlineTag)?.removeFromSuperview()

        // Get title for selected segment
        guard let title = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) else { return }

        // Measure title size with selected font
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Lora-SemiBold", size: 17)! // Match your selected font
        ]
        let titleSize = (title as NSString).size(withAttributes: attributes)

        // Calculate position
        let segmentWidth = segmentedControl.bounds.width / CGFloat(segmentedControl.numberOfSegments)
        let segmentX = CGFloat(segmentedControl.selectedSegmentIndex) * segmentWidth
        let centerX = segmentX + (segmentWidth / 2)
        
        let underlineWidth = titleSize.width
        let underlineHeight: CGFloat = 2.0
        let underlineX = centerX - (underlineWidth / 2)
        let underlineY = segmentedControl.bounds.height - underlineHeight

        let underline = UIView(frame: CGRect(x: underlineX, y: underlineY, width: underlineWidth, height: underlineHeight))
        underline.backgroundColor = UIColor(named: "TextPrimary")
        underline.tag = underlineTag
        segmentedControl.addSubview(underline)
    }


    
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                switchToVC(beenVC)
            case 1:
                switchToVC(wantToTryVC)
            case 2:
            // Only switch to recsVC if it’s still in the control
            if segmentedControl.numberOfSegments > 2 {
                switchToVC(recsVC)
            }
            default:
                break
            }
        
        addUnderlineForSelectedSegment()
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

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
        setBackgroundImage(UIImage(), for: .highlighted, barMetrics: .default)
        setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
}
