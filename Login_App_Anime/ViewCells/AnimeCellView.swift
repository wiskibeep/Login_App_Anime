//
//  AnimeCellView.swift
//  Login_App_Anime
//
//  Created by Tardes on 9/2/26.
//

import UIKit

class AnimeCellView: UITableViewCell {

    @IBOutlet weak var AnimeLabel: UILabel!
    @IBOutlet weak var PortadaView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var EpisodioLabel: UILabel!
    @IBOutlet weak var rankinglabel: UILabel!
    @IBOutlet weak var popularyLabel: UILabel!
    @IBOutlet weak var SipnosisLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Estilos básicos
        cardView.layer.cornerRadius = 25
        cardView.layer.masksToBounds = true
        PortadaView.contentMode = .scaleAspectFill
        PortadaView.clipsToBounds = true
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        AnimeLabel.text = nil
        PortadaView.image = nil
        EpisodioLabel.text = nil
        rankinglabel.text = nil
        popularyLabel.text = nil
        SipnosisLabel.text = nil
    }

    func configure(with anime: AnimeData) {
        // Título
        AnimeLabel.text = anime.title

        // Imagen: intenta usar la grande, luego la normal, luego la pequeña (JPG/WEBP)
        let imageURL: String? =
            anime.images.jpg.large_image_url ??
            anime.images.jpg.image_url ??
            anime.images.jpg.small_image_url ??
            anime.images.webp.large_image_url ??
            anime.images.webp.image_url ??
            anime.images.webp.small_image_url

        if let urlString = imageURL {
            PortadaView.loadFrom(url: urlString)
        } else {
            PortadaView.image = nil
        }

        // Episodios (puede ser nulo)
        if let episodes = anime.episodes {
            EpisodioLabel.text = " \(episodes)"
        } else {
            EpisodioLabel.text = "¿?"
        }

        // Ranking (puede ser nulo)
        if let rank = anime.rank {
            rankinglabel.text = " \(rank)"
        } else {
            rankinglabel.text = "¿?"
        }

        // Popularidad
        if let popularity = anime.popularity {
            popularyLabel.text = " \(popularity)"
        } else {
            popularyLabel.text = "¿?"
        }

        // Sinopsis (puede ser nula o vacía, limitar a 160 caracteres)
        if let synopsis = anime.synopsis, !synopsis.isEmpty {
            let maxChars = 160
            if synopsis.count > maxChars {
                let idx = synopsis.index(synopsis.startIndex, offsetBy: maxChars)
                SipnosisLabel.text = synopsis[synopsis.startIndex..<idx] + "…"
            } else {
                SipnosisLabel.text = synopsis
            }
        } else {
            SipnosisLabel.text = "Sin sinopsis disponible"
        }
    }
}
