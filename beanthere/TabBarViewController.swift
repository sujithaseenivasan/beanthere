import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set selected item font and color
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "JuliusSansOne-Regular", size: 10)!
        ]

        // Set unselected item font and color
        let unselectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "JuliusSansOne-Regular", size: 10)!
        ]

        // Apply to all tab bar items
        UITabBarItem.appearance().setTitleTextAttributes(unselectedAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}
