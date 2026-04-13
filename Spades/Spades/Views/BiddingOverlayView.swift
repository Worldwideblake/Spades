import SwiftUI

struct BiddingOverlayView: View {
    @Binding var selectedBid: Int
    let partnerBid: Int?
    let onSubmit: (Int) -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 20) {
                // Header
                Text("YOUR BID")
                    .font(AppTheme.headingFont)
                    .foregroundColor(AppTheme.primaryText)
                    .tracking(2)

                // Partner bid info
                if let partnerBid = partnerBid {
                    Text("Partner bid: \(partnerBid == 0 ? "Nil" : "\(partnerBid)")")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                }

                // Selected bid display
                VStack(spacing: 4) {
                    Text(selectedBid == 0 ? "NIL" : "\(selectedBid)")
                        .font(AppTheme.scoreFont)
                        .foregroundColor(selectedBid == 0 ? AppTheme.warningColor : AppTheme.accentColor)

                    if selectedBid == 0 {
                        Text("Risk: +100 or -100")
                            .font(AppTheme.tinyFont)
                            .foregroundColor(AppTheme.warningColor.opacity(0.7))
                    }
                }
                .frame(height: 55)

                // Bid grid
                bidGrid

                // Confirm button
                Button(action: { onSubmit(selectedBid) }) {
                    Text("CONFIRM BID")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.accentColor)
                        )
                }
                .padding(.horizontal, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.overlayCorner)
                    .fill(AppTheme.overlayBackground)
            )
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Bid Grid

    private var bidGrid: some View {
        VStack(spacing: 8) {
            // Nil button
            bidButton(value: 0, label: "Nil")

            // Number rows
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { num in
                    bidButton(value: num, label: "\(num)")
                }
            }
            HStack(spacing: 8) {
                ForEach(6...10, id: \.self) { num in
                    bidButton(value: num, label: "\(num)")
                }
            }
            HStack(spacing: 8) {
                ForEach(11...13, id: \.self) { num in
                    bidButton(value: num, label: "\(num)")
                }
            }
        }
    }

    private func bidButton(value: Int, label: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.2)) {
                selectedBid = value
            }
        }) {
            Text(label)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(
                    selectedBid == value
                        ? .white
                        : (value == 0 ? AppTheme.warningColor : AppTheme.primaryText)
                )
                .frame(width: value == 0 ? 120 : 48, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selectedBid == value
                              ? (value == 0 ? AppTheme.warningColor : AppTheme.accentColor)
                              : AppTheme.badgeBackground
                        )
                )
        }
    }
}
