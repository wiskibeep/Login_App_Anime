//
//  AnimeProvider.swift
//  Login_App_Anime
//
//  Created by Tardes on 6/2/26.
//

import Foundation

// Respuesta listado /v4/anime
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

// Respuesta detalle /v4/anime/{id}
struct AnimeDetailResponse: Codable {
    let data: AnimeData
}

enum AnimeProviderError: Error {
    case invalidBaseURL
    case invalidURL
    case httpError(Int)
    case decoding(Error)
    case network(Error)
}

final class AnimeProvider {
    static let shared = AnimeProvider()
    private init() {}
    
    private let session = URLSession.shared
    
    // MARK: - Public API
    
    // Listado con parámetros opcionales (paginación y filtros básicos)
    func fetchAnimes(
        page: Int? = nil,
        limit: Int? = nil,
        query: String? = nil,
        orderBy: String? = nil,
        sort: String? = nil
    ) async throws -> AnimeListResponse {
        let url = try makeListURL(
            page: page,
            limit: limit,
            query: query,
            orderBy: orderBy,
            sort: sort
        )
        return try await request(url, as: AnimeListResponse.self)
    }
    
    // Detalle por id
    func fetchAnime(id: Int) async throws -> AnimeData {
        let url = try makeDetailURL(id: id)
        let response: AnimeDetailResponse = try await request(url, as: AnimeDetailResponse.self)
        return response.data
    }
    
    // MARK: - URL Builders
    
    private func makeListURL(
        page: Int?,
        limit: Int?,
        query: String?,
        orderBy: String?,
        sort: String?
    ) throws -> URL {
        guard let baseURL = URL(string: Constants.SERVER_BASE_URL) else {
            throw AnimeProviderError.invalidBaseURL
        }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        var items: [URLQueryItem] = []
        if let page { items.append(URLQueryItem(name: "page", value: String(page))) }
        if let limit { items.append(URLQueryItem(name: "limit", value: String(limit))) }
        if let query, !query.isEmpty { items.append(URLQueryItem(name: "q", value: query)) }
        if let orderBy, !orderBy.isEmpty { items.append(URLQueryItem(name: "order_by", value: orderBy)) }
        if let sort, !sort.isEmpty { items.append(URLQueryItem(name: "sort", value: sort)) }
        if !items.isEmpty { components?.queryItems = items }
        guard let url = components?.url else { throw AnimeProviderError.invalidURL }
        return url
    }
    
    private func makeDetailURL(id: Int) throws -> URL {
        guard var baseURL = URL(string: Constants.SERVER_BASE_URL) else {
            throw AnimeProviderError.invalidBaseURL
        }
        baseURL.appendPathComponent(String(id))
        return baseURL
    }
    
    // MARK: - Networking
    
    private func request<T: Decodable>(_ url: URL, as type: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                throw AnimeProviderError.httpError(code)
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw AnimeProviderError.decoding(error)
            }
        } catch {
            throw AnimeProviderError.network(error)
        }
    }
}

