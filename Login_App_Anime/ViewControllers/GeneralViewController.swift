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
            candidates.append(anime.title.lowercased())
            if let en = anime.title_english, !en.isEmpty { candidates.append(en.lowercased()) }
            if let jp = anime.title_japanese, !jp.isEmpty { candidates.append(jp.lowercased()) }
            if !anime.title_synonyms.isEmpty { candidates.append(contentsOf: anime.title_synonyms.map { $0.lowercased() }) }
            if !anime.titles.isEmpty { candidates.append(contentsOf: anime.titles.map { $0.title.lowercased() }) }
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
                    self.hasNextPage = nextFlag
                    self.currentPage += 1
                    self.isLoading = false
                    // Aplica filtro vigente y recarga
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
        currentSearchText = searchController.searchBar.text ?? ""
        applyFilterAndReload()
    }
}

/*
 //
 //  ViewController.swift
 //  FreetoGame
 //
 //  Created by Tardes on 20/1/26.
 //

 import UIKit

 //MARK: fucnion inicial de la lista
 class ListViewController: UIViewController, UITableViewDataSource , UISearchBarDelegate{

     // Enlace a la tabla de la interfaz (debe estar conectado en el storyboard)
     @IBOutlet weak var tableView: UITableView!

     
     
     
     // Almacena la lista de juegos que se mostrarán en la tabla (datos originales)
      var gamelist: [Game] = []

     // Lista filtrada según la búsqueda
      var filteredGames: [Game] = []

     // Controlador de búsqueda integrado en la barra de navegación
      let searchController = UISearchController(searchResultsController: nil)

     // Guardar texto de búsqueda actual
      var currentSearchText: String = ""

     
     
     
     
     
     // Método que se llama una vez que la vista ha sido cargada en memoria
     override func viewDidLoad() {
         super.viewDidLoad()

         // Configura el dataSource de la tabla para que sea este controlador
         tableView.dataSource = self

         // Configurar el UISearchController
         configureSearch()

         // Llama a la función que obtiene la lista de juegos de manera asíncrona
         Task {
             // Obtiene la lista de juegos desde el proveedor (API)
             let list = await GameProvider.getGameList()

             // Actualiza datos y recarga en el hilo principal
             DispatchQueue.main.async {
                 self.gamelist = list
                 self.applyFilterAndReload()
             }
         }
     }

     
     
     
     // MARK: - Configuración de búsqueda
      func configureSearch() {
         // Mostrar el search bar en la navigation bar
         navigationItem.searchController = searchController
         navigationItem.hidesSearchBarWhenScrolling = false

         // Configuraciones del search controller
         searchController.obscuresBackgroundDuringPresentation = false
         searchController.searchBar.placeholder = "Buscar juegos por título"
         searchController.searchResultsUpdater = self
         definesPresentationContext = true
     }

     
     
     // Aplica el filtro según el texto actual y recarga la tabla
     private func applyFilterAndReload() {
         let text = currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
         if text.isEmpty {
             filteredGames = gamelist
         } else {
             let lower = text.lowercased()
             filteredGames = gamelist.filter { $0.title.lowercased().contains(lower) }
         }
         tableView.reloadData()
     }

     // MARK: - Métodos de UITableViewDataSource

     
     
     
     
     
     /// Devuelve el número de filas a mostrar en la sección de la tabla.
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return filteredGames.count
     }

     /// Configura y proporciona la celda para una fila específica de la tabla.
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         // Obtiene una celda reutilizable del tipo correcto
         let cell = tableView.dequeueReusableCell(withIdentifier: "Game Cell", for: indexPath) as! GameViewCell
         // Obtiene el juego correspondiente a la fila
         let game = filteredGames[indexPath.row]
         // Configura la celda con la información del juego
         cell.configure(with: game)
         return cell
     }

     
     
     
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         let detailViewController = segue.destination as! DetailViewController
         let indexPath = tableView.indexPathForSelectedRow!
         
         
         
         let game = filteredGames[indexPath.row]
         detailViewController.game = game

         // deseleccionar fila
         tableView.deselectRow(at: indexPath, animated: true)
     }
 }






 // MARK: - Actualización de resultados de búsqueda
 extension ListViewController: UISearchResultsUpdating {
     func updateSearchResults(for searchController: UISearchController) {
         currentSearchText = searchController.searchBar.text ?? ""
         applyFilterAndReload()
     }
 }




 /*
 //
 func searchBar (_searchBar : UISearchBar, textDidChange searchText: String ){
     filtredGameList = originalGameList
     game.title.localizedLowercase.contains(searchText)
 }

 */

 */
