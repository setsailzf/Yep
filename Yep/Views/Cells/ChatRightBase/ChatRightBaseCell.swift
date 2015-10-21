//
//  ChatRightBaseCell.swift
//  Yep
//
//  Created by NIX on 15/6/4.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit

let sendingAnimationName = "RotationOnStateAnimation"

class ChatRightBaseCell: ChatBaseCell {
    
    @IBOutlet weak var dotImageView: UIImageView!

    var inGroup = false {
        willSet {
            dotImageView.hidden = newValue ? true : false
        }
    }

    var messageSendState: MessageSendState = .NotSend {
        didSet {
            switch messageSendState {

            case MessageSendState.NotSend:
                dotImageView.image = UIImage(named: "icon_dot_sending")
                dotImageView.hidden = false

                showSendingAnimation()

            case MessageSendState.Successed:
                dotImageView.image = UIImage(named: "icon_dot_unread")
                dotImageView.hidden = false

                removeSendingAnimation()

            case MessageSendState.Read:
                dotImageView.hidden = true

                removeSendingAnimation()

            case MessageSendState.Failed:
                dotImageView.image = UIImage(named: "icon_dot_failed")
                dotImageView.hidden = false

                removeSendingAnimation()
            }
        }
    }

    var message: Message? {
        didSet {
            tryUpdateMessageState()
        }
    }


    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "tryUpdateMessageState", name: MessageNotification.MessageStateChanged, object: nil)
    }
    
    func tryUpdateMessageState() {

        guard !inGroup else {
            return
        }

        if let message = message {
            if !message.invalidated {
                if let messageSendState = MessageSendState(rawValue: message.sendState) {
                    self.messageSendState = messageSendState
                }
            }
        }
    }

    func showSendingAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = 2 * M_PI
        animation.duration = 1.0
        animation.repeatCount = MAXFLOAT
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.dotImageView.layer.addAnimation(animation, forKey: sendingAnimationName)
        }

    }

    func removeSendingAnimation() {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.dotImageView.layer.removeAnimationForKey(sendingAnimationName)
        }

    }
}
