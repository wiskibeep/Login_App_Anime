//
//  DetailViewController.swift
//  Login_App_Anime
//
//  Created by Tardes on 13/2/26.
//

import UIKit

class DetailViewController: UIViewController {

 //   @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var animeLabel: UILabel!
    @IBOutlet weak var portadaView: UIImageView!
    @IBOutlet weak var episodioLabel: UILabel!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var sinopsisLabel: UILabel!

    var anime: AnimeData?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUI()
    }

    
    private func setupUI() {
       // cardView.layer.cornerRadius = 16
        //cardView.layer.masksToBounds = true
        portadaView.contentMode = .scaleAspectFill
        portadaView.clipsToBounds = true
    }

    private func configureUI() {
        guard let anime = anime else { return }

        animeLabel.text = anime.title

        let imageURL: String? =
            anime.images.jpg.large_image_url ??
            anime.images.jpg.image_url ??
            anime.images.jpg.small_image_url ??
            anime.images.webp.large_image_url ??
            anime.images.webp.image_url ??
            anime.images.webp.small_image_url

        if let urlString = imageURL {
            portadaView.loadFrom(url: urlString)
        } else {
            portadaView.image = nil
        }

        if let episodes = anime.episodes {
            episodioLabel.text = " \(episodes)"
        } else {
            episodioLabel.text = "¿?"
        }

        if let rank = anime.rank {
            rankingLabel.text = " \(rank)"
        } else {
            rankingLabel.text = "¿?"
        }

        if let popularity = anime.popularity {
            popularityLabel.text = " \(popularity)"
        } else {
            popularityLabel.text = "¿?"
        }

        if let synopsis = anime.synopsis, !synopsis.isEmpty {
            sinopsisLabel.text = synopsis
        } else {
            sinopsisLabel.text = "Sin sinopsis disponible"
        }
    }
}
