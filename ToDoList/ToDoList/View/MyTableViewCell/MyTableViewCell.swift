//
//  MyTableViewCell.swift
//  ToDoList
//
//  Created by Wang Allen on 2021/10/2.
//

import UIKit

class MyTableViewCell: UITableViewCell {

    @IBOutlet var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
