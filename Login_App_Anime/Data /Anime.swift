import Foundation

// Modelo principal para el objeto "data"
struct AnimeData: Codable {
    let mal_id: Int
    let url: String
    let images: AnimeImages
    let trailer: AnimeTrailer
    let approved: Bool
    let titles: [AnimeTitle]
    let title: String
    let title_english: String?
    let title_japanese: String?
    let title_synonyms: [String]
    let type: String?
    let source: String?
    let episodes: Int?
    let status: String?
    let airing: Bool?
    let aired: AnimeAired?
    let duration: String?
    let rating: String?
    let score: Double?
    let scored_by: Int?
    let rank: Int?
    let popularity: Int?
    let members: Int?
    let favorites: Int?
    let synopsis: String?
    let background: String?
    let season: String?
    let year: Int?
    let broadcast: AnimeBroadcast?
    let producers: [AnimeEntity]
    let licensors: [AnimeEntity]
    let studios: [AnimeEntity]
    let genres: [AnimeGenre]
    let explicit_genres: [AnimeGenre]
    let themes: [AnimeGenre]
    let demographics: [AnimeGenre]
    
}

// MARK: - Substructs

struct AnimeImages: Codable {
    let jpg: AnimeImageDetail
    let webp: AnimeImageDetail
}

struct AnimeImageDetail: Codable {
    let image_url: String?
    let small_image_url: String?
    let large_image_url: String?
}

struct AnimeTrailer: Codable {
    let youtube_id: String?
    let url: String?
    let embed_url: String?
    let images: AnimeTrailerImages?
}



struct AnimeTrailerImages: Codable {
    let image_url: String?
    let small_image_url: String?
    let medium_image_url: String?
    let large_image_url: String?
    let maximum_image_url: String?
}

struct AnimeTitle: Codable {
    let type: String
    let title: String
}

struct AnimeAired: Codable {
    let from: String?
    let to: String?
    let prop: AnimeAiredProp?
    let string: String?
}

struct AnimeAiredProp: Codable {
    let from: AnimeAiredDateDetail?
    let to: AnimeAiredDateDetail?
}

struct AnimeAiredDateDetail: Codable {
    let day: Int?
    let month: Int?
    let year: Int?
}

struct AnimeBroadcast: Codable {
    let day: String?
    let time: String?
    let timezone: String?
    let string: String?
}

struct AnimeEntity: Codable {
    let mal_id: Int
    let type: String
    let name: String
    let url: String
}

struct AnimeGenre: Codable {
    let mal_id: Int
    let type: String
    let name: String
    let url: String
}

// ---
// Los structs "Personaje" y sus anidados también pueden quedarse en este archivo, pues son independientes.
struct Personaje: Codable {
    let items: [Item]

    struct Item: Codable {
        let id: Int
        let name: String
        let ki: String
        let maxKi: String
        let race: String
        let gender: String
        let description: String
        let affiliation: String
        let image: String?
        let transformations: [Transformation]?     
        struct Transformation: Codable {
            let id: Int
            let name: String
            let ki: String
            let image: String?
        }
    }
}
