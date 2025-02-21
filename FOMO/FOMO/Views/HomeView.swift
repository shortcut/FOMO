import SwiftUI

struct HomeView: View {
    let service = ArticleAPIService()
    @State private var articles: [Article] = []
    var body: some View {
        List(articles, id: \.id) { article in
            Text(article.title)
        }
        .onAppear {
            Task {
                let articles = await self.service.fetchArticles()
                withAnimation(.bouncy) {
                    self.articles = articles
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
