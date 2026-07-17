//
//  UserCell.swift
//  ExamDemo
//
//  Created by Ankit on 16/07/26.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
