import SwiftUI

struct EventsFeedView: View {
    @StateObject private var viewModel = EventsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundMain.edgesIgnoringSafeArea(.all)
                
                if viewModel.isLoading && viewModel.events.isEmpty {
                    ProgressView().tint(.brandAccent)
                } else {
                    List(viewModel.events) { event in
                        EventRowView(event: event)
                    }
                    // Configure the List appearance for the dark theme
                    .listStyle(PlainListStyle())
                    .background(Color.backgroundMain)
                    // Required for custom List backgrounds in modern iOS
                    .scrollContentBackground(.hidden) 
                    .refreshable {
                        await viewModel.loadEvents()
                    }
                }
            }
            .navigationTitle("Catalyst Feed")
            .task {
                if viewModel.events.isEmpty {
                    await viewModel.loadEvents()
                }
            }
        }
    }
}

struct EventRowView: View {
    let event: EventCatalyst
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icon representing the event type
            Image(systemName: event.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 25, height: 25)
                .foregroundColor(event.impactColor)
            
            VStack(alignment: .leading, spacing: 5) {
                // Ticker and Event Type
                HStack {
                    Text(event.ticker)
                        .font(StyleGuide.Typography.headline)
                        .foregroundColor(.brandAccent)
                    Text(event.eventType)
                        .font(StyleGuide.Typography.caption)
                        .foregroundColor(StyleGuide.ColorPalette.textSecondary)
                }
                
                // The main content/title
                Text(event.title)
                    .font(StyleGuide.Typography.body)
                    .foregroundColor(StyleGuide.ColorPalette.textPrimary)
                    .lineLimit(3)
                
                // Date (Formatted Relative to now)
                Text(event.date, style: .relative)
                    .font(StyleGuide.Typography.caption)
                    .foregroundColor(StyleGuide.ColorPalette.textSecondary)
            }
        }
        .padding(.vertical, 8)
        // Ensure the row background matches the main background
        .listRowBackground(Color.backgroundMain) 
    }
}
