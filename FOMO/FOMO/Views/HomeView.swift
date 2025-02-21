import SwiftUI

struct HomeView: View {
    let service = ArticleAPIService()
    @State private var articles: [Article] = []
    var body: some View {
        List(articles, id: \.id) { article in
            VStack(spacing: 8) {
                if let url = URL(string: article.image ?? "") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 150)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                )

                        default:
                            EmptyView()
                        }
                    }
                }

                Text(article.title)
                    .font(.system(.title3, design: .monospaced, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)

            }
            .frame(maxWidth: .infinity)
        }
        .task {
            await performSearchArticles("Elon musk")
        }
    }
}

private extension HomeView {
    func performSearchArticles(_ keyword: String = "") async {
        let articles = await self.service.fetchArticles(keyword)
        withAnimation(.bouncy) {
            self.articles = articles
        }
    }
}

#Preview {
    HomeView()
}
