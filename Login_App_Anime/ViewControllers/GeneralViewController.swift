//
//  GeneralViewController.swift
//  Login_App_Anime
//
//  Created by Tardes on 9/2/26.
//

import UIKit

class GeneralViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    // Ejemplo de datos (añade aquí tus datos reales o prueba con este ejemplo)
    var animes: [AnimeData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        // Si usas storyboard, asegúrate que el identificador de la celda es "AnimeCellView"
        // Si usas nib, registra aquí: tableView.register(UINib(nibName: "AnimeCellView", bundle: nil), forCellReuseIdentifier: "AnimeCellView")

        // Datos de prueba (puedes reemplazar esto por tu carga real desde red)
        animes = [AnimeData(
            mal_id: 1,
            url: "https://myanimelist.net/anime/1/",
            images: AnimeImages(
                jpg: AnimeImageDetail(
                    image_url: "https://cdn.myanimelist.net/images/anime/1723/154941.jpg",
                    small_image_url: "https://cdn.myanimelist.net/images/anime/1723/154941t.jpg",
                    large_image_url: "https://cdn.myanimelist.net/images/anime/1723/154941l.jpg"
                ),
                webp: AnimeImageDetail(
                    image_url: "https://cdn.myanimelist.net/images/anime/1723/154941.webp",
                    small_image_url: "https://cdn.myanimelist.net/images/anime/1723/154941t.webp",
                    large_image_url: "https://cdn.myanimelist.net/images/anime/1723/154941l.webp"
                )
            ),
            trailer: AnimeTrailer(youtube_id: nil, url: nil, embed_url: nil, images: nil),
            approved: true,
            titles: [],
            title: "Mushoku Tensei III: Isekai Ittara Honki Dasu",
            title_english: "Mushoku Tensei: Jobless Reincarnation Season 3",
            title_japanese: "無職転生 III ～異世界行ったら本気だす～",
            title_synonyms: [],
            type: "TV",
            source: "Light novel",
            episodes: nil,
            status: "Not yet aired",
            airing: false,
            aired: nil,
            duration: "Unknown",
            rating: "R - 17+ (violence & profanity)",
            score: nil,
            scored_by: nil,
            rank: nil,
            popularity: 1679,
            members: nil,
            favorites: nil,
            synopsis: "Third season of Mushoku Tensei: Isekai Ittara Honki Dasu.",
            background: "",
            season: "summer",
            year: 2026,
            broadcast: nil,
            producers: [],
            licensors: [],
            studios: [],
            genres: [],
            
            
            
            
            
            
            explicit_genres: [],
            themes: [],
            demographics: []
        )]
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeCellView", for: indexPath) as? AnimeCellView else {
            return UITableViewCell()
        }
        let anime = animes[indexPath.row]
        cell.configure(with: anime)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Puedes realizar una acción al seleccionar el anime, por ejemplo mostrar un detalle
    }
}
