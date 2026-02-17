import UIKit

class DetailViewController: UIViewController {
    var anime: AnimeData? {
        didSet {
            // Si la vista está cargada, actualiza los datos.
            if isViewLoaded {
                configureView()
            }
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var synopsisLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        guard isViewLoaded else { return }
        guard let anime = anime else { return }
        titleLabel.text = anime.title
        synopsisLabel.text = anime.synopsis
        if let imageUrl = anime.images.jpg.large_image_url ?? anime.images.jpg.image_url {
            posterImageView.loadFrom(url: imageUrl)
        }
    }
}
