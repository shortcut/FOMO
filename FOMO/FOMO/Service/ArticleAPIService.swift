//
//  ArticleAPIService.swift
//  FOMO
//
//  Created by Vikram on 21/02/2025.
//

import Foundation

struct ArticleAPIService {
    func fetchArticles(_ keyword: String = "") async -> [Article]{
        let requestData = createRequestBody(withKeyword: keyword)
        var request = URLRequest(url: URL(string: "https://eventregistry.org/api/v1/article/")!)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) =  try await URLSession.shared.data(for: request)
            let result = try JSONDecoder().decode(ArticleResult.self, from: data)

            return result.articles.results
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

private extension ArticleAPIService {
    func createRequestBody(withKeyword keyword: String = "") -> Data {
        let requestBody: [String: Any] = [
            "apiKey":"d7ef0381-b903-42c3-b709-28941051b9fb",
            "action": "getArticles",
            "keyword": keyword,
            "sourceLocationUri": [
                "http://en.wikipedia.org/wiki/United_States",
                "http://en.wikipedia.org/wiki/Canada",
                "http://en.wikipedia.org/wiki/United_Kingdom"
            ],
            "ignoreSourceGroupUri": "paywall/paywalled_sources",
            "articlesPage": 1,
            "articlesCount": 10,
            "articlesSortBy": "date",
            "articlesSortByAsc": false,
            "dataType": [
                "news",
                "pr"
            ],
            "forceMaxDataTimeWindow": 31,
            "resultType": "articles"
        ]

        do {
            let data = try JSONSerialization.data(
                withJSONObject: requestBody,
                options: [])
            return data
        } catch {
            fatalError("Error encoding JSON: \(error)")
        }
    }
}

// MARK: - Welcome
struct ArticleResult: Codable {
    let articles: ArticlesMeta
}

// MARK: - Articles
struct ArticlesMeta: Codable {
    let results: [Article]
}

// MARK: - Result
struct Article: Codable, Hashable, Identifiable {
    let id = UUID()
    let uri: String
    let lang: String
    let isDuplicate: Bool
    let date, time: String
    let dateTime, dateTimePub: String
    let sim: Double
    let url: String
    let title, body: String
    let source: Source
    let authors: [Author]
    let image: String?
    let eventURI: String?
    let sentiment: Double?
    let wgt, relevance: Int

    enum CodingKeys: String, CodingKey {
        case uri, lang, isDuplicate, date, time, dateTime, dateTimePub, sim, url, title, body, source, authors, image
        case eventURI = "eventUri"
        case sentiment, wgt, relevance
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Source
struct Source: Codable {
    let uri: String
    let title: String
}

// MARK: - Author
struct Author: Codable {
    let uri, name: String
    let isAgency: Bool
}
