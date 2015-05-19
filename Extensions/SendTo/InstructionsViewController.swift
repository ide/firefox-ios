/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit

struct InstructionsViewControllerUX {
    static let TopPadding = CGFloat(20)
    static let TextFont = UIFont.systemFontOfSize(UIFont.labelFontSize())
    static let TextColor = UIColor(rgb: 0x555555)
    static let LinkColor = UIColor.blueColor()
}

protocol InstructionsViewControllerDelegate: class {
    func instructionsViewControllerDidClose(instructionsViewController: InstructionsViewController)
}

class InstructionsViewController: UIViewController {
    weak var delegate: InstructionsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge.None
        view.backgroundColor = UIColor.whiteColor()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Close", tableName: "SendTo", comment: "Close button in top navigation bar"), style: UIBarButtonItemStyle.Done, target: self, action: "close")

        let imageView = UIImageView()
        imageView.image = UIImage(named: "emptySync")
        view.addSubview(imageView)
        imageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(view).offset(InstructionsViewControllerUX.TopPadding)
            make.centerX.equalTo(view)
        }

        let label1 = UILabel()
        view.addSubview(label1)
        label1.text = NSLocalizedString("You currently don’t have any other devices currently connected to Firefox Sync.", tableName: "SendTo", comment: "")
        label1.numberOfLines = 0
        label1.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label1.font = InstructionsViewControllerUX.TextFont
        label1.textColor = InstructionsViewControllerUX.TextColor
        label1.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(250)
            make.top.equalTo(imageView.snp_bottom).offset(InstructionsViewControllerUX.TopPadding)
            make.centerX.equalTo(view)
        }

        let label2 = UILabel()
        view.addSubview(label2)
        label2.numberOfLines = 0
        label2.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label2.font = InstructionsViewControllerUX.TextFont
        label2.textColor = InstructionsViewControllerUX.TextColor
        label2.attributedText = highlightLink(NSLocalizedString("<Show me how> to connect my other Firefox-enabled devices.", tableName: "SendTo", comment: "The part between brackets is highlighted in styled text as if it is a link."), withColor: InstructionsViewControllerUX.LinkColor)
        label2.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(250)
            make.top.equalTo(label1.snp_bottom).offset(InstructionsViewControllerUX.TopPadding)
            make.centerX.equalTo(view)
        }

        label2.userInteractionEnabled = true
        label2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "showMeHow"))
    }

    func close() {
        delegate?.instructionsViewControllerDidClose(self)
    }

    func showMeHow() {
        println("Show me how") // TODO Not sure what to do or if to keep this
    }

    private func highlightLink(var s: NSString, withColor color: UIColor) -> NSAttributedString {
        let start = s.rangeOfString("<")
        s = s.stringByReplacingCharactersInRange(start, withString: "")
        let end = s.rangeOfString(">")
        s = s.stringByReplacingCharactersInRange(end, withString: "")
        let a = NSMutableAttributedString(string: s as String)
        let r = NSMakeRange(start.location, end.location-start.location)
        a.addAttribute(NSForegroundColorAttributeName, value: color, range: r)
        return a
    }
}
