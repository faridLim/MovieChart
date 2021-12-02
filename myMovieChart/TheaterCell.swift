//
//  TheaterCell.swift
//  myMovieChart
//
//  Created by 임재헌 on 2021/11/26.
//

import UIKit

class TheaterCell: UITableViewCell {
    @IBOutlet var name: UILabel!
    @IBOutlet var tel: UILabel!
    @IBOutlet var addr: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
