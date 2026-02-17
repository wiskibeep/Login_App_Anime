import UIKit

class GeneralViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    
    var animes: [AnimeData] = []
    private var filteredAnimes: [AnimeData] = []

    // Paginación, búsqueda, etc. (el resto de tus propiedades)
    private var currentPage: Int = 1
    private var isLoading: Bool = false
    private var hasNextPage: Bool = true
    private let pageSize: Int = 20
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentSearchText: String = ""
    private let filterYear: Int = 2004

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        configureSearch()
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
            if let en = anime.title_english, !en.isEmpty {
                candidates.append(en.lowercased())
            }
            if let jp = anime.title_japanese, !jp.isEmpty {
                candidates.append(jp.lowercased())
            }
            if !anime.title_synonyms.isEmpty {
                candidates.append(contentsOf: anime.title_synonyms.map { $0.lowercased() })
            }
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
                let isSearching = !currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

                let response = try await AnimeProvider.shared.fetchAnimes(
                    page: currentPage,
                    limit: pageSize,
                    query: isSearching ? currentSearchText : nil,
                    orderBy: isSearching ? nil : "score",
                    sort: isSearching ? nil : "desc",
                    startDate: nil,
                    endDate: nil,
                    year: isSearching ? nil : filterYear
                )

                let newItems = response.data
                let nextFlag = response.pagination?.has_next_page ?? false

                await MainActor.run {
                    self.animes.append(contentsOf: newItems)
                    self.hasNextPage = nextFlag
                    self.currentPage += 1
                    self.isLoading = false
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

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let threshold = filteredAnimes.count - 5
        if indexPath.row >= threshold {
            loadPage(reset: false)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let anime = filteredAnimes[indexPath.row]
        performSegue(withIdentifier: "ShowAnimeDetail", sender: anime)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAnimeDetail",
           let detailVC = segue.destination as? DetailViewController,
           let anime = sender as? AnimeData {
            detailVC.anime = anime
        }
    }
}

// MARK: - UISearchResultsUpdating
extension GeneralViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let newText = searchController.searchBar.text ?? ""
        if newText != currentSearchText {
            currentSearchText = newText
            loadPage(reset: true)
        } else {
            applyFilterAndReload()
        }
    }
}

