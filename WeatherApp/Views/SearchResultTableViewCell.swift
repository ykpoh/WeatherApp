//
//  SearchResultTableViewCell.swift
//  WeatherApp
//
//  Created by YK Poh on 22/06/2022.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addressLabel: UILabel!
    
    let viewModel = SearchResultTVCViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewModel.address.bind { [weak self] address in
            guard let strongSelf = self else { return }
            strongSelf.addressLabel.text = address
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(viewModel: SearchResultTVCViewModel) {
        self.viewModel.address.value = viewModel.address.value
        self.viewModel.location.value = viewModel.location.value
    }
    
}
