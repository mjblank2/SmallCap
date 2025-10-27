import SwiftUI

struct PicksListView: View {
    @StateObject private var viewModel = PicksViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Set the main background color
                Color.backgroundMain.edgesIgnoringSafeArea(.all)
                
                Group {
                    switch viewModel.state {
                    case .loading:
                        ProgressView().tint(.brandAccent)
                    case .loaded:
                        if viewModel.ideas.isEmpty {
                             Text("No new ideas today.").foregroundColor(.gray)
                        } else {
                            // Use a ScrollView and LazyVStack for custom card layout
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.ideas) { idea in
                                        NavigationLink(destination: IdeaDetailView(idea: idea)) {
                                            IdeaCardView(idea: idea)
                                        }
                                        // Ensure the link doesn't override the card's colors
                                        .buttonStyle(PlainButtonStyle()) 
                                    }
                                }
                                .padding()
                            }
                            .refreshable {
                                await viewModel.loadPicks()
                            }
                        }
                    case .error(let message):
                        VStack {
                            Text(message).foregroundColor(.red).padding()
                            Button("Retry") { Task { await viewModel.loadPicks() } }
                        }
                    }
                }
            }
            .navigationTitle("Today's Picks")
            .task { await viewModel.loadPicks() }
        }
    }
}

// NEW: IdeaCardView replaces IdeaRowView
struct IdeaCardView: View {
    let idea: StockIdea

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header Row
            HStack {
                Text(idea.ticker)
                    .font(StyleGuide.Typography.cardTitle)
                    .foregroundColor(StyleGuide.ColorPalette.textPrimary)
                
                Spacer()
                
                // Risk Badge (Updated visualization)
                Text(idea.riskLevel.rawValue)
                    .font(StyleGuide.Typography.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(idea.riskLevel.displayColor.opacity(0.5))
                    .foregroundColor(StyleGuide.ColorPalette.textPrimary)
                    .clipShape(Capsule())
            }
            
            // Company Name
            Text(idea.companyName)
                .font(StyleGuide.Typography.body)
                .foregroundColor(StyleGuide.ColorPalette.textSecondary)
            
            Divider().background(Color.gray.opacity(0.5))

            // Key Metrics Row
            HStack {
                MetricPill(title: "Entry", value: String(format: "$%.2f", idea.entryPrice ?? 0))
                Spacer()
                MetricPill(title: "Target", value: String(format: "$%.2f", idea.targetPrice ?? 0), color: .brandAccent)
                Spacer()
                if let upside = idea.potentialUpside {
                    MetricPill(title: "Upside", value: String(format: "%.0f%%", upside * 100), color: .brandAccent)
                }
            }
        }
        .padding()
        // Apply the Card background and subtle shadow
        .background(Color.backgroundCard)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
    }
}

// NEW Helper View for Metrics
struct MetricPill: View {
    let title: String
    let value: String
    var color: Color = StyleGuide.ColorPalette.textPrimary
    
    var body: some View {
        VStack {
            Text(title).font(StyleGuide.Typography.caption).foregroundColor(StyleGuide.ColorPalette.textSecondary)
            Text(value).font(StyleGuide.Typography.headline).foregroundColor(color)
        }
    }
}
