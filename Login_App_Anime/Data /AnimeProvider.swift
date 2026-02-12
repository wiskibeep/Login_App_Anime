//
//  AnimeProvider.swift
//  Login_App_Anime
//
//  Created by Tardes on 6/2/26.
//

import Foundation

// Contenedor de respuesta de Jikan v4 para /v4/anime (listado)
struct AnimeListResponse: Codable {
    let data: [AnimeData]
    let pagination: Pagination?
    
    struct Pagination: Codable {
        let last_visible_page: Int?
        let has_next_page: Bool?
        let current_page: Int?
        let items: Items?
        
        struct Items: Codable {
            let count: Int?
            let total: Int?
            let per_page: Int?
        }
    }
}

// Contenedor de respuesta de Jikan v4 para /v4/anime/{id} (detalle)
struct AnimeDetailResponse: Codable {
    let data: AnimeData
}

enum AnimeProviderError: Error {
    case invalidBaseURL
    case invalidURL
    case httpError(statusCode: Int)
    case decodingError(Error)
    case network(Error)
}

final class AnimeProvider {
    
    static let shared = AnimeProvider()
    private init() {}
    
    // Sesión configurable por si más adelante quieres inyectarla (tests, etc.)
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        return URLSession(configuration: config)
    }()
    
    // Método genérico para listar animes desde /v4/anime
    // Parámetros más comunes de Jikan v4:
    // - page, limit: paginación
    // - q: término de búsqueda
    // - order_by: e.g., "score", "popularity", "rank", "members", "favorites", "year"
    // - sort: "asc" o "desc"
    // - type, status, rating, etc. se pueden añadir cuando los necesites.
    func fetchAnimes(
        page: Int? = nil,
        limit: Int? = nil,
        query: String? = nil,
        orderBy: String? = nil,
        sort: String? = nil
    ) async throws -> AnimeListResponse {
        
        guard let baseURL = URL(string: Constants.SERVER_BASE_URL) else {
            throw AnimeProviderError.invalidBaseURL
        }
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        var queryItems: [URLQueryItem] = []
        
        if let page { queryItems.append(URLQueryItem(name: "page", value: String(page))) }
        if let limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let query, !query.isEmpty { queryItems.append(URLQueryItem(name: "q", value: query)) }
        if let orderBy, !orderBy.isEmpty { queryItems.append(URLQueryItem(name: "order_by", value: orderBy)) }
        if let sort, !sort.isEmpty { queryItems.append(URLQueryItem(name: "sort", value: sort)) }
        
        // Puedes añadir más filtros aquí si los necesitas: type, status, rating, sfw, genres, etc.
        
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        
        guard let url = components?.url else {
            throw AnimeProviderError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Jikan recomienda rate limiting; no requiere headers especiales para este endpoint.
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw AnimeProviderError.httpError(statusCode: -1)
            }
            guard 200..<300 ~= http.statusCode else {
                throw AnimeProviderError.httpError(statusCode: http.statusCode)
            }
            
            do {
                let decoded = try JSONDecoder().decode(AnimeListResponse.self, from: data)
                return decoded
            } catch {
                throw AnimeProviderError.decodingError(error)
            }
        } catch {
            throw AnimeProviderError.network(error)
        }
    }
    
    // Método para obtener el detalle de un anime por id: GET /v4/anime/{id}
    func fetchAnime(id: Int) async throws -> AnimeData {
        guard var baseURL = URL(string: Constants.SERVER_BASE_URL) else {
            throw AnimeProviderError.invalidBaseURL
        }
        // Construir /v4/anime/{id}
        baseURL.appendPathComponent(String(id))
        
        var request = URLRequest(url: baseURL)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw AnimeProviderError.httpError(statusCode: -1)
            }
            guard 200..<300 ~= http.statusCode else {
                throw AnimeProviderError.httpError(statusCode: http.statusCode)
            }
            do {
                let decoded = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)
                return decoded.data
            } catch {
                throw AnimeProviderError.decodingError(error)
            }
        } catch {
            throw AnimeProviderError.network(error)
        }
    }
}

