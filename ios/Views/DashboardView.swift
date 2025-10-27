import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = PicksViewModel()
    @EnvironmentObject private var watchlistVM: WatchlistViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.edgesIgnoringSafeArea(.all)
                
                Group {
                    switch viewModel.state {
                    case .loading:
                        ProgressView().tint(.brandAccent)
                    case .loaded:
                        ScrollView {
                            VStack(alignment: .leading, spacing: 30) {
                                // 1. Summary Snapshot (Quick Value)
                                SummarySnapshotView(watchlistCount: watchlistVM.watchedTickers.count)
                                    .padding(.horizontal)

                                // 2. Today's Picks (Core Value Proposition)
                                todaysPicksSection()
                                
                                // 3. Catalyst Highlights (Engagement Placeholder)
                                // CatalystHighlightsView().padding(.horizontal)
                            }
                            .padding(.top)
                        }
                        .refreshable {
                            await refreshData()
                        }
                    case .error(let message):
                        Text("Error: \(message)").foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(getGreeting())
            .task { await refreshData(silent: true) }
        }
    }
    
    // Handles data refresh with haptic feedback
    private func refreshData(silent: Bool = false) async {
        if !silent { Haptics.impactLight() } 
        await viewModel.loadPicks()
        if !silent { Haptics.notifySuccess() }
    }
    
    @ViewBuilder
    private func todaysPicksSection() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Curated Picks")
                .font(StyleGuide.Typography.sectionTitle)
                .foregroundColor(.textPrimary)
                .padding(.horizontal)

            if viewModel.ideas.isEmpty {
                // Robust Empty State (Builds Trust)
                EmptyStateCard(
                    title: "Analysis Complete",
                    message: "Our team found no high-conviction opportunities today. Quality over quantity.",
                    icon: "checkmark.seal.fill"
                )
                .padding(.horizontal)
            } else {
                // Horizontal scroll view for engaging interaction
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.ideas) { idea in
                            NavigationLink(destination: IdeaDetailView(idea: idea)) {
                                IdeaCardView(idea: idea)
                                    .frame(width: UIScreen.main.bounds.width * 0.85)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // Helper for personalized greeting
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
}

// Helper Views (Implementations based on previous iterations adopting the new StyleGuide)

// Example: IdeaCardView (Refined)
struct IdeaCardView: View {
    let idea: StockIdea

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header Row
            HStack {
                Text(idea.ticker)
                    .font(StyleGuide.Typography.cardTitle)
                    .foregroundColor(.textPrimary)
                Spacer()
                // Risk Badge
                Text(idea.riskLevel.rawValue)
                    .font(StyleGuide.Typography.caption).fontWeight(.bold)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(idea.riskLevel.displayColor.opacity(0.7)) 
                    .foregroundColor(.textPrimary)
                    .clipShape(Capsule())
            }
            
            Text(idea.companyName).foregroundColor(.textSecondary)
            
            // NEW: Brief snippet of the thesis for immediate context
            Text(idea.thesis)
                .font(StyleGuide.Typography.body).foregroundColor(.textPrimary)
                .lineLimit(2).truncationMode(.tail)

            Divider().background(Color.gray.opacity(0.5))

            // Key Metrics Row (Using Semantic Green for targets)
            HStack {
                MetricPill(title: "Entry", value: String(format: "$%.2f", idea.entryPrice ?? 0))
                Spacer()
                MetricPill(title: "Target", value: String(format: "$%.2f", idea.targetPrice ?? 0), color: .brandPositive)
                Spacer()
                if let upside = idea.potentialUpside {
                    MetricPill(title: "Upside", value: String(format: "%.0f%%", upside * 100), color: .brandPositive)
                }
            }
        }
        .padding()
        .background(Color.backgroundCard)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// Example: EmptyStateCard
struct EmptyStateCard: View {
    let title: String
    let message: String
    let icon: String

    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.brandAccent)
            Text(title)
                .font(StyleGuide.Typography.headline)
                .foregroundColor(.textPrimary)
            Text(message)
                .font(StyleGuide.Typography.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.backgroundCard)
        .cornerRadius(15)
    }
}
