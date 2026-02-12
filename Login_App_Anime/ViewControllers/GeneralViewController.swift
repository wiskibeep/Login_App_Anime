//
//  GeneralViewController.swift
//  Login_App_Anime
//
//  Created by Tardes on 9/2/26.
//

import UIKit

class GeneralViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    var animes: [AnimeData] = []

    // Estado de paginación
    private var currentPage: Int = 1
    private var isLoading: Bool = false
    private var hasNextPage: Bool = true
    private let pageSize: Int = 20 // puedes ajustar

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        // Si usas nib en vez de storyboard, descomenta y asegúrate del nombre correcto del XIB:
        // tableView.register(UINib(nibName: "AnimeCellView", bundle: nil), forCellReuseIdentifier: "AnimeCellView")

        // Carga inicial (página 1)
        loadPage(reset: true)
    }

    private func loadPage(reset: Bool = false) {
        guard !isLoading else { return }
        if reset {
            currentPage = 1
            hasNextPage = true
            animes.removeAll()
            tableView.reloadData()
        }
        guard hasNextPage else { return }

        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                let response = try await AnimeProvider.shared.fetchAnimes(
                    page: currentPage,
                    limit: pageSize,
                    query: nil,
                    orderBy: nil, // sin orden especial para máxima compatibilidad
                    sort: nil
                )
                let newItems = response.data
                let nextFlag = response.pagination?.has_next_page ?? false

                // Actualiza estado en el MainActor
                await MainActor.run {
                    self.animes.append(contentsOf: newItems)
                    self.tableView.reloadData()
                    self.hasNextPage = nextFlag
                    self.currentPage += 1
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
                print("Error cargando animes (page \(self.currentPage)): \(error)")
            }
        }
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

    // Dispara la carga cuando se vaya a mostrar una de las últimas celdas
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let threshold = animes.count - 5 // cuando queden 5 por mostrar, pedimos más
        if indexPath.row >= threshold {
            loadPage(reset: false)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Ejemplo: si quieres cargar detalle por id al tocar una fila
        // Task {
        //     do {
        //         let selected = animes[indexPath.row]
        //         let detailed = try await AnimeProvider.shared.fetchAnime(id: selected.mal_id)
        //         print("Detalle cargado: \(detailed.title)")
        //         // Aquí podrías navegar a un detalle con 'detailed'
        //     } catch {
        //         print("Error cargando detalle: \(error)")
        //     }
        // }
    }
}

/*
 Notas:
 - hasNextPage se alimenta de response.pagination?.has_next_page de Jikan v4.
 - Si quisieras mantener "más nuevos primero", puedes probar con orderBy: "start_date", sort: "desc".
   Si notas que limita los resultados o complica la paginación, déjalo en nil como aquí.
 - Si quieres pull-to-refresh, añade un UIRefreshControl y llama a loadPage(reset: true).
 */

