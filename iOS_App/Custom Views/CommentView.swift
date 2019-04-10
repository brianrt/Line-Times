//
//  CommentView.swift
//  Wait-Times
//
//  Created by Brian Thompson on 4/3/19.
//  Copyright © 2019 WaitTimes Inc. All rights reserved.
//

class CommentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0.1, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor(red: 0.94, green: 0.99, blue: 0.98, alpha: 1.0)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setComment(comment: String) {
        if (comment.isEmpty) {
            self.isHidden = true
        }
        let label = UILabel()
        label.frame = CGRect(x: 5, y: 5, width: self.frame.width - 10, height: self.frame.height-10)
        label.textAlignment = .center
        label.text = comment
        label.font = UIFont(name: "Demascus-Regular", size: 15)
        label.numberOfLines = 3
        self.addSubview(label)
    }
    
}
