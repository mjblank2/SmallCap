import SwiftUI

struct IdeaDetailView: View {
    let idea: StockIdea
    @EnvironmentObject private var watchlistVM: WatchlistViewModel
    // State for the confirmation overlay
    @State private var showWatchlistConfirmation = false

    var body: some View {
        ZStack {
            Color.backgroundMain.edgesIgnoringSafeArea(.all)
            
            List {
                // ... (Existing Sections using StyleGuide) ...
            }
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden) // Ensure background color shows through
            .navigationTitle(idea.ticker)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    watchlistButton()
                }
            }
            
            // Confirmation Overlay (Delight/Feedback)
            if showWatchlistConfirmation {
                SuccessOverlayView(message: watchlistVM.isWatching(idea.ticker) ? "Added to Watchlist" : "Removed")
                    // Smooth transition in and out
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            }
        }
    }
    
    @ViewBuilder
    private func watchlistButton() -> some View {
        Button(action: {
            Task {
                // Perform the action
                await watchlistVM.toggleWatchlist(ticker: idea.ticker)
                // Provide immediate positive feedback
                Haptics.notifySuccess()
                
                // Show the overlay and hide it after a delay
                showWatchlistConfirmation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showWatchlistConfirmation = false
                }
            }
        }) {
            Image(systemName: watchlistVM.isWatching(idea.ticker) ? "star.fill" : "star")
                .foregroundColor(.yellow)
                // Subtle "bounce" animation on tap
                .scaleEffect(showWatchlistConfirmation ? 1.2 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: showWatchlistConfirmation)
        }
    }
}

// NEW Helper View: SuccessOverlayView (HUD/Toast)
struct SuccessOverlayView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.brandPositive)
            Text(message)
                .font(StyleGuide.Typography.headline)
        }
        .padding(40)
        .background(Color.backgroundCard.opacity(0.95))
        .cornerRadius(20)
        .shadow(radius: 20)
    }
}
