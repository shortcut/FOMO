import SwiftUI

struct HomeView: View {
    let service = ArticleAPIService()
    @State private var articles: [Article] = []
    var body: some View {
        List(articles) { article in
            Button(action: {

            }, label: {
                VStack(spacing: 8) {
                    if let url = URL(string: article.image ?? "") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    )
                                    .overlay(alignment: .topTrailing) {
                                        Text("Breaking news")
                                            .font(.caption)
                                            .padding(4)
                                            .background(.red.gradient)
                                            .foregroundStyle(.white)
                                            .clipShape(Capsule())
                                            .rotationEffect(.degrees(27.5))
                                            .offset(x: 10, y: 10)
                                    }

                            default:
                                EmptyView()
                            }
                        }
                    }

                    Text(article.title)
                        .font(.system(.title3, design: .monospaced, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(article.body)
                        .lineLimit(3)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text(article.dateTimePub, style: .relative)
                            .animation(.smooth)

                        Text(article.source.title)

                        Spacer()
                        Button {

                        } label: {
                            Image(systemName: "bookmark")
                        }


                    }
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.tertiary)
                    .padding(.vertical)
                    .frame(maxWidth: .infinity, alignment: .leading)

                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(style: .init(lineWidth: 0.5))
                        .foregroundStyle(.separator)
                )
            })
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .buttonStyle(ListButtonStyle())
        .listStyle(.plain)
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

struct ListButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.bouncy, value: configuration.isPressed)
    }
}
