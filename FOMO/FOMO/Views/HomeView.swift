import SwiftUI
import Combine

enum SegmentetThemes: String, CaseIterable {
    case politics = "Politics"
    case tech = "Tech"
    case business = "Business"
    case sports = "Sports"
    case health = "Health"

    var dmozValue: String {
        return switch self {
        case .politics: "news/Politics"
        case .tech: "news/Technology"
        case .business: "news/Business"
        case .sports: "news/Sports"
        case .health: "news/Health"
        }
    }
}


struct HomeView: View {
    let service = ArticleAPIService()
    @StateObject private var observer = SearchObserver()
    @State private var articles: [Article] = []
    @State var segmentetThemes: SegmentetThemes = .politics
    @State private var article: Article?

    var body: some View {
        NavigationStack {
            List(articles) { article in
                Button {
                    self.article = article
                } label: {
                    sumeST(article)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(style: .init(lineWidth: 0.5))
                                .foregroundStyle(.separator)
                        )
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .overlay {
                if articles.isEmpty {
                    ContentUnavailableView.search
                }
            }
            .buttonStyle(ListButtonStyle())
            .listStyle(.plain)
            .searchable(text: $observer.searchText, prompt: "Search news...")
            .searchScopes($segmentetThemes, activation: .onSearchPresentation) {
                ForEach(SegmentetThemes.allCases, id: \.self) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .task {
                guard articles.isEmpty else {
                    return
                }

                await performSearchArticles()
            }
            .navigationTitle("Articles")
            .onChange(of: segmentetThemes) { _ , _ in
                Task {
//                    observer.searchText = newValue.rawValue
                    await performSearchArticles(observer.debouncedText)
                }
            }
            .onChange(of: observer.debouncedText) { _ , newValue in
                Task {
                    await performSearchArticles(newValue)
                }
            }
            .navigationDestination(item: $article) {  
                DetailView(article: $0)
            }
        }
    }

    @ViewBuilder
    func sumeST(_ article: Article) -> some View {
        VStack(spacing: 8) {
            if let url = URL(string: article.image ?? "") {
                HStack {
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
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.blue.gradient.opacity(0.2))
                )
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

    }
}

private extension HomeView {
    @MainActor
    func performSearchArticles(_ keyword: String = "") async {
        let articles = await self.service.fetchArticles(keyword, category: segmentetThemes)
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


final class SearchObserver: ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""

    private var subscriptions = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] t in
                self?.debouncedText = t
            } )
            .store(in: &subscriptions)
    }
}
