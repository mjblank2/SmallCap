import SwiftUI

struct WatchlistView: View {
    @EnvironmentObject var watchlistVM: WatchlistViewModel
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("My Watchlist")) {
                    if watchlistVM.watchedTickers.isEmpty {
                        Text("Add stocks from the Daily Picks screen to monitor them here.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(Array(watchlistVM.watchedTickers).sorted(), id: \.self) { ticker in
                            HStack {
                                Text(ticker)
                                Spacer()
                                // In production: Display real-time quotes here
                                Button(action: {
                                     Task { await watchlistVM.toggleWatchlist(ticker: ticker) }
                                }) {
                                    Image(systemName: "star.fill").foregroundColor(.yellow)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Watchlist")
        }
    }
}
