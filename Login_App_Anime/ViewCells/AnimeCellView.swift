//
//  AnimeCellView.swift
//  Login_App_Anime
//
//  Created by Tardes on 9/2/26.
//

import UIKit

class AnimeCellView: UITableViewCell {

    @IBOutlet weak var AnimeLabel: UILabel! //          "type": "Default",
    //"title": "Mushoku Tensei III: Isekai Ittara Honki Dasu"
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var rankinglabel: UILabel!
    @IBOutlet weak var popularyLabel: UILabel!
    @IBOutlet weak var SipnosisLabel: UILabel! //      "synopsis": "Third season of Mushoku Tensei: Isekai Ittara Honki Dasu.",

    override func awakeFromNib() {
        super.awakeFromNib()
        // Estilos básicos
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        genreLabel.text = nil
        shortDescriptionLabel.text = nil
        thumbnailImageView.image = nil
    }

    func configure(with anime: AnimeData) {
        // Título
        titleLabel.text = anime.title

        // Imagen: intenta usar la grande, luego la normal, luego la pequeña
        let imageURL: String? =
            anime.images.jpg.large_image_url ??
            anime.images.jpg.image_url ??
            anime.images.jpg.small_image_url ??
            anime.images.webp.large_image_url ??
            anime.images.webp.image_url ??
            anime.images.webp.small_image_url

        if let urlString = imageURL {
            thumbnailImageView.loadFrom(url: urlString)
        } else {
            thumbnailImageView.image = nil
        }

        // Géneros: concatenar nombres
        let genres = anime.genres.map { $0.name }.joined(separator: " • ")
        genreLabel.text = genres.isEmpty ? nil : genres

        // Descripción corta (sinopsis)
        if let synopsis = anime.synopsis, !synopsis.isEmpty {
            // Opcional: limitar a cierto número de caracteres
            let maxChars = 160
            if synopsis.count > maxChars {
                let idx = synopsis.index(synopsis.startIndex, offsetBy: maxChars)
                shortDescriptionLabel.text = synopsis[synopsis.startIndex..<idx] + "…"
            } else {
                shortDescriptionLabel.text = synopsis
            }
        } else {
            shortDescriptionLabel.text = nil
        }
    }
}


/*
 {
   "data": {
     "mal_id": 59193,
     "url": "https://myanimelist.net/anime/59193/Mushoku_Tensei_III__Isekai_Ittara_Honki_Dasu",
     "images": {
       "jpg": {
         "image_url": "https://cdn.myanimelist.net/images/anime/1723/154941.jpg",
         "small_image_url": "https://cdn.myanimelist.net/images/anime/1723/154941t.jpg",
         "large_image_url": "https://cdn.myanimelist.net/images/anime/1723/154941l.jpg"
       },
       "webp": {
         "image_url": "https://cdn.myanimelist.net/images/anime/1723/154941.webp",
         "small_image_url": "https://cdn.myanimelist.net/images/anime/1723/154941t.webp",
         "large_image_url": "https://cdn.myanimelist.net/images/anime/1723/154941l.webp"
       }
     },
     "trailer": {
       "youtube_id": null,
       "url": null,
       "embed_url": "https://www.youtube-nocookie.com/embed/SUZNsBQP4uI?enablejsapi=1&wmode=opaque&autoplay=1",
       "images": {
         "image_url": null,
         "small_image_url": null,
         "medium_image_url": null,
         "large_image_url": null,
         "maximum_image_url": null
       }
     },
     "approved": true,
     "titles": [
       {
         "type": "Default",
         "title": "Mushoku Tensei III: Isekai Ittara Honki Dasu"
       },
       {
         "type": "Japanese",
         "title": "無職転生 III ～異世界行ったら本気だす～"
       },
       {
         "type": "English",
         "title": "Mushoku Tensei: Jobless Reincarnation Season 3"
       }
     ],
     "title": "Mushoku Tensei III: Isekai Ittara Honki Dasu",
     "title_english": "Mushoku Tensei: Jobless Reincarnation Season 3",
     "title_japanese": "無職転生 III ～異世界行ったら本気だす～",
     "title_synonyms": [],
     "type": "TV",
     "source": "Light novel",
     "episodes": null,
     "status": "Not yet aired",
     "airing": false,
     "aired": {
       "from": "2026-07-01T00:00:00+00:00",
       "to": null,
       "prop": {
         "from": {
           "day": 1,
           "month": 7,
           "year": 2026
         },
         "to": {
           "day": null,
           "month": null,
           "year": null
         }
       },
       "string": "Jul 2026 to ?"
     },
     "duration": "Unknown",
     "rating": "R - 17+ (violence & profanity)",
     "score": null,
     "scored_by": null,
     "rank": null,
     "popularity": 1679,
     "members": 157587,
     "favorites": 1283,
     "synopsis": "Third season of Mushoku Tensei: Isekai Ittara Honki Dasu.",
     "background": "",
     "season": "summer",
     "year": 2026,
     "broadcast": {
       "day": null,
       "time": null,
       "timezone": null,
       "string": "Unknown"
     },
     "producers": [
       {
         "mal_id": 1143,
         "type": "anime",
         "name": "TOHO animation",
         "url": "https://myanimelist.net/anime/producer/1143/TOHO_animation"
       },
       {
         "mal_id": 1444,
         "type": "anime",
         "name": "Egg Firm",
         "url": "https://myanimelist.net/anime/producer/1444/Egg_Firm"
       }
     ],
     "licensors": [],
     "studios": [
       {
         "mal_id": 1993,
         "type": "anime",
         "name": "Studio Bind",
         "url": "https://myanimelist.net/anime/producer/1993/Studio_Bind"
       }
     ],
     "genres": [
       {
         "mal_id": 2,
         "type": "anime",
         "name": "Adventure",
         "url": "https://myanimelist.net/anime/genre/2/Adventure"
       },
       {
         "mal_id": 8,
         "type": "anime",
         "name": "Drama",
         "url": "https://myanimelist.net/anime/genre/8/Drama"
       },
       {
         "mal_id": 10,
         "type": "anime",
         "name": "Fantasy",
         "url": "https://myanimelist.net/anime/genre/10/Fantasy"
       },
       {
         "mal_id": 9,
         "type": "anime",
         "name": "Ecchi",
         "url": "https://myanimelist.net/anime/genre/9/Ecchi"
       }
     ],
     "explicit_genres": [],
     "themes": [
       {
         "mal_id": 62,
         "type": "anime",
         "name": "Isekai",
         "url": "https://myanimelist.net/anime/genre/62/Isekai"
       },
       {
         "mal_id": 72,
         "type": "anime",
         "name": "Reincarnation",
         "url": "https://myanimelist.net/anime/genre/72/Reincarnation"
       }
     ],
     "demographics": []
   }
 }
 */
