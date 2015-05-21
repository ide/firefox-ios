/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import UIKit
import SnapKit

private class TabContentViewUX {
    static let TitleMargin = CGFloat(6)
    static let CloseButtonInset = CGFloat(10)
}

/**
*  Used to display the content within a Tab cell that's shown in the TabTrayController
*/
class TabContentView: UIView {

    lazy var background: UIImageViewAligned = {
        let browserImageView = UIImageViewAligned()
        browserImageView.contentMode = UIViewContentMode.ScaleAspectFill
        browserImageView.clipsToBounds = true
        browserImageView.userInteractionEnabled = false
        browserImageView.alignLeft = true
        browserImageView.alignTop = true
        browserImageView.backgroundColor = UIColor.redColor()
        return browserImageView
    }()

    lazy var titleText: UILabel = {
        let titleText = UILabel()
        titleText.textColor = TabTrayControllerUX.TabTitleTextColor
        titleText.backgroundColor = UIColor.clearColor()
        titleText.textAlignment = NSTextAlignment.Left
        titleText.userInteractionEnabled = false
        titleText.numberOfLines = 1
        titleText.font = TabTrayControllerUX.TabTitleTextFont
        return titleText
    }()

    lazy var titleContainer: UIVisualEffectView = {
        let title = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.ExtraLight))
        title.layer.shadowColor = UIColor.blackColor().CGColor
        title.layer.shadowOpacity = 0.2
        title.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        title.layer.shadowRadius = 0
        title.clipsToBounds = true
        return title
    }()

    lazy var favicon: UIImageView = {
        let favicon = UIImageView()
        favicon.backgroundColor = UIColor.clearColor()
        favicon.layer.cornerRadius = 2.0
        favicon.layer.masksToBounds = true
        return favicon
    }()

    lazy var closeButton: UIButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "stop"), forState: UIControlState.Normal)
        closeButton.imageEdgeInsets = UIEdgeInsets(
            top: TabContentViewUX.CloseButtonInset,
            left: TabContentViewUX.CloseButtonInset,
            bottom: TabContentViewUX.CloseButtonInset,
            right: TabContentViewUX.CloseButtonInset)
        return closeButton
    }()

    private lazy var innerBorder: InnerStrokedView = {
        return InnerStrokedView()
    }()

    var expanded: Bool = false {
        didSet {
            self.titleText.alpha = self.expanded ? 0 : 1
            self.closeButton.alpha = self.expanded ? 0 : 1
            self.favicon.alpha = self.expanded ? 0 : 1
            self.innerBorder.alpha = self.expanded ? 0 : 1
            self.titleContainerHeight?.updateOffset(self.expanded ? 0 : TabTrayControllerUX.TextBoxHeight)
            self.setNeedsLayout()
        }
    }

    private var titleContainerHeight: Constraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.cornerRadius = TabTrayControllerUX.CornerRadius
        self.clipsToBounds = true
        self.opaque = true

        self.titleContainer.addSubview(self.closeButton)
        self.titleContainer.addSubview(self.titleText)
        self.titleContainer.addSubview(self.favicon)

        self.addSubview(self.background)
        self.addSubview(self.titleContainer)
        self.addSubview(self.innerBorder)

        self.setupConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        self.background.snp_makeConstraints { make in
            make.top.left.right.equalTo(self)
        }

        self.titleContainer.snp_makeConstraints { make in
            make.top.left.right.equalTo(self)
            self.titleContainerHeight = make.height.equalTo(TabTrayControllerUX.TextBoxHeight).constraint
        }

        self.favicon.snp_makeConstraints { make in
            make.centerY.equalTo(self.titleContainer)
            make.left.equalTo(self.titleContainer).offset(TabContentViewUX.TitleMargin)
            make.size.equalTo(TabTrayControllerUX.FaviconSize)
        }

        self.closeButton.snp_makeConstraints { make in
            make.centerY.equalTo(self.titleContainer)
            make.right.equalTo(self.titleContainer)
            make.size.equalTo(self.titleContainer.snp_height)
        }

        self.titleText.snp_makeConstraints { make in
            make.centerY.equalTo(self.titleContainer)
            make.left.equalTo(self.favicon.snp_right).offset(TabContentViewUX.TitleMargin)
            make.right.greaterThanOrEqualTo(self.closeButton.snp_left)
            make.height.equalTo(self.titleContainer)
        }

        self.innerBorder.snp_makeConstraints { make in
            make.top.left.right.bottom.equalTo(self)
        }
    }
}

// A transparent view with a rectangular border with rounded corners, stroked
// with a semi-transparent white border.
private class InnerStrokedView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let strokeWidth = CGFloat(1)
        let halfWidth = strokeWidth / 2

        let path = UIBezierPath(roundedRect: CGRect(x: halfWidth,
            y: halfWidth,
            width: rect.width - strokeWidth,
            height: rect.height - strokeWidth),
            cornerRadius: TabTrayControllerUX.CornerRadius)
        
        path.lineWidth = strokeWidth
        UIColor.whiteColor().colorWithAlphaComponent(0.2).setStroke()
        path.stroke()
    }
}