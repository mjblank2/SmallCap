import SwiftUI

struct PicksListView: View {
    @StateObject private var viewModel = PicksViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Analyzing Markets...")
                case .loaded:
                    if viewModel.ideas.isEmpty {
                        Text("No new ideas today. Check back tomorrow.").foregroundColor(.secondary).padding()
                    } else {
                        List(viewModel.ideas) { idea in
                            NavigationLink(destination: IdeaDetailView(idea: idea)) {
                                IdeaRowView(idea: idea)
                            }
                        }
                        // InsetGroupedListStyle provides a professional appearance
                        .listStyle(InsetGroupedListStyle())
                    }
                case .error(let message):
                    VStack(spacing: 20) {
                        Text(message).multilineTextAlignment(.center).padding()
                        Button("Retry") { Task { await viewModel.loadPicks() } }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("MicroCap Daily")
            .task {
                // Fetch data when the view appears
                await viewModel.loadPicks()
            }
            .refreshable {
                 await viewModel.loadPicks()
            }
        }
    }
}

struct IdeaRowView: View {
    let idea: StockIdea

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(idea.ticker)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(idea.companyName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                // Risk Badge
                Text(idea.riskLevel.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(idea.riskLevel.displayColor.opacity(0.2))
                    .foregroundColor(idea.riskLevel.displayColor)
                    .cornerRadius(5)
                
                Spacer()
                
                // Potential Upside Visualization
                if let upside = idea.potentialUpside {
                    Text(String(format: "Target Upside: +%.0f%%", upside * 100))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 5)
    }
}
