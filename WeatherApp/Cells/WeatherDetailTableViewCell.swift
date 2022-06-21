//
//  WeatherDetailTableViewCell.swift
//  WeatherApp
//
//  Created by YK Poh on 20/06/2022.
//

import UIKit

class WeatherDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    let viewModel = WeatherDetailTVCViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        viewModel.title.bind { [weak self] title in
            guard let strongSelf = self else { return }
            strongSelf.titleLabel.text = title
        }
        
        viewModel.value.bind { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.valueLabel.text = value
        }
    }
    
    func configure(viewModel: WeatherDetailTVCViewModel) {
        self.viewModel.title.value = viewModel.title.value
        self.viewModel.value.value = viewModel.value.value
    }
    
}
