//
//  ArticleAPIService.swift
//  FOMO
//
//  Created by Vikram on 21/02/2025.
//

import Foundation

struct ArticleAPIService {
    func fetchArticles(_ keyword: String = "", category: SegmentetThemes) async -> [Article]{
        let requestData = createRequestBody(withKeyword: keyword, category: category)
        var request = URLRequest(url: URL(string: "https://eventregistry.org/api/v1/article/")!)
        request.httpMethod = "POST"
        request.httpBody = requestData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let (data, _) =  try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(ArticleResult.self, from: data)

            print("***", result.articles.results.count)
            return result.articles.results
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

private extension ArticleAPIService {
    func createRequestBody(withKeyword keyword: String = "", category: SegmentetThemes) -> Data {
        let body = """
        {
        "apiKey": "d7ef0381-b903-42c3-b709-28941051b9fb",
        "action": "getArticles",
        "articlesPage": 1,
        "articlesCount": 100,
        "articlesSortBy": "date",
        "articlesSortByAsc": false,
        "dataType": [
        "news",
        "pr"
        ],
        "forceMaxDataTimeWindow": 31,
        "resultType": "articles",
        "query": {
        "$query": {
        "$and": [
        {
          "keyword": "\(keyword)"
        },
        {
          "categoryUri": "\(category.dmozValue)"
        }
        ]
        }
        }
        }
        """.data(using: .utf8)!

        return body
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
    var id: String {
        uri
    }

    let uri: String
    let lang: String
    let isDuplicate: Bool
    let date, time: String
    let dateTime, dateTimePub: Date
    let sim: Double
    let url: String
    let title, body: String
    let source: Source
    let authors: [Author]
    let image: String?
    let eventURI: String?
    let sentiment: Double?
    let wgt, relevance: Int

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
