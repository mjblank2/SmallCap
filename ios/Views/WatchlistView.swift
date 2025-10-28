import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var watchlistVM: WatchlistViewModel
    @EnvironmentObject var realTimeService: RealTimeService
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.edgesIgnoringSafeArea(.all)
                
                List {
                    Section(header: SectionHeaderView(title: "My Watchlist")) {
                        if watchlistVM.watchedTickers.isEmpty {
                            Text("Add stocks from the Daily Picks screen to monitor them here.")
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ForEach(Array(watchlistVM.watchedTickers).sorted(), id: \.self) { ticker in
                                WatchlistRowView(
                                    ticker: ticker,
                                    livePrice: realTimeService.livePrices[ticker]
                                )
                                .swipeActions {
                                    Button(role: .destructive) {
                                        Task { await watchlistVM.toggleWatchlist(ticker: ticker) }
                                    } label: {
                                        Label("Remove", systemImage: "star.slash.fill")
                                    }
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.backgroundCard)
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
                .navigationTitle("Watchlist")
            }
        }
    }
}

struct WatchlistRowView: View {
    let ticker: String
    let livePrice: Double?
    
    var body: some View {
        HStack {
            Text(ticker)
                .font(StyleGuide.Typography.headline)
                .foregroundColor(.textPrimary)
            Spacer()
            if let price = livePrice {
                Text(price, format: .currency(code: "USD"))
                    .font(StyleGuide.Typography.body)
                    .foregroundColor(.brandAccent)
            } else {
                ProgressView()
                    .frame(width: 20)
            }
        }
    }
}
