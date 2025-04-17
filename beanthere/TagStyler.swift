import UIKit

struct TagStyler {
    static func configureTagLabels(_ labels: [UILabel], withTags tags: [String]) {
        let colors: [UIColor] = [
            UIColor(named: "TagColor1") ?? .red,
            UIColor(named: "TagColor2") ?? .blue,
            UIColor(named: "TagColor3") ?? .green,
            UIColor(named: "TagColor4") ?? .orange,
            UIColor(named: "TagColor5") ?? .purple
        ]

        let sortedTags = tags.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
        let limitedTags = Array(sortedTags.prefix(4))

        for label in labels {
            label.text = ""
            label.isHidden = true
            label.backgroundColor = .clear
            label.removeConstraints(label.constraints.filter { $0.firstAttribute == .width })
        }

        if limitedTags.isEmpty {
            if let first = labels.first {
                applyBaseStyle(to: first)
                first.text = "No tags yet"
                first.backgroundColor = .lightGray
                first.isHidden = false
                setFixedWidth(for: first, text: "No tags yet")
            }
            return
        }

        for (index, tag) in limitedTags.enumerated() {
            guard index < labels.count else { break }
            let label = labels[index]
            label.text = tag
            label.isHidden = false
            label.backgroundColor = colors[index % colors.count]
            applyBaseStyle(to: label)
            setFixedWidth(for: label, text: tag)
        }
    }

    private static func applyBaseStyle(to label: UILabel) {
        label.textColor = .white
        label.font = UIFont(name: "Lora-SemiBold", size: 10)
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.adjustsFontSizeToFitWidth = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        label.padding(left: 10, right: 10)
    }

    private static func setFixedWidth(for label: UILabel, text: String) {
        guard let font = label.font else { return }
        let padding: CGFloat = 20 // 10 left + 10 right
        let width = text.size(withAttributes: [.font: font]).width + padding
        let widthConstraint = label.widthAnchor.constraint(equalToConstant: ceil(width))
        widthConstraint.priority = .required
        widthConstraint.isActive = true
    }
}
