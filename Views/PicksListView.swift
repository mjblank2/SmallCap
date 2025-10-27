import SwiftUI

struct PicksListView: View {
    @StateObject private var viewModel = PicksViewModel()
    
    // Professional Color Palette (Define these in Assets.xcassets for dark mode support)
    let primaryColor = Color(red: 0/255, green: 51/255, blue: 102/255) // Navy Blue
    let accentColor = Color(red: 4/255, green: 167/255, blue: 119/255) // Emerald Green

    var body: some View {
        NavigationStack {
            Group {
                // Check the ViewModel's subscription status
                if viewModel.isSubscribed {
                    contentView()
                } else {
                    // Show the Paywall if not subscribed
                    PaywallView(primaryColor: primaryColor, accentColor: accentColor)
                }
            }
            .navigationTitle("MicroCap Daily")
            // Use systemGroupedBackground for a professional look supporting Dark Mode
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        }
        .accentColor(accentColor)
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Analyzing Markets...")
        case .loaded:
            if viewModel.ideas.isEmpty {
                 Text("No new ideas today. Check back tomorrow.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List(viewModel.ideas) { idea in
                    NavigationLink(destination: IdeaDetailView(idea: idea, primaryColor: primaryColor, accentColor: accentColor)) {
                        IdeaRowView(idea: idea, accentColor: accentColor)
                    }
                }
                // InsetGroupedListStyle provides a professional, card-like appearance
                .listStyle(InsetGroupedListStyle())
                .refreshable {
                    await viewModel.loadPicks()
                }
            }
        case .error(let message):
            VStack(spacing: 20) {
                Text(message).multilineTextAlignment(.center).padding()
                Button("Retry") {
                    Task { await viewModel.loadPicks() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct IdeaRowView: View {
    let idea: StockIdea
    let accentColor: Color

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
                        .foregroundColor(accentColor)
                }
            }
        }
        .padding(.vertical, 5)
    }
}
