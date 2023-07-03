//
//  TableViewCell.swift
//  Adres Defteri
//
//  Created by Zehra Coşkun on 9.06.2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var favLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        personImage.layer.cornerRadius = personImage.frame.size.width / 4
        personName.textColor = UIColor(named: "mavi")
        locationName.textColor = UIColor(named: "yesilkoyu")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    
    }

}
