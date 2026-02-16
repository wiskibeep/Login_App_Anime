//
//  DetailTableViewCell.swift
//  Login_App_Anime
//
//  Created by Tardes on 16/2/26.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet weak var animeLabelDetail: UILabel!
    @IBOutlet weak var portadaViewDetail: UIImageView!
    @IBOutlet weak var cardViewDetail: UIView!
    @IBOutlet weak var episodioLabelDetail: UILabel!
    @IBOutlet weak var rankingLabelDetail: UILabel!
    @IBOutlet weak var popularityLabelDetail: UILabel!
    @IBOutlet weak var sinopsisLabelDetail: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        cardViewDetail.layer.cornerRadius = 16
        cardViewDetail.layer.masksToBounds = true
        portadaViewDetail.contentMode = .scaleAspectFill
        portadaViewDetail.clipsToBounds = true
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        animeLabelDetail.text = nil
        portadaViewDetail.image = nil
        episodioLabelDetail.text = nil
        rankingLabelDetail.text = nil
        popularityLabelDetail.text = nil
        sinopsisLabelDetail.text = nil
    }

    func configure(with anime: AnimeData) {
        animeLabelDetail.text = anime.title

        let imageURL: String? =
            anime.images.jpg.large_image_url ??
            anime.images.jpg.image_url ??
            anime.images.jpg.small_image_url ??
            anime.images.webp.large_image_url ??
            anime.images.webp.image_url ??
            anime.images.webp.small_image_url

        if let urlString = imageURL {
            portadaViewDetail.loadFrom(url: urlString)
        } else {
            portadaViewDetail.image = nil
        }

        if let episodes = anime.episodes {
            episodioLabelDetail.text = " \(episodes)"
        } else {
            episodioLabelDetail.text = "¿?"
        }

        if let rank = anime.rank {
            rankingLabelDetail.text = " \(rank)"
        } else {
            rankingLabelDetail.text = "¿?"
        }

        if let popularity = anime.popularity {
            popularityLabelDetail.text = " \(popularity)"
        } else {
            popularityLabelDetail.text = "¿?"
        }

        if let synopsis = anime.synopsis, !synopsis.isEmpty {
            sinopsisLabelDetail.text = synopsis
        } else {
            sinopsisLabelDetail.text = "Sin sinopsis disponible"
        }
    }
}
