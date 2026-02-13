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
    // Lista filtrada para mostrar en la tabla
    private var filteredAnimes: [AnimeData] = []

    // Estado de paginación
    private var currentPage: Int = 1
    private var isLoading: Bool = false
    private var hasNextPage: Bool = true
    private let pageSize: Int = 20 // puedes ajustar

    // Búsqueda
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentSearchText: String = ""

    // Filtro por año exacto cuando NO hay búsqueda
    private let filterYear: Int = 2004

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        // Si usas nib en vez de storyboard, descomenta y asegúrate del nombre correcto del XIB:
        // tableView.register(UINib(nibName: "AnimeCellView", bundle: nil), forCellReuseIdentifier: "AnimeCellView")

        // Configurar búsqueda
        configureSearch()

        // Carga inicial (página 1)
        loadPage(reset: true)
    }

    private func configureSearch() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Buscar animes por título"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }

    // Búsqueda local: filtra por múltiples variantes de título
    private func applyFilterAndReload() {
        let text = currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            filteredAnimes = animes
            tableView.reloadData()
            return
        }

        let needle = text.lowercased()

        filteredAnimes = animes.filter { anime in
            var candidates: [String] = []
            // Título principal
            candidates.append(anime.title.lowercased())
            // Título en inglés
            if let en = anime.title_english, !en.isEmpty {
                candidates.append(en.lowercased())
            }
            // Título japonés
            if let jp = anime.title_japanese, !jp.isEmpty {
                candidates.append(jp.lowercased())
            }
            // Sinónimos
            if !anime.title_synonyms.isEmpty {
                candidates.append(contentsOf: anime.title_synonyms.map { $0.lowercased() })
            }
            // Otros títulos en el array 'titles'
            if !anime.titles.isEmpty {
                candidates.append(contentsOf: anime.titles.map { $0.title.lowercased() })
            }

            return candidates.contains(where: { $0.contains(needle) })
        }

        tableView.reloadData()
    }

    private func loadPage(reset: Bool = false) {
        guard !isLoading else { return }
        if reset {
            currentPage = 1
            hasNextPage = true
            animes.removeAll()
            filteredAnimes.removeAll()
            tableView.reloadData()
        }
        guard hasNextPage else { return }

        isLoading = true
        Task { [weak self] in
            guard let self else { return }
            do {
                // Si hay texto de búsqueda, usamos query en servidor y NO limitamos por año.
                // Si no hay texto, aplicamos el filtro por año y orden descendente por score.
                let isSearching = !currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                let response = try await AnimeProvider.shared.fetchAnimes(
                    page: currentPage,
                    limit: pageSize,
                    query: isSearching ? currentSearchText : nil,
                    orderBy: isSearching ? nil : "score", // relevancia por defecto al buscar; score si no hay búsqueda
                    sort: isSearching ? nil : "desc",     // descendente por score cuando no hay búsqueda
                    startDate: nil,
                    endDate: nil,
                    year: isSearching ? nil : filterYear  // solo año cuando no hay búsqueda
                )

                let newItems = response.data
                let nextFlag = response.pagination?.has_next_page ?? false

                // Actualiza estado en el MainActor
                await MainActor.run {
                    self.animes.append(contentsOf: newItems)
                    self.hasNextPage = nextFlag
                    self.currentPage += 1
                    self.isLoading = false
                    // Aplica filtro vigente y recarga (filtrado local por variantes de título)
                    self.applyFilterAndReload()
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
        return filteredAnimes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AnimeCellView", for: indexPath) as? AnimeCellView else {
            return UITableViewCell()
        }
        let anime = filteredAnimes[indexPath.row]
        cell.configure(with: anime)
        return cell
    }

    // MARK: - UITableViewDelegate

    // Dispara la carga cuando se vaya a mostrar una de las últimas celdas
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let threshold = filteredAnimes.count - 5 // cuando queden 5 por mostrar, pedimos más
        if indexPath.row >= threshold {
            loadPage(reset: false)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Ejemplo: si quieres cargar detalle por id al tocar una fila
        // Task {
        //     do {
        //         let selected = filteredAnimes[indexPath.row]
        //         let detailed = try await AnimeProvider.shared.fetchAnime(id: selected.mal_id)
        //         print("Detalle cargado: \(detailed.title)")
        //         // Aquí podrías navegar a un detalle con 'detailed'
        //     } catch {
        //         print("Error cargando detalle: \(error)")
        //     }
        // }
    }
}

// MARK: - Actualización de resultados de búsqueda
extension GeneralViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let newText = searchController.searchBar.text ?? ""
        // Si cambia el texto, reseteamos la paginación y pedimos desde página 1
        if newText != currentSearchText {
            currentSearchText = newText
            loadPage(reset: true)
        } else {
            // Si no cambió, solo aplicar filtro local
            applyFilterAndReload()
        }
    }
}
