import SwiftUI


struct DetailView: View {
    let article: Article
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 16) {
                if let imageURL = article.image {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .edgesIgnoringSafeArea(.top)
                        default:
                            EmptyView()
                        }
                    }
                }

                VStack {
                    Text(article.authors.first?.name ?? "")
                        .bold()

                    Text(article.dateTimePub, style: .relative)

                }
                .padding(.bottom)
                .font(.caption)

                Text(article.body)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(5)
                Spacer()
            }
            .navigationTitle(article.title)
            .padding(20)
        }
    }
}
